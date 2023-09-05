// Módulo DHT11

module DHT11 (
	input clk50mhz, 
	input en,
	input rst,
	inout dht_data, //Pino em tri-state
	output [39:0] data_out, 
	output WAIT, //Informa quando o circuito está operando e aguardando algum retorno do dht11
	output reg error
	);
	
	reg dht_out, dir, wait_reg, debug_reg; // Registradores de saída
	reg [25:0] counter; //Contador de ciclos - gera o tempo de espera
	reg [5:0] index; // Indexa os barramentos
	reg [39:0] intdata; // Armazenar as informações que serão obtidas do dht11 internamente
	wire dht_in;
	
	assign WAIT = wait_reg;
	
	// dir - Informa ao tri se queremos que o pino inout atue como entrada ou saída
	// dht_out - Dado que será enviado para fora quando o pino estiver em modo de saída
	// dht_int - Dado que será lido a partir do pino quando estiver em modo de entrada
	TRIS TRIS_DATA( .PORT(dht_data), .DIR(dir), .SEND(dht_out), .READ(dht_in));
	
	
	// Conexões dos barramentos
	assign data_out [39:0] = intdata [39:0];
	
	
	// Inicialização máquina de estados
	
	reg [3:0] STATE;
	
	// Definição de estados
	parameter S0=1, S1=2, S2=3, S3=4, S4=5, S5=6, S6=7, S7=8, S8=9, S9=10, STOP=0, START =11;
	
	
	// Processamento da máquina
	// Temporização utilizando o Clock de 50MHz => 50MHz = 0,02 uS; 
	always @(posedge clk50mhz)
	begin
	
		if(en == 1'b1) 
		begin
			if (rst == 1'b1) // Reset da máquina de estados
			begin
			
				dht_out <= 1'b1;
				wait_reg <= 1'b0;
				counter <= 26'b00000000000000000000000000;				
				intdata <= 40'b0000000000000000000000000000000000000000; // Banco de registradores limpo
				dir <= 1'b1; // Configurando o pino para saída
				error <= 1'b0;
				STATE <= START;
				
			end else begin
		
				case (STATE)
				
					START: 
						begin 
						
							wait_reg <= 1'b1;
							dir <= 1'b1; // Direção alterada para saída 
							dht_out <= 1'b1; // DHT11 em modo espera, nível lógico alto
							STATE <= S0;
							
						end
						
						
					S0:
						begin
						
							dir <= 1'b1;
							dht_out <= 1'b1;
							wait_reg <= 1'b1; // Sinaliza que a estrutura ainda está operando
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
						
							dht_out <= 1'b0; // Iniciando a conexão com o DHT11. (Sinal Start)
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

							dht_out <= 1'b1; // Leva para o nível lógico alto
							if(counter < 1000) // Equivale a 20 uS (Aguardar a resposta do DHT)
							begin 
								counter <= counter + 1'b1;
							end else begin
								dir <= 1'b0; // Após 20 uS, a direção do pino será de entrada
								STATE <= S3;
							end
							
						end
						
						
					S3: 
						begin
						
							if (counter < 3000 && dht_in == 1'b1) // Se o counter for menor que 60uS e o dht_in ainda for 1, significa que o dht ainda não respondeu
							begin
								counter <= counter + 1'b1;
								STATE <= S3;
							end else begin
								if(dht_in == 1'b1) // Estourou o tempo limite
								begin 
									error <= 1'b1;	// Se o Dht_in não mudou o valor, erro
									counter <= 26'b00000000000000000000000000;
									STATE <= STOP;
								end else begin		// Dht_in respondeu e passa para o próximo estado
									counter <= 26'b00000000000000000000000000;
									STATE <= S4;
								end
							end
							 
						end
						
					
					S4: 
						begin
						
							// Detecta pulso de sincronismo - 1
							if(dht_in == 1'b0 && counter < 4400) // Dht_in == 0 -> respondeu corretamente, e aguarda 88uS.
							begin 
								counter <= counter + 1'b1;
								STATE <= S4;
							end else begin
								if(dht_in == 1'b0) // O tempo estourou e o Dht_in não mudou, aconteceu um erro.
								begin
									error <= 1'b1;
									counter <= 26'b00000000000000000000000000;
									STATE <= STOP;
								end else begin	// Se o dht é 0 e o counter não atingiu o limite, significa que ele comutou para o nível lógico alto e enviou a primeira parte do sinal de sincronismo
									STATE <= S5; 
									counter <=  26'b00000000000000000000000000;
								end
							end
							
						end
				
				
					S5: 
						begin
							//Detecta pulso de sincronismo - 2
							
							if(dht_in == 1'b1 && counter < 4400) //  O dht_in deve estar em nível lógico 1, e Aguarda 88uS
							begin 
								counter <= counter + 1'b1;
								STATE <= S5;
							end else begin
								if(dht_in == 1'b1) //  O tempo estourou e o dht_in não alterou
								begin
									error <= 1'b1;
									counter <= 26'b00000000000000000000000000;
									STATE <= STOP;
								end else begin	// Se não estourou o counter e o dht == 0, significa que concluiu o sincronismo  
									STATE <= S6;
									error <= 1'b0;
									index <= 6'b000000; // Reseta o indexador	e contador
									counter <=  26'b00000000000000000000000000;
								end
							end
							
						end
					
					
					//	Inicio da análise de dados
					// Pulsos com largura menores que 30uS são bits '0'.
					// Pulsos com largura maiores que 60uS serão bit '1'
					S6:
					
						begin 
						
							if(dht_in == 1'b0) // Se o Dht_in = 0, primeira parte do fluxo de dados ok.
							begin 
								STATE<= S7; 
							end else begin  // Se não, existe algum erro.
								error <= 1'b1;
								counter <= 26'b00000000000000000000000000;
								STATE <= STOP;
							end
							
						end
						
						
					S7:
					
						begin
						
							if(dht_in == 1'b1) // Tudo certo, 2º parte do fluxo de dados.
							begin 
								counter <= 26'b00000000000000000000000000;
								STATE <= S8;
							end else begin
								if (counter < 1600000) // Verificação para caso dht tenha travado - espera 32ms
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
							if(dht_in == 1'b0) // Verifica se o dht_in comutou para 0
							
							//Verificar a largura do pulso, para saber se é 0 ou 1
							begin
							
								if(counter > 2500) // Se o contador estiver maior que 50uS o bit recebe 1
								begin
									
									intdata[index] <= 1'b1;
									
								end else begin // Se o contador estiver menor que 50uS o bit recebe 0
									
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
										
						// Se ainda não comutou para 0, continua aguardando
						end else begin 
							counter <= counter + 1'b1;
							if(counter > 1600000) // Caso mais de 32uS de espera, travou
							begin 
								error <= 1'b1;
								STATE <= STOP;
							end

						end
					end
					
					
				S9:
					// Está separa para ter certeza que dará tempo para o incremento do reg, não podemos ter problemas com esse sinal
					begin
						index <= index + 1'b1; // Incrementa o registrador
						STATE<= S6;
					end
					
					
				STOP: 
				
					begin 
						// A máquina não aparece quando o state está atribuido ao stop, se mudar para start ela aparece no rtl viewer
						STATE <= STOP;
						if ( error == 1'b0 )
						begin  // Resetando, estrutura terminou o processamento
							dht_out <= 1'b1;
							wait_reg <= 1'b0;
							counter <= 26'b00000000000000000000000000;
							dir <= 1'b1;
							error <= 1'b0;
							index <= 6'b000000;
							
						end else begin 
						//Podemos tirar essa parte pois é só para caso de análise
							if(counter < 1600000 ) // Se tiver erro bloqueia a estrutura por 32ms para testes no osciloscopio
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
	end
		

endmodule 


	
	
	
	
