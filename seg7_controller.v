`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 12:29:03 PM
// Design Name: 
// Module Name: seg7_controller
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
//  seg7_controller.v
//
//  Multiplexed 4-digit 7-segment display driver.
//  Refresh rate: 100 MHz / 2^18 ≈ 381 Hz per digit  (flicker-free)
//  Segments are ACTIVE LOW (common-anode display).
//  Anodes   are ACTIVE LOW.
//
//  seg bit mapping:  [7]=DP  [6]=G  [5]=F  [4]=E
//                    [3]=D   [2]=C  [1]=B  [0]=A
// =============================================================
module seg7_controller (
    input            clk,
    input  [3:0]     d0, d1, d2, d3,   // BCD digits (d3=MSD, d0=LSD)
    output reg [7:0] seg,               // segment cathodes (active-low)
    output reg [3:0] an                 // digit anodes     (active-low)
);
    // 18-bit counter â†' ~381 Hz refresh per digit at 100 MHz
    reg [17:0] cnt;
    always @(posedge clk) cnt <= cnt + 18'd1;

    wire [1:0] sel = cnt[17:16];   // selects which digit to drive

    // ---- 7-segment decode (active-low, common anode) ----
    //  Segments:  DP G F E D C B A
    function [7:0] seg_decode;
        input [3:0] digit;
        case (digit)
            4'h0: seg_decode = 8'b1100_0000;  // 0
            4'h1: seg_decode = 8'b1111_1001;  // 1
            4'h2: seg_decode = 8'b1010_0100;  // 2
            4'h3: seg_decode = 8'b1011_0000;  // 3
            4'h4: seg_decode = 8'b1001_1001;  // 4
            4'h5: seg_decode = 8'b1001_0010;  // 5
            4'h6: seg_decode = 8'b1000_0010;  // 6
            4'h7: seg_decode = 8'b1111_1000;  // 7
            4'h8: seg_decode = 8'b1000_0000;  // 8
            4'h9: seg_decode = 8'b1001_0000;  // 9
            4'hA: seg_decode = 8'b1000_1000;  // A
            4'hB: seg_decode = 8'b1000_0011;  // b
            4'hC: seg_decode = 8'b1100_0110;  // C
            4'hD: seg_decode = 8'b1010_0001;  // d
            4'hE: seg_decode = 8'b1000_0110;  // E
            4'hF: seg_decode = 8'b1111_1111;  // blank (all segments off)
            default: seg_decode = 8'b1111_1111;
        endcase
    endfunction

    always @(*) begin
        case (sel)
            2'd0: begin an = 4'b1110; seg = seg_decode(d0); end  // rightmost
            2'd1: begin an = 4'b1101; seg = seg_decode(d1); end
            2'd2: begin an = 4'b1011; seg = seg_decode(d2); end
            2'd3: begin an = 4'b0111; seg = seg_decode(d3); end  // leftmost
            default: begin an = 4'b1111; seg = 8'hFF; end
        endcase
    end

endmodule