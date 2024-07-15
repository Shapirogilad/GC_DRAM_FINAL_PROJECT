module MUX_2_1 #(
    parameter BITS = 1
) (
    input wire [BITS-1:0] a,
    input wire [BITS-1:0] b,
    input wire sel,
    output logic [BITS-1:0] out
);

    always_comb begin
        
        case(sel)
            1'b0: out = a;
            1'b1: out = b;
            default: out = {BITS{1'bx}};
        endcase
    end
    
endmodule