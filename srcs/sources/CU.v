module cu (
    input  wire        clk,
    input  wire        clr_n,
    input  wire [7:0]  opcode,
    input  wire        flag_s,
    input  wire        flag_z,
    input  wire [7:0]  w_bus_in,

    // Active-High Control Signals
    output reg         cpc, epc, ea, eu, et, eb, ec, e_bc, epc_hi, epc_lo, e_stack_ffff, e_stack_fffe,
    // Active-Low Control Signals
    output reg         lmar_n, lmdr_n, emdr_n, we_n, li_n, la_n, lf_n, lt_n, lb_n, lc_n, lo3_n, lo4_n, lpc_n, lpc_hi_n, lpc_lo_n,

    output reg  [3:0]  alu_op
);


    reg [4:0] t_state;
    reg state_reset;
    reg [7:0] target_port;

    always @(posedge clk or negedge clr_n) begin
        if (!clr_n) begin
            t_state     <= 5'd1;
            target_port <= 8'h00;
        end else if (state_reset) begin
            t_state     <= 5'd1;
        end else begin
            t_state     <= t_state + 5'd1;
        end
    end

    // Data Transfer
    localparam MOV_A_B = 8'h78; localparam MOV_A_C = 8'h79;
    localparam MOV_B_A = 8'h47; localparam MOV_B_C = 8'h41;
    localparam MOV_C_A = 8'h4F; localparam MOV_C_B = 8'h48;
    localparam MVI_A   = 8'h3E; localparam MVI_B   = 8'h06; localparam MVI_C   = 8'h0E;
    localparam LDA     = 8'h3A; localparam STA     = 8'h32;
    // Arithmetic
    localparam ADD_B   = 8'h80; localparam ADD_C   = 8'h81;
    localparam SUB_B   = 8'h90; localparam SUB_C   = 8'h91;
    localparam INR_A   = 8'h3C; localparam INR_B   = 8'h04; localparam INR_C   = 8'h0C;
    localparam DCR_A   = 8'h3D; localparam DCR_B   = 8'h05; localparam DCR_C   = 8'h0D;
    // Logical & Rotate
    localparam ANA_B   = 8'hA0; localparam ANA_C   = 8'hA1; localparam ANI     = 8'hE6;
    localparam ORA_B   = 8'hB0; localparam ORA_C   = 8'hB1; localparam ORI     = 8'hF6;
    localparam XRA_B   = 8'hA8; localparam XRA_C   = 8'hA9; localparam XRI     = 8'hEE;
    localparam CMA     = 8'h2F; localparam RAL     = 8'h17; localparam RAR     = 8'h1F;
    // Branching
    localparam JMP     = 8'hC3; localparam JM      = 8'hFA;
    localparam JNZ     = 8'hC2; localparam JZ      = 8'hCA;
    localparam CALL    = 8'hCD; localparam RET     = 8'hC9;
    // Control & I/O
    localparam IN      = 8'hDB; localparam OUT     = 8'hD3;
    localparam NOP     = 8'h00; localparam HLT     = 8'h76;

    always @(*) begin
    
        state_reset = 0;
        
        cpc = 0; epc = 0; ea = 0; eu = 0; et = 0; eb = 0; ec = 0; e_bc = 0;
        lmar_n = 1; lmdr_n = 1; emdr_n = 1; we_n = 1; li_n = 1; la_n = 1; 
        lf_n = 1; lt_n   = 1; lb_n   = 1; lc_n = 1; lo3_n = 1; lo4_n = 1; lpc_n = 1;
        alu_op = 4'b0000;
        epc_hi = 0; epc_lo = 0; e_stack_ffff = 0; e_stack_fffe = 0;
        lpc_hi_n = 1; lpc_lo_n = 1;

        case (t_state)
            5'd1: begin
                epc   = 1;
                lmar_n = 0;
            end
            5'd2: begin
                cpc   = 1;
            end
            5'd3: begin
                emdr_n = 0;
                li_n   = 0;
            end

            default: begin
                case (opcode)

                    // === NOP & HLT CONTROL ===
                    NOP: begin
                        if (t_state == 5'd4) state_reset = 1;
                    end
                    HLT: begin
                        t_state <= 5'd4; 
                    end

                    // === REG-TO-REG DATA TRANSFERS ===
                    MOV_A_B: begin
                        if (t_state == 5'd4) begin eb = 1; la_n = 0; state_reset = 1; end
                    end
                    MOV_A_C: begin
                        if (t_state == 5'd4) begin ec = 1; la_n = 0; state_reset = 1; end
                    end
                    MOV_B_A: begin
                        if (t_state == 5'd4) begin ea = 1; lb_n = 0; state_reset = 1; end
                    end
                    MOV_B_C: begin
                        if (t_state == 5'd4) begin ec = 1; lb_n = 0; state_reset = 1; end
                    end
                    MOV_C_A: begin
                        if (t_state == 5'd4) begin ea = 1; lc_n = 0; state_reset = 1; end
                    end
                    MOV_C_B: begin
                        if (t_state == 5'd4) begin eb = 1; lc_n = 0; state_reset = 1; end
                    end

                    // === MOVE IMMEDIATE OPERATIONS (2 BYTES) ===
                    MVI_A: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; la_n = 0; state_reset = 1; end
                    end
                    MVI_B: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; lb_n = 0; state_reset = 1; end
                    end
                    MVI_C: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; lc_n = 0; state_reset = 1; end
                    end

                    // === DIRECT MEMORY ACCESSION (3 BYTES) ===
                    LDA: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; lc_n = 0; end // Temporarily track low byte in C
                        if (t_state == 5'd7) begin epc = 1; lmar_n = 0; end // Fetch high address byte
                        if (t_state == 5'd8) begin cpc = 1; end
                        if (t_state == 5'd9) begin emdr_n = 0; lb_n = 0; end // Temporarily track high byte in B
                        if (t_state == 5'd10) begin e_bc = 1; lmar_n = 0; end // Output full 16-bit address to MAR
                        if (t_state == 5'd11) begin emdr_n = 0; la_n = 0; state_reset = 1; end // Read payload to A
                    end
                    STA: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; lc_n = 0; end 
                        if (t_state == 5'd7) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd8) begin cpc = 1; end
                        if (t_state == 5'd9) begin emdr_n = 0; lb_n = 0; end 
                        if (t_state == 5'd10) begin e_bc = 1; lmar_n = 0; end // Point MAR to destination target
                        if (t_state == 5'd11) begin ea = 1; lmdr_n = 0; end       // Stage data from A into MDR
                        if (t_state == 5'd12) begin we_n = 0; state_reset = 1; end // Pulse hardware RAM write enable
                    end

                    // === ARITHMETIC REGISTER OPERATIONS ===
                    ADD_B: begin
                        if (t_state == 5'd4) begin eb = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0000; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    ADD_C: begin
                        if (t_state == 5'd4) begin ec = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0000; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    SUB_B: begin
                        if (t_state == 5'd4) begin eb = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0001; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    SUB_C: begin
                        if (t_state == 5'd4) begin ec = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0001; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end

                    // === INCREMENT / DECREMENT MODES (ALU FIX) ===
                    INR_A: begin
                        if (t_state == 5'd4) begin ea = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b1000; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    INR_B: begin
                        if (t_state == 5'd4) begin eb = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b1000; eu = 1; lb_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    INR_C: begin
                        if (t_state == 5'd4) begin ec = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b1000; eu = 1; lc_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    DCR_A: begin
                        if (t_state == 5'd4) begin ea = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b1001; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    DCR_B: begin
                        if (t_state == 5'd4) begin eb = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b1001; eu = 1; lb_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    DCR_C: begin
                        if (t_state == 5'd4) begin ec = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b1001; eu = 1; lc_n = 0; lf_n = 0; state_reset = 1; end
                    end

                    // === LOGICAL REGISTER MATH ===
                    ANA_B: begin
                        if (t_state == 5'd4) begin eb = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0010; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    ANA_C: begin
                        if (t_state == 5'd4) begin ec = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0010; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    ORA_B: begin
                        if (t_state == 5'd4) begin eb = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0011; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    ORA_C: begin
                        if (t_state == 5'd4) begin ec = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0011; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    XRA_B: begin
                        if (t_state == 5'd4) begin eb = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0100; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    XRA_C: begin
                        if (t_state == 5'd4) begin ec = 1; lt_n = 0; end
                        if (t_state == 5'd5) begin alu_op = 4'b0100; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end

                    // === LOGICAL LOGIC IMMEDIATE OPERATIONS ===
                    ANI: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; lt_n = 0; end
                        if (t_state == 5'd7) begin alu_op = 4'b0010; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    ORI: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; lt_n = 0; end
                        if (t_state == 5'd7) begin alu_op = 4'b0011; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end
                    XRI: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; lt_n = 0; end
                        if (t_state == 5'd7) begin alu_op = 4'b0100; eu = 1; la_n = 0; lf_n = 0; state_reset = 1; end
                    end

                    // === ACCUMULATOR ONLY ACCELERATION ===
                    CMA: begin
                        if (t_state == 5'd4) begin alu_op = 4'b0101; eu = 1; la_n = 0; state_reset = 1; end
                    end
                    RAL: begin
                        if (t_state == 5'd4) begin alu_op = 4'b0110; eu = 1; la_n = 0; state_reset = 1; end
                    end
                    RAR: begin
                        if (t_state == 5'd4) begin alu_op = 4'b0111; eu = 1; la_n = 0; state_reset = 1; end
                    end

                    // === CONTROL FLOW & HARDWIRED JUMPS ===
                    JMP: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; lc_n = 0; end 
                        if (t_state == 5'd7) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd8) begin cpc = 1; end
                        if (t_state == 5'd9) begin emdr_n = 0; lb_n = 0; end 
                        if (t_state == 5'd10) begin e_bc = 1; lpc_n = 0; state_reset = 1; end // Latch 16-bit jump
                    end
                    JZ: begin
                        if (flag_z == 1'b0) begin
                            // Condition Failed: Quick skip past target address bytes
                            if (t_state == 5'd4) begin cpc = 1; end
                            if (t_state == 5'd5) begin cpc = 1; state_reset = 1; end
                        end else begin
                            // Condition Passed: Standard 16-bit processing
                            if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                            if (t_state == 5'd5) begin cpc = 1; end
                            if (t_state == 5'd6) begin emdr_n = 0; lc_n = 0; end
                            if (t_state == 5'd7) begin epc = 1; lmar_n = 0; end
                            if (t_state == 5'd8) begin cpc = 1; end
                            if (t_state == 5'd9) begin emdr_n = 0; lb_n = 0; end
                            if (t_state == 5'd10) begin e_bc = 1; lpc_n = 0; state_reset = 1; end
                        end
                    end
                    JNZ: begin
                        if (flag_z == 1'b1) begin
                            if (t_state == 5'd4) begin cpc = 1; end
                            if (t_state == 5'd5) begin cpc = 1; state_reset = 1; end
                        end else begin
                            if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                            if (t_state == 5'd5) begin cpc = 1; end
                            if (t_state == 5'd6) begin emdr_n = 0; lc_n = 0; end
                            if (t_state == 5'd7) begin epc = 1; lmar_n = 0; end
                            if (t_state == 5'd8) begin cpc = 1; end
                            if (t_state == 5'd9) begin emdr_n = 0; lb_n = 0; end
                            if (t_state == 5'd10) begin e_bc = 1; lpc_n = 0; state_reset = 1; end
                        end
                    end
                    JM: begin
                        if (flag_s == 1'b0) begin
                            if (t_state == 5'd4) begin cpc = 1; end
                            if (t_state == 5'd5) begin cpc = 1; state_reset = 1; end
                        end else begin
                            if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                            if (t_state == 5'd5) begin cpc = 1; end
                            if (t_state == 5'd6) begin emdr_n = 0; lc_n = 0; end
                            if (t_state == 5'd7) begin epc = 1; lmar_n = 0; end
                            if (t_state == 5'd8) begin cpc = 1; end
                            if (t_state == 5'd9) begin emdr_n = 0; lb_n = 0; end
                            if (t_state == 5'd10) begin e_bc = 1; lpc_n = 0; state_reset = 1; end
                        end
                    end

                    // === SUBROUTINE EXECUTION SKELETON ===
                    CALL: begin
                        if (t_state == 5'd4)  begin epc = 1; lmar_n = 0; end          // Fetch LowAddr
                        if (t_state == 5'd5)  begin cpc = 1; end
                        if (t_state == 5'd6)  begin emdr_n = 0; lc_n = 0; end        // Save to C
                        if (t_state == 5'd7)  begin epc = 1; lmar_n = 0; end          // Fetch HighAddr
                        if (t_state == 5'd8)  begin cpc = 1; end                      // PC is now at Return Addr
                        if (t_state == 5'd9)  begin emdr_n = 0; lb_n = 0; end        // Save to B
                        
                        if (t_state == 5'd10) begin e_stack_ffff = 1; lmar_n = 0; end // MAR = FFFF
                        if (t_state == 5'd11) begin epc_hi = 1; lmdr_n = 0; end       // MDR = PC High
                        if (t_state == 5'd12) begin we_n = 0; end                     // Write RAM
                        
                        if (t_state == 5'd13) begin e_stack_fffe = 1; lmar_n = 0; end // MAR = FFFE
                        if (t_state == 5'd14) begin epc_lo = 1; lmdr_n = 0; end       // MDR = PC Low
                        if (t_state == 5'd15) begin we_n = 0; end                     // Write RAM
                        
                        if (t_state == 5'd16) begin e_bc = 1; lpc_n = 0; state_reset = 1; end // Jump
                    end
                    
                    RET: begin
                        if (t_state == 5'd4) begin e_stack_fffe = 1; lmar_n = 0; end // MAR = FFFE
                        if (t_state == 5'd5) begin emdr_n = 0; lpc_lo_n = 0; end     // PC Low = RAM[FFFE]
                        if (t_state == 5'd6) begin e_stack_ffff = 1; lmar_n = 0; end // MAR = FFFF
                        if (t_state == 5'd7) begin emdr_n = 0; lpc_hi_n = 0; state_reset = 1; end // PC High = RAM[FFFF]
                    end

                    // === PERIPHERAL INPUT/OUTPUT PROCESSING ===
                    OUT: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; target_port <= w_bus_in; end
                        if (t_state == 5'd7) begin 
                            ea = 1; // Force current Accumulator value onto bus highway
                            if (target_port == 8'h03)      lo3_n = 0;
                            else if (target_port == 8'h04) lo4_n = 0;
                            state_reset = 1;
                        end
                    end
                    IN: begin
                        if (t_state == 5'd4) begin epc = 1; lmar_n = 0; end
                        if (t_state == 5'd5) begin cpc = 1; end
                        if (t_state == 5'd6) begin emdr_n = 0; target_port <= w_bus_in; end
                        if (t_state == 5'd7) begin
                            la_n = 0;
                            state_reset = 1;
                        end
                    end

                    default: state_reset = 1;
                endcase
            end
        endcase
    end

endmodule