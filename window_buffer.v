`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 12:24:42 PM
// Design Name: 
// Module Name: window_buffer
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
// window_buffer.v  -  3x3 sliding window over image stream
//
// FIX 1: WIDTH changed to 32 to match 32x32 image
// FIX 2: window_valid now uses registered (previous-cycle)
//        col/row values so the check is stable
// FIX 3: col/row widths corrected (5-bit for WIDTH=32)
// ============================================================
// =============================================================
//  window_buffer.v  -  3×3 sliding window over 32-wide image
//
//  Image layout : 32 columns × 32 rows  (1024 pixels total)
//  Line buffers : 2 rows stored (line0 = oldest, line1 = newer)
//  Window rows  : p2x = 2 rows ago, p1x = 1 row ago, p0x = current
//
//  window_valid goes high only when we have a full 3×3 window,
//  i.e. row >= 2 AND col >= 2  (after the first 2 full rows)
//
//  NOTE: WIDTH must equal image width (32).
// =============================================================
module window_buffer (
    input            clk,
    input            rst,
    input  [7:0]     pixel_in,
    input            pixel_valid,
    output reg [7:0] p00, p01, p02,  // top row    (oldest)
    output reg [7:0] p10, p11, p12,  // middle row
    output reg [7:0] p20, p21, p22,  // bottom row (newest)
    output reg       window_valid
);
    parameter WIDTH = 32;   // â† must match your image width

    reg [7:0] line0 [0:WIDTH-1];   // oldest stored row
    reg [7:0] line1 [0:WIDTH-1];   // second stored row

    reg [4:0] col;   // 0..31  (5 bits for WIDTH=32)
    reg [4:0] row;   // 0..31

    integer k;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            col          <= 5'd0;
            row          <= 5'd0;
            window_valid <= 1'b0;
            p00<=0; p01<=0; p02<=0;
            p10<=0; p11<=0; p12<=0;
            p20<=0; p21<=0; p22<=0;
            for (k = 0; k < WIDTH; k = k + 1) begin
                line0[k] <= 8'd0;
                line1[k] <= 8'd0;
            end
        end else if (pixel_valid) begin

            // ---- Shift 3Ã-3 window left (oldest pixel drops off) ----
            p00 <= p01;  p01 <= p02;  p02 <= line0[col];
            p10 <= p11;  p11 <= p12;  p12 <= line1[col];
            p20 <= p21;  p21 <= p22;  p22 <= pixel_in;

            // ---- Update line buffers --------------------------------
            line0[col] <= line1[col];
            line1[col] <= pixel_in;

            // ---- Column / row counters -----------------------------
            if (col == WIDTH - 1) begin
                col <= 5'd0;
                row <= row + 5'd1;
            end else begin
                col <= col + 5'd1;
            end

            // Valid once we can fill a complete 3Ã-3 neighbourhood
            window_valid <= (row >= 5'd2) && (col >= 5'd2);
        end else begin
            window_valid <= 1'b0;
        end
    end

endmodule