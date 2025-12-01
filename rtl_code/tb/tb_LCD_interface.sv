`timescale 1ns/1ps
import common_pkg::*;

module tb_LCD_interface;

  // Clock and reset
  logic i_clk;
  logic i_rst_n;

  // Inputs to DUT
  logic [3:0] i_display_data;
  logic i_display_data_valid;
  logic i_RS;

  // Bidirectional LCD bus
  wire [3:0] io_LCD_data;

  // Outputs from DUT
  logic o_E;
  logic o_RW;
  logic o_RS;
  logic o_is_ready;

  // Delayed o_RW for tri-state control
  logic o_RW_delayed;

  // Internal signal to drive io_LCD_data during read cycles
  logic [3:0] lcd_data_driver;

  // Instantiate DUT
  lcd_interface dut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_display_data(i_display_data),
    .i_display_data_valid(i_display_data_valid),
    .i_RS(i_RS),
    .io_LCD_data(io_LCD_data),
    .o_E(o_E),
    .o_RW(o_RW),
    .o_RS(o_RS),
    .o_is_ready(o_is_ready)
  );

  // Clock generation: 10ns period (100MHz)
  initial i_clk = 0;
  always #5 i_clk = ~i_clk;

  // Delay o_RW by 1 clock cycle
  always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
      o_RW_delayed <= 0;
    else
      o_RW_delayed <= o_RW;
  end

  // Use delayed RW to control bidirectional bus
  assign io_LCD_data = (o_RW_delayed) ? lcd_data_driver : 4'bzzzz;

  initial begin
    // Initialize inputs
    i_rst_n = 0;
    i_display_data = 4'h0;
    i_display_data_valid = 0;
    i_RS = 0;
    lcd_data_driver = 4'hF; // LCD busy flag initially high

    // Apply reset for 20 ns
    #20;
    i_rst_n = 1;

    // Wait a few cycles
    #20;

    // First write
    i_display_data = 4'hA;
    i_display_data_valid = 1;
    i_RS = 1;
    #10;
    i_display_data_valid = 0;

    // Simulate LCD busy flag while DUT reads
    repeat (10) begin
      @(posedge i_clk);
      if (o_RW_delayed) lcd_data_driver[3] = 1; // busy
      @(posedge i_clk);
      if (o_RW_delayed) lcd_data_driver[3] = 0; // ready
    end

    // Second write
    i_display_data = 4'h5;
    i_display_data_valid = 1;
    i_RS = 0;
    #10;
    i_display_data_valid = 0;

    // Run simulation for observation
    #200;
    $stop;
  end

  // Monitor signals
  initial begin
    $display("Time\tE RW RS READY LCD");
    $monitor("%0t\t%b  %b  %b   %b    %h", 
              $time, o_E, o_RW, o_RS, o_is_ready, io_LCD_data);
  end

endmodule
