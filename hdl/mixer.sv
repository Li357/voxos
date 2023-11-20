`timescale 1ns / 1ps
`default_nettype none

module mixer #(parameter N_FILTERS = 8) (
  input wire clk_in,
  input wire rst_in,
  input wire valid_in,
  input wire [4:0] shift,
  input wire signed [31:0] carrier_channels [N_FILTERS-1:0],
  input wire signed [31:0] envelope_channels [N_FILTERS-1:0],
  output logic signed [23:0] mixed_out,
  output logic valid_out
);

  typedef enum { WAITING, MULTIPLYING, SHIFTING, ADDING } state_t;
  state_t state;

  logic [$clog2(N_FILTERS)-1:0] index;
  logic signed [63:0] temp;

  always_ff @(posedge clk_in) begin
    if (rst_in) begin
      mixed_out <= 0;
      state <= WAITING;
    end else begin
      case (state)
        WAITING: begin
          valid_out <= 0;
          if (valid_in) begin
            state <= MULTIPLYING;
            index <= 0;
            mixed_out <= 0;
          end
        end
        MULTIPLYING: begin
          temp <= carrier_channels[index] * envelope_channels[index];
          state <= SHIFTING;
        end
        SHIFTING: begin
          temp <= temp >>> shift;
          state <= ADDING;
        end
        ADDING: begin
          mixed_out <= mixed_out + temp;
          index <= index + 1;
          if (index == N_FILTERS - 1) begin
            state <= WAITING;
            valid_out <= 1;
          end else state <= MULTIPLYING;
        end
      endcase
    end
  end

endmodule

`default_nettype wire