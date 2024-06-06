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


    // DFF #(.BITS(64)) ff (    //must erase the ff !!!!!!!         
    //     .in(rd),
    //     .clk(clk),
    //     .rst(rst),
    //     .out(r_in)
    // );

    MUX_2_1 #(.BITS(64)) mux_in  (
        .a(in),
        .b(rd),
        .sel(wr_enable),
        .out(in_mem)
    );

    MUX_2_1 #(.BITS(1)) mux_re  (
        .a(re),
        .b(rr_enable),
        .sel(rr_enable),
        .out(re_mem)
    );

    MUX_2_1 #(.BITS(1)) mux_we  (
        .a(we),
        .b(wr_enable),
        .sel(wr_enable),
        .out(we_mem)
    );

    DRAM_128_64 mem (
        .re(re_mem),
        .we(we_mem),
        .clk(clk),
        .in(in_mem),
        .raddr(raddr),
        .waddr(waddr),
        .wr_enable(wr_enable),
        .rr_enable(rr_enable),
        .rd(rd)
    );
endmodule