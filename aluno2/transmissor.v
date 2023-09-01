/**Módulo responsável pela transmissão na UART
O canal Tx fica em nível alto quando não está transmitindo nada
O módulo faz o envio de 2 bytes, envia primeiro 1 byte e já parte para o próximo.
O start-bit é colocando um nível baixo no tx , após isso envia-se os dados
Após os 8 bits de dados, joga o end-bit que é o nível lógico em 1 tx
*/

module transmissor(clk_9k6hz, tx, data, en, state, fim1, fim2);

	input clk_9k6hz; // clock
	input en;// Sinal que, em 1, irá habilitar o processo de transmissão.
	
	input [0:15]data;  // dados a serem transmitidos, está invertido para mandar primeiro o 15 (menos significativo)
	output reg tx, fim1, fim2;  // pino de saída por onde trafegarão os bit em serial
	
	// Para lógica de estados
	output reg [2:0] state;
	reg [2:0] nextstate;
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
		fim1 = 1'b0;
		fim2 = 1'b0;
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
					if (~en) begin
						state = IDLE;
					end
					else begin
						// Informo que vou começar a transmitir
						tx = 1'b0; //Ver para pôr no assign
						state = DATA;
					end
				end
			// TRANSMITINDO OS DADOS
			DATA:
				begin
					tx = data[pos]; //Ver para pôr no assign
					pos = pos - 1;
					// Se já transmitiu o primeiro byte
					if (pos == 7) begin
						state = STOP;
					end
					else if (pos == -1) begin
						state = STOP;
					end
					else begin
						//tx = data[pos]; //Ver para pôr no assign
						//pos = pos - 1;
						state = DATA;
					end
				end
			STOP: //15 14 13 12 11 10 9 8
				begin
					tx = 1'b1;
					if (pos == 7) begin
						fim1 = 1'b1;
						state = START;// Sem espera
						//state = WAIT;
					end
					else begin
						fim2 = 1'b1;
						state = IDLE;
					end
				end
		endcase
	end

endmodule 