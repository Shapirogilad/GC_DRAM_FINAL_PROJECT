module SR_CTRL_TB;

  // Inputs
  reg rst;
  reg [2:0] waddr;
  reg [2:0] raddr;
  reg ref_done;
  reg [2:0] ref_mem_addr;

  // Outputs
  wire [2:0] waddr_o;
  wire [2:0] raddr_o;

  // Instantiate the Unit Under Test (UUT)
  SR_CTRL uut (
    .rst(rst), 
    .waddr(waddr), 
    .raddr(raddr), 
    .ref_done(ref_done), 
    .ref_mem_addr(ref_mem_addr), 
    .waddr_o(waddr_o), 
    .raddr_o(raddr_o)
  );

  initial begin
    // Initialize Inputs
    rst = 0;
    waddr = 0;
    raddr = 0;
    ref_done = 0;
    ref_mem_addr = 0;

    // Apply reset
    rst = 1;
    #10;
    rst = 0;
    
    // Apply stimulus
    waddr = 3;
    raddr = 4;
    #10;
    ref_mem_addr = 5;
    #50;
    waddr = 0;
    raddr = 5;
    #10;
    // Perform a refresh operation
    ref_done = 1;
    #10;
    ref_done = 0;
    
    // Another set of addresses

    ref_mem_addr = 2;
    #50;
    // Perform another refresh operation
    ref_done = 1;
    #10;
    ref_done = 0;


    // Finish simulation
    #20;
    $finish;
  end
  

endmodule
