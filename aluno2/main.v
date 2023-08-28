module main(input clk, input rx, output led, output colum, output [7:0] linhas);
	wire clk_s, control;
	wire [7:0] data;
	baudRateGenerator geradot(clk, 1, clk_s);
	receptor recep(clk_s, rx, data, control, led);
	assign colum = 0;
	assign linhas = data;
endmodule
