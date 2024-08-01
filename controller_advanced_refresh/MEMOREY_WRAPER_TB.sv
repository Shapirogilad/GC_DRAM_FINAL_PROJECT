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
  reg [63:0] ref_data_in;
  reg u_we_current;
  reg ref_en_old;
  reg u_re_current;
  reg ref_en_current;
  reg start_SR;
  reg [6:0] sr_addr_old;
  reg sr_indicator_old;
  reg u_re_old;
  reg [6:0] u_read_addr;
  reg [6:0] u_write_addr;
  reg u_we_old;

  // Outputs
  wire [6:0] sr_addr_current_out;
  wire sr_ref_indicator_current_out;
  wire ref_done;
  wire [63:0] rd;

  // Instantiate the Unit Under Test (UUT)
  MEM_WRAPPER dut (
    .clk(clk),
    .rst(rst),
    .u_data_in(u_data_in),
    .ref_data_in(ref_data_in),
    .u_we_current(u_we_current),
    .ref_en_old(ref_en_old),
    .u_re_current(u_re_current),
    .ref_en_current(ref_en_current),
    .start_SR(start_SR),
    .sr_addr_old(sr_addr_old),
    .sr_indicator_old(sr_indicator_old),
    .u_re_old(u_re_old),
    .u_read_addr(u_read_addr),
    .u_write_addr(u_write_addr),
    .u_we_old(u_we_old),
    .sr_addr_current_out(sr_addr_current_out),
    .sr_ref_indicator_current_out(sr_ref_indicator_current_out),
    .ref_done(ref_done),
    .rd(rd)
  );


  // Clock generation
always #5 clk = ~clk;

logic [63:0] exp;



    task automatic RESET_SIGNALS;
        begin
            $write("%c[1;34m",27);
            $display("RESET_SIGNALS");
            $write("%c[0m",27);
            rst = 1; // from controller
            u_data_in = 0; // from controller
            ref_data_in = 0; // from prev memory
            u_we_current = 0; // from controller
            ref_en_old = 0; // from controller
            u_re_current = 0; // from controller
            ref_en_current = 0; // from controller ('1' as long as refresh occuring)
            start_SR = 0; // from controller ('1' for one cycle)
            sr_addr_old = 0; // from prev memory
            sr_indicator_old = 0; // from prev memory
            u_re_old = 0; // from controller
            u_read_addr = 0; // from controller
            u_write_addr = 0; // from controller
            u_we_old = 0; // from controller
            @(posedge clk);
            rst = 0;
            @(posedge clk);
        end
    endtask

    task automatic USER_WRITE_READ_NO_REF;
        begin
            $write("%c[1;34m",27);
            $display("USER_WRITE_READ_NO_REF");
            $write("%c[0m",27);
            u_data_in = 9;
            u_we_current = 1;
            u_write_addr = 10;
            #10;
            u_we_current = 0;
            u_re_current = 1;
            u_read_addr = 10;
            exp = 9;
            #50;
            Compare_values("Compare USER_WRITE_READ_NO_REF", exp , rd, 1);
        end
    endtask

    task automatic USER_NOP_REF_ACTIVE; // imitating COI
        begin
            $write("%c[1;34m",27);
            $display("USER_NOP_REF_ACTIVE");
            $write("%c[0m",27);
            ref_en_old = 1;
            for(int i=0;i<128;i++) begin
                ref_data_in = i+1;
                sr_addr_old = i;
                #10;
            end
            
            ref_en_old = 0;
            u_re_current = 1;

            for(int i=0;i<128;i++) begin
                u_read_addr = i;
                #20;
                exp = i+1;
                Compare_values("Compare USER_NOP_REF_ACTIVE", exp , rd, i+1);
            end
            #50;
        end
    endtask

    task automatic USER_WRITE_REF_ACTIVE; // imitating COI
        begin
            $write("%c[1;34m",27);
            $display("USER_WRITE_REF_ACTIVE");
            $write("%c[0m",27);
            ref_en_old = 1;
            u_we_current = 1;
            for(int i=0;i<128;i++) begin
                ref_data_in = i+1;
                sr_addr_old = i;
                #5;
                u_data_in = 900+i;
                u_write_addr = i;
                #5;
            end
            
            ref_en_old = 0;
            u_re_current = 1;
            u_we_current = 0;

            for(int i=0;i<128;i++) begin
                u_read_addr = i;
                #20;
                exp = 900+i;
                Compare_values("Compare USER_WRITE_REF_ACTIVE", exp , rd, i+1);
            end
            #50;
        end
    endtask

    

  initial begin
    // Initialize Inputs
    clk = 1;

    RESET_SIGNALS;

    USER_WRITE_READ_NO_REF;
    
    USER_NOP_REF_ACTIVE;

    USER_WRITE_REF_ACTIVE;



    
    $finish;
  end


endmodule
