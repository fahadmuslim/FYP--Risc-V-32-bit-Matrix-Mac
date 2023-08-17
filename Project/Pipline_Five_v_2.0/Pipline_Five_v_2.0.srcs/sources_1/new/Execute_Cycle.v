// Copyright 2023 MERL-DSU

//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at

//        http://www.apache.org/licenses/LICENSE-2.0

//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

`include "Adder.v"
`include "Mux_2_by_1.v"
`include "Mux_3_by_1.v"
`include "ALU.v"



module execute_cycle(clk, rst, CLR, RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, ALUControlE, 
    RD1_E, RD2_E, Imm_Ext_E, RD_E, PCE, PCPlus4E, PCSrcE, PCTargetE, RegWriteM, MemWriteM, ResultSrcM, RD_M, PCPlus4M, WriteDataM, ALU_ResultM, ResultW, ForwardA_E, ForwardB_E);

    // Declaration I/Os
    input clk, rst, CLR, RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE;
    input [5:0] ALUControlE;
    input [31:0] RD1_E, RD2_E, Imm_Ext_E;
    input [4:0] RD_E;
    input [31:0] PCE, PCPlus4E;
    input [31:0] ResultW;
    input [1:0] ForwardA_E, ForwardB_E;

    output PCSrcE;
    output RegWriteM, MemWriteM, ResultSrcM;
    output [4:0] RD_M; 
    output [31:0] PCPlus4M, WriteDataM, ALU_ResultM;
    output [31:0] PCTargetE;

    // Declaration of Interim Wires
    wire [31:0] Src_A, Src_B_interim, Src_B;
    wire [31:0] ResultE;
    wire ZeroE;

    // Declaration of Register
    reg RegWriteE_r, MemWriteE_r, ResultSrcE_r;
    reg [4:0] RD_E_r;
    reg [31:0] PCPlus4E_r, RD2_E_r, ResultE_r;

    // Declaration of Modules
    // 3 by 1 Mux for Source A
    Mux_3_by_1 SrcA_Mux (
                        .a(RD1_E),
                        .b(ResultW),
                        .c(ALU_ResultM),
                        .s(ForwardA_E),
                        .y(Src_A)
                        );

    // 3 by 1 Mux for Source B
    Mux_3_by_1 SrcB_Mux (
                        .a(RD2_E),
                        .b(ResultW),
                        .c(ALU_ResultM),
                        .s(ForwardB_E),
                        .y(Src_B_interim)
                        );
    // ALU Src Mux
    MUX_2_by_1 ALU_Src_Mux (
            .a(Src_B_interim),
            .b(Imm_Ext_E),
            .s(ALUSrcE),
            .c(Src_B)
            );

    // ALU Unit
    ALU ALU (
            .A(Src_A),
            .B(Src_B),
            .ALU_Out(ResultE),
            .ALU_Sel(ALUControlE),
            .Overflow(),
            .CarryOut(),
            .Zero(ZeroE),  //maybe assign ZeroE = ResultE[0]
            .Negative()
            );

    // Adder
    Adder branch_adder (
            .A(PCE),
            .B(Imm_Ext_E),
            .Sum(PCTargetE)
            );

    // Register Logic
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            RegWriteE_r         <= 1'b0; 
            MemWriteE_r         <= 1'b0; 
            ResultSrcE_r        <= 1'b0;
            RD_E_r              <= 5'h00;
            PCPlus4E_r          <= 32'h00000000; 
            RD2_E_r             <= 32'h00000000; 
            ResultE_r           <= 32'h00000000;
            
        end
        else if(CLR == 1'b1) begin
            RegWriteE_r         <= RegWriteE /*1'b0*/; 
            MemWriteE_r         <= 1'b0; 
            ResultSrcE_r        <= ResultSrcE/* 0*/;
            RD_E_r              <= RD_E  /*0*/;
            PCPlus4E_r          <= 32'h00000000; 
            RD2_E_r             <= 32'h00000000; 
            ResultE_r           <= ResultE;        
                 
        end
        else begin
            RegWriteE_r         <= RegWriteE; 
            MemWriteE_r         <= MemWriteE; 
            ResultSrcE_r        <= ResultSrcE;
            RD_E_r              <= RD_E;
            PCPlus4E_r          <= PCPlus4E; 
            RD2_E_r             <= Src_B_interim; 
            ResultE_r           <= ResultE;
             
        end
           
    end

    // Output Assignments
    assign PCSrcE =         ZeroE &  BranchE;
    assign RegWriteM =      RegWriteE_r;
    assign MemWriteM =      MemWriteE_r;
    assign ResultSrcM =     ResultSrcE_r;
    assign RD_M =           RD_E_r;
    assign PCPlus4M =       PCPlus4E_r;
    assign WriteDataM =     RD2_E_r;
    assign ALU_ResultM =    ResultE_r;

endmodule