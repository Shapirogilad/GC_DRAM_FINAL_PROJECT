module CONTROLLER (
    input wire we,
    input wire re,
    input wire clk,
    input wire [9:0] waddr,
    input wire [9:0] raddr,
    input wire [63:0] in,
    input wire [7:0][63:0] mem_rd,
    output wire [7:0] we_dec_o,
    output wire [7:0] re_dec_o,
    output wire [6:0] waddr_mem,
    output wire [6:0] raddr_mem,
    output wire [63:0] in_mem,
    output wire [63:0] rd
);
    wire [2:0] sel_mux_o;

    DECODER_3_8 write_enable_dec(
        .in(we),
        .sel(waddr[9:7]),
        .out(we_dec_o)
    );

    DECODER_3_8 read_enable_dec(
        .in(re),
        .sel(raddr[9:7]),
        .out(re_dec_o)
    );

    DFF ff(             // delay sel in 1 cycle
        .in(raddr[9:7]),
        .clk(clk),
        .out(sel_mux_o)
    );

    MUX_8_3 read_mux(
        .in(mem_rd),
        .sel(sel_mux_o),
        .out(rd)
    );

    assign waddr_mem = waddr[6:0];
    assign raddr_mem = raddr[6:0];
    assign in_mem = in;

endmodule