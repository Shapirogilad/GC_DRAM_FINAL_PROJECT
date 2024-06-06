module TB();

    // Inputs and outputs for the testbench
    logic we;
    logic re;
    logic clk;
    logic [9:0] waddr;
    logic [9:0] raddr;
    logic [63:0] in;
    logic [63:0] rd;

    // Instance of DUT (Design Under Test)
    TOP DUT(
        .we(we),
        .re(re),
        .clk(clk),
        .waddr(waddr),
        .raddr(raddr),
        .in(in),
        .rd(rd)
    );

    // Task to perform regular operations
    task automatic REGULAR; //check initial condition rd
        begin
            for (int i = 0; i < 32; i++) begin
                in = $urandom_range(0, {16{4'hF}});
                waddr = $urandom_range(0, {10{1'b1}});
                we = $random % 2;
                @(posedge clk);
                if(we) begin
                    we = 1'b0;
                    re = 1'b1;
                    raddr = waddr;
                end
                @(posedge clk);
                re = 1'b0; 
            end
        end
    endtask 

    // Task to simulate a read without a corresponding write
    task automatic DRT_FAIL;
        begin
            in = $urandom_range(0, {16{4'hF}});
            waddr = $urandom_range(0, {10{1'b1}});
            we = 1'b1;
            @(posedge clk);
            we = 1'b0;
            re = 1'b1;
            raddr = waddr;
            @(posedge clk);
            #600;
        end
    endtask 

    // Task to simulate a write and read happening simultaneously
    task automatic WE_RE_COLLISION;
        begin
            in = $urandom_range(0, {16{4'hF}});
            waddr = $urandom_range(0, {10{1'b1}});
            raddr = waddr;
            @(posedge clk);      
            we = 1'b1;
            re = 1'b1;
            #30;
            we = 1'b0;
            #30;
        end
    endtask 

    // Task to simulate a read when no data has been written
    task automatic READ_DATA_NOT_EXIST;
        begin
            raddr = $urandom_range(0, {10{1'b1}});
            re = 1'b1;
            #60;
        end
    endtask 

    always #5 clk = !clk;

    initial begin
        clk = 1; 
        //REGULAR;

        //DRT_FAIL; 

        //WE_RE_COLLISION;

        //READ_DATA_NOT_EXIST;

        $finish();
    end

endmodule

//add exp and act