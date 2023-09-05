// Modulo DHT11

module DHT11 (
	input clk, 
	input en,
	input rst,
	inout dht_data, //Pino em tri-state
	output [39:0] data_out, 
	output WAIT, //Informa quando o circuito está operando e aguardando algum retorno do dht11
	output reg error
	);
	
	reg dht_out, dir, wait_reg, debug_reg; // Registradores de saída
	reg [25:0] counter; //Contador de ciclos para gerar delays
	reg [5:0] index;
	reg [39:0] intdata; // Armazenar as informações que serão obtidas do dht11, como se fosse uma memória cache
	wire dht_in;
	
	assign WAIT = wait_reg;
	
	//dir - Informa ao tri se queremos que o pino inout atue como entrada ou saída
	// dht_out - Dado que será enviado para fora quando o pino estiver em modo de saída
	// dht_int - Dado que será lido a partir do pino quando estiver em modo de entrada
	TRIS TRIS_DATA( .PORT(dht_data), .DIR(dir), .SEND(dht_out), .READ(dht_in));
	
	
	// Conexões dos valores, o intdata é associado de forma invertida, pois ele conecta o mais significativo
	// com o menos significativo, já que os dados virão assim
	assign data_out [39:0] = intdata [39:0];
	
	
	// Inicialização máquina de estados
	
	reg [3:0] STATE;
	
	// Definição de estados
	parameter S0=1, S1=2, S2=3, S3=4, S4=5, S5=6, S6=7, S7=8, S8=9, S9=10, STOP=0, START =11;
	
	
	// Processamento da máquina
	always @(posedge clk)
	begin: FSM
			if (rst == 1'b1)
			begin
				dht_out <= 1'b1;
				wait_reg <= 1'b0;
				counter <= 26'b00000000000000000000000000;
				intdata <= 40'b0000000000000000000000000000000000000000; // Banco de registradores limpo
				dir <= 1'b1; // Configurando o pino para saida
				error <= 1'b0;
				STATE <= START;
			end else begin
		
				case (STATE)
					START: 
						begin 
							wait_reg <= 1'b1;
							dir <= 1'b1; // Direção alterada para saída 
							dht_out <= 1'b1;
							STATE <= S0;
						end
						
					S0:
						begin
							dir <= 1'b1;
							dht_out <= 1'b1;
							wait_reg <= 1'b1;
							error <= 1'b0;
							if  (counter < 900000) //nesse caso ele trabalha com o clock de 50 MHZ, por isso basta aguardar 900.000 ciclos de clock para termos 18ms
							begin
								counter <= counter + 1'b1;
							end else begin
								counter <= 26'b00000000000000000000000000;
								STATE <= S1;
							end
						end
						
					
					S1:
						begin
							dht_out <= 1'b0;
							wait_reg <= 1'b1;
							if  (counter < 900000)
							begin
								counter <= counter + 1'b1;
							end else begin
								counter <= 26'b00000000000000000000000000;
								STATE <= S2;
							end
						end
						
					S2: 
						begin
							dht_out <= 1'b1; //Leva para 1 mantendo o pino como saída e aguarada 20 uS (tempo de resposta do dht entre 20 e 40)
							if(counter < 1000)
							begin 
								counter <= counter + 1'b1;
							end else begin
								dir <= 1'b0; // Após os 20uS mudamos a direção do pino para entrada, para o dht comutar como nível lógico baixo
								STATE <= S3;
							end
						end
						
					S3: 
						begin
							if (counter < 3000 && dht_in == 1'b1) // Se o counter for menor que 60uS e o dht_in ainda for 1, significa que o dht ainda n respondeu
							begin
								counter <= counter + 1'b1;
								STATE <= S3;
							end else begin
								if(dht_in == 1'b1) // se for nível lógico alto, significa que estourou o tempo limite
								begin 
									error <= 1'b1;	
									counter <= 26'b00000000000000000000000000;
									STATE <= STOP;
								end else begin		// se não, significa que o dht respondeu e passa para o próximo estado
									counter <= 26'b00000000000000000000000000;
									STATE <= S4;
								end
							end
						end
					
					S4: 
						begin
							//detecta pulso de sincronismo
							if(dht_in == 1'b0 && counter < 4400) // Se dht_in == 0 significa que respondeu corretamente, então ele aguarda 88uS
							begin 
								counter <= counter + 1'b1;
								STATE <= S4;
							end else begin
								if(dht_in == 1'b0)
								begin
									error <= 1'b1;
									counter <= 26'b00000000000000000000000000;
									STATE <= STOP;
								end else begin	// se o dht é 0 e o counter não atingiu o limite, significa que ele comutou para o nível lógico alto e enviou a primeira parte do sinal de sincronismo
									STATE <= S5; 
									counter <=  26'b00000000000000000000000000;
								end
							end
						end
					
					S5: 
						
						begin
							//detecta pulso de sincronismo - 2
							if(dht_in == 1'b1 && counter < 4400) 
							begin 
								counter <= counter + 1'b1;
								STATE <= S5;
							end else begin
								if(dht_in == 1'b1)
								begin
									error <= 1'b1;
									counter <= 26'b00000000000000000000000000;
									STATE <= STOP;
								end else begin	// se não estourou o counter e o dht == 0, significa que concluiu o sincronismo  
									STATE <= S6;
									error <= 1'b0;
									index <= 6'b000000; // reseta o indexador	
									counter <=  26'b00000000000000000000000000;
								end
							end
						end
					
					//inicio da analise de dados
					// pulsos com largura menores que 30us são bits '0', pulsos com largura maiores que 60 us serão bit '1'
					S6:
						begin 
							if(dht_in == 1'b0) // arguarde do pulso de dados
							begin 
								STATE<= S7;
							end else begin 
								error <= 1'b1;
								counter <= 26'b00000000000000000000000000;
								STATE <= STOP;
							end
						end
						
					S7:
					
						begin
							if(dht_in == 1'b1)
							begin 
								counter <= 26'b00000000000000000000000000;
								STATE <= S8;
							end else begin
								if (counter <1600000) //verificar se estourou o tempo 32mS, verificação para caso dht tenha travado
								begin
									counter <= counter +1'b1;
									STATE <= S7;
								end else begin
									counter <= 26'b00000000000000000000000000;
									error <= 1'b1;
									STATE <= STOP;
								end
							end
						end
						
					S8: //Aguarda comutação para 0
					
						begin
							if(dht_in == 1'b0) //50Mhz = 0,02 us -> 60uS = 2500 ciclos de clock
							
							begin
								if(counter > 2500) //se o contador estiver maior que 50uS o bit recebe 1
								begin
									intdata[index] <= 1'b1;
								end else begin //se o contador estiver menor que 50uS o bit recebe 0
									intdata[index] <= 1'b0;
								end
								
								if(index<39)
								begin 
									counter <= 26'b00000000000000000000000000;
									STATE <= S9;
								end else begin
									error <= 1'b0;
									STATE <= STOP;
								end
												
						end else begin 
						
							counter <= counter + 1'b1;
							if(counter > 1600000) // caso mais de 32uS de espera, aborta
							begin 
								error <= 1'b1;
								STATE <= STOP;
							end

						end
					end
					
				S9:
					begin
						index <= index+ 1'b1; //incrementa o registrador
						STATE<= S6;
					end
					
				STOP: 
					begin 
						STATE <= STOP;
						if ( error == 1'b0 )
						begin  //resetando
							dht_out <= 1'b1;
							wait_reg <= 1'b0;
							counter <= 26'b00000000000000000000000000;
							dir <= 1'b1;
							error <= 1'b0;
							index <= 6'b000000;
						end else begin 
							if(counter < 1600000 ) // se tiver erro bloqueia a estrutura por 32ms
							begin 
								intdata <= 40'b0000000000000000000000000000000000000000;
								counter <= counter + 1'b1;
								error <= 1'b1;
								wait_reg <= 1'b1;
								dir <= 1'b0; // configura pino entrada
							end else begin
								error <= 1'b0; // volta o error para 0 para resetear tudo
							end
						end
					end
					
				endcase
				
			end
		end
		
		

endmodule 


	
	
	
	
