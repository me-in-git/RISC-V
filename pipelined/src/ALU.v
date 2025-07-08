
module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    wire w1, w2, w3;
    xor x1(w1, a, b);
    xor x2(sum, w1, cin);
    and a1(w2, a, b);
    and a2(w3, w1, cin);
    or o1(cout, w2, w3);
endmodule

module RippleCarryAdder (
    input wire [63:0] A,  // 64-bit input A
    input wire [63:0] B,  // 64-bit input B
    input wire Cin,       // Carry-in for the first full adder
    output wire [63:0] Sum, // 64-bit sum output
    output wire Cout      // Carry-out from the last full adder
);

    wire [63:0] Carry; // Internal carry signals between full adders

    // First full adder (bit 0)
    full_adder FA0 (
        .a(A[0]),
        .b(B[0]),
        .cin(Cin),
        .sum(Sum[0]),
        .cout(Carry[0])
    );

    // Generate full adders for bits 1 to 63
    genvar i;
    generate
        for (i = 1; i < 64; i = i + 1) begin : RCA
            full_adder FA0 (
                .a(A[i]),
                .b(B[i]),
                .cin(Carry[i-1]),
                .sum(Sum[i]),
                .cout(Carry[i])
            );
        end
    endgenerate

    // Final carry-out
    assign Cout = Carry[63];

endmodule

module subtractor64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] diff,
    output cout
);
    wire [63:0] not_b = ~b;
    RippleCarryAdder add(a, not_b, 1'b1, diff, cout);
endmodule

module and64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : and_loop
            and g(result[i], a[i], b[i]);
        end
    endgenerate
endmodule

module or64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
    genvar i;   
    generate
        for (i = 0; i < 64; i = i + 1) begin : or_loop
            or g(result[i], a[i], b[i]);
        end
    endgenerate
endmodule

module beq64(
    input [63:0] a,
    input [63:0] b,
    output [63:0] result
);
     wire [63:0] diff;
    wire cout; 

    subtractor64 sub_inst(
        .a(a),
        .b(b),
        .diff(diff),
        .cout(cout)
    );

    assign result = {63'b0, (diff == 64'b0)};
endmodule

module ALU(A,B,Result,ALUControl,OverFlow,Carry,Zero,Negative);

    input [63:0]A,B;
    input [2:0]ALUControl;
    output Carry,OverFlow,Zero,Negative;
    output reg [63:0]Result;

    wire Cout;
    
    parameter ADD  = 4'b0000;
    parameter SUB  = 4'b0001;
    parameter AND  = 4'b0100;
    parameter OR   = 4'b0101;
    parameter BEQ  = 4'b1010;

    wire [63:0] add_result, sub_result;
    wire [63:0] and_result, or_result;
    wire [63:0] beq_result;

    RippleCarryAdder add_inst(A, B, 1'b0, add_result, Cout);
    subtractor64 sub_inst(A, B, sub_result, );
    and64 and_inst(A, B, and_result);
    or64 or_inst(A, B, or_result);
    beq64 beq_inst(A, B, beq_result);

    always @(*) begin
        case(ALUControl)
            ADD:  Result = add_result;
            SUB:  Result = sub_result;
            AND:  Result = and_result;
            OR:   Result = or_result;
            BEQ:  Result = beq_result;
            default: Result = 64'b0;
        endcase
    end

    assign OverFlow = ((add_result[63] ^ A[63]) & 
                      (~(ALUControl[0] ^ B[63] ^ A[63])) &
                      (~ALUControl[1]));
    assign Carry = ((~ALUControl[1]) & Cout);
    assign Zero = (Result==64'b0);
    assign Negative = Result[63];

endmodule