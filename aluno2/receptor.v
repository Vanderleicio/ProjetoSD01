module receptor(clk_115200hz, rx, data, control, led);

	input clk_115200hz, rx;		// in = sinal vindo da raspberry	
	output control, led;				// sinal de enable do decodificador
	reg control = 1'b0;
	
	output [7:0]data;           // registrador de dados que enviará os dados recebidos para o decodificador
	reg [7:0]data;	
	reg [7:0]buffer;            //buffer temporário para receber os dados
	reg [1:0]state;				// registrador de estados da maquina de estados
		parameter START = 0, 
					 DATA = 1,
					 STOP = 2;			 

	integer counter = 0;		

	always @ (posedge clk_115200hz) begin
		case (state)
			START:
				begin
					if(rx) begin		// in == 1 => idle
						control = 1'b0;
						state <= START;
					end
					else					// in == 0 => start bit
						state <= DATA;
				end
			DATA:
				begin
					if(counter > 7) begin  // Se counter > 7 acabou a recepção
						control = 1'b0;
						state <= STOP;
					end
					else begin		    	// Se counter < 7 armazena o bit atual no buffer e incrementa counter
						buffer[counter] = rx;
						counter = counter + 1;		
						state <= DATA;
					end	
				end
			STOP:
				begin
					data[7:0] <= buffer [7:0];  // registrador data recebe o buffer que é passado para saída
					counter <= 0; 				// reseta counter
					control <= 1'b1;			// seta o controle do decodificador em 1
					state <= START;
					
				end
		endcase
	end
	
	assign led = (data == 8'b00110010);
endmodule