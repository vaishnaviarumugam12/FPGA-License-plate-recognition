`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 12:23:07 PM
// Design Name: 
// Module Name: binarize
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


module binarize (
    input  [7:0] pixel_in,
    input  [7:0] threshold,
    output       pixel_out
);
    assign pixel_out = (pixel_in >= threshold) ? 1'b1 : 1'b0;
endmodule