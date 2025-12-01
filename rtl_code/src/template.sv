module template (
  input  logic        i_clk,
  input  logic        i_rst_n,
  input  logic        i_signal1,
  input  logic [1:0]  i_signal2,
  output logic        o_signal3,
  output logic [1:0]  o_signal4
);

always_ff @(posedge i_clk) begin : register_block
  if (!i_rst_n) begin

  end else begin

  end
end

always_comb begin

end

endmodule
