
module main(input clk, input rx, input ch2, output led, output colum, output [7:0] linhas, output tx, output [1:0] debug2, output fim1, output fim2);
	wire clk_s, control;
	
	wire [7:0] data;
	baudRateGenerator geradot(clk, 1, clk_s);
	
	receptor recep(clk_s, rx, data, control, led);
	
	transmissor transm(clk, tx, 16'b1100001010000001, ch2, debug, fim1, fim2); //01000011 00000001
	
	assign colum = 0;
	assign linhas = data;
endmodule
