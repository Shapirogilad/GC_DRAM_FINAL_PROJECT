module MEM_WRAPPER (
    input wire clk,
    input wire rst,
    input wire [63:0] u_data_in,
    input wire [63:0] ref_data_in,
    input wire u_we_current,
    input wire ref_en_old, // active when current wraper is COI
    input wire u_re_current,
    input wire ref_en_current, // active when current wraper is refreshed
    input wire start_SR, // pulse coming from controller - 1 cycle to reset SR
    input wire [6:0] sr_addr_old,
    input wire sr_indicator_old,
    input wire u_re_old,
    input wire [6:0] u_read_addr,
    input wire [6:0] u_write_addr,
    input wire u_we_old,
    output wire [6:0] sr_addr_current_out,
    output wire sr_ref_indicator_current_out,
    output wire ref_done, // indication to the controller when the memory is refreshed
    output wire [63:0] rd  
);  

    wire [63:0] data_in, data_out;
    wire re_mem, we_mem, mux_re_out;
    wire or_read_addr;
    wire [6:0] read_addr_mem, write_addr_mem, write_addr_mux_two_out;
    wire ref_en_old_ff;
    wire [6:0] sr_addr_old_ff;

    //sr wires
    wire sr_ref_indicator_current, sr_u_indicator;
    wire [6:0] sr_addr_current;

//NOTICE: clk starting at 1

    MUX_2_1 #(.BITS(64)) mux_data_in  (
        .a(u_data_in),
        .b(ref_data_in),
        .sel(clk),
        .out(data_in)
    );

    DFF #(.BITS(1)) ff_we (  // delay ref_en_old in 1 cycle
        .in(ref_en_old),
        .clk(clk),
        .rst(rst),
        .out(ref_en_old_ff)
    );

    MUX_2_1 #(.BITS(1)) mux_we  (
        .a(or_write_en),
        .b(ref_en_old_ff),
        .sel(clk),
        .out(we_mem)
    );

    MUX_2_1 #(.BITS(1)) mux_re  (
        .a(u_re_current),
        .b(~sr_ref_indicator_current), // to be created in sr
        .sel(ref_en_current),
        .out(mux_re_out)
    );

    MUX_2_1 #(.BITS(7)) mux_read_addr  (
        .a(sr_addr_current), // to be created in sr
        .b(u_read_addr),
        .sel(or_read_addr),
        .out(read_addr_mem)
    );

    MUX_2_1 #(.BITS(7)) mux_write_addr_two  (
        .a(u_write_addr),
        .b(u_read_addr),
        .sel(and_sel_write_addr),
        .out(write_addr_mux_two_out) // address that supposed to happen on users cycle
    );

    DFF #(.BITS(7)) ff_ref_addr (             // delay ref_addr in 1 cycle
        .in(sr_addr_old),
        .clk(clk),
        .rst(rst),
        .out(sr_addr_old_ff)
    );

    MUX_2_1 #(.BITS(7)) mux_write_addr_one  (
        .a(write_addr_mux_two_out),
        .b(sr_addr_old_ff), // to be created in sr
        .sel(clk),
        .out(write_addr_mem)
    );

    DRAM_128_64 mem (
        .re(re_mem),
        .we(we_mem),
        .clk(clk),
        .in(data_in),
        .raddr(read_addr_mem),
        .waddr(write_addr_mem),
        .rd(rd)
    );

    SR sr (
    .start(start_SR),// indication so start the SR, must fix and find solution
    .rst(rst),
    .clk(clk),
    .addr_user(write_addr_mux_two_out),
    .user_write_enable(or_write_en),
    .indicator_user(sr_u_indicator),
    .indicator_ref(sr_ref_indicator_current),
    .addr_ref(sr_addr_current),
    .done(ref_done)
    );

    assign re_mem = mux_re_out | (ref_en_old & sr_indicator_old);

    assign or_write_en = (u_we_current | (ref_en_old & u_we_old) | (ref_en_old_ff & u_re_old));

    assign and_sel_read_addr = u_re_current & ~sr_u_indicator; // to be created in sr
    assign or_read_addr = and_sel_read_addr | u_re_old; 

    assign and_sel_write_addr = ~u_we_current & ~u_we_old & u_re_old;

    //outputs
    assign sr_addr_current_out = sr_addr_current;
    assign sr_ref_indicator_current_out = sr_ref_indicator_current;

endmodule