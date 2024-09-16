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
    wire we_mem, mux_re_out, ref_or_we_ff;
    reg re_mem, or_write_en, or_read_addr, and_ref_write_en, or_ref_read_en;
    reg or_ref_write_en, and_ref_write_en_port_1, and_re, u_ref_w_addr_cmp, and_ref_write_en_after_or;
    wire [6:0] read_addr_mem, write_addr_mem, sr_addr_old_ff;

    //sr wires
    wire sr_ref_indicator_current, sr_u_indicator;
    wire [6:0] sr_addr_current;

//NOTICE: clk starting at 1
    DFF #(.BITS(64)) ff_rd (  
        .in(data_out),
        .clk(clk),
        .rst(rst),
        .out(rd)
    );

    MUX_2_1 #(.BITS(64)) mux_data_in (
        .a(u_data_in),
        .b(ref_data_in),
        .sel(clk),
        .out(data_in)
    );

    DFF #(.BITS(1)) ff_or_we (  
        .in(and_ref_write_en_after_or),
        .clk(clk),
        .rst(rst),
        .out(ref_or_we_ff)
    );

    MUX_2_1 #(.BITS(1)) mux_we (
        .a(or_write_en),
        .b(ref_or_we_ff), 
        .sel(clk),
        .out(we_mem)
    );

    MUX_2_1 #(.BITS(1)) mux_re (
        .a(u_re_current),
        .b(or_ref_read_en), 
        .sel(ref_en_current),
        .out(mux_re_out)
    );

    MUX_2_1 #(.BITS(7)) mux_read_addr (
        .a(sr_addr_current), 
        .b(u_read_addr),
        .sel(or_read_addr),
        .out(read_addr_mem)
    );

    DFF #(.BITS(7)) ff_ref_addr ( 
        .in(sr_addr_old),
        .clk(clk),
        .rst(rst),
        .out(sr_addr_old_ff)
    );

    MUX_2_1 #(.BITS(7)) mux_write_addr_one (
        .a(u_write_addr), 
        .b(sr_addr_old_ff), 
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
        .rd(data_out)
    );

    SR sr (
        .start(start_SR),
        .rst(rst),
        .clk(clk),
        .write_addr_user(u_write_addr),
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

    //assign offs_ref_re = ref_en_current & u_re_current & (sr_u_indicator & ~(&(sr_addr_current ^~ u_read_addr))); //ugly change
    assign offs_ref_re = ref_en_current & u_re_current & sr_u_indicator;//nice change

    always_comb begin    
        and_re = (ref_en_old & sr_u_indicator_old & u_re_old);
        re_mem = mux_re_out | and_re;
        //or_read_addr = (u_re_old & sr_u_indicator_old) | (u_re_current & ref_en_current & ~sr_u_indicator) | (u_re_current & ~ref_en_current);
        //or_read_addr = (u_re_old & (sr_u_indicator_old & ~(&(sr_addr_old ^~ u_read_addr)))) | (u_re_current & ref_en_current & ~sr_u_indicator) | (u_re_current & ~ref_en_current); //ugly change
        or_read_addr = (u_re_old & sr_u_indicator_old) | (u_re_current & ref_en_current & ~sr_u_indicator) | (u_re_current & ~ref_en_current); //nice change
        or_write_en = (u_we_current | (ref_en_old & u_we_old));

        //or_ref_read_en = ~sr_ref_indicator_current | (u_re_current & (~sr_u_indicator));
        or_ref_read_en = ~sr_ref_indicator_current | (u_re_current & ((~(sr_u_indicator)) || (sr_u_indicator & (&(sr_addr_current ^~ u_read_addr))))); //ugly change

        and_ref_write_en = ref_en_old & (~sr_ref_indicator_old);
        and_ref_write_en_port_1 = ref_en_old & u_re_old & ~sr_u_indicator_old;
        or_ref_write_en = and_ref_write_en_port_1 | and_ref_write_en;
        u_ref_w_addr_cmp = ~(&(sr_addr_old ^~ u_write_addr) & u_we_old);
        and_ref_write_en_after_or =  or_ref_write_en & u_ref_w_addr_cmp;
    end

    // &(sr_addr_old ^~ u_read_addr) == (sr_addr_old == u_read_addr)

endmodule