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
    input wire sr_ref_indicator_old,
    input wire sr_u_indicator_old,
    input wire u_re_old,
    input wire [6:0] u_read_addr,
    input wire [6:0] u_write_addr,
    input wire u_we_old,
    output wire offs_ref_re,
    output wire [6:0] sr_addr_current_out,
    output wire sr_ref_indicator_current_out,
    output wire sr_u_indicator_out,
    output wire ref_done, // indication to the controller when the memory is refreshed
    output wire [63:0] rd  
);  

    wire [63:0] data_in, data_out;
    wire we_mem, mux_re_out;
    reg re_mem, or_write_en, and_sel_write_addr, or_read_addr, and_ref_write_en, or_ref_read_en, or_ref_write_en, and_ref_write_en_port_1;
    wire [6:0] read_addr_mem, write_addr_mem, write_addr_mux_two_out;
    wire ref_write_en_ff, and_ref_write_en_port_1_ff;
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

    DFF #(.BITS(1)) ff_we_ref_en_old (  // delay ref_en_old in 1 cycle
        .in(and_ref_write_en_port_1),
        .clk(clk),
        .rst(rst),
        .out(and_ref_write_en_port_1_ff)
    );

    DFF #(.BITS(1)) ff_we (  // delay and_ref_write_en in 1 cycle
        .in(and_ref_write_en),
        .clk(clk),
        .rst(rst),
        .out(ref_write_en_ff)
    );

    MUX_2_1 #(.BITS(1)) mux_we  (
        .a(or_write_en),
        .b(or_ref_write_en),
        .sel(clk),
        .out(we_mem)
    );

    MUX_2_1 #(.BITS(1)) mux_re  (
        .a(u_re_current),
        .b(or_ref_read_en), // to be created in sr
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
    .write_addr_user(write_addr_mux_two_out),
    .read_addr_user(u_read_addr),
    .user_write_enable(or_write_en),
    .user_read_enable(u_re_current),
    .indicator_user(sr_u_indicator),
    .indicator_ref(sr_ref_indicator_current),
    .addr_ref(sr_addr_current),
    .done(ref_done)
    );

    //outputs
    assign sr_addr_current_out = sr_addr_current;
    assign sr_ref_indicator_current_out = sr_ref_indicator_current;
    assign sr_u_indicator_out = sr_u_indicator;
    assign offs_ref_re = ref_en_old & sr_u_indicator_old & u_re_old;

    always_comb begin       
        re_mem = mux_re_out | (ref_en_old & sr_u_indicator_old & u_re_old);
        or_read_addr = (u_re_old & sr_u_indicator_old) | (u_re_current & ref_en_current & ~sr_u_indicator) | (u_re_current & ~ref_en_current);
        or_write_en = (u_we_current | (ref_en_old & u_we_old));
        and_sel_write_addr = ~u_we_current & ~u_we_old & u_re_old;
        and_ref_write_en = ref_en_old & (~sr_ref_indicator_old);

        or_ref_read_en = ~sr_ref_indicator_current | (u_re_current & (~sr_u_indicator));
        or_ref_write_en = and_ref_write_en_port_1_ff | ref_write_en_ff;
        and_ref_write_en_port_1 = ref_en_old & u_re_old & ~sr_u_indicator_old;
    end

endmodule