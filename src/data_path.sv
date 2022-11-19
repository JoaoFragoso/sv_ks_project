module data_path
import k_and_s_pkg::*;
(
    input  logic                    rst_n,
    input  logic                    clk,
    input  logic                    branch,
    input  logic                    pc_enable,
    input  logic                    ir_enable,
    input  logic                    addr_sel,
    input  logic                    c_sel,
    input  logic              [1:0] operation,
    input  logic                    write_reg_enable,
    input  logic                    flags_reg_enable,
    output decoded_instruction_type decoded_instruction,
    output logic                    zero_op,
    output logic                    neg_op,
    output logic                    unsigned_overflow,
    output logic                    signed_overflow,
    output logic              [4:0] ram_addr,
    output logic             [15:0] data_out,
    input  logic             [15:0] data_in

);

logic [4:0] mem_addr;
logic [4:0] program_counter;
logic [15:0] bus_a;
logic [15:0] bus_b;
logic [15:0] bus_c;
logic [15:0] instruction;
logic [1:0] a_addr;
logic [1:0] b_addr;
logic [1:0] c_addr;
logic [15:0] alu_out;
logic zero_f;
logic neg_f;
logic ov_f;
logic sov_f;
logic carry_in_ultimo_bit;

always_ff @(posedge clk) begin : ir_ctrl
    if (ir_enable)
        instruction <= data_in;
end

always_ff @(posedge clk) begin : pc_ctrl
    if (pc_enable) begin
        if (branch)
            program_counter <= mem_addr;
        else
            program_counter <= program_counter + 1;
    end
end

always_comb begin : ula_ctrl
    case(operation)
        2'b00: begin // soma
           {carry_in_ultimo_bit,alu_out[14:0]} = bus_a[14:0] + bus_b[14:0];
           {ov_f, alu_out[15]} = bus_a[15]+bus_b[15]+carry_in_ultimo_bit;
           sov_f = ov_f ^ carry_in_ultimo_bit;
        end
        2'b01: begin //and
            alu_out = bus_a & bus_b;
            ov_f = 1'b0;
            sov_f = 1'b0;
            carry_in_ultimo_bit = 1'b0;
        end
        2'b10: begin //or
            alu_out = bus_a | bus_b;
            ov_f = 1'b0;
            sov_f = 1'b0;
            carry_in_ultimo_bit = 1'b0;
        end
        default: begin //sub
        end
    endcase
end

assign zero_f = ~|(alu_out); //reducao em NOR
assign neg_f = alu_out[15];  // bit sinal

endmodule : data_path
