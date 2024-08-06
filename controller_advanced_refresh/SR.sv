module SR (
    input wire start,
    input wire rst,
    input wire clk,
    input wire [6:0] write_addr_user,
    input wire [6:0] read_addr_user,
    input wire user_write_enable,
    input wire user_read_enable,
    output reg indicator_user,
    output reg indicator_ref,// check if there is a clock delay between the user_addr and indicator
    output reg [6:0] addr_ref,
    output reg done
);
    reg sr [0:127];
    reg next_indicator_ref;
    reg [6:0] next_addr_ref;
    wire next_done;
    reg [6:0] debug;

    always_ff @(posedge clk or posedge start or posedge rst) begin
        if (rst) begin
            sr <= {(128){0}};
            done <= 1;
            addr_ref <= 0;
            //indicator_ref <= 0;
            indicator_user <= 0;
        end
        else if (start) begin
            sr <= {(128){0}};
            done <= 0;
            addr_ref <= 0;
            //indicator_ref <= 0;
            indicator_user <= 0;
        end
        else if (~done) begin
            addr_ref <= next_addr_ref;
            //indicator_ref <= next_indicator_ref;
            sr[addr_ref] <= 1'b1;
            indicator_user <= sr[read_addr_user];
            if(user_write_enable) begin
                sr[write_addr_user] <= 1'b1;
            end
            if(user_read_enable && ~sr[read_addr_user]) begin 
                sr[read_addr_user] <= 1'b1;
            end
            // else begin
            //     addr_ref <= next_addr_ref;
            //     indicator_ref <= next_indicator_ref;
            //     sr[addr_ref] <= 1'b1;
            // end
            
            done <= next_done;
        end
    end

    //assign next_addr_ref = (start || rst) ? 1 : (addr_ref+1);
    //assign next_indicator_ref = (start || rst) ? 0 : sr[next_addr_ref];
    assign next_done = rst ? 1 : (start ? 0 : ((addr_ref == 127) ? 1 : done)); //Not Suspicius

    always_comb begin
        if(start || rst) begin
            next_addr_ref = 1'b1;
            indicator_ref = 0;
        end
        else if(user_read_enable && ~sr[read_addr_user]) begin
            next_addr_ref = addr_ref;
        end
        else begin
            next_addr_ref = addr_ref+1;
            indicator_ref = sr[addr_ref];
        end

    end
        


endmodule

