//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// lcd_shared.sv
// Global SystemVerilog package containing hardware constants and color structs
//===========================================================

package lcd_pkg;
    // -------------------------------------------------------
    // Native 24-bit RGB (R=8, G=8, B=8)
    // -------------------------------------------------------
    typedef struct packed {
        logic [7:0] r;
        logic [7:0] g;
        logic [7:0] b;
    } rgb_pixel_t;

    // Primary & Secondary Colors
    localparam rgb_pixel_t COLOR_BLACK     = '{r: 8'h00, g: 8'h00, b: 8'h00};
    localparam rgb_pixel_t COLOR_WHITE     = '{r: 8'hFF, g: 8'hFF, b: 8'hFF};
    localparam rgb_pixel_t COLOR_RED       = '{r: 8'hFF, g: 8'h00, b: 8'h00};
    localparam rgb_pixel_t COLOR_GREEN     = '{r: 8'h00, g: 8'hFF, b: 8'h00};
    localparam rgb_pixel_t COLOR_BLUE      = '{r: 8'h00, g: 8'h00, b: 8'hFF};
    localparam rgb_pixel_t COLOR_YELLOW    = '{r: 8'hFF, g: 8'hFF, b: 8'h00};
    localparam rgb_pixel_t COLOR_CYAN      = '{r: 8'h00, g: 8'hFF, b: 8'hFF};
    localparam rgb_pixel_t COLOR_PURPLE    = '{r: 8'hFF, g: 8'h00, b: 8'hFF};
    
    // Grayscale
    localparam rgb_pixel_t COLOR_LIGHT_GRAY= '{r: 8'h80, g: 8'h80, b: 8'h80};
    localparam rgb_pixel_t COLOR_DARK_GRAY = '{r: 8'h20, g: 8'h20, b: 8'h20};

    // =======================================================
    // SYSTEM CONSTANTS
    // =======================================================
    // Change this when adding or removing patterns!
    localparam int NUM_PATTERNS = 6; 

    // -------------------------------------------------------
    // Video Timing Structures and Presets
    // -------------------------------------------------------
    typedef struct packed {
        int h_visible;
        int h_front_porch;
        int h_sync_width;
        int h_back_porch;
        int v_visible;
        int v_front_porch;
        int v_sync_width;
        int v_back_porch;
    } video_timing_t;

    // Preset for 5" 800x480 Panel
    localparam video_timing_t TIMING_800x480 = '{
        h_visible: 800, h_front_porch: 210, h_sync_width: 1, h_back_porch: 182,
        v_visible: 480, v_front_porch: 45,  v_sync_width: 5, v_back_porch: 0
    };

    // Preset for 3.5" 640x480 Panel 
    localparam video_timing_t TIMING_640x480 = '{
        h_visible: 640, h_front_porch: 16, h_sync_width: 96, h_back_porch: 48,
        v_visible: 480, v_front_porch: 10, v_sync_width: 2,  v_back_porch: 33
    };
    endpackage

    // -------------------------------------------------------
    // Video Bus Interface
    // -------------------------------------------------------
    interface video_if;
    import lcd_pkg::*;

    logic [15:0] x;
    logic [15:0] y;
    rgb_pixel_t  pixel;
    logic        frame_tick;

    // A pattern generator takes in X/Y and outputs R/G/B
    modport source (input x, y, frame_tick, output pixel); 

    // A display driver takes in X/Y and R/G/B
    modport sink (input x, y, pixel, frame_tick);
    endinterface