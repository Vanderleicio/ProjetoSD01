module dht11_receive(input clk, input en, input reset, inout bitComunDHT11, output dados);
   
   reg [39:0] data;// dados em paralelo
	
   // Para máquina de estados
   reg [2:0] state;
		parameter START = 0,//Baixa o nível da linha, solicitando dados ao DHT11
					 RESPOSTA0 = 1,//Espera 20-40us pela resposta e mais 80uS pelo primeiro sinal de resposta. 
					 RESPOSTA1 = 2 //Espera mais 80uS pelo segundo sinal de resposta.
					 PARTEPADRAO  = 3,//Espera os 50uS iniciais de todo bit.
					 POSSIVEL0  = 4;//Espera até 28uS para o bit ser um possivel 0.
					 POSSIVEL1 = 5; //Espera 70uS para o bit ser um possivel 1;
					 ERRO = 6; //Bit passou mais de 70uS em nível alto
					 FIMRECEBIMENTO = 7; //Envio de bits finalizado. 50uS em 0;
	
	integer contador = 0; // Máximo 900 000, pois: 1 ciclo de clock = 1/50.10^6 = 0.02 uS. O maior valor de espera é 18mS, ou seja, 900 000 ciclos.
	integer i = 39;// Recebe primeiro o mais significativo
	
	reg direcao;
	reg respostaParaDHT11;
	reg deuErro = 1'b0;;
	
	reg bitTraduzido = 1'b0;
	wire bitCom;
	
	TRIS TRISTATE(bitComunDHT11, direcao, respostaParaDHT11, bitCom);

	always @ (posedge clk_115200hz or posedge reset) begin
		if (en) begin
			
			if(reset)begin
				
			end else begin
			
				case(state)
					START:
						begin
							direcao <= 1'b1;
							if(contador < 900000) begin //Conta 18ms
								respostaParaDHT11 <= 1'b0;
								contador <= contador + 1;
							end else begin
								respostaParaDHT11 <= 1'b1;
								state <= RESPOSTA0;
								contador <= 0;
							end
							
						end
					RESPOSTA0:
						begin
							direcao <= 1'b0;
							if (contador < 2000 && bitCom) begin //Conta 40uS
								contador <= contador + 1;
								
							end else begin
								if (bitCom) begin
									deuErro = 1'b1;
								end else begin
									
						end
					RESPOSTA1:     
						begin	
							
						end
					PARTEPADRAO:
						begin
						
						end 
				endcase
			end //end do else reset 
		end //end do enable
	end //end do always
endmodule