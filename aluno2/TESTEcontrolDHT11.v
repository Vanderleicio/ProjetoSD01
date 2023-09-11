module TESTEcontrolDHT11(clk, comando, bufferUsado, dado, bufferPronto, info, TenableDHT, TresetDHT, TsaidaDHT,TdhtTrabalhando,TerroDHT,Tterminou, estadoAtual, debug);
	input clk;
	input[15:0] comando; // Comando para o controlador retorna o que foi pedido. (7 bits data + 5 ender  + 4 comando = 16)
	input bufferUsado; // Sinaliza que o escalonador já transmitiu os dados do buffer.
	inout dado; // Dado para comunicar com o DHT11.
	output reg bufferPronto; // Sinaliza que já guardou todas as informações do DHT11 no buffer.
	output reg [15:0] info; // Resposta do sensor.
	output [2:0] estadoAtual;
	output debug;
	//ÁREA DE TESTE
	output reg TenableDHT;
	output reg TresetDHT;
	input [39:0] TsaidaDHT;
	input TdhtTrabalhando;
	input TerroDHT;
	input Tterminou;
	// FIM ÁREA DE TESTE
	//wire [39:0] saidaDHT;
	
	reg [39:0] bufferDHT; 
	
	reg [2:0] estado;
	reg debug_reg = 0;
	assign debug = debug_reg;
	
	parameter ESPCOMANDO = 0, // Espera por um comando para o sensor;
	COLETANDO = 1, // Coleta os dados do DHT11;
	TRANSMITIR = 2, // Separa e transmite a respostas que será enviada;
	RESETAR = 3; // Reseta o sensor e a máquina de estados
	
	initial begin
		debug_reg = 0;
		estado = ESPCOMANDO;
		bufferPronto = 0;
		info = 0;
	end
	
	
	assign estadoAtual = estado;
	always @(posedge clk) begin
			
			case(estado)
				
				ESPCOMANDO:
					begin
						
						if (comando[15]) //A entrada de comando representa um comando real
							begin
								TenableDHT = 1;
								TresetDHT = 0;
								info = 0;
								estado <= COLETANDO;
							end else
							begin //A entrada de comando não representa um comando real
								estado <= ESPCOMANDO;
								TenableDHT = 1;
								TresetDHT = 1;
								info = 0;
							end
					end
				
				COLETANDO:
					begin
						if (Tterminou) //Módulo que coleta os dados do DHT11 terminou de coletá-los.
						begin
							TenableDHT = 0;
							bufferDHT <= TsaidaDHT;
							case(comando[3:0])
								4'b0001:
								begin
									info[7:0] <= TsaidaDHT[39:32];
								end
								4'b0010:
								begin
									info[7:0] <= TsaidaDHT[23:16];
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
							debug_reg <= 0;
							bufferPronto = 1;
							estado <= TRANSMITIR;
							
						end
						
					end
				
				RESETAR:
					begin
						info = 0;
						TenableDHT = 1;
						TresetDHT = 1;
						bufferPronto = 0;
						estado <= ESPCOMANDO;
					end
			endcase
		end
endmodule