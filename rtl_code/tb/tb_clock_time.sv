`timescale 1ns/1ps

module tb_clock_time;

  // Parameters
  localparam int CLOCK_FREQUENCY = 2; // from DUT
  localparam real CLK_PERIOD = 10.0;  // 100 MHz clock

  // DUT signals
  logic i_clk;
  logic i_rst_n;
  logic i_mode_is_DT;
  logic i_time_left;
  logic i_time_up;
  logic [5:0]  o_time_sel;
  logic [19:0] o_time_read_time;

  // Instantiate DUT
  clock_time #(
    .CLOCK_FREQUENCY(CLOCK_FREQUENCY)
  ) dut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_mode_is_DT(i_mode_is_DT),
    .i_time_left(i_time_left),
    .i_time_up(i_time_up),
    .o_time_sel(o_time_sel),
    .o_time_read_time(o_time_read_time)
  );

  // Clock generation
  initial i_clk = 0;
  always #(CLK_PERIOD/2.0) i_clk = ~i_clk;

  // Reset sequence
  initial begin
    i_rst_n = 0;
    i_mode_is_DT = 0;
    i_time_left = 0;
    i_time_up = 0;
    #50;
    i_rst_n = 1;
    i_mode_is_DT = 1; // enable time counting
  end

  // Decode o_time_read_time into HH:MM:SS (based on your bit slicing)
  function automatic string format_time(input logic [19:0] t);
    int H2, H1, M2, M1, S2, S1;
    begin
      S1 = t[3:0];
      S2 = t[6:4];
      M1 = t[10:7];
      M2 = t[13:11];
      H1 = t[17:14];
      H2 = t[19:18];
      return $sformatf("%0d%0d:%0d%0d:%0d%0d", H2, H1, M2, M1, S2, S1);
    end
  endfunction

  // Monitor and print the time
  always @(posedge dut.o_time_sel[0]) begin
    $display("[%0t] Time = %s  (sel=%b)", $time, format_time(o_time_read_time), o_time_sel);
  end

  // Stop simulation after some time
  initial begin
    #1000_000_000; // run long enough to see rollovers
    $display("Simulation finished.");
    $finish;
  end

endmodule