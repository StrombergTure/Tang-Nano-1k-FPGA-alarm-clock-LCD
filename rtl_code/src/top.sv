import common_pkg::*;

module top(
  input  logic        sys_clk,
  input  logic        sys_rst_n,
  inout  logic [3:0]  io_LCD_data,

  // Outputs from lcd_interface
  output logic        o_E,
  output logic        o_RW,
  output logic        o_RS
);

  // Signals for display_controller
  logic          buf_rd_en;
  logic [3:0]    display_data;
  logic          display_data_valid;
  logic          rs;

  // Inputs for display_controller (placeholders / can be driven externally)
  logic [25:0]   display_data_in;
  logic          buf_has_entry;
  logic          is_ready;
  display_op     display_op;

  // Instantiate display_controller
  display_controller u_display_controller (
    .i_clk(sys_clk),
    .i_rst_n(sys_rst_n),
    .i_display_op(display_op),
    .i_display_data(display_data_in),
    .i_buf_has_entry(buf_has_entry),
    .i_is_ready(is_ready),
    .o_buf_rd_en(buf_rd_en),
    .o_display_data(display_data),
    .o_display_data_valid(display_data_valid),
    .o_RS(rs)
  );

  // Instantiate lcd_interface
  lcd_interface u_lcd_interface (
    .i_clk(sys_clk),
    .i_rst_n(sys_rst_n),
    .i_display_data(display_data),           // Connected to display_controller output
    .i_display_data_valid(display_data_valid), // Connected to display_controller output
    .i_RS(rs),                               // Connected to display_controller output
    .io_LCD_data(io_LCD_data),                    // Optional: LCD feedback
    .o_E(o_E),
    .o_RW(o_RW),
    .o_RS(o_RS),
    .o_is_ready(is_ready)                 // Feed back ready signal to controller
  );

endmodule
