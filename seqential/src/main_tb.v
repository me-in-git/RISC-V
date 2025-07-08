module tb();
    reg clk = 0;
    reg rst = 1;
    riscv_processor cpu(clk, rst);
    
    always #5 clk = ~clk;
    
    initial begin
        // Initialize all memory to NOPs
          $dumpfile("sed_tb.vcd");  // Waveform file name
        $dumpvars(0, tb);
        for(integer i=0; i<1024; i++) begin
            cpu.instr_mem[i] = 32'h00000013;  // NOP
            cpu.data_mem[i] = 0;
        end
        
        // Modified Test Program (JALs replaced with NOPs)
        cpu.instr_mem[0]  = 32'h00500093;  // ADDI x1, x0, 5
        cpu.instr_mem[1]  = 32'h00300113;  // ADDI x2, x0, 3
        cpu.instr_mem[2]  = 32'h002081B3;  // ADD  x3, x1, x2
        cpu.instr_mem[3]  = 32'h40208233;  // SUB  x4, x2, x1
        cpu.instr_mem[4]  = 32'h00418863;  // BEQ  x3, x4, 16
        cpu.instr_mem[5]  = 32'h00A02423;  // SW   x10,8(x0)
        cpu.instr_mem[6]  = 32'h00802603;  // LW   x12,8(x0)
        cpu.instr_mem[7]  = 32'h00000013;  // NOP (was JAL)
        cpu.instr_mem[8]  = 32'h00000013;  // NOP (was infinite loop)

        // Data Memory Initialization
        cpu.data_mem[2] = 32'h0000000A;  // Initialize address 8 with 10
        
        $display("Starting simulation...");
        #10 rst = 0;
        #200; 
        $display("\n=== FINAL STATE ===");
        print_results();
        $finish;
    end
    
    task print_results;
    begin
        $display("PC = %h", cpu.pc);
        $display("Registers:");
        $display("x1: %h (5 expected)", cpu.registers[1]);
        $display("x2: %h (3 expected)", cpu.registers[2]);
        $display("x3: %h (8 expected)", cpu.registers[3]);
        $display("x4: %h (FFFFFFFE expected)", cpu.registers[4]);
        $display("x12: %h (0 expected)", cpu.registers[12]);
        $display("Memory[8]: %h (0 expected)", cpu.data_mem[2]);
    end
    endtask
    
    always @(posedge clk) begin
        if (!rst) begin
            $display("\n=== CYCLE %0d ===", $time/10);
            $display("PC: %h", cpu.pc);
            $display("Instr: %h", cpu.instruction);
            
            // Control Signals
            $display("CTRL: Branch=%b, Jump=%b, RegWrite=%b", 
                    cpu.Branch, cpu.Jump, cpu.RegWrite);
            
            // ALU Info
            $display("ALU: a=%h, b=%h, result=%h", 
                    cpu.read_data1, cpu.alu_in2, cpu.alu_result);
            
            // Register Updates
            if (cpu.RegWrite && cpu.rd != 0) begin
                $display("WRITE: x%d <= %h", cpu.rd, cpu.write_data);
            end
            
            // Memory Operations
            if (cpu.MemWrite) begin
                $display("STORE: [%h] <= %h", 
                        cpu.alu_result, cpu.read_data2);
            end
            if (cpu.MemRead) begin
                $display("LOAD: x%d <= [%h] = %h", 
                        cpu.rd, cpu.alu_result, cpu.mem_data);
            end
        end
    end
endmodule
