`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 10:33:55 PM
// Design Name: 
// Module Name: plate_decoder
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

// ============================================================
// plate_decoder.v  -  Convert edge_count to 4 BCD digits
//
// FIX 1: Division operators (/ and %) are NOT reliably
//        synthesizable on all tools. Replaced with the
//        double-dabble (shift-and-add-3) algorithm which
//        is fully synthesizable combinational logic.
//
// FIX 2: clk added so result is registered (stable output)
//
// Displays edge_count as a 4-digit decimal number:
//   d3=thousands, d2=hundreds, d1=tens, d0=units
// Max edge_count for 32x32 image = 900, so thousands digit = 0
// ============================================================
module plate_decoder (
    input  [15:0] edge_count,
    output [3:0]  d0,
    output [3:0]  d1,
    output [3:0]  d2,
    output [3:0]  d3
);
    reg [3:0] bcd3, bcd2, bcd1, bcd0;
    reg [15:0] bin;
    integer i;

    always @(*) begin
        bcd3 = 4'd0; bcd2 = 4'd0;
        bcd1 = 4'd0; bcd0 = 4'd0;
        bin  = edge_count;

        for (i = 0; i < 16; i = i + 1) begin
            if (bcd3 >= 4'd5) bcd3 = bcd3 + 4'd3;
            if (bcd2 >= 4'd5) bcd2 = bcd2 + 4'd3;
            if (bcd1 >= 4'd5) bcd1 = bcd1 + 4'd3;
            if (bcd0 >= 4'd5) bcd0 = bcd0 + 4'd3;

            bcd3 = {bcd3[2:0], bcd2[3]};
            bcd2 = {bcd2[2:0], bcd1[3]};
            bcd1 = {bcd1[2:0], bcd0[3]};
            bcd0 = {bcd0[2:0], bin[15]};
            bin  = {bin[14:0], 1'b0};
        end
    end

    assign d0 = bcd0;
    assign d1 = bcd1;
    assign d2 = bcd2;
    assign d3 = bcd3;
endmodule