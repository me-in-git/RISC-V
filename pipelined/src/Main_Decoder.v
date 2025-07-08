
module Main_Decoder(Op,RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp);
    input [6:0]Op;
    output reg RegWrite,ALUSrc,MemWrite,ResultSrc,Branch;
    output reg[1:0]ImmSrc,ALUOp;

    always @(*) begin
        // Default values to avoid latches
        RegWrite = 1'b0;
        ImmSrc = 2'b00;
        ALUSrc = 1'b0;
        MemWrite = 1'b0;
        ResultSrc = 1'b0;
        Branch = 1'b0;
        ALUOp = 2'b00;

        case (Op)
            7'b0000011: begin // Load instructions
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
                ResultSrc = 1'b1;
            end

            7'b0110011: begin // R-type instructions
                RegWrite = 1'b1;
                ALUOp = 2'b10;
            end

            7'b0010011: begin // I-type ALU instructions
                RegWrite = 1'b1;
                ALUSrc = 1'b1;
            end

            7'b0100011: begin // Store instructions
                ImmSrc = 2'b01;
                ALUSrc = 1'b1;
                MemWrite = 1'b1;
            end

            7'b1100011: begin // Branch instructions
                ImmSrc = 2'b10;
                Branch = 1'b1;
                ALUOp = 2'b01;
            end

            default: begin
                // Defaults are already set at the beginning
            end
        endcase
    end
endmodule