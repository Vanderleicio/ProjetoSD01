module receptor(clk_9k6hz, rx, data, concluded);

	input clk_9k6hz; // clock
	//input en;// Sinal que, em 1, irá habilitar o processo de recepçao.
	input rx;		// sinal vindo do pc	
	
	output reg concluded = 1'b0;// Sinal para informar que recebi 2 bytes
	
	output reg [15:0]data;           //registrador de dados que enviará os dados recebidos para o decodificador
	reg [15:0]buffer;            //buffer temporário para receber os dados
	
	// Para lógica de estados
	reg [1:0] state;
	//
	parameter START= 2'b01;
	parameter DATA = 2'b10;
	parameter STOP = 2'b11;		 

	integer pos = 0;// Indica qual o bit do array será transmitidos	
	// Só para iniciar em espera
	initial begin
		concluded = 1'b0;
		state <= START;
	end
	
	
	always @ (posedge clk_9k6hz) begin
		case (state)
			// Fica esperando o sinal de start
			START:
				begin
					// Se cheguei aqui, mas ja terminei o 2° byte. Volte a contar do inicio
					if (pos == 16) begin
						pos = 0;
						concluded = 1'b0;
					end
					
					if(rx) begin// Nao recebi o start-bit
						state = START;
					end
					else// Recebi o start-bit
						state = DATA;
				end
			DATA:
				begin
					data[pos] = rx;
					pos = pos + 1;
					if(pos == 8) begin// Acabou a recepção do 1° byte
						state = STOP;
					end
					else if (pos == 16) begin// Acabou a recepção do 2° byte
						state = STOP;
					end
					else begin// Continua no DATA
						//buffer[counter] = rx;
						//counter = counter + 1;		
						state = DATA;
					end	
				end
			STOP:
				begin
					// Se terminei o 2º byte, informo que terminei
					//if (pos == 8) begin
					//	data[7:0] = buffer[7:0];
					//end
					if (pos == 16) begin
						//data[15:0] <= buffer[15:0];// registrador data recebe o buffer que é passado para saída
						concluded = 1'b1; // Informa 
					end
					state = START;
				end
		endcase
	end
	
endmodule