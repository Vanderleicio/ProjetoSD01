module geradorMicrossegundo(
	input clk, 
	output microssegundo
);
	reg [5:0] counterClk = 0; //Contador para alcaçar o Clock Desejado
	reg invertedSignal; //Criado para passar o sinal para saída a cada atualização.
	
	
	//Como é necessario gerar um microsegundo, então é preciso alcançar o 1Mhz,
	//Então é necessario dividir 50mhz por 50 para alcaçar esse valor e ainda divir por dois para durar cada borda.
	always @(posedge clk) begin
	
		counterClk  <= counterClk +1;
		
		if(counterClk == 24) begin // 24 por questão de indice
			counterClk <= 0;
			invertedSignal <= !invertedSignal; 
		end
	end
	
	assign microssegundo = invertedSignal; // Assimilar a saída ao sinal invertido.


endmodule 