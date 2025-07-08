
module ALU_Decoder(ALUOp,funct3,funct7,op,ALUControl);

    input [1:0]ALUOp;
    input [2:0]funct3;
    input [6:0]funct7,op;
    output reg [2:0] ALUControl;

     always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000; // Default for ALUOp = 00 (ld, sd, etc.)
            2'b01: ALUControl = 3'b001; // Default for ALUOp = 01 (Branch)
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        if ({op[5], funct7[5]} == 2'b11)
                            ALUControl = 3'b001; // SUB
                        else
                            ALUControl = 3'b000; // ADD
                    end
                    3'b110: ALUControl = 3'b011; // OR
                    3'b111: ALUControl = 3'b010; // AND
                    default: ALUControl = 3'b000; // Default for unsupported funct3
                endcase
            end
            default: ALUControl = 3'b000; // Default for unsupported ALUOp
        endcase
    end                                                             
endmodule