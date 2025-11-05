// common_pkg.sv
package common_pkg;

  // -------------------------------------------------
  // Enumerations (for states, modes, etc.)
  // -------------------------------------------------
  //typedef enum logic [1:0] {
  //  CON_DISPLAY_TIME,       // 2'b00
  //  CON_SET_TIME,    // 2'b01
  //  CON_SET_ALARM,     // 2'b10
  //  CON_TOGGLE_ALARM       // 2'b11
  //} con_op_t;

  // typedef enum logic [1:0] {
  //   CL_DISPLAY_TIME,       // 2'b00
  //   CL_SET_TIME,    // 2'b01
  //   CL_SET_ALARM,     // 2'b10
  //   CL_TOGGLE_ALARM       // 2'b11
  // } clock_op_t;

  typedef struct packed {
    logic but_do_display_time;
    logic but_do_set_time;
    logic but_do_set_alarm;
    logic but_do_toggle_alarm;
    logic but_do_left;
    logic but_do_up;

  } con_op_t;

  typedef struct packed {
    logic clock_do_display_time;
    logic clock_do_set_time;
    logic clock_do_set_alarm;
    logic clock_do_toggle_alarm;
    logic clock_do_left;
    logic clock_do_up;

  } clock_op_t;

  // -------------------------------------------------
  // Parameters / constants
  // -------------------------------------------------
  localparam int CLOCK_FREQ_DEFAULT = 2;

endpackage : common_pkg