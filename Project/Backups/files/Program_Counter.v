`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2023 04:27:48 PM
// Design Name: 
// Module Name: Program_Counter
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


module Program_Counter(
    input [31:0] PC_Next,
    input clk,rst,//using active low reset(inverted)
    
    output reg [31:0] PC
);

always @(posedge clk)
begin
    if(rst == 1'b0)//reset low => acces start of the memory
        begin
            PC <= 32'h00000000;//blocking statement
        end 
    else // reset high => access the next instruction value
        begin
            PC <= PC_Next;
        end
    


end







endmodule







