`timescale 1ns/1ps

module tb_clock_time_manual;

  // -------------------------------------------------
  // DUT signals
  // -------------------------------------------------
  logic          i_clk;
  logic          i_rst_n;
  logic          i_mode_is_DT;    // 0 = manual mode
  logic          i_mode_wr_en;
  logic          i_time_left;
  logic          i_time_up;
  logic  [5:0]   o_time_sel;
  logic  [19:0]  o_time_read_time;

  // -------------------------------------------------
  // Instantiate the DUT
  // -------------------------------------------------
  clock_time #(
    .CLOCK_FREQUENCY(2)
  ) dut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_mode_is_DT(i_mode_is_DT),
    .i_mode_wr_en(i_mode_wr_en),
    .i_time_left(i_time_left),
    .i_time_up(i_time_up),
    .o_time_sel(o_time_sel),
    .o_time_read_time(o_time_read_time)
  );

  // -------------------------------------------------
  // Clock generation
  // -------------------------------------------------
  always #5 i_clk = ~i_clk;  // 100 MHz -> 10 ns period

  // -------------------------------------------------
  // Helper task to display all digits in decimal
  // -------------------------------------------------
  task display_digits;
    $display("[%0t] Time: S1=%0d S2=%0d M1=%0d M2=%0d H1=%0d H2=%0d sel=%b",
      $time,
      o_time_read_time[3:0],    // S1
      o_time_read_time[6:4],    // S2
      o_time_read_time[10:7],   // M1
      o_time_read_time[13:11],  // M2
      o_time_read_time[17:14],  // H1
      o_time_read_time[19:18],  // H2
      o_time_sel
    );
  endtask

  // -------------------------------------------------
  // Test sequence
  // -------------------------------------------------
  initial begin
    // Initialize inputs
    i_clk          = 0;
    i_rst_n        = 0;
    i_mode_is_DT   = 0;  // Manual mode
    i_mode_wr_en   = 0;
    i_time_left    = 0;
    i_time_up      = 0;

    // Reset pulse
    #20;
    i_rst_n = 1;
    $display("[%0t] Reset released.", $time);

    // -------------------------------------------------
    // Step 1: Enter write mode
    // -------------------------------------------------
    #10;
    i_mode_wr_en = 1; #10; i_mode_wr_en = 0;
    $display("[%0t] Write mode enabled, sel=%b", $time, o_time_sel);

    // -------------------------------------------------
    // Step 2: Increment first digit several times
    // -------------------------------------------------
    repeat (5) begin
      #20;
      i_time_up = 1; #10; i_time_up = 0;
      #10;
      display_digits();
    end

    // -------------------------------------------------
    // Step 3: Move selection LEFT and increment new digit
    // -------------------------------------------------
    repeat (5) begin
      #20;
      i_time_left = 1; #10; i_time_left = 0;
      #10;
      $display("[%0t] LEFT pressed -> sel=%b", $time, o_time_sel);

      repeat (2) begin
        #20;
        i_time_up = 1; #10; i_time_up = 0;
        #10;
        display_digits();
      end
    end

    // -------------------------------------------------
    // Step 4: Cycle through all digits with increments
    // -------------------------------------------------
    for (int i = 0; i < 6; i++) begin
      #30;
      i_time_left = 1; #10; i_time_left = 0;
      #10;
      $display("[%0t] LEFT pressed -> sel=%b", $time, o_time_sel);

      repeat (3) begin
        #20;
        i_time_up = 1; #10; i_time_up = 0;
        #10;
        display_digits();
      end
    end

    // -------------------------------------------------
    // Step 5: Test overflow behavior
    // -------------------------------------------------
    $display("[%0t] Testing overflow behavior...", $time);
    for (int j = 0; j < 20; j++) begin
      #20;
      i_time_up = 1; #10; i_time_up = 0;
      #10;
      display_digits();
    end

    // -------------------------------------------------
    // Step 6: Simulation complete
    // -------------------------------------------------
    #50;
    $display("[%0t] Simulation complete.", $time);
    $stop;
  end

endmodule
