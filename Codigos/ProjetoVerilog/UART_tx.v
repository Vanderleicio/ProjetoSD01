/**Módulo responsável pela transmissão na UART
O canal Tx fica em nível alto quando não está transmitindo nada
O módulo faz o envio de 2 bytes, envia primeiro 1 byte e já parte para o próximo.
O start-bit é colocando um nível baixo no tx , após isso envia-se os dados
Após os 8 bits de dados, joga o end-bit que é o nível lógico em 1 tx
espera n ciclos de clock e envia o segundo byte
*/

module UART_tx(clk_9k6hz, tx, data, en, done);

	input clk_9k6hz; // clock
	input en;// Sinal que, em 1, irá habilitar o processo de transmissão.
	
	input [15:0]data;  // dados a serem transmitidos, está invertido para mandar primeiro o 15 (menos significativo)
	reg [15:0] buffer;
	output reg tx;  // pino de saída por onde trafegarão os bit em serial
	output reg done;
	
	// Para lógica de estados
	reg [1:0] state;
	//
	parameter IDLE = 2'b00;
	parameter START= 2'b01;
	parameter DATA = 2'b10;
	parameter STOP = 2'b11;

	integer pos = 0;// Indica qual o bit do array será transmitido
	
	// Só para iniciar em espera
	initial begin
		done = 1'b0;
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
					done = 1'b0;
					pos = 0;// Reinicia o indicador da posição p/ transmitir
					tx = 1'b1;
					if (en) begin
						buffer <= data;
						state = START;
					end
					else begin
						state = IDLE;
					end	
				end
			// COMEÇA A TRANSMISSÃO
			START:
				begin
					if (en) begin
						tx = 1'b0; //Informo o start-bit
						state = DATA;
					end
					else begin
						state = IDLE;
					end
				end
			// TRANSMITINDO OS DADOS
			DATA:
				begin
					if (en) begin
							tx = buffer[pos]; //
							pos = pos + 1;
							// Se encerrou a transmissão do primeiro byte
							if (pos == 8) begin
								state = STOP;
							end
							// Se encerrou a transmissão do segundo byte
							else if (pos == 16) begin
								state = STOP;
							end
							// Se está no meio do processo de enviar algum byte
							else begin
								state = DATA;
							end
						end
					else begin
							state = IDLE;
					end	
	
				end
			// Encerrando a transmissão do byte
			STOP:
				begin
					tx = 1'b1;// Informe o stop-bit
					// Se ainda não terminei o segundo byte
					if (pos == 8) begin
						state = START;// Sem espera
					end
					// Se já encerrei todo o processo (2 bytes)
					else begin
						done = 1'b1;
						state = IDLE;
					end
				end
		endcase
	end

endmodule 