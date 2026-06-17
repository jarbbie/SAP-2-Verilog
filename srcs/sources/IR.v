`timescale 1ns / 1ps

module ir (
    input wire clk,
    input wire clr_n,
    input wire li_n,
    input wire [7:0] w_bus_in,
    output reg [7:0] opcode_out
    );
    
    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            opcode_out <= 8'h00;
        end else if (!li_n) begin
            opcode_out <= w_bus_in;
        end
    end
    
endmodule
