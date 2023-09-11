module controlDHT11(clk, comando, bufferUsado, dado, bufferPronto, info);
	input clk;
	input[15:0] comando; // Comando para o controlador retorna o que foi pedido. (7 bits data + 5 ender  + 4 comando = 16)
	input bufferUsado; // Sinaliza que o escalonador já transmitiu os dados do buffer.
	inout dado; // Dado para comunicar com o DHT11.
	output reg bufferPronto; // Sinaliza que já guardou todas as informações do DHT11 no buffer.
	output reg [15:0] info; // Resposta do sensor.

	wire [39:0] saidaDHT;
	
	reg enableDHT = 1; 
	reg resetDHT = 1;
	wire dhtTrabalhando;
	wire erroDHT;
	wire terminou;
	
	reg [39:0] bufferDHT; 
	DHT11 DHT(clk, enableDHT, resetDHT, dado, saidaDHT, dhtTrabalhando, erroDHT, terminou);
	
	reg [2:0] estado;
	
	parameter ESPCOMANDO = 0, // Espera por um comando para o sensor;
	COLETANDO = 1, // Coleta os dados do DHT11;
	TRANSMITIR = 2, // Separa e transmite a respostas que será enviada;
	RESETAR = 3; // Reseta o sensor e a máquina de estados
	
	initial begin
		estado = ESPCOMANDO;
		bufferPronto = 0;
		info = 0;
	end
	
	
	always @(posedge clk)
		begin
			
			case(estado)
				
				ESPCOMANDO:
					begin
						if (comando[15]) //A entrada de comando representa um comando real
							begin
								enableDHT = 1;
								resetDHT = 0;
								info = 0;
								estado <= COLETANDO;
							end else
							begin //A entrada de comando não representa um comando real
								estado <= ESPCOMANDO;
								enableDHT = 1;
								resetDHT = 1;
								info = 0;
							end
					end
				
				COLETANDO:
					begin
						if (terminou) //Módulo que coleta os dados do DHT11 terminou de coletá-los.
						begin
							enableDHT = 0;
							bufferDHT <= saidaDHT;
							case(comando[3:0])
								4'b0010:
								begin
									info[7:0] <= saidaDHT[39:32];
								end
								4'b0001:
								begin
									info[7:0] <= saidaDHT[23:16];
								end
							
								//ADICIONAR OS OUTROS COMANDOS E O QUE PRECISAR SER RETORNADO
							endcase
							estado <= TRANSMITIR;
						end else
						begin
							estado <= COLETANDO;
						end
					end
					
				TRANSMITIR:
					begin
						if (bufferUsado)
						begin
						
							estado <= RESETAR;
							
						end else
						begin
						
							bufferPronto = 1;
							estado <= TRANSMITIR;
							
						end
						
					end
				
				RESETAR:
					begin
						info = 0;
						enableDHT = 1;
						resetDHT = 1;
						bufferPronto = 0;
						estado <= ESPCOMANDO;
					end
			endcase
		end
endmodule