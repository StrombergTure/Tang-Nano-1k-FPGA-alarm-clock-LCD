

module clock_time #(
  parameter int CLOCK_FREQUENCY = 2
) (
  input  logic          i_clk,
  input  logic          i_rst_n,
  input  logic          i_mode_is_DT,
  input  logic          i_mode_wr_en,
  input  logic          i_time_left,
  input  logic          i_time_up,
  output logic [5:0]    o_time_sel,
  output logic [19:0]   o_time_read_time,
  output logic          o_time_wr_en
);

logic [19:0]  cur_read_time, nxt_read_time;
logic [5:0]   cur_sel, nxt_sel;
logic [$clog2(CLOCK_FREQUENCY):0]  cur_time_counter, nxt_time_counter;
logic cur_time_wr_en_del, nxt_time_wr_en_del;

always_ff @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    cur_read_time     <= '0;
    cur_sel           <= '0;
    cur_time_counter  <= '0;
    cur_time_wr_en_del<= '0;
  end else begin
    cur_read_time     <= nxt_read_time;
    cur_sel           <= nxt_sel;
    cur_time_counter  <= nxt_time_counter;
    cur_time_wr_en_del<= nxt_time_wr_en_del;
  end
end

assign o_time_read_time = cur_read_time;
assign o_time_sel       = cur_sel;
assign o_time_wr_en     = cur_time_wr_en_del;

always_comb begin
  // output default
  nxt_time_wr_en_del = 0;
  // Register default
  nxt_time_counter  = cur_time_counter;
  nxt_sel           = cur_sel;
  nxt_read_time     = cur_read_time;

  if (i_mode_is_DT) begin
    nxt_time_counter = cur_time_counter +1;
    nxt_sel          = '0;
    if (cur_time_counter >= CLOCK_FREQUENCY- 1) begin
      nxt_time_wr_en_del = 1;
      nxt_time_counter = 0;
      nxt_sel[0] = 1;
      nxt_read_time[3:0] = cur_read_time[3:0] + 1;
      // S1
      if (cur_read_time[3:0] == 4'd9) begin
        nxt_read_time[3:0] = '0;
        nxt_read_time[6:4] = cur_read_time[6:4] + 1;
        nxt_sel[1] = 1;
        // S2
        if (cur_read_time[6:4] == 3'd5) begin
          nxt_read_time[6:4] = '0;
          nxt_read_time[10:7] = cur_read_time[10:7] + 1;
          nxt_sel[2] = 1;
          // M1
          if (cur_read_time[10:7] == 4'd9) begin
            nxt_read_time[10:7] = '0;
            nxt_read_time[13:11] = cur_read_time[13:11] + 1;
            nxt_sel[3] = 1;
            // M2
            if (cur_read_time[13:11] == 3'd5) begin
              nxt_read_time[13:11] = '0;
              nxt_read_time[17:14] = cur_read_time[17:14] + 1;
              nxt_sel[4] = 1;
              // H1
              if (cur_read_time[17:14] == 4'd9) begin
                nxt_read_time[17:14] = '0;
                nxt_read_time[19:18] = cur_read_time[19:18] + 1;
                nxt_sel[5] = 1;
              end
              if (cur_read_time[19:18] == 2'd2) begin
                // H2
                if (cur_read_time[17:14] == 4'd3) begin
                  nxt_read_time[19:18] = '0;
                  nxt_read_time[17:14] = '0;
                  nxt_sel[5] = 1;
                end
              end
            end
          end
        end
      end
    end

  end else begin
    if (i_mode_wr_en) begin
      nxt_sel = 6'b000001;
      nxt_time_counter = '0;
    end
    if (i_time_left) begin
      nxt_time_wr_en_del = 1;
      nxt_sel = {cur_sel[4:0], cur_sel[5]};
    end else if (i_time_up) begin
      nxt_time_wr_en_del = 1;
      case (cur_sel)
        6'b000001: begin
          nxt_read_time[3:0] = (cur_read_time[3:0] + 1) & 4'b1111;
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
end

endmodule
