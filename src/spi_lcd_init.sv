//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// spi_lcd_init.sv
// Generic 9-bit SPI LCD initialization controller
// Contains the NV3052 mapped initialization matrix
// For use with 3.5" 640x480 54-pin RGB888 display
// Sequence from: https://www.buydisplay.com/8051/ER-TFT035-7_Initial_Tutorial.zip
//===========================================================

module spi_lcd_init #(
    parameter int CLK_FREQ = 27_000_000
) (
    input  logic clk,         // Main system clock
    input  logic reset_n,     // Async reset
    
    output logic spi_res,     // LCD Hardware Reset
    output logic spi_cs,      // Chip Select
    output logic spi_clk,     // SPI Clock
    output logic spi_di       // SPI MOSI Data
);

    // Command dictionary config
    // [9:8] = Type (00: Data, 01: Cmd, 10: Delay ms, 11: End)
    // [7:0] = Payload
    localparam logic [9:0] INIT_SEQ [0:384] = '{
        {2'b01, 8'hFF}, {2'b00, 8'h30},
        {2'b01, 8'hFF}, {2'b00, 8'h52},
        {2'b01, 8'hFF}, {2'b00, 8'h01},
        {2'b01, 8'hE3}, {2'b00, 8'h00},
        {2'b01, 8'h40}, {2'b00, 8'h00},
        {2'b01, 8'h03}, {2'b00, 8'h40},
        {2'b01, 8'h04}, {2'b00, 8'h00},
        {2'b01, 8'h05}, {2'b00, 8'h03},
        {2'b01, 8'h08}, {2'b00, 8'h00},
        {2'b01, 8'h09}, {2'b00, 8'h07},
        {2'b01, 8'h0A}, {2'b00, 8'h01},
        {2'b01, 8'h0B}, {2'b00, 8'h32},
        {2'b01, 8'h0C}, {2'b00, 8'h32},
        {2'b01, 8'h0D}, {2'b00, 8'h0B},
        {2'b01, 8'h0E}, {2'b00, 8'h00},
        {2'b01, 8'h23}, {2'b00, 8'hA2},
        {2'b01, 8'h24}, {2'b00, 8'h0c},
        {2'b01, 8'h25}, {2'b00, 8'h06},
        {2'b01, 8'h26}, {2'b00, 8'h14},
        {2'b01, 8'h27}, {2'b00, 8'h14},
        {2'b01, 8'h38}, {2'b00, 8'h9C}, 
        {2'b01, 8'h39}, {2'b00, 8'hA7}, 
        {2'b01, 8'h3A}, {2'b00, 8'h3a}, 
        {2'b01, 8'h28}, {2'b00, 8'h40},
        {2'b01, 8'h29}, {2'b00, 8'h01},
        {2'b01, 8'h2A}, {2'b00, 8'hdf},
        {2'b01, 8'h49}, {2'b00, 8'h3C},   
        {2'b01, 8'h91}, {2'b00, 8'h57}, 
        {2'b01, 8'h92}, {2'b00, 8'h57}, 
        {2'b01, 8'hA0}, {2'b00, 8'h55},
        {2'b01, 8'hA1}, {2'b00, 8'h50},
        {2'b01, 8'hA4}, {2'b00, 8'h9C},
        {2'b01, 8'hA7}, {2'b00, 8'h02},  
        {2'b01, 8'hA8}, {2'b00, 8'h01},  
        {2'b01, 8'hA9}, {2'b00, 8'h01},  
        {2'b01, 8'hAA}, {2'b00, 8'hFC},  
        {2'b01, 8'hAB}, {2'b00, 8'h28},  
        {2'b01, 8'hAC}, {2'b00, 8'h06},  
        {2'b01, 8'hAD}, {2'b00, 8'h06},  
        {2'b01, 8'hAE}, {2'b00, 8'h06},  
        {2'b01, 8'hAF}, {2'b00, 8'h03},  
        {2'b01, 8'hB0}, {2'b00, 8'h08},  
        {2'b01, 8'hB1}, {2'b00, 8'h26},  
        {2'b01, 8'hB2}, {2'b00, 8'h28},  
        {2'b01, 8'hB3}, {2'b00, 8'h28},  
        {2'b01, 8'hB4}, {2'b00, 8'h33},  
        {2'b01, 8'hB5}, {2'b00, 8'h08},  
        {2'b01, 8'hB6}, {2'b00, 8'h26},  
        {2'b01, 8'hB7}, {2'b00, 8'h08},  
        {2'b01, 8'hB8}, {2'b00, 8'h26}, 
        {2'b01, 8'hF0}, {2'b00, 8'h00}, 
        {2'b01, 8'hF6}, {2'b00, 8'hC0},
        {2'b01, 8'hFF}, {2'b00, 8'h30},
        {2'b01, 8'hFF}, {2'b00, 8'h52},
        {2'b01, 8'hFF}, {2'b00, 8'h02},
        {2'b01, 8'hB0}, {2'b00, 8'h0B},
        {2'b01, 8'hB1}, {2'b00, 8'h16},
        {2'b01, 8'hB2}, {2'b00, 8'h17}, 
        {2'b01, 8'hB3}, {2'b00, 8'h2C}, 
        {2'b01, 8'hB4}, {2'b00, 8'h32},  
        {2'b01, 8'hB5}, {2'b00, 8'h3B},  
        {2'b01, 8'hB6}, {2'b00, 8'h29}, 
        {2'b01, 8'hB7}, {2'b00, 8'h40},   
        {2'b01, 8'hB8}, {2'b00, 8'h0d},
        {2'b01, 8'hB9}, {2'b00, 8'h05},
        {2'b01, 8'hBA}, {2'b00, 8'h12},
        {2'b01, 8'hBB}, {2'b00, 8'h10},
        {2'b01, 8'hBC}, {2'b00, 8'h12},
        {2'b01, 8'hBD}, {2'b00, 8'h15},
        {2'b01, 8'hBE}, {2'b00, 8'h19},              
        {2'b01, 8'hBF}, {2'b00, 8'h0E},
        {2'b01, 8'hC0}, {2'b00, 8'h16},  
        {2'b01, 8'hC1}, {2'b00, 8'h0A},
        {2'b01, 8'hD0}, {2'b00, 8'h0C},
        {2'b01, 8'hD1}, {2'b00, 8'h17},
        {2'b01, 8'hD2}, {2'b00, 8'h14},
        {2'b01, 8'hD3}, {2'b00, 8'h2E},   
        {2'b01, 8'hD4}, {2'b00, 8'h32},   
        {2'b01, 8'hD5}, {2'b00, 8'h3C},  
        {2'b01, 8'hD6}, {2'b00, 8'h22},
        {2'b01, 8'hD7}, {2'b00, 8'h3D},
        {2'b01, 8'hD8}, {2'b00, 8'h0D},
        {2'b01, 8'hD9}, {2'b00, 8'h07},
        {2'b01, 8'hDA}, {2'b00, 8'h13},
        {2'b01, 8'hDB}, {2'b00, 8'h13},
        {2'b01, 8'hDC}, {2'b00, 8'h11},
        {2'b01, 8'hDD}, {2'b00, 8'h15},
        {2'b01, 8'hDE}, {2'b00, 8'h19},                   
        {2'b01, 8'hDF}, {2'b00, 8'h10},
        {2'b01, 8'hE0}, {2'b00, 8'h17},    
        {2'b01, 8'hE1}, {2'b00, 8'h0A},
        {2'b01, 8'hFF}, {2'b00, 8'h30},
        {2'b01, 8'hFF}, {2'b00, 8'h52},
        {2'b01, 8'hFF}, {2'b00, 8'h03},   
        {2'b01, 8'h00}, {2'b00, 8'h2A},
        {2'b01, 8'h01}, {2'b00, 8'h2A},
        {2'b01, 8'h02}, {2'b00, 8'h2A},
        {2'b01, 8'h03}, {2'b00, 8'h2A},
        {2'b01, 8'h04}, {2'b00, 8'h61},  
        {2'b01, 8'h05}, {2'b00, 8'h80},   
        {2'b01, 8'h06}, {2'b00, 8'hc7},   
        {2'b01, 8'h07}, {2'b00, 8'h01},  
        {2'b01, 8'h08}, {2'b00, 8'h03}, 
        {2'b01, 8'h09}, {2'b00, 8'h04},
        {2'b01, 8'h70}, {2'b00, 8'h22},
        {2'b01, 8'h71}, {2'b00, 8'h80},
        {2'b01, 8'h30}, {2'b00, 8'h2A},
        {2'b01, 8'h31}, {2'b00, 8'h2A},
        {2'b01, 8'h32}, {2'b00, 8'h2A},
        {2'b01, 8'h33}, {2'b00, 8'h2A},
        {2'b01, 8'h34}, {2'b00, 8'h61},
        {2'b01, 8'h35}, {2'b00, 8'hc5},
        {2'b01, 8'h36}, {2'b00, 8'h80},
        {2'b01, 8'h37}, {2'b00, 8'h23},
        {2'b01, 8'h40}, {2'b00, 8'h03}, 
        {2'b01, 8'h41}, {2'b00, 8'h04}, 
        {2'b01, 8'h42}, {2'b00, 8'h05}, 
        {2'b01, 8'h43}, {2'b00, 8'h06}, 
        {2'b01, 8'h44}, {2'b00, 8'h11}, 
        {2'b01, 8'h45}, {2'b00, 8'he8}, 
        {2'b01, 8'h46}, {2'b00, 8'he9}, 
        {2'b01, 8'h47}, {2'b00, 8'h11},
        {2'b01, 8'h48}, {2'b00, 8'hea}, 
        {2'b01, 8'h49}, {2'b00, 8'heb},
        {2'b01, 8'h50}, {2'b00, 8'h07}, 
        {2'b01, 8'h51}, {2'b00, 8'h08}, 
        {2'b01, 8'h52}, {2'b00, 8'h09}, 
        {2'b01, 8'h53}, {2'b00, 8'h0a}, 
        {2'b01, 8'h54}, {2'b00, 8'h11}, 
        {2'b01, 8'h55}, {2'b00, 8'hec}, 
        {2'b01, 8'h56}, {2'b00, 8'hed}, 
        {2'b01, 8'h57}, {2'b00, 8'h11}, 
        {2'b01, 8'h58}, {2'b00, 8'hef}, 
        {2'b01, 8'h59}, {2'b00, 8'hf0}, 
        {2'b01, 8'hB1}, {2'b00, 8'h01}, 
        {2'b01, 8'hB4}, {2'b00, 8'h15}, 
        {2'b01, 8'hB5}, {2'b00, 8'h16}, 
        {2'b01, 8'hB6}, {2'b00, 8'h09}, 
        {2'b01, 8'hB7}, {2'b00, 8'h0f}, 
        {2'b01, 8'hB8}, {2'b00, 8'h0d}, 
        {2'b01, 8'hB9}, {2'b00, 8'h0b}, 
        {2'b01, 8'hBA}, {2'b00, 8'h00}, 
        {2'b01, 8'hC7}, {2'b00, 8'h02}, 
        {2'b01, 8'hCA}, {2'b00, 8'h17}, 
        {2'b01, 8'hCB}, {2'b00, 8'h18}, 
        {2'b01, 8'hCC}, {2'b00, 8'h0a}, 
        {2'b01, 8'hCD}, {2'b00, 8'h10}, 
        {2'b01, 8'hCE}, {2'b00, 8'h0e}, 
        {2'b01, 8'hCF}, {2'b00, 8'h0c}, 
        {2'b01, 8'hD0}, {2'b00, 8'h00}, 
        {2'b01, 8'h81}, {2'b00, 8'h00}, 
        {2'b01, 8'h84}, {2'b00, 8'h15}, 
        {2'b01, 8'h85}, {2'b00, 8'h16}, 
        {2'b01, 8'h86}, {2'b00, 8'h10}, 
        {2'b01, 8'h87}, {2'b00, 8'h0a}, 
        {2'b01, 8'h88}, {2'b00, 8'h0c}, 
        {2'b01, 8'h89}, {2'b00, 8'h0e},
        {2'b01, 8'h8A}, {2'b00, 8'h02}, 
        {2'b01, 8'h97}, {2'b00, 8'h00}, 
        {2'b01, 8'h9A}, {2'b00, 8'h17}, 
        {2'b01, 8'h9B}, {2'b00, 8'h18},
        {2'b01, 8'h9C}, {2'b00, 8'h0f},
        {2'b01, 8'h9D}, {2'b00, 8'h09}, 
        {2'b01, 8'h9E}, {2'b00, 8'h0b}, 
        {2'b01, 8'h9F}, {2'b00, 8'h0d}, 
        {2'b01, 8'hA0}, {2'b00, 8'h01}, 
        {2'b01, 8'hFF}, {2'b00, 8'h30},
        {2'b01, 8'hFF}, {2'b00, 8'h52},
        {2'b01, 8'hFF}, {2'b00, 8'h02},  
        {2'b01, 8'h01}, {2'b00, 8'h01},
        {2'b01, 8'h02}, {2'b00, 8'hDA},
        {2'b01, 8'h03}, {2'b00, 8'hBA},
        {2'b01, 8'h04}, {2'b00, 8'hA8},
        {2'b01, 8'h05}, {2'b00, 8'h9A},
        {2'b01, 8'h06}, {2'b00, 8'h70},
        {2'b01, 8'h07}, {2'b00, 8'hFF},
        {2'b01, 8'h08}, {2'b00, 8'h91},
        {2'b01, 8'h09}, {2'b00, 8'h90},
        {2'b01, 8'h0A}, {2'b00, 8'hFF},
        {2'b01, 8'h0B}, {2'b00, 8'h8F},
        {2'b01, 8'h0C}, {2'b00, 8'h60},
        {2'b01, 8'h0D}, {2'b00, 8'h58},
        {2'b01, 8'h0E}, {2'b00, 8'h48},
        {2'b01, 8'h0F}, {2'b00, 8'h38},
        {2'b01, 8'h10}, {2'b00, 8'h2B},
        {2'b01, 8'hFF}, {2'b00, 8'h30},
        {2'b01, 8'hFF}, {2'b00, 8'h52},
        {2'b01, 8'hFF}, {2'b00, 8'h00},   
        {2'b01, 8'h36}, {2'b00, 8'h02},
        {2'b01, 8'h11}, {2'b00, 8'h00}, // sleep out
        {2'b10, 8'd200},                // delay 200ms
        {2'b01, 8'h29}, {2'b00, 8'h00}, // display on
        {2'b10, 8'd10},                 // delay 10ms
        {2'b11, 8'h00}                  // EOF
    };

    localparam int TOTAL_CMDS = $size(INIT_SEQ);
    
    // Divisor to get a nice ~1.6MHz SPI clock and 1ms ticker base
    // 27MHz / 16 = 1.6875 MHz SPI Clock
    logic [3:0] clk_div;
    wire tick = (clk_div == 0);
    
    // 27MHz / 1000 = 27000 cycles per ms. Shift by clock divisor domain (16)
    localparam int TICKS_PER_MS = (CLK_FREQ / 1000) / 16; 

    typedef enum logic [3:0] {
        ST_INIT_RESET_0,
        ST_INIT_RESET_1,
        ST_INIT_RESET_2,
        ST_FETCH,
        ST_SHIFT_PRE,
        ST_SHIFT_CLK_L,
        ST_SHIFT_CLK_H,
        ST_DELAY,
        ST_DONE
    } state_t;

    state_t state;
    logic [19:0] delay_cnt;
    logic [8:0]  seq_idx;
    
    logic [8:0]  shift_reg;
    logic [3:0]  bit_cnt;

    // Combinational evaluation of current ROM instruction
    wire [1:0] cmd_type = INIT_SEQ[seq_idx][9:8];
    wire [7:0] payload  = INIT_SEQ[seq_idx][7:0];
    wire       dc_bit   = (cmd_type == 2'b00) ? 1'b1 : 1'b0;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_div <= '0;
            state   <= ST_INIT_RESET_0;
            delay_cnt <= '0;
            seq_idx <= '0;
            
            spi_res <= 1'b1;
            spi_cs  <= 1'b1;
            spi_clk <= 1'b1;
            spi_di  <= 1'b1;
        end else begin
            clk_div <= clk_div + 1'b1;
            
            if (tick) begin
                case (state)
                    ST_INIT_RESET_0: begin
                        spi_res <= 1'b1;
                        if (delay_cnt == 100 * TICKS_PER_MS) begin
                            delay_cnt <= '0;
                            state <= ST_INIT_RESET_1;
                        end else begin
                            delay_cnt <= delay_cnt + 1'b1;
                        end
                    end
                    
                    ST_INIT_RESET_1: begin
                        spi_res <= 1'b0;
                        if (delay_cnt == 100 * TICKS_PER_MS) begin
                            delay_cnt <= '0;
                            state <= ST_INIT_RESET_2;
                        end else begin
                            delay_cnt <= delay_cnt + 1'b1;
                        end
                    end
                    
                    ST_INIT_RESET_2: begin
                        spi_res <= 1'b1;
                        if (delay_cnt == 100 * TICKS_PER_MS) begin
                            delay_cnt <= '0;
                            state <= ST_FETCH;
                        end else begin
                            delay_cnt <= delay_cnt + 1'b1;
                        end
                    end
                    
                    ST_FETCH: begin
                        spi_cs  <= 1'b1;
                        spi_clk <= 1'b1;
                        
                        if (seq_idx == TOTAL_CMDS) begin
                            state <= ST_DONE;
                        end else begin
                            if (cmd_type == 2'b11) begin
                                state <= ST_DONE;
                            end else if (cmd_type == 2'b10) begin
                                delay_cnt <= payload * TICKS_PER_MS;
                                state     <= ST_DELAY;
                                seq_idx   <= seq_idx + 1'b1;
                            end else begin
                                // 01 = Cmd (D/C=0), 00 = Data (D/C=1)
                                shift_reg <= {dc_bit, payload};
                                bit_cnt   <= 9;
                                state     <= ST_SHIFT_PRE;
                            end
                        end
                    end
                    
                    ST_SHIFT_PRE: begin
                        spi_cs <= 1'b0;
                        state  <= ST_SHIFT_CLK_L;
                    end
                    
                    ST_SHIFT_CLK_L: begin
                        spi_di  <= shift_reg[8];
                        spi_clk <= 1'b0;
                        state   <= ST_SHIFT_CLK_H;
                    end
                    
                    ST_SHIFT_CLK_H: begin
                        spi_clk   <= 1'b1;
                        shift_reg <= {shift_reg[7:0], 1'b0};
                        
                        if (bit_cnt == 1) begin
                            seq_idx <= seq_idx + 1'b1;
                            state   <= ST_FETCH;
                        end else begin
                            bit_cnt <= bit_cnt - 1'b1;
                            state   <= ST_SHIFT_CLK_L;
                        end
                    end
                    
                    ST_DELAY: begin
                        if (delay_cnt == 0) begin
                            state <= ST_FETCH;
                        end else begin
                            delay_cnt <= delay_cnt - 1'b1;
                        end
                    end
                    
                    ST_DONE: begin
                        spi_res <= 1'b1;
                        spi_cs  <= 1'b1;
                        spi_clk <= 1'b1;
                    end
                endcase
            end
        end
    end

endmodule
