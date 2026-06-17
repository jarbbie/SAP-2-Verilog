`timescale 1ns / 1ps

module memory (
    input wire clk,
    input wire we_n,
    input wire [15:0] addr,
    input wire [7:0] data_in,
    output wire [7:0] data_out
    );
    
    reg [7:0] ram [0:65535]; // 2 bytes -> 16 bits -> 2^16 = 65536
    integer i;
    
    initial begin
        // Overwrite XX unknown states with 0s
        for (i = 0; i < 65535; i = i + 1) begin
            ram[i] = 8'h00;
        end
        
        $readmemh("program.mem", ram);
    end
    
    always @(posedge clk) begin
        if (!we_n) begin
            ram[addr] = data_in;
        end
    end
    
    assign data_out = ram[addr];
    
endmodule
