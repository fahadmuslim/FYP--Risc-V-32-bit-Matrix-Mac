`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/02/2023 03:37:34 PM
// Design Name: 
// Module Name: Fetch_Cycle
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`include "Program_Counter.v"
`include "PC_Adder.v"
`include "MUX_2_by_1.v"
`include "Instruction_Memory.v"
`include "Adder.v"


module Fetch_Cycle(EN, clk, rst, CLR , PCSrcM, /*PCTargetE,*/PcBranchD , InstrD, /*PCD,*/ PCPlus4D );
    
        
       // Declare input & outputs
       input clk, rst, EN, CLR;
       input PCSrcM;
       input [31:0] /*PCTargetE*/ PcBranchD;
       
       output [31:0] InstrD;
       output [31:0] /*PCD,*/ PCPlus4D;
    
       // Declaring interim wires
       wire [31:0] PC_F, PCF, PCPlus4F;
       wire [31:0] InstrF;
    
       // Declaration of Register
       reg [31:0] InstrF_reg;
       reg [31:0] PCF_reg, PCPlus4F_reg;

     
    //initiating modules
    
     MUX_2_by_1 PC_MUX(
        .a(PCPlus4F),
        .b(PcBranchD),
        .s(PCSrcM),
        .c(PC_F)
     );
    
     Program_Counter Program_Counter(
        .clk(clk),
        .rst(rst),
        .PC(PCF) ,
        .PC_Next(PC_F)
     );
    
    
     Instruction_Memory I_MEM(
       .rst(rst),
       .A(PCF), 
       .RD(InstrF)
    );


    Adder PC_Fetch_Adder(
        .A(PCF),
        .B(32'd4),
        .Sum(PCPlus4F),
        .Carry_Out()
    );
    
    /*    PC_Adder PC_Adder(
            .curr_address(PCF), 
            .offset(32'd4), 
            .ALU_Out(ALU_Out),
            .branch(1'b1),
            .next_address(PCPlus4F)
        );*/
        
    
    //Fetch Cycle Register Values Storage Logic
    always @(posedge clk or negedge rst)
    begin
        if(rst ==1'b0)begin
            InstrF_reg      <= 32'h00000000;
            /*PCF_reg         <= 32'h00000000;*/
            PCPlus4F_reg    <= 32'h00000000;
        end 
        else begin
            if(EN == 1'b0)begin
                InstrF_reg      <= InstrF;
                /*PCF_reg         <= PCF;*/
                PCPlus4F_reg    <= PCPlus4F;
            end
            else begin
                InstrF_reg      <= InstrF_reg;
                /*PCF_reg         <= PCF;*/
                PCPlus4F_reg    <= PCPlus4F_reg;
            end

        end
    end
    
    //assigning registers value to the output port
    assign InstrD   = (rst == 1'b0) ? 32'h00000000 : InstrF_reg;
    /*assign PCD      = (rst == 1'b0) ? 32'h00000000 : PCF_reg;*/
    assign PCPlus4D = (rst == 1'b0) ? 32'h00000000 : PCPlus4F_reg;

endmodule














