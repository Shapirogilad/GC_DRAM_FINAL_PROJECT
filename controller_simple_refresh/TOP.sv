module TOP (
    input wire we,
    input wire re,
    input wire clk,
    input wire [9:0] waddr,
    input wire [9:0] raddr,
    input wire [63:0] in,
    input wire rst,
    input wire disable_ref,
    output wire busy,
    output wire [63:0] rd
);
    wire w_rr_enable,w_wr_enable;
    wire [7:0] we_dec, re_dec;
    wire [6:0] waddr_mem, raddr_mem;
    wire [63:0] in_mem;
    wire [7:0][63:0] out_mem;

    CONTROLLER controller (
        .we(we),
        .re(re),
        .clk(clk),
        .waddr(waddr),
        .raddr(raddr),
        .in(in),
        .rst(rst),
        .disable_ref(disable_ref),
        .mem_rd(out_mem),
        .we_dec_o(we_dec),
        .re_dec_o(re_dec),
        .rr_enable(w_rr_enable),
        .wr_enable(w_wr_enable),  
        .waddr_mem(waddr_mem),
        .raddr_mem(raddr_mem),
        .in_mem(in_mem),
        .rd(rd),
        .busy(busy)
    );

    genvar i;
    generate
        for (i=0; i<8; i++) begin
            MEM_WRAPPER mw (
            .in(in_mem), 
            .raddr(raddr_mem), 
            .waddr(waddr_mem),
            .rst(rst),
            .we(we_dec[i]),
            .re(re_dec[i]),
            .wr_enable(w_wr_enable),
            .rr_enable(w_rr_enable),
            .clk(clk),
            .rd(out_mem[i])
            );
        end
    endgenerate

endmodule