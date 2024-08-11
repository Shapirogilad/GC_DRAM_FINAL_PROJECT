module TB();

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

    // Inputs and outputs for the testbench
    reg clk;
    reg rst;
    reg we;
    reg re;
    reg [9:0] waddr;
    reg [9:0] raddr;
    reg [63:0] data_in;
    wire [63:0] rd;

    // Instance of DUT (Design Under Test)
    TOP DUT(
        .clk(clk),
        .rst(rst),
        .we(we),
        .re(re),
        .waddr(waddr),
        .raddr(raddr),
        .data_in(data_in),
        .rd(rd)
    );

    // exp behavior
    logic [63:0] exp ;


    task automatic RESET_SIGNALS;
        begin
            $write("%c[1;34m",27);
            $display("RESET_SIGNALS");
            $write("%c[0m",27);
            rst = 0;
            data_in = 0;
            waddr = 0;
            raddr = 0;
            we = 0;
            re = 0;
            #10;
            rst = 1; // from controller
            #10;
            rst = 0;
            #10;
        end
    endtask

    task automatic FILL_ALL_MEM;
        begin
            $write("%c[1;34m",27);
            $display("FILL_ALL_MEM");
            $write("%c[0m",27);
            we = 1;
            for(int i=1;i<8;i++) begin
                for(int j=0;j<128;j++) begin
                    data_in = j + 200*i;
                    waddr = {i[2:0],j[6:0]};
                    #10;
                end
            end
            we = 0;
            #30; 
        end
    endtask
    
    task automatic READ_ALL_MEM;
        begin
            $write("%c[1;34m",27);
            $display("READ_ALL_MEM");
            $write("%c[0m",27);
            re = 1;
            for(int i=1;i<8;i++) begin
                for(int j=0;j<128;j++) begin
                    raddr = {i[2:0],j[6:0]};
                    #10; // for exp to work change to 20
                    exp = j + 200*i;
                    Compare_values("Compare READ_ALL_MEM",exp,rd,1);
                end
            end
            #10;
            re = 0;
            #30; 
        end
    endtask

    task automatic USER_NOP_REF_ACTIVE;
        begin
            $write("%c[1;34m",27);
            $display("USER_NOP_REF_ACTIVE");
            $write("%c[0m",27);
            repeat(6000) @(posedge clk);

        end
    endtask

    task automatic USER_READ_REF_NOP_OFFSET; // this task must be used with task USER_NOP_REF_ACTIVE
        begin
            $write("%c[1;34m",27);
            $display("USER_READ_REF_NOP_OFFSET");
            $write("%c[0m",27);
            //raddr =  899; // addr 3 in mem7 after ref should be addr 3 in mem0 exp in rd 1403
            #9;
            raddr = 387; // addr 3 in mem3 after ref should be addr 3 in mem4 exp in rd 603
            re = 1;
            #11;
            re = 0;
            #20;
        end
    endtask

    task automatic USER_WRITE_REF_ACTIVE;
        /*
            now refreshing mem5 at addr ~~ 32 (seconed refresh cycle so ref mem6 to mem7)
        */
        begin
            $write("%c[1;34m",27);
            $display("USER_WRITE_REF_ACTIVE");
            $write("%c[0m",27);
            repeat(7500) @(posedge clk); 
            data_in = 1;
            waddr = 740; // addr 100 in mem5
            we = 1;
            #10;
            we = 0;
            #10;  
            repeat(100) @(posedge clk);
        end
    endtask

    task automatic USER_READ_REF_ACTIVE_ADDR_REF; // reading an address that has been refreshed, this task must be used with task USER_WRITE_REF_ACTIVE
        begin
            $write("%c[1;34m",27);
            $display("USER_READ_REF_ACTIVE_ADDR_REF");
            $write("%c[0m",27);
            raddr = 740; // addr 100 in mem5
            #9
            re = 1;
            #11;
            re = 0;
            #100;
            
        end
    endtask

    task automatic USER_READ_REF_ACTIVE_ADDR_NO_REF; // reading an address that has not been refreshed
        begin
            $write("%c[1;34m",27);
            $display("USER_READ_REF_ACTIVE_ADDR_NO_REF");
            $write("%c[0m",27);
            repeat(7500) @(posedge clk);
            raddr = 760; // addr 120 in mem5
            #9;
            re = 1;
            #11;
            re = 0;
            repeat(110) @(posedge clk);
            
        end
    endtask



    always #5 clk = ~clk;

    initial begin
        clk = 1; 
        
        RESET_SIGNALS;

        FILL_ALL_MEM;

        //READ_ALL_MEM;

        // USER_NOP_REF_ACTIVE;
        // USER_READ_REF_NOP_OFFSET;

        // USER_WRITE_REF_ACTIVE;
        // USER_READ_REF_ACTIVE_ADDR_REF;

        USER_READ_REF_ACTIVE_ADDR_NO_REF; // still need to be fixed (rd)

        $finish();
    end

endmodule
