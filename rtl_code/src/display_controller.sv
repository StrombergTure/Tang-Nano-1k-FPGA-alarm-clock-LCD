import common_pkg::*;

module display_controller(
  input  logic          i_clk,
  input  logic          i_rst_n,
  input  display_op     i_display_op,
  input  logic [25:0]   i_display_data,
  input  logic          i_buf_has_entry,
  input  logic          i_is_ready,
  output logic          o_buf_rd_en,
  output logic [3:0]    o_display_data,
  output logic          o_display_data_valid,
  output logic          o_RS
);



logic cur_state, nxt_state;
logic [3:0] cur_counter, nxt_counter;

always_ff @(posedge i_clk, negedge i_rst_n) begin : blockName
  if (!i_rst_n) begin
    cur_state       <= IDLE;
    cur_counter     <= '0;
  end else begin
    cur_state       <= nxt_state;
    cur_counter     <= nxt_counter;
  end
end

always_comb begin
  nxt_state = cur_state;
  o_buf_rd_en = 0;
  o_display_data_valid = 0;
  o_display_data = '0;
  o_RS = 0;
  nxt_counter = cur_counter;

  if (i_is_ready) begin
    nxt_counter = cur_counter + 1;
    o_display_data_valid = 1;
  end
  case (cur_counter)
  //STARTUP
    4'd0: begin
        o_display_data = 4'b0010;
    end
    4'd1: begin
        o_display_data = 4'b0010;
    end
    4'd2: begin
        o_display_data = 4'b1000;
    end
    4'd3: begin
        o_display_data = 4'b0000;
    end
    4'd4: begin
        o_display_data = 4'b0110;
    end
    // INIT_DT
    4'd5: begin
        o_display_data = 4'b1000;
    end
    4'd6: begin
        o_display_data = 4'b0110;
    end
    4'd7: begin
        o_display_data = 4'b0101;
    end
    4'd8: begin
        o_display_data = 4'b0100;
    end
    4'd9: begin
        o_display_data_valid = 0;
        nxt_counter = 0;
    end

    default: begin
      
    end
  endcase

  case (cur_state)
    IDLE: begin
      //if (i_buf_has_entry && i_is_ready) begin
    SEND_DATA: begin
      
    end
    end

    default: begin
        
    end
  endcase
end

endmodule
