module hazard_unit_tb;

    // Inputs
    reg rst;
    reg RegWriteM, RegWriteW;
    reg [4:0] RD_M, RD_W, Rs1_E, Rs2_E;
    
    // Outputs
    wire [1:0] ForwardAE, ForwardBE;
    
    // Instantiate the Unit Under Test (UUT)
    hazard_unit uut (
        .rst(rst),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .RD_M(RD_M),
        .RD_W(RD_W),
        .Rs1_E(Rs1_E),
        .Rs2_E(Rs2_E),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );
    
    initial begin
        // Initialize VCD dump (optional)
        $dumpfile("hazard_unit_tb.vcd");
        $dumpvars(0, hazard_unit_tb);

        // Initialize Inputs
        rst = 0;
        RegWriteM = 0;
        RegWriteW = 0;
        RD_M = 0;
        RD_W = 0;
        Rs1_E = 0;
        Rs2_E = 0;
        
        // Wait 10 ns for global reset to finish
        #10;

        // Test Case 1: Reset Condition
        $display("\nTest Case 1: Reset");
        rst = 0;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        // Test Case 2: No Hazard
        $display("\nTest Case 2: No Hazard");
        rst = 1;
        RegWriteM = 0;
        RegWriteW = 0;
        RD_M = 5;
        RD_W = 5;
        Rs1_E = 1;
        Rs2_E = 2;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        // Test Case 3: Forward from M to Rs1_E
        $display("\nTest Case 3: Forward from M to Rs1_E");
        RegWriteM = 1;
        RD_M = 5;
        Rs1_E = 5;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        // Test Case 4: Forward from W to Rs1_E
        $display("\nTest Case 4: Forward from W to Rs1_E");
        RegWriteM = 0;
        RegWriteW = 1;
        RD_W = 5;
        Rs1_E = 5;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        // Test Case 5: Priority to M over W for Rs1_E
        $display("\nTest Case 5: Priority to M over W");
        RegWriteM = 1;
        RegWriteW = 1;
        RD_M = 5;
        RD_W = 5;
        Rs1_E = 5;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        // Test Case 6: Forward from M to Rs2_E
        $display("\nTest Case 6: Forward from M to Rs2_E");
        RegWriteM = 1;
        RD_M = 5;
        Rs2_E = 5;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        // Test Case 7: Forward from W to Rs2_E
        $display("\nTest Case 7: Forward from W to Rs2_E");
        RegWriteM = 0;
        RegWriteW = 1;
        RD_W = 5;
        Rs2_E = 5;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        // Test Case 8: RD_M is x0 (no forwarding)
        $display("\nTest Case 8: RD_M is x0");
        RegWriteM = 1;
        RD_M = 0;
        Rs1_E = 0;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        // Test Case 9: RD_W is x0 (no forwarding)
        $display("\nTest Case 9: RD_W is x0");
        RegWriteM = 0;
        RegWriteW = 1;
        RD_W = 0;
        Rs2_E = 0;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        // Test Case 10: Cross forwarding
        $display("\nTest Case 10: Cross forwarding");
        RegWriteM = 1;
        RegWriteW = 1;
        RD_M = 6;
        RD_W = 7;
        Rs1_E = 7;
        Rs2_E = 6;
        #10;
        $display("ForwardAE = %b, ForwardBE = %b", ForwardAE, ForwardBE);

        $display("\nAll test cases completed.");
        $finish;
    end
    
endmodule