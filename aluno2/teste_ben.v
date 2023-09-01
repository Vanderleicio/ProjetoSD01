module teste_ben(input cc, output out);
	reg [6:0] data = 7'b0110001;
	integer i=7;
	
	always @ (posedge cc) begin
		if (i>=0) begin
			i = i-1;
		end
	end
	
	assign out = data[i];

endmodule
