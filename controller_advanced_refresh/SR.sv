module SR (
    input wire start,
    input wire rst,
    input wire clk,
    input wire [6:0] addr_user,
    input wire user_write_enable,
    output reg indicator_user,
    output reg indicator_ref,// check if there is a clock delay between the user_addr and indicator
    output reg [6:0] addr_ref,
    output reg done
);
    reg sr [0:127];
    wire next_indicator_ref, next_indicator_user;
    wire [6:0] next_addr_ref;
    wire next_done;
    reg [6:0] debug;

    always_ff @(posedge clk or posedge start or posedge rst) begin
        if (rst) begin
            sr <= {(128){0}};
            done <= 1;
            addr_ref <= 0;
            indicator_ref <= 0;
            indicator_user <= 0;
        end
        else if (start) begin
            sr <= {(128){0}};
            done <= 0;
            addr_ref <= 0;
            indicator_ref <= 0;
            indicator_user <= 0;
        end
        else if (~done) begin
            indicator_ref <= next_indicator_ref;
            sr[addr_ref] <= 1'b1;
            addr_ref <= next_addr_ref;
            indicator_user <= next_indicator_user;
            if(user_write_enable) begin // notice what happens if there is an addr_user just sitting there
                debug <= addr_user;
                sr[addr_user] <= 1'b1;
            end
            done <= next_done;
        end
    end

    assign next_addr_ref = (start || rst) ? 1 : find_next_sr_addr(addr_ref,sr);
    assign next_indicator_ref = (start || rst) ? 0 : sr[next_addr_ref];
    assign next_indicator_user = sr[addr_user]; 
    assign next_done = rst ? 1 : (start ? 0 : ((addr_ref == 127) ? 1 : done)); //Not Suspicius

    function [6:0] find_next_sr_addr;
        input [6:0] current_addr;
        input sr [0:127];
        integer i;
        integer flag;
        begin
            flag = 0;
            find_next_sr_addr = current_addr;
            for (i = 0; i < 128; i = i + 1) begin
                if(flag ==0) begin
                    if (find_next_sr_addr == 127)
                        find_next_sr_addr = 0;
                    else
                        find_next_sr_addr = find_next_sr_addr + 1;
                    
                    if (!sr[find_next_sr_addr]) begin
                        find_next_sr_addr = find_next_sr_addr;
                        flag = 1;
                    end
                end
            end
        end
    endfunction

endmodule

