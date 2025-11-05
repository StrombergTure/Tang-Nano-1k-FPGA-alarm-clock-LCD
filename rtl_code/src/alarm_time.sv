module alarm_time #(
  parameter int CLOCK_FREQUENCY = 2
) (
  input  logic          i_clk,
  input  logic          i_rst_n,
  input  logic          i_alarm_left,
  input  logic          i_alarm_up,
  input  logic          i_alarm_rst_sel,
  output logic [5:0]    o_alarm_sel,
  output logic [19:0]   o_alarm_read_time,
  output logic          o_alarm_wr_en
);

logic [19:0]  cur_read_time, nxt_read_time;
logic [5:0]   cur_sel, nxt_sel;
logic cur_alarm_wr_en_del, nxt_alarm_wr_en_del;

always_ff @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    cur_read_time     <= '0;
    cur_sel           <= 6'd000001;
    cur_alarm_wr_en_del<= '0;
  end else begin
    cur_read_time     <= nxt_read_time;
    cur_sel           <= nxt_sel;
    cur_alarm_wr_en_del<= nxt_alarm_wr_en_del;
  end
end

assign o_alarm_read_time = cur_read_time;
assign o_alarm_sel       = cur_sel;
assign o_time_wr_en      = cur_alarm_wr_en_del;

always_comb begin
  nxt_sel           = cur_sel;
  nxt_read_time     = cur_read_time;
  nxt_alarm_wr_en_del = 0;

  if (i_alarm_rst_sel) begin
    nxt_sel = 6'b000001;
  end
  if (i_alarm_left) begin
    nxt_alarm_wr_en_del = 1;
      nxt_sel = {cur_sel[4:0], cur_sel[5]};
    end else if (i_alarm_up) begin
      nxt_alarm_wr_en_del = 1;
      case (cur_sel)
        6'b000001: begin
          nxt_read_time[3:0] = cur_read_time[3:0] + 1;
          if (cur_read_time[3:0] == 4'd9) begin
            nxt_read_time[3:0] = '0;
          end
        end

        6'b000010: begin
          nxt_read_time[6:4] = cur_read_time[6:4] + 1;
          if (cur_read_time[6:4] == 4'd6) begin
            nxt_read_time[6:4] = '0;
          end
        end

        6'b000100: begin
          nxt_read_time[10:7] = cur_read_time[10:7] + 1;
          if (cur_read_time[10:7] == 4'd9) begin
            nxt_read_time[10:7] = '0;
          end
        end

        6'b001000: begin
          nxt_read_time[13:11] = cur_read_time[13:11] + 1;
          if (cur_read_time[13:11] == 4'd6) begin
            nxt_read_time[13:11] = '0;
          end
        end

        6'b010000: begin
          nxt_read_time[17:14] = cur_read_time[17:14] + 1;
          if (cur_read_time[17:14] == 4'd9) begin
            nxt_read_time[17:14] = '0;
          end
        end

        6'b100000: begin
          nxt_read_time[19:18] = cur_read_time[19:18] + 1;
          if (cur_read_time[19:18] == 4'd2) begin
            nxt_read_time[19:18] = '0;
          end
        end

        default :;
      endcase
    end
end

endmodule
