//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// video_timings.sv
// Generates HSYNC, VSYNC, DEN, and pixel coordinates based on preset values
//===========================================================

module video_timings #(
    // Horizontal timing parameters (pixels)
    parameter int H_VISIBLE,       // Visible pixels per line
    parameter int H_FRONT_PORCH,   // Pixels after visible area before sync
    parameter int H_SYNC_WIDTH,    // Horizontal sync pulse width
    parameter int H_BACK_PORCH,    // Pixels after sync before next line

    // Vertical timing parameters (lines)
    parameter int V_VISIBLE,       // Visible lines per frame
    parameter int V_FRONT_PORCH,   // Lines after visible area before sync
    parameter int V_SYNC_WIDTH,    // Vertical sync pulse width
    parameter int V_BACK_PORCH     // Lines after sync before next frame
)(
    input  logic pixel_clk,        // Pixel clock
    input  logic reset_n,          // Active-low reset
    output logic lcd_hsync,        // Horizontal sync pulse (active low)
    output logic lcd_vsync,        // Vertical sync pulse (active low)
    output logic lcd_den,          // Data enable (high when pixels valid)
    output logic [15:0] lcd_x,     // Current pixel X coordinate
    output logic [15:0] lcd_y      // Current pixel Y coordinate
);

    // Total horizontal and vertical counts including porches and sync
    localparam int H_TOTAL = H_VISIBLE + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH;
    localparam int V_TOTAL = V_VISIBLE + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH;

    // Counters for current pixel
    logic [15:0] h_cnt;
    logic [15:0] v_cnt;

    always_ff @(posedge pixel_clk or negedge reset_n) begin
        if (!reset_n) begin
            {h_cnt, v_cnt} <= '0;
        end else begin
            h_cnt <= (h_cnt == H_TOTAL - 1) ? 16'd0 : h_cnt + 1'b1;
            
            if (h_cnt == H_TOTAL - 1) begin
                v_cnt <= (v_cnt == V_TOTAL - 1) ? 16'd0 : v_cnt + 1'b1;
            end
        end
    end

    // Calculate sync pulse boundaries
    localparam int H_SYNC_START = H_VISIBLE + H_FRONT_PORCH;
    localparam int H_SYNC_END   = H_SYNC_START + H_SYNC_WIDTH;
    localparam int V_SYNC_START = V_VISIBLE + V_FRONT_PORCH;
    localparam int V_SYNC_END   = V_SYNC_START + V_SYNC_WIDTH;

    // Generate HSYNC and VSYNC pulses (active low)
    assign lcd_hsync = ~((h_cnt >= H_SYNC_START) && (h_cnt < H_SYNC_END));
    assign lcd_vsync = ~((v_cnt >= V_SYNC_START) && (v_cnt < V_SYNC_END));

    // Data enable: high only during visible pixels
    assign lcd_den   = (h_cnt < H_VISIBLE) && (v_cnt < V_VISIBLE);

    // Pixel coordinates
    assign lcd_x = h_cnt;
    assign lcd_y = v_cnt;

endmodule