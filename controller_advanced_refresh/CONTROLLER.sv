module CONTROLLER (
    input wire clk,
    input wire rst,
    input wire we,
    input wire re,
    input wire [9:0] waddr,
    input wire [9:0] raddr,
    input wire [63:0] data_in,
    input wire [63:0] mem_rd [0:7],
    input wire [7:0] ref_done,
    input wire [7:0] offs_ref_re,
    output wire [7:0] we_dec_o,
    output wire [7:0] re_dec_o,
    output wire [6:0] waddr_mem,
    output wire [6:0] raddr_mem,
    output wire [63:0] in_mem,
    output wire [7:0] ref_en_o,
    output wire [7:0] start_SR,
    output wire [63:0] rd
);
    wire [2:0] sel_mux_rd, sel_mux_we, sel_mux_re, ref_mem_addr, sel_mux_rd_ff;
    wire [7:0] ref_done_chopped;
    wire ref_en, ref_cycle_done, any_ref_done, re_ff;
    wire [63:0] rd_lock;

    DECODER_3_8 write_enable_dec(
        .in(we),
        .sel(sel_mux_we), // to be generated from SR_CTRL
        .out(we_dec_o)
    );

    DECODER_3_8 read_enable_dec(
        .in(re),
        .sel(sel_mux_re),// to be generated from SR_CTRL
        .out(re_dec_o)
    );

    DFF #(.BITS(3)) ff_mux_rd (            
        .in(sel_mux_rd),// 3 MSB from raddr to be generated from SR_CTRL
        .clk(clk),
        .rst(rst),
        .out(sel_mux_rd_ff)
    );

    MUX_8_3 mux_rd(
        .in(mem_rd),
        .sel(sel_mux_rd_ff),
        .out(rd_lock)
    );

    DFF #(.BITS(1)) ff_re (            
        .in(re),// 3 MSB from raddr to be generated from SR_CTRL
        .clk(clk),
        .rst(rst),
        .out(re_ff)
    );

    // wire re_ff_ff;
    // DFF #(.BITS(1)) ff_ff_re (        // must change Harel won't like    
    //     .in(re_ff),// 3 MSB from raddr to be generated from SR_CTRL
    //     .clk(clk),
    //     .rst(rst),
    //     .out(re_ff_ff)
    // );

    MUX_2_1 #(.BITS(64)) mux_rd_lock (
        .a(rd),
        .b(rd_lock),
        .sel(re_ff), // Harel won't like put here re_ff_ff
        .out(rd)
    );

    // Refresh Logic

    SR_CTRL sr_ctrl(
        .rst(rst),
        .clk(clk),
        .waddr(waddr[9:7]),
        .raddr(raddr[9:7]),
        .any_ref_done(any_ref_done),
        .ref_mem_addr(ref_mem_addr),// to be generated from ref mem counter
        .waddr_o(sel_mux_we),
        .raddr_o(sel_mux_re)
    );

    CYCLES_COUNTER #(.CYCLES(4055)) counter (
        .clk(clk),
        .rst(rst),
        .cycle_done(ref_cycle_done),
        .out(ref_en)

    );

    REF_MEM_COUNTER ref_mem_counter(
        .clk(clk),
        .rst(rst),
        .any_ref_done(any_ref_done),
        .ref_mem_addr_o(ref_mem_addr),
        .cycle_done(ref_cycle_done)
    );

    DECODER_3_8 ref_en_dec(
        .in(ref_en),//ref_en from time counter
        .sel(ref_mem_addr),// from ref mem counter
        .out(ref_en_o)
    );

    genvar i;
    generate
        for (i=0; i<8; i++) begin
            POSEDGE_DETECTOR ref_en_chopper (
                .clk(clk),
                .rst(rst),
                .in(ref_en_o[i]),
                .out(start_SR[i])
            );

            POSEDGE_DETECTOR ref_done_chopper (
                .clk(clk),
                .rst(rst),
                .in(ref_done[i]),
                .out(ref_done_chopped[i])
            );

        end
    endgenerate


    assign in_mem = data_in;
    assign waddr_mem = waddr[6:0];
    assign raddr_mem = raddr[6:0];
    assign any_ref_done = |ref_done_chopped;
    assign any_offs_ref_re = |offs_ref_re;
    assign sel_mux_rd = (any_offs_ref_re == 1 && sel_mux_re == 7) ? 0 : (any_offs_ref_re + sel_mux_re);

endmodule