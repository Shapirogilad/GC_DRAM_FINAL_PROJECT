module REF_MEM_COUNTER (
    input wire clk,
    input wire rst,
    input wire any_ref_done,
    output reg [2:0] ref_mem_addr_o,
    output wire cycle_done
);

    wire [2:0] ref_mem_addr; 
    wire [2:0] next_counter;
    reg [2:0] counter;

    always_ff @(posedge clk or posedge rst) begin 
        if(rst) begin
            ref_mem_addr_o <= 7;
            counter <= 7;
        end
        else begin
            ref_mem_addr_o <= ref_mem_addr;
            counter <= next_counter;
        end
    end

    assign ref_mem_addr = rst ? 7 : ((any_ref_done) ? ((ref_mem_addr_o == 0) ? 7 : (ref_mem_addr_o - 1)) : (ref_mem_addr_o));
    assign next_counter = rst ? 7 : ((any_ref_done) ? ((counter  == 1) ? 7 : (counter - 1)) : counter);
    assign cycle_done = rst ? 0 : ((any_ref_done && counter == 1) ? 1 : 0);
    
    
endmodule