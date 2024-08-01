module tb_SR;
    // Testbench signals
    reg start;
    reg rst;
    reg clk;
    reg [6:0] addr_user;
    reg user_write_enable;
    wire indicator_user;
    wire indicator_ref;
    wire [6:0] addr_ref;
    wire done;

    // Instantiate the DUT (Device Under Test)
    SR dut (
        .start(start),
        .rst(rst),
        .clk(clk),
        .addr_user(addr_user),
        .user_write_enable(user_write_enable),
        .indicator_user(indicator_user),
        .indicator_ref(indicator_ref),
        .addr_ref(addr_ref),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst = 0;
        start = 0;
        addr_user = 0;
        user_write_enable = 0;

        // Apply reset
        $display("Applying reset...");
        rst = 1;
        #10;
        rst = 0;
        start = 1;
        #10;
        start = 0;
        #10

        // Set some addresses in sr
        $display("Setting sr[1] and sr[3]...");
        user_write_enable = 1;
        addr_user = 15;
        #10;
        user_write_enable = 0;
        #10;

        // Test normal operation
        $display("Testing normal operation...");
        repeat (130) begin
            #10;
            $display("addr_ref: %d, indicator_ref: %d, indicator_user: %d, done: %d", addr_ref, indicator_ref, indicator_user, done);
        end

        // Test with user address
        $display("Testing with user address 2...");
        addr_user = 7'd2;
        #10;
        $display("indicator_user: %d", indicator_user);

        // Test done signal
        $display("Testing done signal...");
        while (!done) begin
            #10;
        end
        $display("Simulation done.");

        // End the simulation
        $finish();
    end

endmodule
