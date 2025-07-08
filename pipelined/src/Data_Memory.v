module Data_Memory(clk,rst,WE,WD,A,RD);

    input clk,rst,WE;
    input [63:0]A,WD;
    output [63:0]RD;

    reg [63:0] mem [1023:0];

    
    always @ (posedge clk)
    begin
        if(WE)
            mem[A] <= WD;
    end

    assign RD = (~rst) ? 32'd0 : mem[A];

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) begin
            mem[i] = 8'd0; 
        end
    end


endmodule