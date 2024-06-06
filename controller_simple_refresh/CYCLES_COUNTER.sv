module CYCLES_COUNTER #(
    parameter CYCLES = 5000
) (
    input wire clk,
    input wire busy, // connected to done from MEM_ADDR_COUNTER
    input wire rst,
    input wire disable_ref,
    output logic out
);
    parameter bits = $clog2(CYCLES);
    reg [bits-1:0] counter;
    wire [bits-1:0] next_count;

    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            out <= 0;
            counter <= 0;
        end
        else if (disable_ref) begin
            counter <= counter;
            out <= 0;
        end
        else if(!busy) begin
            if (counter == CYCLES - 1) begin
                out <= 1'b1;
                counter <= 0;
            end
            else begin
                out <= 1'b0;
                counter <= next_count;
            end
        end
    end

    assign next_count = counter + 1;

endmodule