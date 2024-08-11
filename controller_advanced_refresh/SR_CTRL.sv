module SR_CTRL (
    input wire rst,
    input wire clk,
    input wire [2:0] waddr,
    input wire [2:0] raddr,
    input wire any_ref_done,
    input wire [2:0] ref_mem_addr,
    output reg [2:0] waddr_o,
    output reg [2:0] raddr_o
    
);
    reg [2:0] sr [0:7];
    reg [2:0] temp;

    always_ff @( posedge clk ) begin 
        if (rst) begin
             sr <= '{7, 1, 2, 3, 4, 5, 6, 0};
        end
        else if (any_ref_done) begin
            sr[ref_mem_addr] <= sr[0];
            sr[0] <= sr[ref_mem_addr];
        end
        
    end

    always_comb begin
        if(rst) begin
           //sr = '{7, 1, 2, 3, 4, 5, 6, 0}; // because when rst it does one swap
           waddr_o = 0;
           raddr_o = 0; 
        end
        // else if(any_ref_done) begin
        //     temp = sr[ref_mem_addr];
        //     sr[ref_mem_addr] = sr[0];
        //     sr[0] = temp;
        // end
        waddr_o = sr[waddr];
        raddr_o = sr[raddr];
        
    end

endmodule

