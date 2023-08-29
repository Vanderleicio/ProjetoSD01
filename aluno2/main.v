module main(input clk, input rx, input ch2, output led, output colum, output [7:0] linhas, output out);
	wire clk_s, control, debug;
	wire [7:0] data;
	
	baudRateGenerator geradot(clk, 1, clk_s);
	
	receptor recep(clk_s, rx, data, control, led);
	
	transmissor transm(clk, out, 16'b0100001001000001, ch2,  debug); 
	
	assign colum = debug;
	assign linhas = data;
endmodule
