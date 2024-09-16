module CONTROLLER (
    input wire clk,
    input wire rst,
    input wire u_we,
    input wire u_re,
    input wire [9:0] u_waddr,
    input wire [9:0] u_raddr,
    input wire [63:0] u_data_in,
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
    wire we, re;
    wire [9:0] waddr, raddr;
    wire [63:0] data_in;

    wire [2:0] sel_mux_rd, sel_mux_we, sel_mux_re, ref_mem_addr, sel_mux_rd_ff;
    wire [7:0] ref_done_chopped;
    wire ref_en, ref_cycle_done, any_ref_done, re_ff;
    wire [63:0] rd_lock;

    // ff on user's input

    DFF #(.BITS(1)) ff_we (            
        .in(u_we),
        .clk(clk),
        .rst(rst),
        .out(we)
    );

    DFF #(.BITS(1)) ff_re (            
        .in(u_re),
        .clk(clk),
        .rst(rst),
        .out(re)
    );

    DFF #(.BITS(10)) ff_waddr (            
        .in(u_waddr),
        .clk(clk),
        .rst(rst),
        .out(waddr)
    );

    DFF #(.BITS(10)) ff_raddr (            
        .in(u_raddr),
        .clk(clk),
        .rst(rst),
        .out(raddr)
    );

    DFF #(.BITS(64)) ff_data_in (            
        .in(u_data_in),
        .clk(clk),
        .rst(rst),
        .out(data_in)
    );

    // controller logic

    DECODER_3_8 write_enable_dec (
        .in(we),
        .sel(sel_mux_we), 
        .out(we_dec_o)
    );

    DECODER_3_8 read_enable_dec (
        .in(re),
        .sel(sel_mux_re),
        .out(re_dec_o)
    );

    DFF #(.BITS(3)) ff_sel_mux_rd (            
        .in(sel_mux_rd),
        .clk(clk),
        .rst(rst),
        .out(sel_mux_rd_ff)
    );

    MUX_8_3 mux_rd(
        .in(mem_rd),
        .sel(sel_mux_rd_ff),
        .out(rd_lock)
    );

    DFF #(.BITS(1)) ff_re_sel_rd_lock (            
        .in(re),
        .clk(clk),
        .rst(rst),
        .out(re_ff)
    );

    MUX_2_1 #(.BITS(64)) mux_rd_lock (
        .a(rd),
        .b(rd_lock),
        .sel(re_ff),
        .out(rd)
    );

    // Refresh Logic

    SAT sat( // Shift Addr Table
        .rst(rst),
        .clk(clk),
        .waddr(waddr[9:7]),
        .raddr(raddr[9:7]),
        .any_ref_done(any_ref_done),
        .ref_mem_addr(ref_mem_addr),
        .waddr_o(sel_mux_we),
        .raddr_o(sel_mux_re)
    );

    CYCLES_COUNTER #(.CYCLES(4055)) counter (
        .clk(clk),
        .rst(rst),
        .cycle_done(ref_cycle_done),
        .out(ref_en)
    );

    REF_MEM_COUNTER ref_mem_counter (
        .clk(clk),
        .rst(rst),
        .any_ref_done(any_ref_done),
        .ref_mem_addr_o(ref_mem_addr),
        .cycle_done(ref_cycle_done)
    );

    DECODER_3_8 ref_en_dec(
        .in(ref_en),
        .sel(ref_mem_addr),
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