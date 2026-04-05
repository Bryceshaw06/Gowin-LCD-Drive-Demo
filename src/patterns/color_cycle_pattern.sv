//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// color_cycle_pattern.sv
// Cycles through primary colors - red, green, blue, white, black
//===========================================================

import lcd_pkg::*;

module color_cycle_pattern (
    input  logic clk,
    input  logic reset_n,
    input  logic active,
    input  logic frame_tick,
    output rgb_pixel_t pixel
);

    logic [5:0] frame_wait; // Counter to slow down the cycle (60 frames ~= 1s)
    logic [2:0] color_state;



    logic active_prev;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            frame_wait  <= 6'd0;
            color_state <= 3'd0;
            active_prev <= 1'b0;
        end else begin
            active_prev <= active;

            // Reset timers whenever the user switches to this pattern!
            if (active && !active_prev) begin
                frame_wait  <= 6'd0;
                color_state <= 3'd0;
            end else if (active && frame_tick) begin
                frame_wait <= frame_wait + 1'b1;
                
                // Change color every 60th frame
                if (frame_wait == 6'd59) begin
                    frame_wait <= 6'd0;
                    if (color_state == 3'd4) color_state <= 3'd0;
                    else color_state <= color_state + 1'b1;
                end
            end
        end
    end

    // Combinational logic to map the current state to a full-screen color
    always_comb begin
        case (color_state)
            3'd0: begin pixel = COLOR_RED;   end
            3'd1: begin pixel = COLOR_GREEN; end
            3'd2: begin pixel = COLOR_BLUE;  end
            3'd3: begin pixel = COLOR_WHITE; end
            3'd4: begin pixel = COLOR_BLACK; end
            default: begin pixel = COLOR_BLACK; end
        endcase
    end

endmodule