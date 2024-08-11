module REF_MEM_COUNTER_TB;
    // Testbench signals
    reg rst;
    reg clk;
    reg any_ref_done;
    wire [2:0] ref_mem_addr_o;
    wire cycle_done;

    // Instantiate the DUT (Device Under Test)
    REF_MEM_COUNTER dut (
        .clk(clk),
        .rst(rst),
        .any_ref_done(any_ref_done),
        .ref_mem_addr_o(ref_mem_addr_o),
        .cycle_done(cycle_done)
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
        any_ref_done = 0;

        // Apply reset
        $display("Applying reset...");
        rst = 1;
        #10;
        rst = 0;
        #10;

        repeat (100) begin
            any_ref_done = 1;
            #10;
            any_ref_done = 0;
            #100;
        end


        // End the simulation
        $finish();
    end

endmodule
