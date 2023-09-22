module dhtAlt(
	input clk, 							//clk de 1 microssegundo
	inout dht_data, 			//pino de data do dht11
	input start_bit, 					//sinal de start para a máquina começar
	output reg errorSensor, 		//pino de identificação de erro
	output reg done,                //reg de 1 bit para indicação de conclusão
	output [7:0]hum_int, 			//parte inteira da humidade
	output [7:0]hum_float, 			//parte float da humidade
	output [7:0]temp_int, 			//parte inteira da temperatura
	output [7:0]temp_float, 		//parte float da temperatura
	output [7:0]check_sum 			//8 bits de checagem
	);
	
	reg direction; 			//registrador de 1 bit da direção do pino de data 
	reg [14:0]counter; 				//contador de 1 em 1 microssegundo
	reg [5:0]index; 					//registrador de index
	reg [39:0]temp_data; 			//registrador temporário de 40 bits
	reg send; 					//registrador de 1 bit que manda sinal da fpga para o dht11
	wire read; 					//leitura do dht11
	reg error; 							// Erro que aconteceu durante o procedimento
	
	//triState tris0(dht_data, direction, send, read);
	
	//tristates que alternam os 32 dht_data de input para output
	TRIS tris(dht_data, direction, send, read);
	
	reg [3:0]state = 0; //registrador do estado
	
	//estados possíveis
	parameter IDLE=0, START=1, DETECT_SIGNAL=2, WAIT_DHT11=3, DHT11_RESPONSE=4, 
	DHT11_HIGH_RESPONSE=5, TRANSMIT=6, DETECT_BIT=7, WAIT_SIGNAL=8, STOP = 9;
	
	//copia os valores da variável temporária para a saída
	assign hum_int[7:0] = temp_data[39:32];
	assign hum_float[7:0] = temp_data[31:24];
	assign temp_int[7:0] = temp_data[23:16];
	assign temp_float[7:0] = temp_data[15:8];
	assign check_sum[7:0] = temp_data[7:0];

	
	initial begin
		send <= 1;
		direction <= 1; //Direção é do FPGA para o sensor
	end
	
	always @(posedge clk) begin
		
		case(state)
			IDLE: begin//Se estado for IDLE
				error <= 0;
				done <= 0;
				errorSensor <=0;
				if (start_bit ==1) begin
					temp_data = 0; //temp_data resetado
					index = 0; //index resetado
					send <= 0; //envia 0 para o sensor
					counter <= 0; //contador resetado	
					state <= START;
				end	
			end
			START: begin//Se estado for START
				counter <= counter + 1;
				if(counter == 19000) begin //Quando chegar a 19ms...
					counter <= 0; //reseta o contador
					send <= 1; //envia 1 para o sensor
					state <= DETECT_SIGNAL; //próximo estado
				end
			end
			
			DETECT_SIGNAL:begin//Se estado for DETECT_SIGNAL // 2
				counter <= counter + 1;
				if(counter == 20) begin //Enquanto não der 20us...
					counter <= 0; //reseta o contador
					direction <= 0; //agora o dht11 que manda sinal para a FPGA
					state <= WAIT_DHT11; //próximo estado
				end
			end
			
			WAIT_DHT11: begin//Se estado for WAIT_DHT11  // 3
				counter <= counter + 1;
				if(counter == 21 || read == 0) begin //Enquanto não der 40 ou 41us...
					counter <= 0; //reseta o contador
					direction <= 0; //agora o dht11 que manda sinal para a FPGA
					state <= DHT11_RESPONSE; //próximo estado
				end
			end
			
			DHT11_RESPONSE:  begin//Se estado for DHT11_RESPONSE // 4
				counter <= counter + 1;
				if(read == 1 || counter == 100) begin //enquanto o sinal for 0 e contagem durar até 80 us...
					counter <= 0;
					if(read == 0) begin //caso passado o tempo e o dht11 manteve o 0 de sinal, deu erro
						error <= 1;
						state <= WAIT_SIGNAL; //estado de STOP
					end else begin //caso passado o tempo ou dht11 mudou o sinal para 1
						state <= DHT11_HIGH_RESPONSE; //próximo estado
					end
				end 
			end
			
			DHT11_HIGH_RESPONSE: begin//Se estado for DHT11_HIGH_RESPONSE  // 5
				counter <= counter + 1;
				if(read == 0 || counter == 100) begin //enquanto o sinal for 1 e contagem durar até uns 100 us... ***
					if(read == 1) begin //caso passado o tempo e o dht11 manteve o 1 de sinal, deu erro
						counter <= 0;
						error <= 1;
						state <= WAIT_SIGNAL; //estado de STOP
					end else begin //caso passado o tempo ou dht11 mudou o sinal para 0 ******
						counter <= 0;
						state <= TRANSMIT; //próximo estado
					end
				end
			end
			
			TRANSMIT: begin//Se estado for TRANSMIT (começa transmissão dos bits) // 6
				if(index < 40) begin //enquanto index for menor que 40
					counter <= counter + 1;
					if(read == 1 || counter == 70) begin //enquanto o sinal for 0 e contagem durar até 50 us...
						counter <= 0;
						if(read == 0) begin //caso passado o tempo e o dht11 manteve o 0 de sinal, deu erro
							error <= 1;
							state <= WAIT_SIGNAL; //estado de STOP
						end else begin //caso passado o tempo ou dht11 mudou o sinal para 1
							state <= DETECT_BIT; //próximo estado
						end
					end
				end else begin //estorou o número limite de 40 bits
					state <= WAIT_SIGNAL; //estado de STOP
				end
			end
			
			DETECT_BIT: begin//Se estado for DETECT_BIT (detecção se o bit é 0 ou 1) // 7
				if(read == 1) begin //enquanto a leitura do sinal for 1
					counter <= counter + 1;
				end else begin
					if(counter > 50) begin //se a contagem do tempo extrapolou 50us(Meio a meio do limite 30 ~ 70us) 
						temp_data[39-index] <= 1; //bit 1
					end else begin //senão
						temp_data[39-index] <= 0; //bit 0
					end
					counter <= 0; //reseta contador
					index <= index + 1; //incrementa em 1 o index
					state <= TRANSMIT; //volta para transmit
				end
			end
			WAIT_SIGNAL: begin// Tempo para aguardar livramento do sinal pelo dht11 // 8
				counter <= counter + 1;
				if (counter == 100) begin // Tempo de 100us para garantir que está livre para uso novamente
					counter <= 0;
					send <=1;
					direction <= 1; //Direção é do FPGA para o sensor
					state <= STOP; // Volta para o estado final da maquina.
				end
			end
			
			STOP: begin//Se o estado for STOP, parou a transmissão com sucesso ou erro // 9
				if(error == 1)
					errorSensor <= 1;
				done <= 1;
				state <= IDLE; // Manda para o estado inicial.
			end
			
		endcase
	end
	
	
	
endmodule 	