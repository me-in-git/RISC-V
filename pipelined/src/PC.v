module PC_Module(clk,rst,PC,PC_Next);
    input clk,rst;
    input [63:0]PC_Next;
    output [63:0]PC;
    reg [63:0]PC;

    always @(posedge clk)
    begin
        if(rst == 1'b0)
            PC <= {64{1'b0}};
        else
            PC <= PC_Next;
    end
endmodule