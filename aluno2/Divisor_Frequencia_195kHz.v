/** Divisor de clock que recebe 50Mhz e devolve um clock de 195kHz
Este módulo serve para ajudar a observar a duração dos pulsos emitidos pelo DHT11
e traduzir em um número binário equivalente.

- Para 195kHz tenho períodos de 0,00000512s  (Uso 8 regs)
- Para 97kHz tenho períodos de  0,00001024s  (Uso 9 regs)
*/
module Divisor_Frequencia_195kHz(clk_195kHz, clk_50Mhz);

	input clk_50Mhz;
	output reg clk_195kHz; //Clock dividido
	
	reg [8:0] ffs;  //Flip-Flops

	
	initial begin
		clk_195kHz = 1'b0; // desnecessário (testar para certeza)
		ffs = 9'b0; // Precisa de 9 zeros??
	end


	always @(posedge clk_50Mhz) begin
		ffs = ffs + 1'b1;
			if(ffs[8] == 1'b1) begin
				ffs = 9'b0;
				clk_195kHz = clk_195kHz + 1'b1;
			end
	end

endmodule
