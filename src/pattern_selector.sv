//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// pattern_selector.sv
// Selects between demonstration patterns
//===========================================================

import lcd_pkg::*;

module pattern_selector #(
    parameter int H_VISIBLE,
    parameter int V_VISIBLE 
)(
    input  logic clk,                  
    input  logic reset_n,              
    input  logic [$clog2(NUM_PATTERNS)-1:0] sel,
    video_if.source vid_out
);

    // Pixel outputs from patterns
    rgb_pixel_t p_xor, p_solid, p_border, p_bounce, p_cycle, p_stripes;

    xor_pattern xor_inst (
        .x(vid_out.x), .y(vid_out.y), 
        .pixel(p_xor)
    );

    solid_pattern solid_inst (
        .pixel(p_solid)
    );
    
    border_pattern #(
        .H_VISIBLE(H_VISIBLE), .V_VISIBLE(V_VISIBLE)
    ) border_inst (
        .x(vid_out.x), .y(vid_out.y), 
        .pixel(p_border)
    );
    
    bounce_pattern #(
        .H_VISIBLE(H_VISIBLE), .V_VISIBLE(V_VISIBLE)
    ) bounce_inst (
        .clk(clk), .reset_n(reset_n), 
        .x(vid_out.x), .y(vid_out.y), .frame_tick(vid_out.frame_tick), 
        .pixel(p_bounce)
    );

    color_cycle_pattern color_cycle_inst (
        .clk(clk), .reset_n(reset_n), .active(sel == 4), .frame_tick(vid_out.frame_tick), 
        .pixel(p_cycle)
    );

    moving_stripes_pattern stripes_inst (
        .clk(clk), .reset_n(reset_n), 
        .x(vid_out.x), .frame_tick(vid_out.frame_tick),
        .pixel(p_stripes)
    );

    always_comb begin
        vid_out.pixel = COLOR_BLACK;

        case (sel)
            0: begin vid_out.pixel = p_xor;     end
            1: begin vid_out.pixel = p_solid;   end
            2: begin vid_out.pixel = p_border;  end
            3: begin vid_out.pixel = p_bounce;  end 
            4: begin vid_out.pixel = p_cycle;   end 
            5: begin vid_out.pixel = p_stripes; end
            default: begin vid_out.pixel = p_xor; end
        endcase
    end

endmodule