module POSEDGE_DETECTOR (
    input wire clk,
    input wire rst,
    input wire in,
    output reg out
);
    wire ff_o; 

    DFF #(.BITS(1)) ff (            
        .in(in),// 3 MSB from raddr to be generated from SR_CTRL
        .clk(clk),
        .rst(rst),
        .out(ff_o)
    );
    
    always_comb begin 
        out = in & ~ff_o;
    end
endmodule