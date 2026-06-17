`timescale 1ns / 1ps

module accumulator (
    input wire clk,
    input wire clr_n,
    input wire la_n,
    input wire ea,
    input wire [7:0] w_bus_in,
    output wire [7:0] w_bus_out,
    output wire [7:0] alu_out
);

    reg [7:0] reg_a;
    
    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            reg_a <= 8'h00;
        end else if (!la_n) begin
            reg_a <= w_bus_in;  
        end
    end
    
    assign w_bus_out = (ea) ? reg_a : 8'hZZ;
    assign alu_out = reg_a;
    
endmodule