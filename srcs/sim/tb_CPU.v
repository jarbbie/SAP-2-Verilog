`timescale 1ns / 1ps

module tb_CPU();

    reg clk;
    reg clr_n;

    wire [7:0] hex_display;

    cpu UUT (
        .clk(clk),
        .clr_n(clr_n),
        .hex_display(hex_display)
    );

    always begin
        #10 clk = ~clk; 
    end

    initial begin
        clk = 0;
        clr_n = 0;
        
        $display("Powering on SAP-2 CPU...");
        
        #50;
        
        clr_n = 1;
        $display("Reset released. CPU executing program...");

        // Configure this if CPU isn't run long enough
        #100000; 
        
        $display("Simulation complete.");
        $finish; 
    end

    always @(hex_display) begin
        if (hex_display !== 8'hZZ && hex_display !== 8'hXX) begin
            $display("Time: %0t ns | Port 3 (Hex Display) updated to: %h", $time, hex_display);
        end
    end

endmodule