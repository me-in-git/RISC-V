// ======================================================
// RISC-V Processor (Single-Cycle)
// ======================================================
module riscv_processor(
    input wire clk,
    input wire rst
);
    // Program Counter
    reg [31:0] pc;
    wire [31:0] next_pc;
    
    // Instruction Memory
    reg [31:0] instr_mem [0:1023];
    wire [31:0] instruction = instr_mem[pc >> 2];
    
    // Control Signals
    wire RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, Branch, Jump;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    
    // Control Unit
    control_unit control(
        .opcode(instruction[6:0]),
        .Branch(Branch),
        .Jump(Jump),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );
    
    // ALU Control
    alu_control alu_ctrl(
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .alu_control(ALUControl)
    );
    
    // Register File
    reg [31:0] registers [0:31];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd = instruction[11:7];
    wire [31:0] read_data1 = registers[rs1];
    wire [31:0] read_data2 = registers[rs2];
    
    // Immediate Generator
    wire [31:0] imm_gen;
    immediate_generator imm_gen_module(
        .instruction(instruction),
        .immediate(imm_gen)
    );
    
    // ALU
    wire [31:0] alu_in2 = ALUSrc ? imm_gen : read_data2;
    wire [31:0] alu_result;
    wire zero;
    alu my_alu(
        .a(read_data1),
        .b(alu_in2),
        .alu_control(ALUControl),
        .result(alu_result),
        .zero(zero)
    );
    
    // Branch Logic
    wire branch_taken;
    branch_decision branch_dec(
        .funct3(instruction[14:12]),
        .zero(zero),
        .branch(branch_taken)
    );
    
    // Next PC
    wire [31:0] branch_target = pc + imm_gen;
    wire [31:0] jump_target = pc + imm_gen;
    assign next_pc = Jump                ? jump_target :      // JAL/JALR
                 (Branch & branch_taken) ? branch_target : // Branches
                 pc + 4;                                   // Default

    
    // Data Memory
    reg [31:0] data_mem [0:1023];
    wire [31:0] mem_data = MemRead ? data_mem[alu_result >> 2] : 0;
    wire [31:0] write_data = MemtoReg ? mem_data : alu_result;
    
    // Update State
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            pc <= 0;
            for(integer i=0; i<32; i++) registers[i] <= 0;
        end else begin
            pc <= next_pc;
            if(RegWrite && rd != 0) registers[rd] <= write_data;
            if(MemWrite) data_mem[alu_result >> 2] <= read_data2;
        end
    end
endmodule

// ======================================================
// Control Unit
// ======================================================
module control_unit(
    input wire [6:0] opcode,
    output reg Branch, Jump,
    output reg RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc,
    output reg [1:0] ALUOp
);
    always @(*) begin
        RegWrite = 0; MemRead = 0; MemWrite = 0;
        MemtoReg = 0; ALUSrc = 0; ALUOp = 2'b00;
        Branch = 0; Jump = 0;
        
        case(opcode)
            7'b0110011: begin RegWrite=1; ALUOp=2'b10; end        // R-type
            7'b0010011: begin RegWrite=1; ALUSrc=1; ALUOp=2'b11; end // I-type
            7'b0000011: begin RegWrite=1; ALUSrc=1; MemRead=1; MemtoReg=1; end // Load
            7'b0100011: begin ALUSrc=1; MemWrite=1; end            // Store
            7'b1100011: begin Branch=1; ALUOp=2'b01; end           // Branch
7'b1101111: begin // JAL
                RegWrite = 1;
                Jump = 1;
                // Additional logic for JAL (see notes)
            end
            7'b1100111: begin // JALR
                RegWrite = 1;
                Jump = 1;
                ALUSrc = 1;
                ALUOp = 2'b00; // ADD for address calculation
            end
            default: ; 
        endcase
    end
endmodule

// ======================================================
// ALU Control
// ======================================================
module alu_control(
    input wire [1:0] ALUOp,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg [3:0] alu_control
);
    always @(*) begin
        case(ALUOp)
            2'b00: alu_control = 4'b0010; // ADD (for loads/stores/JALR)
            
            2'b01: begin // Branches (BEQ/BNE/BLT/etc)
                case(funct3)
                    3'b000: alu_control = 4'b0110; // BEQ/BNE: SUB
                    3'b100: alu_control = 4'b1000; // BLT: SLT
                    3'b101: alu_control = 4'b1001; // BGE: SLTU (inverted)
                    default: alu_control = 4'b0000;
                endcase
            end
            
            2'b10: begin // R-type
                case(funct3)
                    3'b000: alu_control = funct7[5] ? 4'b0110 : 4'b0010; // ADD/SUB
                    3'b001: alu_control = 4'b0100; // SLL
                    3'b010: alu_control = 4'b1000; // SLT
                    3'b011: alu_control = 4'b1001; // SLTU
                    3'b100: alu_control = 4'b0011; // XOR
                    3'b101: alu_control = funct7[5] ? 4'b0111 : 4'b0101; // SRL/SRA
                    3'b110: alu_control = 4'b0001; // OR
                    3'b111: alu_control = 4'b0000; // AND
                    default: alu_control = 4'b0000;
                endcase
            end
            
            2'b11: begin // I-type (immediate ops)
                case(funct3)
                    3'b000: alu_control = 4'b0010; // ADDI
                    3'b001: alu_control = 4'b0100; // SLLI
                    3'b010: alu_control = 4'b1000; // SLTI
                    3'b011: alu_control = 4'b1001; // SLTIU
                    3'b100: alu_control = 4'b0011; // XORI
                    3'b101: alu_control = funct7[5] ? 4'b0111 : 4'b0101; // SRLI/SRAI
                    3'b110: alu_control = 4'b0001; // ORI
                    3'b111: alu_control = 4'b0000; // ANDI
                    default: alu_control = 4'b0000;
                endcase
            end
            
            default: alu_control = 4'b0000;
        endcase
    end
endmodule

// ======================================================
// Immediate Generator
// ======================================================
module immediate_generator(
    input wire [31:0] instruction,
    output reg [31:0] immediate
);
    always @(*) begin
        case(instruction[6:0])
            7'b0010011,7'b0000011: // I-type
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: // S-type
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: // B-type
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], 
                           instruction[30:25], instruction[11:8], 1'b0};
 7'b1101111: // JAL (UJ-type)
                immediate = { {12{instruction[31]}}, instruction[31], instruction[19:12], 
                           instruction[20], instruction[30:21], 1'b0 };
            default: immediate = 0;
        endcase
    end
endmodule

// ======================================================
// Branch Decision
// ======================================================
module branch_decision(
    input wire [2:0] funct3,
    input wire zero,
    output reg branch
);
    always @(*) begin
        case(funct3)
            3'b000: branch = zero;   // BEQ
            3'b001: branch = ~zero;  // BNE
            default: branch = 0;
        endcase
    end
endmodule

// ======================================================
// ALU
// ======================================================
module alu(
    input wire [31:0] a, b,
    input wire [3:0] alu_control,
    output reg [31:0] result,
    output reg zero
);
    always @(*) begin
        case(alu_control)
           4'b0000: result = a & b;               // AND
            4'b0001: result = a | b;               // OR
            4'b0010: result = a + b;               // ADD
            4'b0011: result = a ^ b;               // XOR
            4'b0100: result = a << b[4:0];         // SLL
            4'b0101: result = a >> b[4:0];         // SRL (logical)
            4'b0110: result = b - a;               // SUB
            4'b0111: result = $signed(a) >>> b[4:0]; // SRA (arithmetic)
            4'b1000: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT
            4'b1001: result = (a < b) ? 1 : 0;     // SLTU
              
            default: result = 0;
        endcase
        zero = (result == 0);
    end
endmodule


