`timescale 1ns / 1ps

module alu (
    input wire [3:0] alu_op,
    input wire [7:0] a_in,
    input wire [7:0] tmp_in,
    input wire eu,
    output wire [7:0] w_bus_out,
    output wire [1:0] flags_out
);

    reg [7:0] alu_result;
    
    always @(*) begin
        case (alu_op)
            4'b0000: alu_result = a_in + tmp_in; // ADD
            4'b0001: alu_result = a_in - tmp_in; // SUB
            4'b0010: alu_result = a_in & tmp_in; // ANA
            4'b0011: alu_result = a_in | tmp_in; // ORA
            4'b0100: alu_result = a_in ^ tmp_in; // XRA
            4'b0101: alu_result = ~a_in;                     // CMA
            4'b0110: alu_result = {a_in[6:0], a_in[7]};      // RAL
            4'b0111: alu_result = {a_in[0],   a_in[7:1]};    // RAR
            4'b1000: alu_result = tmp_in + 8'h01;            // INR
            4'b1001: alu_result = tmp_in - 8'h01;            // DCR

            default: alu_result = 8'h00;
        endcase
    end

    assign flags_out[1] = alu_result[7];
    assign flags_out[0] = (alu_result == 8'h00) ? 1 : 0;
    
    assign w_bus_out = (eu) ? alu_result : 8'hZZ;
    
endmodule
