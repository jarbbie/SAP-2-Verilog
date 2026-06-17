`timescale 1ns / 1ps

module mar(
    input wire clk,
    input wire clr_n,
    input wire lmar_n,
    input wire [15:0] w_bus_in,
    output reg [15:0] mem_addr
    );
    
    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            mem_addr <= 16'h0000;
        end else if (!lmar_n) begin
            mem_addr <= w_bus_in;
        end
    end
    
endmodule
