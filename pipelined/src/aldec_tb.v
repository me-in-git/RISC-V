module ALU_Decoder_tb;

    // Inputs
    reg [1:0] ALUOp;
    reg [2:0] funct3;
    reg [6:0] funct7, op;
    
    // Output
    wire [2:0] ALUControl;
    
    // Instantiate the Unit Under Test (UUT)
    ALU_Decoder uut (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .op(op),
        .ALUControl(ALUControl)
    );
    
    initial begin
        // Test Case 1: ALUOp = 2'b00 (Load/Store: ADD)
        ALUOp = 2'b00;
        funct3 = 3'bxxx;
        op = 7'hxx;
        funct7 = 7'hxx;
        #10;
        $display("Test 1: ALUOp=00 | ALUControl=%b (Expected: 000)", ALUControl);
        
        // Test Case 2: ALUOp = 2'b01 (Branch: SUB)
        ALUOp = 2'b01;
        #10;
        $display("Test 2: ALUOp=01 | ALUControl=%b (Expected: 001)", ALUControl);
        
        // Test Case 3a: ALUOp=10, funct3=000, R-type SUB (op=0110011, funct7=0100000)
        ALUOp = 2'b10;
        funct3 = 3'b000;
        op = 7'b0110011;  // R-type (op[5] = 1)
        funct7 = 7'b0100000;  // funct7[5] = 1
        #10;
        $display("Test 3a: ALUOp=10, funct3=000, R-SUB | ALUControl=%b (Expected: 001)", ALUControl);
        
        // Test Case 3b: ALUOp=10, funct3=000, R-type ADD (op=0110011, funct7=0000000)
        funct7 = 7'b0000000;  // funct7[5] = 0
        #10;
        $display("Test 3b: ALUOp=10, funct3=000, R-ADD | ALUControl=%b (Expected: 000)", ALUControl);
        
        // Test Case 3c: ALUOp=10, funct3=000, I-type (op=0010011, funct7=xxxxxxx)
        op = 7'b0010011;  // I-type (op[5] = 0)
        funct7 = 7'b1010101;  // funct7[5] = 1 (ignored)
        #10;
        $display("Test 3c: ALUOp=10, funct3=000, I-ADD | ALUControl=%b (Expected: 000)", ALUControl);
        
        // Test Case 4: ALUOp=10, funct3=010 (SLT)
        funct3 = 3'b010;
        #10;
        $display("Test 4: ALUOp=10, funct3=010 | ALUControl=%b (Expected: 101)", ALUControl);
        
        // Test Case 5: ALUOp=10, funct3=110 (OR)
        funct3 = 3'b110;
        #10;
        $display("Test 5: ALUOp=10, funct3=110 | ALUControl=%b (Expected: 011)", ALUControl);
        
        // Test Case 6: ALUOp=10, funct3=111 (AND)
        funct3 = 3'b111;
        #10;
        $display("Test 6: ALUOp=10, funct3=111 | ALUControl=%b (Expected: 010)", ALUControl);
        
        // Test Case 7: ALUOp=10, funct3=001 (Unhandled, default to ADD)
        funct3 = 3'b001;
        #10;
        $display("Test 7: ALUOp=10, funct3=001 | ALUControl=%b (Expected: 000)", ALUControl);
        
        // Test Case 8: ALUOp=2'b11 (Invalid, default to ADD)
        ALUOp = 2'b11;
        #10;
        $display("Test 8: ALUOp=11 | ALUControl=%b (Expected: 000)", ALUControl);
        
        $finish;
    end
    
endmodule