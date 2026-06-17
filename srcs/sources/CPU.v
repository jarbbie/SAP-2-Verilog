`timescale 1ns / 1ps

module cpu (
    input wire clk,
    input wire clr_n,
    output wire [7:0] hex_display
);

    wire [15:0] w_bus;

    wire cpc, epc, lmar_n, lmdr_n, emdr_n, we_n, li_n;
    wire la_n, ea, eu, lf_n, lt_n, et, lb_n, eb, lc_n, ec, e_bc;
    wire [7:0] b_val, c_val;
    wire lo3_n, lo4_n, lpc_n;
    wire [3:0] alu_op;
    wire lpc_hi_n, lpc_lo_n, epc_hi, epc_lo;
    wire e_stack_ffff, e_stack_fffe;

    // Hardwired connection
    wire [15:0] mar_to_ram;       // MAR -> RAM
    wire [7:0]  ram_to_mdr;       // RAM -> MDR
    wire [7:0]  mdr_to_ram;       // MDR -> RAM
    wire [7:0]  a_to_alu;         // A -> ALU
    wire [7:0]  tmp_to_alu;       // TMP -> ALU
    wire [1:0]  alu_to_flags;     // ALU -> FLAGS
    wire        flag_s, flag_z;   // FLAGS -> CU
    wire [7:0]  ir_to_cu;         // IR -> CU
    wire [7:0]  port4_out;        // Unused, wired for expansion

    
    pc PROGRAM_COUNTER (
        .clk(clk), .clr_n(clr_n), .cpc(cpc), .epc(epc), .lpc_n(lpc_n),
        .lpc_hi_n(lpc_hi_n), .lpc_lo_n(lpc_lo_n), .epc_hi(epc_hi), .epc_lo(epc_lo),
        .w_bus_in(w_bus), .w_bus_out(w_bus)
    );

    mar MEM_ADDR_REG (
        .clk(clk), .clr_n(clr_n), .lmar_n(lmar_n),
        .w_bus_in(w_bus), .mem_addr(mar_to_ram)
    );

    memory SYSTEM_RAM (
        .clk(clk), .we_n(we_n), .addr(mar_to_ram),
        .data_in(mdr_to_ram), .data_out(ram_to_mdr)
    );

    mdr MEM_DATA_REG (
        .clk(clk), .clr_n(clr_n), .lmdr_n(lmdr_n), .emdr_n(emdr_n),
        .w_bus_in(w_bus[7:0]), .w_bus_out(w_bus[7:0]),
        .ram_data_out(ram_to_mdr), .ram_data_in(mdr_to_ram)
    );

    ir INSTRUCTION_REG (
        .clk(clk), .clr_n(clr_n), .li_n(li_n),
        .w_bus_in(w_bus[7:0]), .opcode_out(ir_to_cu)
    );

    accumulator REG_A (
        .clk(clk), .clr_n(clr_n), .la_n(la_n), .ea(ea),
        .w_bus_in(w_bus[7:0]), .w_bus_out(w_bus[7:0]), .alu_out(a_to_alu)
    );

    tmp_register REG_TMP (
        .clk(clk), .clr_n(clr_n), .lt_n(lt_n), .et(et),
        .w_bus_in(w_bus[7:0]), .w_bus_out(w_bus[7:0]), .alu_out(tmp_to_alu)
    );

    alu MATH_ENGINE (
        .alu_op(alu_op), .a_in(a_to_alu), .tmp_in(tmp_to_alu), .eu(eu),
        .w_bus_out(w_bus[7:0]), .flags_out(alu_to_flags)
    );

    flags STATUS_FLAGS (
        .clk(clk), .clr_n(clr_n), .lf_n(lf_n),
        .flags_in(alu_to_flags), .flag_s(flag_s), .flag_z(flag_z)
    );

    gpr REG_B (
        .clk(clk), .clr_n(clr_n), .load_n(lb_n), .enable(eb),
        .w_bus_in(w_bus[7:0]), .w_bus_out(w_bus[7:0]), .reg_val(b_val)
    );

    gpr REG_C (
        .clk(clk), .clr_n(clr_n), .load_n(lc_n), .enable(ec),
        .w_bus_in(w_bus[7:0]), .w_bus_out(w_bus[7:0]), .reg_val(c_val)
    );

    output_port PORT_3 (
        .clk(clk), .clr_n(clr_n), .load_n(lo3_n),
        .w_bus_in(w_bus[7:0]), .port_out(hex_display)
    );

    output_port PORT_4 (
        .clk(clk), .clr_n(clr_n), .load_n(lo4_n),
        .w_bus_in(w_bus[7:0]), .port_out(port4_out)
    );

    cu CONTROL_UNIT (
        .clk(clk), .clr_n(clr_n),   
        .opcode(ir_to_cu), .flag_s(flag_s), .flag_z(flag_z),
        .w_bus_in(w_bus[7:0]), 
        .cpc(cpc), .epc(epc), .lmar_n(lmar_n), .lmdr_n(lmdr_n), .emdr_n(emdr_n), .we_n(we_n),
        .li_n(li_n), .la_n(la_n), .ea(ea), .eu(eu), .lf_n(lf_n), .lt_n(lt_n), .et(et),
        .lb_n(lb_n), .eb(eb), .lc_n(lc_n), .ec(ec), .e_bc(e_bc), .lo3_n(lo3_n), .lo4_n(lo4_n), .lpc_n(lpc_n),
        .alu_op(alu_op),
        .epc_hi(epc_hi), .epc_lo(epc_lo), .e_stack_ffff(e_stack_ffff), .e_stack_fffe(e_stack_fffe),
        .lpc_hi_n(lpc_hi_n), .lpc_lo_n(lpc_lo_n)

    );
    
    assign w_bus = (e_bc) ? {b_val, c_val} : 16'hZZZZ;
    
    assign w_bus = (e_bc)         ? {b_val, c_val} : 
                   (e_stack_ffff) ? 16'hFFFF :
                   (e_stack_fffe) ? 16'hFFFE : 16'hZZZZ;

endmodule
