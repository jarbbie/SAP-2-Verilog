`timescale 1ns / 1ps

module flags (
    input wire clk,
    input wire clr_n,
    input wire lf_n,
    input wire [1:0] flags_in,
    output reg flag_s,
    output reg flag_z
);

    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            flag_s <= 1'b0;
            flag_z <= 1'b0;
        end 
        else if (!lf_n) begin
            flag_s <= flags_in[1];
            flag_z <= flags_in[0];
        end
    end

endmodule