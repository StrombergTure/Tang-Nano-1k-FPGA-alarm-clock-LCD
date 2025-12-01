import common_pkg::*;
module clock_controller #(
  parameter int CLOCK_FREQUENCY = 2
)(
  input  logic                  i_clk,
  input  logic                  i_rst_n,
  
  // External inputs for controller logic
  //input  logic                  i_clock_left,
  //input  logic                  i_clock_up,
  input  clock_op_t               i_clock_control,
  //input  logic                  i_clock_op_en,
  
  // Outputs from the modules
  output logic [5:0]            o_clock_sel,
  output logic [19:0]           o_clock_val,
  output logic                  o_clock_do_ring,
  output logic                  o_clock_wr_en
);
  // 1. Define the states
  typedef enum logic [1:0] {
    S_DISPLAY_TIME,       // 2'b00
    S_SET_TIME,    // 2'b01
    S_SET_ALARM     // 2'b10
  } state_t;

  // time signals
  logic mode_is_DT;
  logic mode_wr_en;
  logic time_left;
  logic time_up;
  logic [5:0]  time_sel;
  logic [19:0] time_read_time;
  logic time_wr_en;

  // Alarm_time signals
  logic alarm_left;
  logic alarm_up;
  logic alarm_rst_sel;
  logic [5:0]  alarm_sel;
  logic [19:0] alarm_read_time;
  logic alarm_wr_en;

  // time equals alarm
  logic equals_alarm_time;

  // Registers
  state_t cur_state, nxt_state;
  logic cur_equals_edge, nxt_equals_edge;
  logic cur_alarm_is_on, nxt_alarm_is_on;

  always_ff @(posedge i_clk, negedge i_rst_n) begin : blockName
    if (!i_rst_n) begin
      cur_state             <= S_DISPLAY_TIME;
      cur_equals_edge       <= '0;
      cur_alarm_is_on       <= 1;
    end else begin
      cur_state             <= nxt_state;
      cur_equals_edge       <= nxt_equals_edge;
      cur_alarm_is_on       <= nxt_alarm_is_on;
    end
  end

  // edge detector for when alarm_time == clock_time
  assign nxt_equals_edge = equals_alarm_time;
  assign o_clock_do_ring = (cur_equals_edge == 0 && equals_alarm_time == 1 && cur_alarm_is_on) ? 1 : 0;

  always_comb begin
    // Default registers
    nxt_state = cur_state;
    nxt_alarm_is_on = cur_alarm_is_on;
    // Default outputs
    o_clock_sel = time_sel;
    o_clock_val = time_read_time;
    o_clock_wr_en = time_wr_en;

    // Default signals
    equals_alarm_time = 0;

    // Defauly clock_time
    mode_is_DT = 0;
    mode_wr_en = 0;
    time_left = 0;
    time_up = 0;
    // Default clock_alarm
    alarm_rst_sel = 0;
    alarm_left = 0;
    alarm_up = 0;

    // change to state and make submodules ready for inputs
    // if (i_clock_op_en) begin
    //   case (i_clock_op)
    //     CL_DISPLAY_TIME: begin
    //       mode_is_DT = 1;
    //       mode_wr_en = 1;
    //       nxt_state = S_DISPLAY_TIME;
    //     end
    //     CL_SET_TIME: begin
    //       mode_is_DT = 0;
    //       mode_wr_en = 1;
    //       nxt_state = S_SET_TIME;
    //     end
    //     CL_SET_ALARM: begin
    //       alarm_rst_sel = 1;
    //       nxt_state = S_SET_ALARM;
    //     end
    //     CL_TOGGLE_ALARM: begin
    //       nxt_alarm_is_on = ~cur_alarm_is_on;
    //     end

    //     default: begin

    //     end
    //   endcase
    // end
    if (i_clock_control.clock_do_display_time) begin
      mode_is_DT = 1;
      mode_wr_en = 1;
      nxt_state = S_DISPLAY_TIME;
    end else if (i_clock_control.clock_do_set_time) begin
      mode_is_DT = 0;
      mode_wr_en = 1;
      nxt_state = S_SET_TIME;
    end else if (i_clock_control.clock_do_set_alarm) begin
      alarm_rst_sel = 1;
    end else if (i_clock_control.clock_do_toggle_alarm) begin
      nxt_alarm_is_on = ~cur_alarm_is_on;
    end

    // What to do in each state
    case (cur_state)
      S_DISPLAY_TIME: begin
        if (time_read_time == alarm_read_time) begin
          equals_alarm_time = 1;
        end
        o_clock_sel = time_sel;
        o_clock_val = time_read_time;
        o_clock_wr_en = time_wr_en;
      end
      S_SET_TIME: begin
        time_left = i_clock_control.clock_do_left;
        time_up = i_clock_control.clock_do_up;
        o_clock_sel = time_sel;
        o_clock_val = time_read_time;
        o_clock_wr_en = time_wr_en;
      end
      S_SET_ALARM: begin
        alarm_left = i_clock_control.clock_do_left;
        alarm_up = i_clock_control.clock_do_up;
        o_clock_sel = alarm_sel;
        o_clock_val = alarm_read_time;
        o_clock_wr_en = alarm_wr_en;
      end

      default: begin

      end
    endcase
  end
  // -----------------------------
  // Instantiate clock_time
  // -----------------------------
  clock_time #(
      .CLOCK_FREQUENCY(CLOCK_FREQUENCY)
  ) u_clock_time (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_mode_is_DT(mode_is_DT),
      .i_mode_wr_en(mode_wr_en),
      .i_time_left(time_left),
      .i_time_up(time_up),
      .o_time_sel(time_sel),
      .o_time_read_time(time_read_time),
      .o_time_wr_en(time_wr_en)
  );
  // -----------------------------
  // Instantiate alarm_time
  // -----------------------------
  alarm_time #(
      .CLOCK_FREQUENCY(CLOCK_FREQUENCY)
  ) u_alarm_time (
      .i_clk(i_clk),
      .i_rst_n(i_rst_n),
      .i_alarm_left(alarm_left),
      .i_alarm_up(alarm_up),
      .i_alarm_rst_sel(alarm_rst_sel),
      .o_alarm_sel(alarm_sel),
      .o_alarm_read_time(alarm_read_time),
      .o_alarm_wr_en(alarm_wr_en)
  );

endmodule
