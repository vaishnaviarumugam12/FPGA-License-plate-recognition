`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 12:21:09 PM
// Design Name: 
// Module Name: image_rom
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
// image_rom.v  -  Wraps Vivado Block Memory Generator IP
//
// Configure blk_mem_gen_0 in Vivado:
//   - Memory type  : Single Port ROM
//   - Width        : 8 bits
//   - Depth        : 1024 (for 32x32 image)
//   - Load init file: YES - point to your .coe file
//   - Output register: 1 (adds 1 cycle latency - accounted for in LPR.v)
// ============================================================
// ============================================================
// binarize.v  -  Threshold pixel to binary (combinational)
// ============================================================
module image_rom (
    input        clk,
    input  [9:0] addr,
    output [7:0] pixel_out
);
    // ena must be tied HIGH for ROM (always enabled).
    // This fixes: [Synth 8-4442] BlackBox u_bram has unconnected pin ena
    blk_mem_gen_0 u_bram (
        .clka  (clk),
        .ena   (1'b1),      // always enable
        .addra (addr),
        .douta (pixel_out)
    );
endmodule