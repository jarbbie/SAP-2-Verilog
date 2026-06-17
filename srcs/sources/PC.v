`timescale 1ns / 1ps

module pc (
    input wire clk,
    input wire clr_n,
    input wire cpc,
    input wire lpc_n,
    input wire epc,
    input wire [15:0] w_bus_in,
    output wire [15:0] w_bus_out,
    
    // Three-states added for CALL & RET
    input wire lpc_hi_n, // Load high byte
    input wire lpc_lo_n, // Load low byte
    input wire epc_hi,   // Dump high byte
    input wire epc_lo   // Dump low byte
    );
    
    reg [15:0] pc_reg;
    
    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            pc_reg <= 16'h0000;
        end else if (!lpc_n) begin
            pc_reg <= w_bus_in;
        end else if (!lpc_hi_n) begin
            pc_reg[15:8] <= w_bus_in[7:0];
        end else if (!lpc_lo_n) begin
            pc_reg[7:0] <= w_bus_in[7:0];
        end else if (cpc) begin
            pc_reg <= pc_reg + 16'h0001;
        end
    end
    
    assign w_bus_out = (epc) ? pc_reg :
                       (epc_hi) ? pc_reg[15:8] :
                       (epc_lo) ? pc_reg[7:0] : 16'hZZZZ;
    
endmodule
