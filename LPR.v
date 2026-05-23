`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2026 07:46:44 PM
// Design Name: 
// Module Name: LPR
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
// LPR.v  -  License Plate Recognition core
//
// FIX 1: addr < 1023 was off-by-one - changed to addr <= 1023
// FIX 2: ROM has 1-cycle latency, so pixel_valid delayed by 1
// FIX 3: ILA removed (causes bitstream error if IP not created)
// FIX 4: result_valid latched only after done pulse
// ============================================================
// =============================================================
//  LPR.v  -  Core license-plate recognition pipeline
//
//  ILA probe summary (must match ila_0 IP settings):
//    probe0  [15:0]  edge_count
//    probe1  [0:0]   edge_pix
//    probe2  [0:0]   win_valid
//    probe3  [9:0]   addr
//    probe4  [7:0]   pixel_raw
//    probe5  [0:0]   pixel_bin
//    probe6  [0:0]   result_valid
//    probe7  [0:0]   done
//  Total probes = 8
// =============================================================
module LPR (
    input        clk,
    input        rst,
    output [3:0] digit0, digit1, digit2, digit3,
    output reg   result_valid
);

    (* mark_debug = "true" *) reg  [9:0]  addr;
    reg                                   pixel_valid;
    (* mark_debug = "true" *) wire [7:0]  pixel_raw;
    (* mark_debug = "true" *) wire        pixel_bin;
    wire [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;
    (* mark_debug = "true" *) wire        win_valid;
    (* mark_debug = "true" *) wire        edge_pix;
    (* mark_debug = "true" *) wire [15:0] edge_count;
    (* mark_debug = "true" *) wire        done;

    // ---- 3-cycle pipeline delay on win_valid ----------------
    // Sobel is 3 registered stages, so edge_pix is valid 3 clocks
    // after win_valid. We must count on the same timing.
    reg win_d1, win_d2, win_d3;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            win_d1 <= 1'b0;
            win_d2 <= 1'b0;
            win_d3 <= 1'b0;
        end else begin
            win_d1 <= win_valid;
            win_d2 <= win_d1;
            win_d3 <= win_d2;
        end
    end

    // ---- Address sequencer ----------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            addr         <= 10'd0;
            pixel_valid  <= 1'b0;
            result_valid <= 1'b0;
        end else begin
            // Start pixel stream immediately after reset
            if (addr < 10'd1023) begin
                pixel_valid <= 1'b1;
                addr        <= addr + 10'd1;
            end else begin
                pixel_valid <= 1'b0;
                // STICKY: once done pulses high, hold result_valid forever
                if (done)
                    result_valid <= 1'b1;
            end
        end
    end

    // ---- Sub-modules ----------------------------------------
    image_rom rom (
        .clk       (clk),
        .addr      (addr),
        .pixel_out (pixel_raw)
    );

    binarize bin (
        .pixel_in  (pixel_raw),
        .threshold (8'h80),
        .pixel_out (pixel_bin)
    );

    window_buffer win (
        .clk          (clk),
        .rst          (rst),
        .pixel_in     ({7'b0, pixel_bin}),
        .pixel_valid  (pixel_valid),
        .p00(p00),.p01(p01),.p02(p02),
        .p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22),
        .window_valid (win_valid)
    );

    sobel sob (
        .clk          (clk),
        .rst          (rst),
        .window_valid (win_valid),
        .p00(p00),.p01(p01),.p02(p02),
        .p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22),
        .edge_out     (edge_pix)
    );

    // Use win_d3 so counting is aligned with edge_pix output
    feature_counter fc (
        .clk        (clk),
        .rst        (rst),
        .edge_in    (edge_pix),
        .valid      (win_d3),
        .edge_count (edge_count),
        .done       (done)
    );

    plate_decoder dec (
        .edge_count (edge_count),
        .d0 (digit0),
        .d1 (digit1),
        .d2 (digit2),
        .d3 (digit3)
    );

endmodule