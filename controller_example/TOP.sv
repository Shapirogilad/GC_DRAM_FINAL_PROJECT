module TOP (
    input wire we,
    input wire re,
    input wire clk,
    input wire [9:0] waddr,
    input wire [9:0] raddr,
    input wire [63:0] in,
    output wire [63:0] rd
);
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
        .mem_rd(out_mem),
        .we_dec_o(we_dec),
        .re_dec_o(re_dec),
        .waddr_mem(waddr_mem),
        .raddr_mem(raddr_mem),
        .in_mem(in_mem),
        .rd(rd)
    );

    DRAM_128_64 mem1 (
        .re(re_dec[0]),
        .we(we_dec[0]),
        .clk(clk),
        .in(in_mem),
        .raddr(raddr_mem),
        .waddr(waddr_mem),
        .rd(out_mem[0])
    );

    DRAM_128_64 mem2 (
        .re(re_dec[1]),
        .we(we_dec[1]),
        .clk(clk),
        .in(in_mem),
        .raddr(raddr_mem),
        .waddr(waddr_mem),
        .rd(out_mem[1])
    );

    DRAM_128_64 mem3 (
        .re(re_dec[2]),
        .we(we_dec[2]),
        .clk(clk),
        .in(in_mem),
        .raddr(raddr_mem),
        .waddr(waddr_mem),
        .rd(out_mem[2])
    );

    DRAM_128_64 mem4 (
        .re(re_dec[3]),
        .we(we_dec[3]),
        .clk(clk),
        .in(in_mem),
        .raddr(raddr_mem),
        .waddr(waddr_mem),
        .rd(out_mem[3])
    );

    DRAM_128_64 mem5 (
        .re(re_dec[4]),
        .we(we_dec[4]),
        .clk(clk),
        .in(in_mem),
        .raddr(raddr_mem),
        .waddr(waddr_mem),
        .rd(out_mem[4])
    );

    DRAM_128_64 mem6 (
        .re(re_dec[5]),
        .we(we_dec[5]),
        .clk(clk),
        .in(in_mem),
        .raddr(raddr_mem),
        .waddr(waddr_mem),
        .rd(out_mem[5])
    );

    DRAM_128_64 mem7 (
        .re(re_dec[6]),
        .we(we_dec[6]),
        .clk(clk),
        .in(in_mem),
        .raddr(raddr_mem),
        .waddr(waddr_mem),
        .rd(out_mem[6])
    );

    DRAM_128_64 mem8 (
        .re(re_dec[7]),
        .we(we_dec[7]),
        .clk(clk),
        .in(in_mem),
        .raddr(raddr_mem),
        .waddr(waddr_mem),
        .rd(out_mem[7])
    );

endmodule