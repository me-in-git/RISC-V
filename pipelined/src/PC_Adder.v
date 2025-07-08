module PC_Adder (a,b,c);

    input [63:0]a,b;
    output [63:0]c;

    wire carry; 
    RippleCarryAdder U1(a,b,1'b0,c, carry);
    
endmodule