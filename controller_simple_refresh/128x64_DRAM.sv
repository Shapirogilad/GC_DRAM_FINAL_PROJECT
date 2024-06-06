module DRAM_128_64 (
    input wire re,
    input wire we,
    input wire clk,
    input wire [63:0] in,
    input wire [6:0] raddr,
    input wire [6:0] waddr,
    input wire wr_enable,
    input wire rr_enable,
    output logic [63:0] rd
);
    localparam CYCLES = 4999; //The DRT FAIL is 5000 cycles, because of the sequence of the code
    reg [63:0]mem[0:127];
    reg [12:0]counter[0:127];

    initial begin
        for (int i = 0; i < 128; i = i + 1) begin
            counter[i] = 0;
        end 
    end

    always_ff @(posedge clk) begin 
        if (re == we && !(wr_enable || rr_enable))
            rd <= 64'bx;
        else if (re)
            rd <= mem[raddr];
        else
            rd <= 64'bx;
    end

    always_ff @(posedge clk) begin 
        if (we) begin
            mem[waddr] <= in;
            counter[waddr] <= CYCLES;
        end
    end
    
    always_ff @(posedge clk) begin
        for (int i = 0; i < 128; i++) begin
            if (counter[i])
                counter[i] <= counter[i] - 1;
            if (counter[i] == 0)
                mem[i] <= 64'bx;
        end
    end

endmodule

