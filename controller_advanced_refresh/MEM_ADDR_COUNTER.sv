module ADDR_COUNTER #(
    parameter BITS = 10
) (
    input wire clk,
    input wire enable,
    input wire rst,
    output wire busy,
    output logic [BITS-1:0] addr
);
    wire [BITS-1:0] next_addr;

    always_ff @( posedge clk or posedge rst ) begin
        if (rst)
            addr <= 0;
        else if (enable)
            addr <= next_addr;
        else
            addr <= 0;
    end
        
    assign next_addr = addr+1;
    assign busy = (enable) ? ((addr == 127) ? 1'b0 : 1'b1) : 1'b0;
endmodule