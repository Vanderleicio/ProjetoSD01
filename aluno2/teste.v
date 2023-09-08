
module teste(bus, clk, y);
  input [7:0] bus;
  input clk;
  output reg y;
  
  reg [2:0] cont;
  
  always @(posedge clk) begin
	y <= bus[cont];
	cont <= cont + 1;
  end
endmodule