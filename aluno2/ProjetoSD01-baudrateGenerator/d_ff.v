// flip flop d
module d_ff(input d,
		   input clk,
			output reg q);

  always @ (posedge clk)
	q<=d;
  
endmodule

