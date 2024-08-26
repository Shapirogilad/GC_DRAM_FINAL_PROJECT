module TOP (
    input wire clk,
    input wire rst,
    input wire we,
    input wire re,
    input wire [9:0] waddr,
    input wire [9:0] raddr,
    input wire [63:0] data_in,
    output wire [63:0] rd
);

    wire [63:0] out_mem [0:7];
    wire [7:0] we_dec_o, re_dec_o, ref_en_o, start_SR, sr_ref_indicator, sr_u_indicator, ref_done, offs_ref_re;
    wire [6:0] sr_addr [0:7];
    wire [6:0] raddr_mem, waddr_mem;
    wire [63:0] in_mem;

    CONTROLLER controller (
        .clk(clk),
        .rst(rst),
        .u_we(we),
        .u_re(re),
        .u_waddr(waddr),
        .u_raddr(raddr),
        .u_data_in(data_in),
        .mem_rd(out_mem),
        .ref_done(ref_done),
        .offs_ref_re(offs_ref_re),
        .we_dec_o(we_dec_o),
        .re_dec_o(re_dec_o),
        .waddr_mem(waddr_mem),
        .raddr_mem(raddr_mem),
        .in_mem(in_mem),
        .ref_en_o(ref_en_o),
        .start_SR(start_SR),
        .rd(rd)
    );

    genvar i;
    generate
        for (i=1; i<8; i++) begin
            MEM_WRAPPER mw (
                .clk(clk),
                .rst(rst),
                .u_data_in(in_mem),
                .ref_data_in(out_mem[i-1]),
                .u_we_current(we_dec_o[i]),
                .ref_en_old(ref_en_o[i-1]),
                .u_re_current(re_dec_o[i]),
                .ref_en_current(ref_en_o[i]),
                .start_SR(start_SR[i]),
                .sr_addr_old(sr_addr[i-1]),
                .sr_ref_indicator_old(sr_ref_indicator[i-1]),
                .sr_u_indicator_old(sr_u_indicator[i-1]),
                .u_re_old(re_dec_o[i-1]),
                .u_read_addr(raddr_mem),
                .u_write_addr(waddr_mem),
                .u_we_old(we_dec_o[i-1]),
                .offs_ref_re(offs_ref_re[i]),
                .sr_addr_current_out(sr_addr[i]),
                .sr_ref_indicator_current_out(sr_ref_indicator[i]),
                .sr_u_indicator_out(sr_u_indicator[i]),
                .ref_done(ref_done[i]),
                .rd(out_mem[i])
            );
        end
    endgenerate

    MEM_WRAPPER mw0 (
        .clk(clk),
        .rst(rst),
        .u_data_in(in_mem),
        .ref_data_in(out_mem[7]),
        .u_we_current(we_dec_o[0]),
        .ref_en_old(ref_en_o[7]),
        .u_re_current(re_dec_o[0]),
        .ref_en_current(ref_en_o[0]),
        .start_SR(start_SR[0]),
        .sr_addr_old(sr_addr[7]),
        .sr_ref_indicator_old(sr_ref_indicator[7]),
        .sr_u_indicator_old(sr_u_indicator[7]),
        .u_re_old(re_dec_o[7]),
        .u_read_addr(raddr_mem),
        .u_write_addr(waddr_mem),
        .u_we_old(we_dec_o[7]),
        .offs_ref_re(offs_ref_re[0]),
        .sr_addr_current_out(sr_addr[0]),
        .sr_ref_indicator_current_out(sr_ref_indicator[0]),
        .sr_u_indicator_out(sr_u_indicator[0]),
        .ref_done(ref_done[0]),
        .rd(out_mem[0])
    );

endmodule