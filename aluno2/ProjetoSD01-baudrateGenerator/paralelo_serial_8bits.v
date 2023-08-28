module paralelo_serial_8bits(paralelo, control, clk, serial);
  input [7:0] paralelo;
  input clk, control;
  output reg serial;
  
  wire controlador;
  
  assign controlador = clk & control;
  reg [2:0] cont;
  
  always @(posedge controlador) begin
	serial <= paralelo[cont];
	cont <= cont + 1;
  end
endmodule