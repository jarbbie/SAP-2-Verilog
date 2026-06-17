`timescale 1ns / 1ps

module gpr (
    input  wire       clk,
    input  wire       clr_n,
    input  wire       load_n,
    input  wire       enable,
    input  wire [7:0] w_bus_in,
    output wire [7:0] w_bus_out,
    output wire [7:0] reg_val
);

    reg [7:0] data;
    
    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            data <= 8'h00;
        end else if (!load_n) begin
            data <= w_bus_in;
        end
    end
    
    assign w_bus_out = (enable) ? data : 8'hZZ;
    assign reg_val = data;
    
endmodule