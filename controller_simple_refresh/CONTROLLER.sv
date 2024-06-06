module CONTROLLER (
    input wire we,
    input wire re,
    input wire clk,
    input wire rst,
    input wire [9:0] waddr,
    input wire [9:0] raddr,
    input wire [63:0] in,
    input wire [7:0][63:0] mem_rd,
    input wire disable_ref,
    output wire busy,
    output wire rr_enable,
    output wire wr_enable,
    output wire [7:0] we_dec_o,
    output wire [7:0] re_dec_o,
    output wire [6:0] waddr_mem,
    output wire [6:0] raddr_mem,
    output wire [63:0] in_mem,
    output wire [63:0] rd
);
    wire busy_refresh;
    wire [2:0] sel_mux_o;
    wire [63:0] w_rd;
    wire [6:0] rr_addr, wr_addr;

    //disable refresh

    CYCLES_COUNTER #(.CYCLES(4865)) cyc_counter (  // =No. of DRT_FAIL param - Cycles to do refresh - delta
        .clk(clk),
        .busy(busy_refresh),
        .rst(rst),
        .disable_ref(disable_ref),
        .out(rr_enable)
    );

    DFF #(.BITS(1)) f_cycle_counter (            
        .in(rr_enable),
        .clk(clk),
        .rst(rst),
        .out(wr_enable)
    );

    ADDR_COUNTER #(.BITS(8)) addr_counter (
        .clk(clk),
        .enable(rr_enable), //CHECK TIMING
        .busy(busy_refresh),
        .rst(rst),
        .addr(rr_addr)
    );

    DFF #(.BITS(7)) f_addr_counter (            
        .in(rr_addr),
        .clk(clk),
        .rst(rst),
        .out(wr_addr)
    );

    MUX_2_1 #(.BITS(7)) mux_waddr (
        .a(waddr[6:0]),
        .b(wr_addr),
        .sel(wr_enable),
        .out(waddr_mem)
    );

    DECODER_3_8 write_enable_dec(
        .in(we),
        .sel(waddr[9:7]),
        .out(we_dec_o)
    );

    MUX_2_1 #(.BITS(7)) mux_raddr (
        .a(raddr[6:0]),
        .b(rr_addr),
        .sel(rr_enable),
        .out(raddr_mem)
    );

    DECODER_3_8 read_enable_dec(
        .in(re),
        .sel(raddr[9:7]),
        .out(re_dec_o)
    );

    DFF #(.BITS(3)) ff (             // delay sel in 1 cycle
        .in(raddr[9:7]),
        .clk(clk),
        .rst(rst),
        .out(sel_mux_o)
    );

    MUX_8_3 read_mux(
        .in(mem_rd),
        .sel(sel_mux_o),
        .out(w_rd)
    );

    MUX_2_1 #(.BITS(64)) mux_out (
        .a(w_rd),
        .b(rd),
        .sel(busy),
        .out(rd)
    );

    assign in_mem = in;
    assign busy = rr_enable | wr_enable;

endmodule