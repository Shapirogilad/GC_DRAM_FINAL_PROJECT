module DFF (
    input wire [2:0] in,
    input wire clk,
    output logic [2:0] out
);

    always_ff @(posedge clk) begin
        out <= in; 
    end
  
endmodule