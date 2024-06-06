module DFF #(
    parameter BITS = 1
) (
    input wire [BITS-1:0] in,
    input wire clk,
    input wire rst,
    output logic [BITS-1:0] out
);
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            out <= 0;
        else
            out <= in; 
    end

endmodule