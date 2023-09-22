module baudRateGenerator(clk_in, reset, out);
	input clk_in;
	input reset;	
	
	reg [12:0]baud_Rate = 13'b1010001011000;
	reg [12:0]baudRateReg; 
		
	
	output out;
	
	always @(posedge clk_in or negedge reset)
		 if (!reset) baudRateReg <= 13'b1;
		 
		 else if (out) baudRateReg <= 13'b1;
				else baudRateReg <= baudRateReg + 1'b1;
				
	assign out = (baudRateReg == baud_Rate);


	
endmodule