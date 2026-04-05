//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// xor_pattern.sv
// XOR pattern module using X/Y logical bitwise XOR logic
//===========================================================

import lcd_pkg::*;

module xor_pattern (
    input  logic [15:0] x,
    input  logic [15:0] y,
    output rgb_pixel_t pixel
);

    always_comb begin
        pixel = '{
            r: (x[5] ^ y[5]) ? 8'hFF : 8'h00,
            g: (x[6] ^ y[6]) ? 8'hFF : 8'h00,
            b: (x[7] ^ y[7]) ? 8'hFF : 8'h00
        };
    end

endmodule