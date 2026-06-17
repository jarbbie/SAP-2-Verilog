`timescale 1ns / 1ps

module tmp_register (
    input wire clk,
    input wire clr_n,
    input wire lt_n,
    input wire et,
    input wire [7:0] w_bus_in,
    output wire [7:0] w_bus_out,
    output wire [7:0] alu_out
    );
    
    reg [7:0] reg_tmp;
    
    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            reg_tmp <= 8'h00;
        end else if (!lt_n) begin
            reg_tmp <= w_bus_in;
        end
    end
    
    assign w_bus_out = (et) ? reg_tmp : 8'hZZ;
    assign alu_out = reg_tmp;
    
endmodule
