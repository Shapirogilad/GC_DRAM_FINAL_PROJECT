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
    logic we;
    logic re;
    logic clk;
    logic busy;
    logic rst;
    logic disable_ref;
    logic [9:0] waddr;
    logic [9:0] raddr;
    logic [63:0] in;
    logic [63:0] rd;

    // Instance of DUT (Design Under Test)
    TOP DUT(
        .we(we),
        .re(re),
        .clk(clk),
        .rst(rst),
        .disable_ref(disable_ref),
        .waddr(waddr),
        .raddr(raddr),
        .in(in),
        .busy(busy),
        .rd(rd)
    );
    // exp behavior
    logic [63:0] exp ;
    logic flag ;
    
    // Task to perform regular operations
    task automatic REGULAR; //check initial condition rd
        begin
            $write("%c[1;34m",27);
            $display("Regular");
            $write("%c[0m",27);
            flag  = 1'b0;
            disable_ref = 1'b0;
            rst = 1'b1;
            @(posedge clk);
            rst = 1'b0;
            for (int i = 1; i < 33; i++) begin
                in = $urandom_range(0, {16{4'hF}});
                waddr = $urandom_range(0, {10{1'b1}});
                we = $random % 2;
                @(posedge clk);
                exp = flag ? (re ? in : 64'bx) : 64'bz;
                if(we) begin
                    we = 1'b0;
                    re = 1'b1;
                    flag = 1'b1;
                    raddr = waddr;
                end
                @(posedge clk);
                exp = flag ? (re ? in : 64'bx) : 64'bz;
                @(posedge clk);
                Compare_values("Compare Regular", exp , rd, i);
                re = 1'b0; 
            end
        end
    endtask 

    // Task to simulate a read without a corresponding write
    task automatic DRT_FAIL;
        input integer CYCLES;
        begin
            $write("%c[1;34m",27);
            $display("DRT_FAIL");
            $write("%c[0m",27);
            disable_ref = 1'b0;
            rst = 1'b1;
            @(posedge clk);
            rst = 1'b0;
            in = $urandom_range(0, {16{4'hF}});
            waddr = $urandom_range(0, {10{1'b1}});
            we = 1'b1;
            @(posedge clk);
            we = 1'b0;
            re = 1'b1;
            raddr = waddr;
            @(posedge clk);
            exp = in;
            repeat(CYCLES) @(posedge clk);
            Compare_values("Compare DRT FAIL", exp , rd, 1);
        end
    endtask 
    
    task automatic WE_RE_COLLISION;
        begin
            $write("%c[1;34m",27);
            $display("WE_RE_COLLISION");
            $write("%c[0m",27);
            flag = 1'b0;
            disable_ref = 1'b0;
            rst = 1'b1;
            @(posedge clk);
            rst = 1'b0;
            in = $urandom_range(0, {16{4'hF}});
            waddr = $urandom_range(0, {10{1'b1}});
            raddr = waddr;
            @(posedge clk);      
            we = 1'b1;
            re = 1'b1;
            #30;
            exp = flag ? in : 64'bx ; 
            Compare_values("Compare WE_RE_COLLISION", exp, rd, 1);
            we = 1'b0;
            flag = 1'b1;
            #30;
            exp = flag ? in : 64'bx ; 
            Compare_values("Compare WE_RE_COLLISION", exp, rd, 2);
        end
    endtask 

    task automatic READ_DATA_NOT_EXIST;
        begin
            $write("%c[1;34m",27);
            $display("READ_DATA_NOT_EXIST");
            $write("%c[0m",27);
            disable_ref = 1'b0;
            rst = 1'b1;
            @(posedge clk);
            rst = 1'b0;
            raddr = $urandom_range(0, {10{1'b1}});
            re = 1'b1;
            #60;
            exp = 64'bx;
            Compare_values("Compare READ_DATA_NOT_EXIST", exp, rd, 1);
        end
    endtask 

        task automatic DISABLE_REFRESH;
            input integer CYCLES;
        begin
            $write("%c[1;34m",27);
            $display("DISABLE_REFRESH");
            $write("%c[0m",27);
            disable_ref = 1'b1;
            rst = 1'b1;
            @(posedge clk);
            rst = 1'b0;
            in = $urandom_range(0, {16{4'hF}});
            waddr = $urandom_range(0, {10{1'b1}});
            we = 1'b1;
            @(posedge clk);
            we = 1'b0;
            re = 1'b1;
            raddr = waddr;
            @(posedge clk);
            repeat(CYCLES) @(posedge clk);
            exp = 64'bx;
            Compare_values("Compare DISABLE_REFRESH", exp , rd, 1);
        end
    endtask 

    always #5 clk = !clk;

    initial begin
        clk = 1; 
        REGULAR;

        DRT_FAIL(6000); 

        WE_RE_COLLISION;

        READ_DATA_NOT_EXIST;

        DISABLE_REFRESH(6000);

        $finish();
    end

endmodule
