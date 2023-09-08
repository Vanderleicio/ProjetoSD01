module ESCALONADOR(clk, transmissao_ence, sensor, sensor_preparado, dados);
	
	// UART tx informa que encerrou a transmiss~ao
	input transmissao_ence;
	// bit de cada controlador que diz se os bits do buffer est~ao prontos
	input [7:0] sensor_preparado;
	
	// Preciso de um cara que vai jogar aqui todos os sensores em um barramento
	input [127:0] sensor_barramento;// Todos os 8, cada um com (7 bits data + 5 ender  +4 comando = 16) 16*8
	
	// Sa´ida com 16 bits
	output reg[15:0] dados;
	
	integer sensor = 1;// Vai de 1 a 8
	
	always @ (posedge clk) begin
		// Se encerrei uma transmiss~ao
		if (transmissao_ence) begin
		end
		
		// Reseta o contador se j´a passei por todos
		if (sensor == 9) begin
			sensor = 1;
		end
		// Verifico se o sensor que estou dando a vez est´a pronto para enviar os dados
		// PRECISO MANTER A SA´IDA IGUAL ENQUANTO O TRANSMISSOR NAO TIVER TERMINADO
		if (sensor_preparado[sensor]) begin
			// Envio os dados
			dados = sensor_barramento[sensor*15:sensor*15-15];
		end
		// S´o incremento se eu comecei 
		sensor = sensor + 1;
	end
	
endmodule



// Ver se faço com as m´aquinas
