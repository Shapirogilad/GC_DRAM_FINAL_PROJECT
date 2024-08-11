
module CYCLES_COUNTER_TB;

  // Parameters
  parameter CYCLES = 5000;

  // Testbench variables
  reg clk;
  reg rst;
  reg cycle_done;
  wire out;

  // Instantiate the DUT (Device Under Test)
  CYCLES_COUNTER #(
    .CYCLES(CYCLES)
  ) dut (
    .clk(clk),
    .rst(rst),
    .cycle_done(cycle_done),
    .out(out)
  );

  // Clock generation
  initial clk = 1;
  always #5 clk = ~clk; // 10ns clock period

  // Test sequence
  initial begin
    // Initializing signals
    rst = 0;
    cycle_done = 0;
    
    // Apply reset
    rst = 1;
    #10;
    rst = 0;
    #10;

    // Wait for the counter to reach CYCLES
    repeat (5*CYCLES) @(posedge clk);
    

    // Trigger cycle_done
    cycle_done = 1;
    #10;
    cycle_done = 0;
    #10;


    // Wait for the counter to reach CYCLES again
    repeat (5*CYCLES) @(posedge clk);

    $finish();
  end
endmodule
