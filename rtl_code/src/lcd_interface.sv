import common_pkg::*;

module lcd_interface(
  input  logic          i_clk,
  input  logic          i_rst_n,
  input  logic [3:0]    i_display_data,
  input  logic          i_display_data_valid,
  input  logic          i_RS,
  inout  wire  [3:0]    io_LCD_data,
  output logic          o_E,
  output logic          o_RW,
  output logic          o_RS,
  output logic          o_is_ready
);

  typedef enum logic [1:0] {
    IDLE,
    CHECK_BUSY,
    SET_ENABLE,
    HOLD_DATA
  } state_t;

state_t cur_state, nxt_state;
logic[2:0] cur_counter, nxt_counter;
logic[3:0] cur_in_data, nxt_in_data;
logic cur_RW, nxt_RW;

always_ff @(posedge i_clk, negedge i_rst_n) begin : blockName
  if (!i_rst_n) begin
    cur_state <= IDLE;
    cur_counter <= '0;
    cur_in_data <= '0;
    cur_RW <= '0;
  end else begin
    cur_state <= nxt_state;
    cur_counter <= nxt_counter;
    cur_in_data <= nxt_in_data;
    cur_RW <= nxt_RW;
  end
end

assign io_LCD_data = cur_RW ? 4'bzzzz : cur_in_data;
assign o_RW = cur_RW;
always_comb begin
  // Default
  o_E = 0;
  o_RS = i_RS;
  o_is_ready = 0;
  nxt_state = cur_state;
  nxt_counter = cur_counter;
  nxt_in_data = cur_in_data;
  nxt_RW = cur_RW;

  case (cur_state)
    IDLE: begin
      o_is_ready = 1;
      if (i_display_data_valid) begin
        nxt_state = CHECK_BUSY;
        nxt_in_data = i_display_data;
      end
    end

    CHECK_BUSY: begin
      //io_LCD_data = 4'bzzzz;
      nxt_RW = 1;
      nxt_counter = cur_counter +1;
      if (cur_counter >= 2) begin
        nxt_counter = cur_counter;
        if (io_LCD_data[3] == 1) begin
          nxt_state = SET_ENABLE;
          nxt_counter = 0;
          nxt_RW = 0;
        end
      end
    end

    SET_ENABLE: begin
      o_E = 1;
      nxt_counter = cur_counter +1;
      if (cur_counter == 4) begin
        nxt_state = HOLD_DATA;
        nxt_counter = 0;
      end
    end

    HOLD_DATA: begin
      nxt_state = IDLE;
    end

    default: begin

    end
  endcase



end

endmodule