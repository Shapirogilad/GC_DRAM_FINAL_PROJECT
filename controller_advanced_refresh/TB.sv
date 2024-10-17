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
            @(posedge clk);
            rst = 1; // from controller
            @(posedge clk);
            rst = 0;
            @(posedge clk);
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
                    @(posedge clk);
                end
            end
            we = 0;
            repeat(3) @(posedge clk); 
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
                    @(posedge clk);
                    exp = j + 200*i;
                    Compare_values("Compare READ_ALL_MEM",exp,rd,1);
                end
            end
            @(posedge clk);
            re = 0;
            repeat(3) @(posedge clk);
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

    task automatic USER_READ_REF_NOP_OFFSET;
        begin
            $write("%c[1;34m",27);
            $display("USER_READ_REF_NOP_OFFSET");
            $write("%c[0m",27);
            //raddr =  899; // addr 3 in mem7 after ref should be addr 3 in mem0 exp in rd 1403
            raddr = 387; // addr 3 in mem3 after ref should be addr 3 in mem4 exp in rd 603
            re = 1;
            @(posedge clk);
            re = 0;
            repeat(2) @(posedge clk);
        end
    endtask

    task automatic USER_WRITE_REF_ACTIVE;
        begin
            $write("%c[1;34m",27);
            $display("USER_WRITE_REF_ACTIVE");
            $write("%c[0m",27);
            repeat(7500) @(posedge clk); 
            data_in = 1;
            waddr = 740; // addr 100 in mem5
            we = 1;
            @(posedge clk);
            we = 0;
            @(posedge clk);  
            repeat(70) @(posedge clk);
        end
    endtask

    task automatic USER_READ_REF_ACTIVE_ADDR_REF; 
        begin
            $write("%c[1;34m",27);
            $display("USER_READ_REF_ACTIVE_ADDR_REF");
            $write("%c[0m",27);
            raddr = 740; // addr 100 in mem5
            re = 1;
            @(posedge clk);
            re = 0;
            repeat(10) @(posedge clk);
            
        end
    endtask

    task automatic USER_READ_REF_ACTIVE_ADDR_NO_REF; 
        begin
            $write("%c[1;34m",27);
            $display("USER_READ_REF_ACTIVE_ADDR_NO_REF");
            $write("%c[0m",27);
            repeat(7500) @(posedge clk);
            re = 1;
            raddr = 760; // addr 120 in mem5
            @(posedge clk);
            re = 0;
            repeat(110) @(posedge clk);
        end
    endtask

    task automatic USER_LONG_TIME_READ_REF_ACTIVE_ADDR_NO_REF(input int num_cycles); 
        begin
            $write("%c[1;34m",27);
            $display("USER_READ_REF_ACTIVE_ADDR_NO_REF");
            $write("%c[0m",27);
            repeat(7500) @(posedge clk);
            re = 1;
            raddr = 760; // addr 120 in mem5
            repeat (num_cycles) @(posedge clk);
            re = 0;
            repeat(110) @(posedge clk);
        end
    endtask

    task automatic USER_LONG_TIME_WRITE_REF_ACTIVE(input int num_cycles); 
        begin
            $write("%c[1;34m",27);
            $display("USER_LONG_TIME_WRITE_REF_ACTIVE");
            $write("%c[0m",27);
            repeat(7500) @(posedge clk);
            we = 1;
            waddr = 685; // addr 45 in mem5
            data_in = 2;
            repeat (num_cycles) @(posedge clk);
            we = 0;
            repeat(110) @(posedge clk);
        end
    endtask

    task automatic USER_WRITE_REF_ACTIVE_SAME_ADDR; 
        begin
            $write("%c[1;34m",27);
            $display("USER_WRITE_REF_ACTIVE_SAME_ADDR");
            $write("%c[0m",27);
            repeat(7470) @(posedge clk);
            we = 1;
            waddr = 640; // addr 0 in mem5
            data_in = 10;
            repeat(20) @(posedge clk);
            we = 0;
            repeat(40) @(posedge clk);
            we = 1;
            waddr = 700; // addr 60 in mem5
            data_in = 20;
            repeat(20) @(posedge clk);
            we = 0;
            repeat(47) @(posedge clk); // till here 127 cycles
            we = 1;
            waddr = 767; // addr 127 in mem5
            data_in = 30;
            repeat (20) @(posedge clk);
            we = 0;
            repeat (20) @(posedge clk);

        end
    endtask

    task automatic USER_NOP_REF_ACTIVE_2_FULL_CYCLES; 
        begin
            $write("%c[1;34m",27);
            $display("USER_NOP_REF_ACTIVE");
            $write("%c[0m",27);
            repeat(65000) @(posedge clk);

        end
    endtask

    task automatic READ_ALL_MEM1_REFֹֹ_ACTIVE;
        begin
            $write("%c[1;34m",27);
            $display("READ_ALL_MEM1_REFֹֹ_ACTIVE");
            $write("%c[0m",27);
            repeat(3920) @(posedge clk);
            for(int i=0;i<128;i++) begin
            re = 1;
            raddr = {3'b001,i[6:0]};
            @(posedge clk);
            //exp = i + 1400;
            end
            @(posedge clk);
            re = 0; 
            repeat(100) @(posedge clk);
        end
    endtask

    task automatic WRITE_MEM1_TOP_DOWN_REF_ACTIVE;
        begin
            $write("%c[1;34m",27);
            $display("WRITE_MEM1_TOP_DOWN_REF_ACTIVE");
            $write("%c[0m",27);
            repeat(3934) @(posedge clk);
            for(int i=127;i>=0;i--) begin
                we = 1;
                data_in = i;
                waddr = {3'b001,i[6:0]};
                @(posedge clk);
            end
            we = 0;
            repeat(100) @(posedge clk); 
        end
    endtask

    task automatic WRITE_MEM5_TOP_DOWN_REF_ACTIVE_MEM1;
        begin
            $write("%c[1;34m",27);
            $display("WRITE_MEM5_TOP_DOWN_REF_ACTIVE_MEM1");
            $write("%c[0m",27);
            repeat(3934) @(posedge clk);
            for(int i=127;i>=0;i--) begin
                we = 1;
                data_in = i;
                waddr = {3'b101,i[6:0]};
                @(posedge clk);
            end
            we = 0;
            repeat(100) @(posedge clk); 
        end
    endtask

    always #5 clk = ~clk;

    initial begin
        clk = 1; 

        /*  
            All the explanations are per each task individualy

            Dictionary:
                        One shift - refresh MEM_i to MEM_i+1
                        Cycle - refreshed all MEM one time (7 one shifts)
                        Full cycle - values return to their original MEM (8 cycles)
        */
        
        /*
            Reset all signals to zero
        */
        RESET_SIGNALS; 

         /*
            Set MEM0 as COI, and fill MEM_i at address_j with 200*i + j
        */
        FILL_ALL_MEM; 

         /*
            Read all values to see if the FILL_ALL_MEM was successfull
        */
        //READ_ALL_MEM;

        /*
            Check 1 cycle, all mems should be shifted once.
            Then, user wants to read addr 3 in MEM3. 
            After cycle, the value of addr 3 should be in MEM4, and we expect rd = 603.
        */
        // USER_NOP_REF_ACTIVE;
        // USER_READ_REF_NOP_OFFSET;

        /*
            Excecuting 1 cycle with no interuption.
            In the middle of the one shift of MEM6 to MEM7, the user wants to write to MEM5 (which is currently in MEM6) at addr 100.
            The controller shifts the user to write to MEM6 and the MW shifts the user to write also to MEM7.
            Later, user wants to read refreshed addr 100 in MEM5, controller shifts the user to MEM6, MW shifts the user to MEM7. 
            List to check:
                            The value data_in = 1 was written to addr 100 both in MEM6 & MEM7.
                            When MEM6 refreshing addr 100, re should be 0.
                            Check mux_rd that we are reading from MEM7, and check rd = 1.
        */
        // USER_WRITE_REF_ACTIVE;
        // USER_READ_REF_ACTIVE_ADDR_REF;

        /*
            Excecuting 1 cycle with no interuption.
            In the middle of the one shift of MEM6 to MEM7, the user wants to read from MEM5 (which is currently in MEM6) at addr 120.
            We note that addr 120 hasn't been refreshed.
            List to check:
                            Check mux_rd that we are reading from MEM6, and check rd = 1120.
                            Check the write of 1120 to MEM7 at addr 120 at the same time as the read occurs.
                            When MEM6 refreshing addr 120, re should be 0.
        */
        //USER_READ_REF_ACTIVE_ADDR_NO_REF;

        /*
            Similar as the task: USER_READ_REF_ACTIVE_ADDR_NO_REF, but here user reads for 20 clk cycles straight.
            List to check:
                           Check mux_rd that we are reading 2 clk cycles from MEM6, and the rest from MEM7.
                           Check rd = 1120 for 20 clk cycles. 
        */
        //USER_LONG_TIME_READ_REF_ACTIVE_ADDR_NO_REF(20);
        //USER_LONG_TIME_READ_REF_ACTIVE_ADDR_NO_REF(1000);
        //USER_LONG_TIME_READ_REF_ACTIVE_ADDR_NO_REF(10000);

        /*
            Similar as the task: USER_WRITE_REF_ACTIVE, but here user writes for 20 clk cycles straight.
            List to check:
                           Check that refresh does not get stuck.
                           The value data_in = 2 was written to addr 45 both in MEM6 & MEM7.
        */
        //USER_LONG_TIME_WRITE_REF_ACTIVE(20);
        //USER_LONG_TIME_WRITE_REF_ACTIVE(1000);
        //USER_LONG_TIME_WRITE_REF_ACTIVE(10000);

        /*
            Excecuting 1 cycle with no interuption.
            In the begining, middle, and end of the one shift of MEM6 to MEM7, the user wants to write to MEM5 (which is currently in MEM6)
            at addr 0,60,127 accordingly.
            We note that the user writes exactly when the refresh is happening at the same addr.
            List to check:
                            Check that the refresh occures as expected.
                            Check: MEM7[0] = 10, MEM7[60] = 20, MEM7[127] = 30.
        */
        //USER_WRITE_REF_ACTIVE_SAME_ADDR;

        /*
            Start reading from MEM1[0] before refresh starts.
            We read from 0 -> 127.
            Refresh of MEM1 starts in the middle of the read.
            List to check:
                           Check that refresh does not get stuck, and starts from the same addr that the reading operation is at.
                           (also check that the refresh goes back to refresh the initial addresses).
                           Check rd gives all the values from 200 -> 327 in order.
        */
        //READ_ALL_MEM1_REFֹֹ_ACTIVE;
        /*
            Start writing from MEM1[127] as refresh starts.
            We write from 127 -> 0.
            List to check:
                           Check that refresh does not get stuck, and starts from addr 0 and going up.
                           Check that in paralel we write to addr 127 and going down.
                           At some point they should meet somewhere in the middle.
                           Check that MEM1 and MEM2 are filled with the values - 0 -> 127.
        */
        //WRITE_MEM1_TOP_DOWN_REF_ACTIVE;

        /*
            Start writing to MEM5 while refreshing MEM1.
            Notice that MEM5 is refreshed so there is offset to MEM6.
            List to check:
                           Check that refresh does not get stuck.
                           Check that the values are written to MEM6.
        */
        //WRITE_MEM5_TOP_DOWN_REF_ACTIVE_MEM1;

        /*
            JUST WATCH THE BEAUTY !!
        */
        //USER_NOP_REF_ACTIVE_2_FULL_CYCLES;
        $finish();
    end

endmodule
