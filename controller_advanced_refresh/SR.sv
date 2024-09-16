module SR (
    input wire start,
    input wire rst,
    input wire clk,
    input wire [6:0] write_addr_user,
    input wire [6:0] read_addr_user,
    input wire user_write_enable,
    input wire user_read_enable,
    output wire indicator_user,
    output wire indicator_ref,
    output wire [6:0] addr_ref,
    output reg done
);
    reg sr [0:127];
    reg [6:0] temp_addr, addr_ref_buf;
    wire next_done;
    reg [16:0] counter;
    wire [16:0] next_counter;

    always_ff @(posedge clk or posedge rst) begin 
        if (rst) begin
            done <= 1;
            sr  <= {(128){0}};
            temp_addr <= 0;
        end
        else if (start) begin
            done <= 0;
            sr  <= {(128){0}};
            temp_addr <= 0;
        end
        else if (~done) begin
            if (user_write_enable) begin
                sr[write_addr_user] <= 1;
            end
            if(~(user_read_enable && ~sr[read_addr_user])) begin
                temp_addr <= temp_addr + 1;
            end
            addr_ref_buf <= addr_ref;
            sr[addr_ref_buf] <= 1;      
            done <= next_done;
        end
        else if(counter == 3000) begin
            sr <= {(128){0}};
        end
        if (done) begin
            temp_addr <= 0;
        end
        counter <= next_counter;
        addr_ref_buf <= addr_ref;
    end

    assign addr_ref = (user_read_enable && ~sr[read_addr_user]) ? read_addr_user : temp_addr;
    assign next_done = rst ? 1 : (start ? 0 : ((temp_addr == 127) ? 1 : done));
    assign indicator_user = sr[read_addr_user];
    assign indicator_ref = sr[addr_ref];

    assign next_counter = (rst | start | (~done)) ? 0 : counter + 1;

endmodule