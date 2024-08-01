module tb_MEM_WRAPPER;

 // Comparison Function Definition
  function automatic Compare_values(string msg, logic [63:0] exp, logic [63:0] act, int num_test);
    begin
      // Perform Comparison
      if(exp !== act) begin
        $write("%c[1;91m",27);
        $display("Error in %s Exp 0x%h Act 0x%h",msg, exp, act);
        $write("%c[0m",27);
        return 1;
      end
    $write("%c[1;92m",27);
    $display("Test %0d passed!", num_test);
    $write("%c[0m",27);
    end
  endfunction

// Inputs
reg clk;
reg rst;
reg [63:0] u_data_in;

reg u_we0;
reg u_we1;
reg u_we2;

reg ref_en0;
reg ref_en1;
reg ref_en2;

reg u_re0;
reg u_re1;
reg u_re2;


reg start_SR0;
reg start_SR1;
reg start_SR2;

reg [6:0] u_read_addr;
reg [6:0] u_write_addr;

// Outputs
wire ref_done0;
wire ref_done1;
wire ref_done2;

wire [63:0] rd0;
wire [63:0] rd1;
wire [63:0] rd2;

//wire to connect
wire [6:0] sr_addr0;
wire [6:0] sr_addr1;
wire [6:0] sr_addr2;

wire sr_indicator0;
wire sr_indicator1;
wire sr_indicator2;

// Instantiate the Unit Under Test (UUT)
MEM_WRAPPER mw0 ( // old mem - 2
    .clk(clk),
    .rst(rst),
    .u_data_in(u_data_in),
    .ref_data_in(rd2),
    .u_we_current(u_we0),
    .ref_en_old(ref_en2),
    .u_re_current(u_re0),
    .ref_en_current(ref_en0),
    .start_SR(start_SR0),
    .sr_addr_old(sr_addr2),
    .sr_indicator_old(sr_indicator2),
    .u_re_old(u_re2),
    .u_read_addr(u_read_addr),
    .u_write_addr(u_write_addr),
    .u_we_old(u_we2),
    .sr_addr_current_out(sr_addr0),
    .sr_ref_indicator_current_out(sr_indicator0),
    .ref_done(ref_done0),
    .rd(rd0)
);

MEM_WRAPPER mw1 ( // old mem - 0
    .clk(clk),
    .rst(rst),
    .u_data_in(u_data_in),
    .ref_data_in(rd0),
    .u_we_current(u_we1),
    .ref_en_old(ref_en0),
    .u_re_current(u_re1),
    .ref_en_current(ref_en1),
    .start_SR(start_SR1),
    .sr_addr_old(sr_addr0),
    .sr_indicator_old(sr_indicator0),
    .u_re_old(u_re0),
    .u_read_addr(u_read_addr),
    .u_write_addr(u_write_addr),
    .u_we_old(u_we0),
    .sr_addr_current_out(sr_addr1),
    .sr_ref_indicator_current_out(sr_indicator1),
    .ref_done(ref_done1),
    .rd(rd1)
);

MEM_WRAPPER mw2 ( // old mem - 1
    .clk(clk),
    .rst(rst),
    .u_data_in(u_data_in),
    .ref_data_in(rd1),
    .u_we_current(u_we2),
    .ref_en_old(ref_en1),
    .u_re_current(u_re2),
    .ref_en_current(ref_en2),
    .start_SR(start_SR2),
    .sr_addr_old(sr_addr1),
    .sr_indicator_old(sr_indicator1),
    .u_re_old(u_re1),
    .u_read_addr(u_read_addr),
    .u_write_addr(u_write_addr),
    .u_we_old(u_we1),
    .sr_addr_current_out(sr_addr2),
    .sr_ref_indicator_current_out(sr_indicator2),
    .ref_done(ref_done2),
    .rd(rd2)
);
  // Clock generation
always #5 clk = ~clk;

logic [63:0] exp0;
logic [63:0] exp1;
logic [63:0] exp2;



    task automatic RESET_SIGNALS;
        begin
            $write("%c[1;34m",27);
            $display("RESET_SIGNALS");
            $write("%c[0m",27);
            rst = 1; // from controller
            u_data_in = 0;
            u_we0 = 0;
            u_we1 = 0;
            u_we2 = 0;
            ref_en0 = 0;
            ref_en1 = 0;
            ref_en2 = 0;
            u_re0 = 0;
            u_re1 = 0;
            u_re2 = 0;
            start_SR0 = 0;
            start_SR1 = 0;
            start_SR2 = 0;
            u_read_addr = 0;
            u_write_addr = 0;

            #10;
            rst = 0;
            #10;
        end
    endtask


    task automatic FILL_MEM0; // imitating COI
        begin
            $write("%c[1;34m",27);
            $display("FILL_MEM0");
            $write("%c[0m",27);
            u_we0 = 1;
            for(int i=0;i<128;i++) begin
                u_data_in = 900+i;
                u_write_addr = i;
                #10;
            end
            u_we0 = 0;
            #30;
            
        end
    endtask

    task automatic USER_NOP_REF_ACTIVE; // imitating COI
        begin
            $write("%c[1;34m",27);
            $display("USER_NOP_REF_ACTIVE_0_TO_1");
            $write("%c[0m",27);
            ref_en0 = 1;
            start_SR0 = 1;
            #10;
            start_SR0 = 0;
            repeat(129) @(posedge clk);

            ref_en0 = 0;
            // u_re1 = 1;
            // for(int i=0;i<128;i++) begin
            //     u_read_addr = i;
            //     #10; // should be #10
            //     exp1 = 900+i;
            //     Compare_values("Compare USER_NOP_REF_ACTIVE", exp1, rd1, i+1);
            // end
            // u_re1 = 0;
            
            // till here refreshed mem0 to mem1
            $write("%c[1;34m",27);
            $display("USER_NOP_REF_ACTIVE_1_TO_2");
            $write("%c[0m",27);

            
            ref_en1 = 1;
            start_SR1 = 1;
            #10;
            start_SR1 = 0;
            repeat(129) @(posedge clk);

            ref_en1 = 0;
            // u_re2 = 1;
            // for(int i=0;i<128;i++) begin
            //     u_read_addr = i;
            //     #10; // should be #10
            //     exp2 = 900+i;
            //     Compare_values("Compare USER_NOP_REF_ACTIVE", exp2, rd2, 129+i);
            // end
            // u_re2 = 0;
            // #10;

            // till here refreshed mem1 to mem2
            $write("%c[1;34m",27);
            $display("USER_NOP_REF_ACTIVE_2_TO_0");
            $write("%c[0m",27);

            
            ref_en2 = 1;
            start_SR2 = 1;
            #10;
            start_SR2 = 0;
            repeat(129) @(posedge clk);

            ref_en2 = 0;
            u_re0 = 1;
            for(int i=0;i<128;i++) begin
                u_read_addr = i;
                #10; // should be #10
                exp0 = 900+i;
                Compare_values("Compare USER_NOP_REF_ACTIVE", exp0, rd0, 129+i);
            end
            #10;
  
        end
    endtask 


    task automatic USER_WRITE_REF_ACTIVE; // imitating COI
        begin
            $write("%c[1;34m",27);
            $display("USER_WRITE_REF_ACTIVE");
            $write("%c[0m",27);
            ref_en0 = 1;
            start_SR0 = 1;
            #10;
            start_SR0 = 0;
            repeat(49) @(posedge clk);
            #9
            u_data_in = 2600;
            u_we0 = 1; // orignally u_we0=1, but the memory wraper made shift to mem1
            u_write_addr = 100;
            #11;
            u_we0 = 0;

            repeat(79) @(posedge clk);
            ref_en0 = 0;
            
        end
    endtask

    task automatic USER_READ_REF_ACTIVE; // imitating COI
        begin
            $write("%c[1;34m",27);
            $display("USER_WRITE_REF_ACTIVE");
            $write("%c[0m",27);
            ref_en0 = 1;
            start_SR0 = 1;
            #10;
            start_SR0 = 0;
            repeat(50) @(posedge clk);
            u_data_in = 2600;
            u_we0 = 1; // orignally u_we0=1, but the memory wraper made shift to mem1
            u_write_addr = 100;
            #10;
            u_we0 = 0;

            repeat(79) @(posedge clk);
            ref_en0 = 0;
            
        end
    endtask

    

  initial begin
    // Initialize Inputs
    clk = 1;

    RESET_SIGNALS;

    FILL_MEM0;
    
    //USER_NOP_REF_ACTIVE;

    USER_WRITE_REF_ACTIVE;

    //USER_READ_REF_ACTIVE;



    
    $finish;
  end


endmodule
