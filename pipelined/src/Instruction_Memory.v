module Instruction_Memory(rst,A,RD);

  input rst;
  input [63:0]A;
  output [31:0]RD;

  reg [31:0] mem [1023:0];
  
  assign RD = (rst == 1'b0) ? {32{1'b0}} : mem[A[31:2]];

  initial begin
    $readmemh("memfile.hex",mem); //memfile2,3 also attached
  end

endmodule