`timescale 1ns/1ps
import common_pkg::*;

module tb_clock_controller;

  // Parameters
  parameter CLOCK_FREQUENCY = 2;
  parameter CLK_PERIOD = 10;

  // Clock & reset
  logic i_clk;
  logic i_rst_n;

  // Control input
  clock_op_t i_clock_control;

  // Outputs
  logic [5:0]  o_clock_sel;
  logic [19:0] o_clock_val;
  logic        o_clock_do_ring;
  logic        o_clock_wr_en;

  // Instantiate DUT
  clock_controller #(
    .CLOCK_FREQUENCY(CLOCK_FREQUENCY)
  ) uut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_clock_control(i_clock_control),
    .o_clock_sel(o_clock_sel),
    .o_clock_val(o_clock_val),
    .o_clock_do_ring(o_clock_do_ring),
    .o_clock_wr_en(o_clock_wr_en)
  );

  // Clock generation
  initial i_clk = 0;
  always #(CLK_PERIOD/2) i_clk = ~i_clk;

  // Reset sequence
  initial begin
    i_rst_n = 0;
    $display("[%0t] Applying reset", $time);
    #(2*CLK_PERIOD);
    i_rst_n = 1;
    $display("[%0t] Releasing reset", $time);
  end

  // Test procedure with descriptive prints
  initial begin
    // Initialize control signals
    i_clock_control = '{default:0};
    #(2*CLK_PERIOD);

    // 1. Display time mode
    $display("[%0t] Step 1: Enter DISPLAY TIME mode", $time);
    i_clock_control.clock_do_display_time = 1;
    #(CLK_PERIOD);
    i_clock_control.clock_do_display_time = 0;
    #(CLK_PERIOD*5);

    // 2. Set time mode
    $display("[%0t] Step 2: Enter SET TIME mode", $time);
    i_clock_control.clock_do_set_time = 1;
    #(CLK_PERIOD);
    i_clock_control.clock_do_set_time = 0;

    // Increment first digit 3 times
    repeat (3) begin
      $display("[%0t] Incrementing first digit of time", $time);
      i_clock_control.clock_do_up = 1;
      #(CLK_PERIOD);
      i_clock_control.clock_do_up = 0;
      #(CLK_PERIOD);
    end

    // Move selection left
    $display("[%0t] Moving selection left", $time);
    i_clock_control.clock_do_left = 1;
    #(CLK_PERIOD);
    i_clock_control.clock_do_left = 0;
    #(CLK_PERIOD);

    // Increment new selected digit
    $display("[%0t] Incrementing new selected digit of time", $time);
    i_clock_control.clock_do_up = 1;
    #(CLK_PERIOD);
    i_clock_control.clock_do_up = 0;
    #(CLK_PERIOD*5);

    // 3. Set alarm mode
    $display("[%0t] Step 3: Enter SET ALARM mode", $time);
    i_clock_control.clock_do_set_alarm = 1;
    #(CLK_PERIOD);
    i_clock_control.clock_do_set_alarm = 0;

    // Increment alarm digit
    $display("[%0t] Incrementing alarm digit", $time);
    i_clock_control.clock_do_up = 1;
    #(CLK_PERIOD);
    i_clock_control.clock_do_up = 0;

    // Toggle alarm ON/OFF
    $display("[%0t] Toggling alarm ON/OFF", $time);
    i_clock_control.clock_do_toggle_alarm = 1;
    #(CLK_PERIOD);
    i_clock_control.clock_do_toggle_alarm = 0;
    #(CLK_PERIOD*5);

    // Finish
    $display("[%0t] Test complete", $time);
    $display("Final clock value: %b", o_clock_val);
    $display("Final clock sel: %b", o_clock_sel);
    $finish;
  end

  // Monitor outputs continuously
  initial begin
    $display("Time(ns) | clk rst | sel val wr ring");
    $monitor("%0t | %b   %b | %b %b %b %b",
             $time, i_clk, i_rst_n, o_clock_sel, o_clock_val, o_clock_wr_en, o_clock_do_ring);
  end

endmodule
