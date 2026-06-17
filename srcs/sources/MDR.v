`timescale 1ns / 1ps

module mdr (
    input wire clk,
    input wire clr_n,
    input wire lmdr_n,
    input wire emdr_n,
    input wire [7:0] ram_data_out,
    input wire [7:0] w_bus_in,
    output wire [7:0] ram_data_in,
    output wire [7:0] w_bus_out
    );
    
    reg [7:0] mdr_reg;
    
    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            mdr_reg <= 8'h00;
        end else if (!lmdr_n) begin
            mdr_reg <= w_bus_in;
        end
    end
    
    assign ram_data_in = mdr_reg;
    assign w_bus_out = (!emdr_n) ? ram_data_out : 8'hZZ;
    
endmodule
