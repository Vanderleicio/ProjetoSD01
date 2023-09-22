module controlDHT11(clk, sinalRequest, comando, bufferUsado, dado, bufferPronto, info);
	
	input clk;
	input[15:0] comando; // Comando para o controlador retorna o que foi pedido. (5 bits endereco(15:11) + 4 comando(10:7)  + 7 dados(6:0) = 16)
	input bufferUsado; // Sinaliza que o escalonador já transmitiu os dados do buffer.
	input sinalRequest;
	
	inout dado; // Dado para comunicar com o DHT11.
	output reg bufferPronto; // Sinaliza que já guardou todas as informações do DHT11 no buffer.
	output reg [15:0] info; // Resposta do sensor.
	
	reg enableDHT = 1;
	reg resetDHT = 1;
	wire [39:0] saidaDHT;
	
	wire dhtTrabalhando;
	wire erroDHT;
	wire terminou;
	
	reg houveRequest;
	reg [39:0] bufferDHT; 
	reg [15:0] bufferComando;
	reg [26:0]contador = 27'b101111101011110000100000000;
	reg [2:0] estado;
	reg tempContinuo = 0;
	reg umidContinuo = 0;
	reg solicitacao = 1; //Sinaliza que agora será atendida uma solicitação ou um monitoramento contínuo.
	
	DHT11 DHT(clk, enableDHT, resetDHT, dado, saidaDHT, dhtTrabalhando, erroDHT, terminou);
	
	parameter ESPCOMANDO = 0, // Espera por um comando para o sensor;
	COLETANDO = 1, // Coleta os dados do DHT11;
	TRANSMITIR = 2, // Separa e transmite a respostas que será enviada;
	RESETAR = 3; // Reseta o sensor e a máquina de estados
	initial begin
		estado = ESPCOMANDO;
		bufferPronto = 0;
		info = 0;
	end
	
	always @(posedge clk) begin
			
			if (sinalRequest) begin //Verifica se nessa oscilação do clock algo foi solicitado ao controlador pelo entregador
				houveRequest = 1;
				bufferComando = comando;
			end
			
			case(estado)
				
				ESPCOMANDO:
					begin
						
						if ((sinalRequest || (tempContinuo || umidContinuo)) && (contador == 0)) //A entrada de comando representa um comando real
							begin
								
								if (solicitacao == 0) begin //Se for para atender um sensoriamento contínuo, altera o comando para atender o sensoriamento correspondente.
									if (tempContinuo) begin
										bufferComando[7:5] = 3'b011;
									end else begin
										bufferComando[7:5] = 3'b100;
									end
								end else begin
									houveRequest = 0;
								end
								
								enableDHT = 1;
								resetDHT = 0;
								info = 0;
								estado <= COLETANDO;
							end else
							begin //A entrada de comando não representa um comando real
								if (contador != 0) begin
								contador = contador - 1'b1;
								end 
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
							info[4:0] = bufferComando[4:0]; //Coloca o endereço do sensor.
							case(bufferComando[11:8])
								
								4'b0000: //Envia a situação atual do sensor.
								begin
									if (erroDHT) begin
										info[8:5] = 4'b0000; //Código 0 para sinalizar sensor com problema.
										info[15:9] = 7'b0000000; //Não é para enviar dados do sensor;
									end else begin
										info[8:5] = 4'b0001; //Código 1 para sinalizar sensor funcionando.
										info[15:9] = 7'b0000000; //Não é para enviar dados do sensor;
									end
								end
								
								4'b0001://Envia a temperatura medida atual.
								begin
									info[8:5] = 4'b0011; //Código 3 para sinalizar envio de temperatura.
									info[15:9] = saidaDHT[22:16]; //Enviando os 7 últimos bits da temperatura;
								end
								
								4'b0010://Envia a umidade medida atual.
								begin
									info[8:5] = 4'b0010; //Código 2 para sinalizar envio de umidade.
									info[15:9] = saidaDHT[38:32]; //Enviando os 7 últimos bits da umidade;
								end
								
								4'b0011: //Ativa o sensoriamento contínuo de temperatura.
								begin
									tempContinuo = 1;
									info[8:5] = 4'b0011; //Código 3 para sinalizar envio de temperatura.
									info[15:9] = saidaDHT[38:32]; //Enviando os 7 últimos bits da temperatura;
								end
								
								4'b0100: //Ativa o sensoriamento contínuo de umidade.
								begin
									umidContinuo = 1;
									info[8:5] = 4'b0010; //Código 2 para sinalizar envio de umidade.
									info[15:9] = saidaDHT[22:16]; //Enviando os 7 últimos bits da umidade;
								end
								
								4'b0101: //Desativa o sensoriamento contínuo de temperatura.
								begin
									tempContinuo = 0;
									info[8:5] = 4'b0100; //Código 4 para sinalizar desativação do sensoriamento continuo de temperatura.
									info[15:9] = 7'b0000000; //Dados não são enviados;
								end
								
								4'b0110: //Desativa o sensoriamento contínuo de umidade.
								begin
									umidContinuo = 0;
									info[8:5] = 4'b0101; //Código 5 para sinalizar desativação do sensoriamento continuo de umidade.
									info[15:9] = 7'b0000000; //Dados não são enviados;
								end

								
							endcase
							contador = 27'b101111101011110000100000000;
							estado <= TRANSMITIR;
						end else
						begin
							estado <= COLETANDO;
						end
					end
					
				TRANSMITIR:
					begin
						if (contador != 0) begin	
						
							contador = contador - 1'b1;
							
						end
						
						if (bufferUsado)
						begin
						
							estado <= RESETAR;
							
						end else begin
						
							bufferPronto = 1;
							estado <= TRANSMITIR;
							
						end
						
					end
				
				RESETAR:
					begin
						if (contador != 0) begin	
							contador = contador - 1'b1;
						end
						
						if (tempContinuo || umidContinuo) 
							begin
							
								solicitacao = ~solicitacao;
			
							end else begin
								solicitacao = 1;
							end
							
						info = 0;
						enableDHT = 1;
						resetDHT = 1;
						bufferPronto = 0;
						estado <= ESPCOMANDO;
					end
			endcase
		end
endmodule