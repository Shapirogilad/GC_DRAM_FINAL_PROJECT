module CYCLES_COUNTER #(
    parameter CYCLES = 5000
) (
    input wire clk,
    input wire rst,
    input wire cycle_done,
    output reg out
);
    parameter bits = $clog2(CYCLES);
    reg [bits-1:0] counter;
    wire [bits-1:0] next_count;

    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            out <= 0;
            counter <= 0;
        end
        else begin
            if (counter == CYCLES - 1) begin
                out <= 1'b1;
                counter <= 0;
            end
            else begin
                counter <= next_count;
            end
            if(cycle_done) begin
                out <= 0;
            end
        end
    end

    assign next_count = counter + 1;

endmodule