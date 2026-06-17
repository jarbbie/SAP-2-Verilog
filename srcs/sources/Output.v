`timescale 1ns / 1ps

module output_port(
    input wire clk,
    input wire clr_n,
    input wire load_n,
    input wire [7:0] w_bus_in,
    output reg [7:0] port_out
    );
    
    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            port_out <= 8'h00;
        end else if (!load_n) begin
            port_out <= w_bus_in;
        end
    end
    
endmodule
