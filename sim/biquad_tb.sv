`timescale 1ns / 1ps
`default_nettype none

module biquad_tb();

  logic clk_in;
  logic rst_in;
  logic [23:0] sample;
  logic [23:0] filtered;

  biquad #(
    .b0(32'd75467), 
    .b1(32'd0), 
    .b2(-32'd75467),
    .a1(-32'd1237071), 
    .a2(32'd937178)
  ) uut(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .sample_in(sample),
    .sample_out(filtered)
  );

  always begin
    #10;
    clk_in = !clk_in;
  end

  initial begin
    $dumpfile("biquad_tb.vcd");
    $dumpvars(0, biquad_tb);
    $display("Starting");

    clk_in = 0;
    rst_in = 0;
    #20;
    rst_in = 1;
    #20;
    rst_in = 0;
    sample = 32'h00100000;
    #20;
    sample = 32'h00200000;
    #20;
    sample = 32'h00300000;
    #20;
    sample = 32'h00400000;
    #20;
    sample = 32'h00500000;
    #200;

    $display("Finishing");
    $finish;
  end

endmodule