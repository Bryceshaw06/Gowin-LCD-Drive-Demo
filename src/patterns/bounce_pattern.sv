//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// bounce_pattern.sv
// Generates a "DVD logo" square that bounces off screen edges
//===========================================================

import lcd_pkg::*;

module bounce_pattern #(
    parameter int H_VISIBLE,
    parameter int V_VISIBLE
)(
    input  logic clk,
    input  logic reset_n,
    input  logic [15:0] x,
    input  logic [15:0] y,
    input  logic frame_tick,
    output rgb_pixel_t pixel
);

    localparam int BOX_SIZE = 50;

    // Registers for position and direction
    logic [15:0] box_x, box_y;
    logic dir_x, dir_y; // 0 = moving right/down, 1 = moving left/up

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            box_x <= 16'd100;
            box_y <= 16'd100;
            dir_x <= 1'b0;
            dir_y <= 1'b0;
        end else if (frame_tick) begin
            // X-axis bounce logic
            if (dir_x == 1'b0) begin // Moving right
                if (box_x + BOX_SIZE >= H_VISIBLE - 1) dir_x <= 1'b1;
                else box_x <= box_x + 1'b1;
            end else begin           // Moving left
                if (box_x == 0) dir_x <= 1'b0;
                else box_x <= box_x - 1'b1;
            end

            // Y-axis bounce logic
            if (dir_y == 1'b0) begin // Moving down
                if (box_y + BOX_SIZE >= V_VISIBLE - 1) dir_y <= 1'b1;
                else box_y <= box_y + 1'b1;
            end else begin           // Moving up
                if (box_y == 0) dir_y <= 1'b0;
                else box_y <= box_y - 1'b1;
            end
        end
    end

    // Draw the box: check if current pixel is inside the box bounds
    wire in_box = (x >= box_x) && (x < box_x + BOX_SIZE) &&
                  (y >= box_y) && (y < box_y + BOX_SIZE);

    assign pixel = in_box ? COLOR_CYAN : COLOR_DARK_GRAY;

endmodule