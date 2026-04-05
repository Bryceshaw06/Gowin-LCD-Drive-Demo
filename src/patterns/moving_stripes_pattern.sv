//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// moving_stripes_pattern.sv
// Generates continuous moving red and blue stripes
//===========================================================

import lcd_pkg::*;

module moving_stripes_pattern (
    input  logic clk,
    input  logic reset_n,
    input  logic [15:0] x,
    input  logic frame_tick,
    output rgb_pixel_t pixel
);

    logic [9:0] offset;

    // Offset increments once per frame
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            offset <= 0;
        else if (frame_tick)
            offset <= offset + 1'b1;
    end

    wire [15:0] x_shifted = x + offset;

    // 32 pixel wide stripes using bit slicing
    wire stripe = x_shifted[5];
    
    assign pixel = stripe ? COLOR_RED : COLOR_BLUE;

endmodule