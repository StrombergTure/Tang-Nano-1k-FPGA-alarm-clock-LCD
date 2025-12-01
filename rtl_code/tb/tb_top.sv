`timescale 1ns/1ps
import common_pkg::*;

module top_tb;

  // DUT I/O
  logic        sys_clk;
  logic        sys_rst_n;
  wire  [3:0]  io_LCD_data;

  logic        o_E;
  logic        o_RW;
  logic        o_RS;

  // LCD data bus (tri-state driver in TB)
  logic [3:0] lcd_data_drv;   // Driven when DUT reads busy flag
  assign io_LCD_data = o_RW ? lcd_data_drv : 4'bzzzz;

  // Instantiate DUT
  top dut (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .io_LCD_data(io_LCD_data),
    .o_E(o_E),
    .o_RW(o_RW),
    .o_RS(o_RS)
  );

  // Clock generation
  initial begin
    sys_clk = 0;
    forever #5 sys_clk = ~sys_clk;   // 100 MHz
  end

  // Reset generation
  initial begin
    sys_rst_n = 0;
    #100;
    sys_rst_n = 1;
  end

  // LCD busy flag model
  // lcd_interface reads io_LCD_data[3] when o_RW = 1
  // This simple behavioral model returns "BUSY=0" most of the time,
  // but inserts occasional "busy = 1" cycles.
  initial begin
    lcd_data_drv = 4'h0;
    wait(sys_rst_n);

    forever begin
      @(posedge sys_clk);

      if (o_RW) begin
        // Randomly insert busy=1
        if ($urandom_range(0,10) < 3)
          lcd_data_drv = 4'b1000;   // BUSY = 1
        else
          lcd_data_drv = 4'b0000;   // BUSY = 0
      end else begin
        lcd_data_drv = 4'bzzzz;
      end
    end
  end

  // Stimulus driver (drives display_controller inputs inside DUT)
  // Access signals through hierarchical references.
  initial begin
    wait(sys_rst_n);

    // Initialize the display_controller inputs
    dut.display_op       = display_op'(0);
    dut.display_data_in  = 26'h0;
    dut.buf_has_entry    = 0;
    dut.is_ready         = 1;     // LCD interface initially ready

    // Wait for startup sequence to finish
    repeat (200) @(posedge sys_clk);

    // → Example stimulus: trigger 3 writes
    send_char(8'h41); // 'A'
    send_char(8'h42); // 'B'
    send_char(8'h43); // 'C'

    repeat (300) @(posedge sys_clk);

    $display("[TB] Simulation completed.");
    $finish;
  end

  // ------------------------------------------
  //  Task: send a character to display_controller
  // ------------------------------------------
  task send_char(input byte data);
    begin
      $display("[TB] Sending character 0x%02h", data);

      // Pack into upper nibble protocol (whatever your design expects)
      dut.display_data_in = {data, 18'h0};

      dut.buf_has_entry = 1;   // Indicate data available
      @(posedge sys_clk);
      dut.buf_has_entry = 0;

      // Wait for lcd_interface READY cycle
      wait (dut.u_lcd_interface.o_is_ready == 1);
      repeat (10) @(posedge sys_clk);

      $display("[TB] Character 0x%02h processed.", data);
    end
  endtask


  // Dump waveforms
  initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);
  end

endmodule
