/**Módulo responsável pela transmissão na UART
O canal Tx fica em nível alto quando não está transmitindo nada
O módulo faz o envio de 2 bytes, envia primeiro 1 byte e já parte para o próximo.
O start-bit é colocando um nível baixo no tx , após isso envia-se os dados
Após os 8 bits de dados, joga o end-bit que é o nível lógico em 1 tx
espera n ciclos de clock e envia o segundo byte
*/

module transmissor_com_wait(clk_9k6hz, tx, data, en);

	input clk_9k6hz; // clock
	input en;// Sinal que, em 1, irá habilitar o processo de transmissão.
	
	input [0:15]data;  // dados a serem transmitidos, está invertido para mandar primeiro o 15 (menos significativo)
	output reg tx;  // pino de saída por onde trafegarão os bit em serial
	
	// Para lógica de estados
	reg [2:0] state;
	//
	parameter IDLE = 3'b000;
	parameter START= 3'b001;
	parameter DATA = 3'b010;
	parameter STOP = 3'b011;
	parameter WAIT = 3'b100;//Ver se é necessário esperar 1 ciclo ou 2 antes da segunda parte do bit
	integer waitCycles = 3;// Variável para contar o nº de ciclos que deve-se esperar antes de enviar o 2º byte

	integer pos = 15;// Indica qual o bit do array será transmitido
	
	// Só para iniciar em espera
	initial begin
		tx = 1'b1;
		state <= IDLE;
	end
	
	
	//wire clk_control = clk_9k6hz & en;//usar esse clk_control no always em vez de clk_9k6hz

	always @ (posedge clk_9k6hz) begin
		// Se recebe o en, passa pro próximo estado
		case (state)
			// PARADO
			IDLE:
				begin
					pos = 15;// Reinicia o indicador da posição p/ transmitir
					waitCycles = 3;
					tx = 1'b1;
					if (en) begin
						state = START;
					end
					else begin
						state = IDLE;
					end	
				end
			// COMEÇA A TRANSMISSÃO
			START:
				begin
					//if (~en) begin
						//state = IDLE;
					//end
					//else begin
						tx = 1'b0; //Informo o start-bit
						state = DATA;
					//end
				end
			// TRANSMITINDO OS DADOS
			DATA:
				begin
					tx = data[pos]; //
					pos = pos - 1;
					// Se encerrou a transmissão do primeiro byte
					if (pos == 7) begin
						state = STOP;
					end
					// Se encerrou a transmissão do segundo byte
					else if (pos == -1) begin
						state = STOP;
					end
					// Se está no meio do processo de enviar algum byte
					else begin
						state = DATA;
					end
				end
			// Encerrando a transmissão do byte
			STOP:
				begin
					tx = 1'b1;// Informe o stop-bit
					// Se ainda não terminei o segundo byte
					if (pos == 7) begin
						//state = START;// Sem espera
						state = WAIT;
					end
					// Se já encerrei todo o processo (2 bytes)
					else begin
						state = IDLE;
					end
				end
			// ESTADO QUE SÓ SERVE PARA GERAR UMA ESPERA DE 3 CICLOS PARA PODER MANDAR OS DOIS DADOS
			WAIT:
				begin
					tx = 1'b1;
					if (waitCycles != 0) begin
						waitCycles = waitCycles - 1;
						state = WAIT;
					end
					else begin
						state = START;
					end
				end
		endcase
	end

endmodule 