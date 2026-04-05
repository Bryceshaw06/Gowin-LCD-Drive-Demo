//===========================================================
// Gowin LCD Drive Demo
// Bryce Shaw - 2026 - https://github.com/Bryceshaw06
// button_toggle.sv
// Debounced button abstraction that safely toggles outputs on each press
//===========================================================

module button_toggle #(
    parameter int STATES = 2,
    parameter int DEBOUNCE_CYCLES = 330000
) (
    input  logic clk,         // Clock
    input  logic reset_n,     // Active-low reset
    input  logic btn_raw,     // Raw button input (active low)
    output logic [$clog2(STATES)-1:0] toggle_out   // Toggled output
);

    logic sync0, sync1;
    logic stable;
    logic prev;
    
    // Auto-size debounce counter based on required cycles
    logic [$clog2(DEBOUNCE_CYCLES)-1:0] debounce_cnt;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            {sync1, sync0, stable, prev} <= '1;
            {toggle_out, debounce_cnt}   <= '0;
        end else begin
            // Synchronize button to clock domain via shift register
            {sync1, sync0} <= {sync0, btn_raw};

            // Debounce logic
            if (sync1 != stable) begin
                debounce_cnt <= debounce_cnt + 1'b1;
                if (debounce_cnt == DEBOUNCE_CYCLES - 1) begin
                    stable       <= sync1;
                    debounce_cnt <= 0;
                end
            end else begin
                debounce_cnt <= 0;
            end

            // Detect falling edge (active low press) and toggle output
            if (prev && !stable) begin
                toggle_out <= (toggle_out == STATES - 1) ? '0 : toggle_out + 1'b1;
            end

            prev <= stable;
        end
    end

endmodule