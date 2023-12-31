`timescale 1ns / 1ps
`default_nettype none

module switch_keyboard
  import constants::*;
(
  input wire [6:0] sw_in,
  output logic [SYNTH_PHASE_ACC_BITS-1:0] phase_acc_out
);

  always_comb begin
    case (sw_in)
      // 16'b0000000000000001: phase_acc_out = 24'b0001_0000_1011_1001_1010; // G5  = 783.99
      // 16'b0000000000000010: phase_acc_out = 24'b0000_1111_1100_0110_0011; // F#5 = 739.99
      // 16'b0000000000000100: phase_acc_out = 24'b0000_1110_1110_0110_1001; // F5  = 698.47
      //7'b0000000: phase_acc_out = 24'b0000_1110_0001_0000_0111; // E5  = 659.26
      7'b0000001: phase_acc_out = 24'b0000_1101_0100_0110_0101; // Eb5 = 622.25
      7'b0000010: phase_acc_out = 24'b0000_1100_1000_0111_1010; // D5  = 587.33
      7'b0000100: phase_acc_out = 24'b0000_1011_1101_0011_1010; // C#5 = 554.37
      7'b0001000: phase_acc_out = 24'b0000_1011_0010_1001_1010; // C5  = 523.25
      7'b0010000: phase_acc_out = 24'b0000_1010_1000_1001_0100; // B4  = 493.88
      7'b0100000: phase_acc_out = 24'b0000_1001_1111_0001_1110; // Bb4 = 466.16
      7'b1000000: phase_acc_out = 24'b0000_1001_0110_0011_0000; // A4  = 440
      //8'b00000000: phase_acc_out = 24'b0000_1000_1101_1100_0001; // Ab4 = 415.30
      // 9'b000000000: phase_acc_out = 24'b0000_1000_0101_1100_1101; // G4  = 391.99
      // 9'b000000000: phase_acc_out = 24'b0000_0111_1110_0100_1010; // F#4 = 369.99
      // 9'b000000000: phase_acc_out = 24'b0000_0111_0111_0011_0100; // F4  = 349.23
      // 9'b000000000: phase_acc_out = 24'b0000_0111_0000_1000_0100; // E4  = 329.63
      default: phase_acc_out = 24'b0;
    endcase
  end

endmodule