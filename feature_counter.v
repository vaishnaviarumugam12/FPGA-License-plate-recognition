`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 10:32:18 PM
// Design Name: 
// Module Name: feature_counter
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
// feature_counter.v  -  Count edge pixels over a full frame
//
// FIX 1: done pulse is generated based on total valid pixels
//        processed = (WIDTH-2)*(HEIGHT-2) = 30*30 = 900
//        (the 3x3 kernel excludes border pixels)
// FIX 2: Counter resets properly for next frame
// FIX 3: edge_count held stable after done for plate_decoder
// ============================================================
module feature_counter (
    input             clk,
    input             rst,
    input             edge_in,
    input             valid,
    output reg [15:0] edge_count,
    output reg        done
);
    parameter TOTAL_VALID = 10'd900;  // (32-2)*(32-2)
    reg [9:0] valid_cnt;
    reg       active;   // counting is active

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            edge_count <= 16'd0;
            valid_cnt  <= 10'd0;
            done       <= 1'b0;
            active     <= 1'b1;
        end else begin
            done <= 1'b0;  // pulse only

            if (active && valid) begin
                if (edge_in)
                    edge_count <= edge_count + 16'd1;

                if (valid_cnt == TOTAL_VALID - 1) begin
                    done   <= 1'b1;
                    active <= 1'b0;  // stop; holds edge_count
                end else begin
                    valid_cnt <= valid_cnt + 10'd1;
                end
            end
        end
    end
endmodule