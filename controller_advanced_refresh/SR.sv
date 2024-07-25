//reconsider the SR
module SR (
    input wire rst,
    input wire clk,
    input wire pause,//check if needed
    input wire [6:0] user_addr,
    output wire indicator,// check if there is a clock delay between the user_addr and indicator
    output reg [6:0] addr,
    output reg done
);
    reg sr [0:127];
    reg [6:0] sr_addr;
    wire [6:0] next_sr_addr;
    wire [6:0] next_addr;
    wire next_done;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            sr <= {(128){0}};
        end
        else if(pause) begin
            sr[user_addr] <= 1;
        end
        else
            sr[sr_addr] <= 1;
    end

    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            sr_addr <= 0;
            done <= 0;
            addr <= 0;
        end
        else begin
            sr_addr <= next_sr_addr;
            addr <= next_addr;
            done <= next_done;
        end
    end

    assign next_sr_addr = rst ? 0 : (pause ? sr_addr : find_next_sr_addr(sr_addr));
    assign indicator = sr[addr];
    assign next_addr = pause ? user_addr : sr_addr;
    assign next_done = (addr+1 == 128) ? 1 : done; //Suspicius
    function [6:0] find_next_sr_addr;
        input [6:0] current_addr;
        integer i;
        begin
            find_next_sr_addr = current_addr;
            for (i = 0; i < 128; i = i + 1) begin
                find_next_sr_addr = find_next_sr_addr + 1;
                if (!sr[find_next_sr_addr]) begin
                    find_next_sr_addr = find_next_sr_addr;
                    break;
                end
            end
        end
    endfunction

endmodule

