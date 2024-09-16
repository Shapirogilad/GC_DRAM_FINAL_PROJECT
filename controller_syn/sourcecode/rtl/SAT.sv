module SAT ( // Shift Addr Table
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
    reg [2:0] swap_index;

    always_ff @( posedge clk ) begin 
        if (rst) begin
             sr <= '{1, 0, 2, 3, 4, 5, 6, 7};
             swap_index <= 1;
        end
        else if (any_ref_done) begin
            sr[swap_index] <= sr[0];
            sr[0] <= sr[swap_index];
            if (swap_index == 1) begin
                swap_index <= 7;
            end
            else begin
                swap_index <= swap_index - 1;
            end
            
        end
        
    end

    always_comb begin
        if(rst) begin
           waddr_o = 0;
           raddr_o = 0; 
        end
        waddr_o = sr[waddr];
        raddr_o = sr[raddr];
        
    end

endmodule

