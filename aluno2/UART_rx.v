module UART_rx(clk_9k6hz, rx, buffer, concluded);

	input clk_9k6hz; // clock
	input rx;		  // sinal vindo do pc	
	
	output reg concluded = 1'b0;// Sinal para informar, os outros módulos, que já recebi os 2 bytes
	
	// Dados recebidos armazenados em buffer
	output reg [15:0] buffer; // Só está aqui para garantir que o ENTREGADOR leve a requisição para o módulo correto a tempo, antes da UART receber outros dados e acabar sobreescrevendo tudo  
	reg [15:0] data_tmp;      // Regs com os dados temporários recebidos pela UART
	
	// Para lógica de estados
	reg [1:0] state;
	parameter IDLE = 2'b00;
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
			// Esperando o sinal de start
			START:
				begin
					// Se cheguei aqui, mas ja terminei o 2° byte. Volte a contar do inicio
					if (pos == 16) begin
						pos = 0;
						concluded = 1'b0;
					end
					// Se não recebi o start-bit
					if(rx) begin
						state = START;
					end
					// Se recebi o start-bit
					else
						state = DATA;
				end
			// Recebendo 8 bits
			DATA:
				begin
					data_tmp[pos] = rx;
					pos = pos + 1;
					// Se recebi o último bit do 1° byte
					if(pos == 8) begin
						state = STOP;
					end
					// Se recebi o último bit do 2° byte
					else if (pos == 16) begin 
						state = STOP;
					end
					// Caso contrário, continua no DATA
					else begin		
						state = DATA;
					end	
				end
			// Fim dos 8 bits
			STOP:
				begin
					// Se terminei o 2º byte, informo que terminei
					if (pos == 16) begin
						// Buffer recebendo os dados
						buffer[15:0] <= data_tmp[15:0];
						// Sinalizo aos outros módulos que tenho os 2 bytes prontos no buffer
						concluded = 1'b1; 
					end
					state = START;
				end
		endcase
	end
	
endmodule