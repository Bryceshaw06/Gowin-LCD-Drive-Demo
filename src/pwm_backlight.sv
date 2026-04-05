//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// pwm_backlight.sv
// Simple counter-based PWM with prescaler for backlight control
//===========================================================

module pwm_backlight #(
    parameter int WIDTH = 8,          // Duty cycle resolution (8 = 0-255)
    parameter int CLK_FREQ = 27000000,// Source clock frequency
    parameter int PWM_FREQ = 10000    // Target PWM frequency in Hz
) (
    input  logic             clk,      // System clock
    input  logic             rst_n,    // Active-low reset
    input  logic [WIDTH-1:0] duty,     // Duty level (0 to 2^WIDTH-1)
    output logic             pwm_out   // PWM output to LCD
);

    // -----------------------
    // Prescaler Math
    // -----------------------
    localparam int TOTAL_STEPS = 1 << WIDTH;
    localparam int CLKS_PER_STEP = CLK_FREQ / (PWM_FREQ * TOTAL_STEPS);
    localparam int PRE_WIDTH = (CLKS_PER_STEP > 1) ? $clog2(CLKS_PER_STEP) : 1;
    
    // -----------------------
    // Internal Registers
    // -----------------------
    logic [PRE_WIDTH-1:0] prescaler;
    logic [WIDTH-1:0] counter;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prescaler <= '0;
            counter   <= '0;
            pwm_out   <= 1'b0;
        end else begin
            if (CLKS_PER_STEP <= 1 || prescaler >= (CLKS_PER_STEP - 1)) begin
                prescaler <= '0;
                counter <= counter + 1'b1;
            end else begin
                prescaler <= prescaler + 1'b1;
            end
            
            // PWM output: high when counter < duty
            pwm_out <= (counter < duty);
        end
    end

endmodule
