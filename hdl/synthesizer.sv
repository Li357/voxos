`timescale 1ns / 1ps
`default_nettype none

`ifdef SYNTHESIS
`define FPATH(X) `"X`"
`else /* ! SYNTHESIS */
`define FPATH(X) `"data/X`"
`endif  /* ! SYNTHESIS */

module synthesizer
  import constants::*;
(
  input wire clk_in,
  input wire rst_in,
  input wire [8:0] vol_in,
  input wire [SYNTH_PHASE_ACC_BITS-1:0] phase_incr_in,
  input wire [2:0] wave_type_in,
  output logic signed [SYNTH_WIDTH-1:0] synth_out
);

  logic signed [SYNTH_WIDTH-1:0] synth_temp;
  logic signed [SYNTH_WIDTH + 8:0] synth_adsr_temp;
  assign synth_adsr_temp = synth_temp * vol_in;

  logic [SYNTH_WIDTH-1:0] sine_out;
  sine s(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .phase_incr_in(phase_incr_in),
    .val_out(sine_out)
  );

  logic [SYNTH_WIDTH-1:0] sq_out;
  square sq(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .phase_incr_in(phase_incr_in),
    .val_out(sq_out)
  );

  logic [SYNTH_WIDTH-1:0] tri_out;
  triangle tr(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .phase_incr_in(phase_incr_in),
    .val_out(tri_out)
  );

  logic [SYNTH_WIDTH-1:0] saw_out;
  sawtooth sw(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .phase_incr_in(phase_incr_in),
    .val_out(saw_out)
  );

  always_comb begin
    case (wave_type_in)
      3'b001: synth_temp = sq_out;
      3'b010: synth_temp = tri_out;
      3'b100: synth_temp = saw_out;
      default: synth_temp = sine_out;
    endcase
  end

  always_ff @(posedge clk_in) begin
    if (rst_in) synth_out <= 0;
    else synth_out <= synth_adsr_temp >>> 7;
  end

endmodule

`default_nettype wire