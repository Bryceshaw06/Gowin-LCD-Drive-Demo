 //===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// top.sv
// Top level HDL
// Adjust module parameters to swap target displays for a custom board
//===========================================================

import lcd_pkg::*;

module top #(
    
    // =======================================================
    // HARDWARE CONFIGURATION
    // =======================================================
    
    // SET MASTER CLOCK (Updates bounce counters and SPI delays)
    parameter int CLOCK_FREQ_HZ = 27_000_000,
    
    // SET PHYSICAL PORT BIT-WIDTH (RGB565 for Tang 9k)
    parameter int RGB_WIDTH_R = 5,
    parameter int RGB_WIDTH_G = 6,
    parameter int RGB_WIDTH_B = 5,
    
    // SET ACTIVE RESOLUTION TIMING 
    // (5" Display = TIMING_800x480, 3.5" Display = TIMING_640x480)
    parameter video_timing_t ACTIVE_TIMING = TIMING_800x480,
    
    // SET BACKLIGHT PWM FREQUENCY
    // (Tang 9k LP3320 Boost = 10000 Hz, AP3019A Boost = up to 2000 Hz)
    parameter int BACKLIGHT_PWM_FREQ = 10000

)(
    input  logic reset_n,         // Active-low reset
    input  logic sys_clk_in,      // Global input clock (27MHz for Tang 9k)
    input  logic button_mode,     // Active-low user button

    output logic lcd_clk,         // Pixel clock to LCD
    output logic lcd_hsync,       // Horizontal sync
    output logic lcd_vsync,       // Vertical sync
    output logic lcd_den,         // Data enable
    output logic [RGB_WIDTH_R-1:0] lcd_red,   // Red Video Data
    output logic [RGB_WIDTH_G-1:0] lcd_green, // Green Video Data
    output logic [RGB_WIDTH_B-1:0] lcd_blue,  // Blue Video Data
    output logic lcd_bl,          // Backlight PWM control
    
    // SPI initialization pins
    output logic spi_res,
    output logic spi_cs,
    output logic spi_clk,
    output logic spi_di
);

    // -------------------------------------------------------
    // PIXEL CLOCK GENERATION
    // Note: If using a custom system clock or swapping timings 
    // the Gowin_rPLL IP block must be regenerated to output 
    // the correct pixel clock for the display!
    // -------------------------------------------------------
    logic sys_clk;

    Gowin_rPLL pll_inst (
        .clkin(sys_clk_in),
        .clkout(sys_clk),
        .clkoutd(lcd_clk)
    );

    // -----------------------
    // Reset Synchronizer
    // -----------------------
    logic meta_rst_n, sync_reset_n;
    
    always_ff @(posedge lcd_clk or negedge reset_n) begin
        if (!reset_n)
            {sync_reset_n, meta_rst_n} <= '0;
        else
            {sync_reset_n, meta_rst_n} <= {meta_rst_n, 1'b1};
    end

    // -----------------------
    // Video Bus Interface
    // -----------------------
    video_if main_vid();

    // -----------------------
    video_timings #(
        .H_VISIBLE(ACTIVE_TIMING.h_visible), 
        .H_FRONT_PORCH(ACTIVE_TIMING.h_front_porch),
        .H_SYNC_WIDTH(ACTIVE_TIMING.h_sync_width), 
        .H_BACK_PORCH(ACTIVE_TIMING.h_back_porch),
        .V_VISIBLE(ACTIVE_TIMING.v_visible), 
        .V_FRONT_PORCH(ACTIVE_TIMING.v_front_porch),
        .V_SYNC_WIDTH(ACTIVE_TIMING.v_sync_width), 
        .V_BACK_PORCH(ACTIVE_TIMING.v_back_porch)
    ) vt (
        .pixel_clk(lcd_clk),
        .reset_n(sync_reset_n),
        .lcd_hsync(lcd_hsync),
        .lcd_vsync(lcd_vsync),
        .lcd_den(lcd_den),
        .lcd_x(main_vid.x),
        .lcd_y(main_vid.y)
    );

    // -----------------------
    // Debounced button toggle
    // -----------------------
    logic [$clog2(NUM_PATTERNS)-1:0] pattern_index;

    button_toggle #(
        .STATES(NUM_PATTERNS),
        .DEBOUNCE_CYCLES(CLOCK_FREQ_HZ / 100) // Scales to ~10ms delays
    ) btn_inst (
        .clk(lcd_clk),
        .reset_n(sync_reset_n),
        .btn_raw(button_mode),
        .toggle_out(pattern_index)
    );

    // -----------------------
    // Pattern selector 
    // -----------------------
    pattern_selector #(
        .H_VISIBLE(ACTIVE_TIMING.h_visible),
        .V_VISIBLE(ACTIVE_TIMING.v_visible)
    ) pattern_inst (
        .clk(lcd_clk),           
        .reset_n(sync_reset_n),    
        .sel(pattern_index),
        .vid_out(main_vid)
    );

    // -----------------------
    // SPI Display Boot Initializer
    // -----------------------
    spi_lcd_init #(
        .CLK_FREQ(CLOCK_FREQ_HZ)
    ) spi_init_inst (
        .clk(sys_clk_in),
        .reset_n(reset_n), // SPI uses sys_clk domain natively so pass async raw
        
        .spi_res(spi_res),
        .spi_cs(spi_cs),
        .spi_clk(spi_clk),
        .spi_di(spi_di)
    );

    // -----------------------
    // Backlight PWM Control 
    // Note: Tang 9k leaves R24 NC on the breakout board. A jumper must be 
    // placed across the pads to enable the backlight brightness control. 
    // -----------------------
    pwm_backlight #(
        .WIDTH(8),
        .CLK_FREQ(CLOCK_FREQ_HZ),
        .PWM_FREQ(BACKLIGHT_PWM_FREQ)
    ) u_backlight_pwm (
        .clk     (sys_clk_in),   // Using system clock
        .rst_n   (reset_n),      // Global async reset
        .duty    (8'd64),        // 25% brightness
        .pwm_out (lcd_bl)
    );

    // -----------------------
    // Centralized Frame Tick
    // -----------------------
    assign main_vid.frame_tick = (main_vid.x == 0) && (main_vid.y == 0);

    // -----------------------
    // Physical Pin Assignments
    // We render everything in 24-bit color internally. 
    // This part just slices off the bottom bits to fit whatever 
    // hardware display width (e.g. RGB565) we parameterized above.
    // -----------------------
    assign lcd_red   = main_vid.pixel.r[7 -: RGB_WIDTH_R];
    assign lcd_green = main_vid.pixel.g[7 -: RGB_WIDTH_G];
    assign lcd_blue  = main_vid.pixel.b[7 -: RGB_WIDTH_B];

endmodule