module gerador_serial_8bit(input en, input clk, output reg serial);
  reg [2:0] count;
  reg [7:0] paralelo;
  wire clk_control;  

  initial begin
	paralelo = 8'b01100101;
  end
  
  assign clk_control = clk & en;
  
  
  always @(posedge clk_control) begin
	serial <= paralelo[count];
	count <= count + 1;
  end
endmodule
