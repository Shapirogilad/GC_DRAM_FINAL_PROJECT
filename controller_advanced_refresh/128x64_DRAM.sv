module DRAM_128_64 (
    input wire re,
    input wire we,
    input wire clk,
    input wire [63:0] in,
    input wire [6:0] raddr,
    input wire [6:0] waddr,
    output reg [63:0] rd
);
    localparam CYCLES = 4999; //The DRT FAIL is 5000 cycles, because of the sequence of the code
    reg [63:0]mem[0:127];
    reg [12:0]counter[0:127];
    reg [63:0]not_delayed_rd;
    initial counter = '{default: 13'b0};

    always_comb begin 
        if (re == we && raddr == waddr) begin
            rd = 64'bx;
        end
        else if (re == 1) begin
           rd = mem[raddr];
        end
        else begin
            rd = 64'bx;
        end 
    end

    always_comb begin
        if (we == 1) begin
            mem[waddr] = in;
            counter[waddr] = CYCLES;
        end
        else begin
            counter[waddr] = counter[waddr];
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

