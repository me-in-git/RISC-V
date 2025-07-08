module Sign_Extend (In,ImmSrc,Imm_Ext);
    input [31:0] In;
    input [1:0] ImmSrc;
    output [63:0] Imm_Ext;

    assign Imm_Ext = (ImmSrc == 2'b00) ? {{52{In[31]}}, In[31:20]} :  // I-Type
                     (ImmSrc == 2'b01) ? {{52{In[31]}}, In[31:25], In[11:7]} :  // S-Type
                     64'h0000000000000000;  // Default case
endmodule