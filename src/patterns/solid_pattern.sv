//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// solid_pattern.sv
// Solid color pattern module
//===========================================================

import lcd_pkg::*;

module solid_pattern (
    output rgb_pixel_t pixel
);

    // Uses purple color defined in lcd_shared.sv
    assign pixel = COLOR_PURPLE;

endmodule