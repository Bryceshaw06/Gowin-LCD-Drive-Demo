//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// border_pattern.sv
// Generates a 2-pixel wide solid white border around the screen boundary
//===========================================================

import lcd_pkg::*;

module border_pattern #(
    parameter int H_VISIBLE,
    parameter int V_VISIBLE
)(
    input  logic [15:0] x,
    input  logic [15:0] y,
    output rgb_pixel_t pixel
);
    wire border = (x < 2) | (x >= H_VISIBLE - 2) | 
                  (y < 2) | (y >= V_VISIBLE - 2);
    
    assign pixel = border ? COLOR_WHITE : COLOR_DARK_GRAY;
endmodule