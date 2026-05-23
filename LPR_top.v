`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 12:31:49 PM
// Design Name: 
// Module Name: LPR_top
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


// =============================================================
//  LPR_top.v  -  Top-level wrapper
//  Ports match XDC exactly: seg[7:0], an[3:0]
// =============================================================
// =============================================================
//  LPR_top.v  -  Top level for Boolean board (xc7s50csga324-2)
//
//  Boolean board has TWO 4-digit 7-segment displays:
//    DISP0 (D0): right display  → ports D0_SEG[7:0], D0_AN[3:0]
//    DISP1 (D1): left  display  → ports D1_SEG[7:0], D1_AN[3:0]
//
//  We use DISP1 (left) to show the 4-digit edge count.
//  DISP0 (right) is blanked.
//
//  Reset: btn[0] = J2 (BTN0 on Boolean board) - active high
// =============================================================
module LPR_top (
    input        clk,     // F14  100 MHz
    input        rst,     // J2   BTN0
    output [7:0] D0_SEG,
    output [3:0] D0_AN,
    output [7:0] D1_SEG,
    output [3:0] D1_AN
);

    wire [3:0] d0, d1, d2, d3;
    wire       valid;

    LPR core (
        .clk          (clk),
        .rst          (rst),
        .digit0       (d0),
        .digit1       (d1),
        .digit2       (d2),
        .digit3       (d3),
        .result_valid (valid)
    );

    // DISP1 (left): shows digits when valid, else shows dashes
    seg7_controller disp1 (
        .clk (clk),
        .d0  (valid ? d0 : 4'hD),
        .d1  (valid ? d1 : 4'hD),
        .d2  (valid ? d2 : 4'hD),
        .d3  (valid ? d3 : 4'hD),
        .seg (D1_SEG),
        .an  (D1_AN)
    );

    // DISP0 (right): shows "0000" when valid
    // before valid: shows "----"
    seg7_controller disp0 (
        .clk (clk),
        .d0  (valid ? 4'h0 : 4'hD),
        .d1  (valid ? 4'h0 : 4'hD),
        .d2  (valid ? 4'h0 : 4'hD),
        .d3  (valid ? 4'h0 : 4'hD),
        .seg (D0_SEG),
        .an  (D0_AN)
    );

endmodule