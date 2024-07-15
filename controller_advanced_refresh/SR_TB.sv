module tb_SR;
    // Testbench signals
    reg rst;
    reg clk;
    reg pause;
    reg [6:0] user_addr;
    wire indicator;
    wire [6:0] addr;
    wire done;

    // Instantiate the DUT (Device Under Test)
    SR dut (
        .rst(rst),
        .clk(clk),
        .pause(pause),
        .user_addr(user_addr),
        .indicator(indicator),
        .addr(addr),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst = 0;
        pause = 0;
        user_addr = 0;

        // Reset the module
        $display("Applying reset...");
        rst = 1;
        #10;
        rst = 0;
        #10;

        // Test pause functionality
        $display("Testing pause functionality...");
        pause = 1;
        user_addr = 7'd10;
        #10;
        pause = 0;
        #10;

        // Set some addresses
        $display("Setting addresses 0, 2, and 4...");
        pause = 0;
        #10;
        pause = 1;
        user_addr = 7'd2;
        #10;
        pause = 1;
        user_addr = 7'd4;
        #10;
        pause = 0;
        #10;

        // Check find_next_sr_addr functionality
        $display("Checking address skipping...");
        repeat (200) begin
            #10;
            $display("addr: %d, indicator: %d, done: %d", addr, indicator, done);
        end

        // End the simulation
        $stop;
    end

endmodule
