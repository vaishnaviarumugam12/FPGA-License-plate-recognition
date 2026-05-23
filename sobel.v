`timescale 1ns / 1ps
// =============================================================
//  sobel.v  -  3-stage pipelined Sobel edge detector
//
//  Stage 1 (clk 1): capture window, compute Gx & Gy
//  Stage 2 (clk 2): compute |Gx| + |Gy|  = gradient magnitude
//  Stage 3 (clk 3): threshold → edge_out
//
//  This pipeline avoids the classic bug where abs() and Gx/Gy
//  are evaluated in the SAME clock edge (Gx not yet updated).
//
//  Window pixel map (p[row][col]):
//    p00 p01 p02      Sobel Gx kernel:    Sobel Gy kernel:
//    p10 p11 p12       -1  0 +1            -1 -2 -1
//    p20 p21 p22       -2  0 +2             0  0  0
//                      -1  0 +1            +1 +2 +1
// =============================================================
module sobel (
    input            clk,
    input            rst,
    input            window_valid,
    input  [7:0]     p00, p01, p02,
    input  [7:0]     p10, p11, p12,
    input  [7:0]     p20, p21, p22,
    output reg       edge_out
);
    parameter THRESHOLD = 40;  // lower = more edges detected

    // ---- Stage 1 registers ----
    reg signed [11:0] Gx_s1, Gy_s1;
    reg               valid_s1;

    // ---- Stage 2 registers ----
    reg [11:0]        mag_s2;
    reg               valid_s2;

    // ---- Stage 1: Gradient computation ----
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Gx_s1   <= 12'sd0;
            Gy_s1   <= 12'sd0;
            valid_s1 <= 1'b0;
        end else begin
            valid_s1 <= window_valid;
            if (window_valid) begin
                // Gx = (-p00 + p02) + 2(-p10 + p12) + (-p20 + p22)
                Gx_s1 <= ( -$signed({1'b0, p00}) + $signed({1'b0, p02}) )
                        + ( (-$signed({1'b0, p10}) + $signed({1'b0, p12})) <<< 1 )
                        + ( -$signed({1'b0, p20}) + $signed({1'b0, p22}) );

                // Gy = (-p00-2*p01-p02) + (p20+2*p21+p22)
                Gy_s1 <= ( -$signed({1'b0, p00}) - ($signed({1'b0, p01}) <<< 1) - $signed({1'b0, p02}) )
                        + (  $signed({1'b0, p20}) + ($signed({1'b0, p21}) <<< 1) + $signed({1'b0, p22}) );
            end
        end
    end

    // ---- Stage 2: Magnitude = |Gx| + |Gy| ----
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mag_s2   <= 12'd0;
            valid_s2 <= 1'b0;
        end else begin
            valid_s2 <= valid_s1;
            if (valid_s1) begin
                mag_s2 <= (Gx_s1[11] ? -Gx_s1 : Gx_s1)
                         + (Gy_s1[11] ? -Gy_s1 : Gy_s1);
            end
        end
    end

    // ---- Stage 3: Threshold â†' binary edge ----
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            edge_out <= 1'b0;
        end else begin
            if (valid_s2)
                edge_out <= (mag_s2 > THRESHOLD);
            else
                edge_out <= 1'b0;
        end
    end

endmodule