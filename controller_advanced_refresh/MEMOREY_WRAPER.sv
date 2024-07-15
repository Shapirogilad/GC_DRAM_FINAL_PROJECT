module MEM_WRAPPER (
    input wire [63:0] in,
    input wire [6:0] raddr,
    input wire [6:0] waddr,
    input wire we,
    input wire re,
    input wire wr_enable,
    input wire rr_enable,
    input wire clk,
    input wire rst,
    output logic [63:0] rd
);  
    wire [63:0] r_in, in_mem;
    wire re_mem, we_mem;

    MUX_2_1 #(.BITS(64)) mux_in  (
        .a(),
        .b(),
        .sel(),
        .out()
    );

    MUX_2_1 #(.BITS(1)) mux_re  (
        .a(),
        .b(),
        .sel(),
        .out()
    );

    MUX_2_1 #(.BITS(1)) mux_we  (
        .a(),
        .b(),
        .sel(),
        .out()
    );

    DRAM_128_64 mem (
        .re(),
        .we(),
        .clk(),
        .in(),
        .raddr(),
        .waddr(),
        .wr_enable(),
        .rr_enable(),
        .rd()
    );
endmodule