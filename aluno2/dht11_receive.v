module dht11_receive(input clk, input en, input dht11_data_s);
   integer i = 7;// Recebe primeiro o mais significativo
   reg [7:0] data;// dados em paralelo

   // Para máquina de estados
   reg [1:0] state , nextstate ;
   parameter S0 = 2'b00 ;//Analisando o 0
   parameter S1 = 2'b01 ;//Analisando o 1
   parameter E  = 2'b10 ;//Deu erro
   parameter I  = 2'b11 ;//Inativo
    
   // 0(8) 0(4) 0(2) 0(1)
   reg [3:0] COUNTER;// Contador de ciclos de clock de 1/195.312,5 = 0,00000512s = 5,12us
	
	initial begin
		state <= I;
		nextstate <= I;
	end
	
	// Lóogica para mudança de estado
   always @ ( posedge clk ) begin
       state <= nextstate ;
   end
	 
	 
	always @ (*) begin
		// Se não estiver habilitado
		if(~en) begin
			nextstate <= I;
		end
		// Se estiver habilitado
		if (en) begin
			case(state) 
				I://Em modo inativo
					if (en) begin
						nextstate <= S0;
					end
					else begin
						nextstate <= I;
					end
				S0:// Analisando o 0
					if (~dht11_data_s)begin
						COUNTER <= COUNTER + 1;
					end
					else begin
						if (COUNTER == 4'b1010) begin
							COUNTER <= 4'b0001;
                     nextstate <= S1 ;
						end 
                  else begin
							nextstate <= E ;
						end
					end
				S1:// Analisando o 1
					if (dht11_data_s)begin
						COUNTER <= COUNTER + 1;
					end
					else begin
						// Caso tenha ficado por tempo para o bit=0
						if (COUNTER <= 4'b0110) begin// se fiquei por <= 5us*6 = 30us) 
							data[i] <= 0;
							COUNTER <= 4'b0001;
                     nextstate <= S0 ;
						end 
						// Caso tenha ficado por tempo para o bit=1
                  else if(COUNTER == 4'b1110) begin// se fiquei por == 5us*14 = 71us
							data[i] <= 1;
							COUNTER <= 4'b0001;
                     nextstate <= S0 ;
						end
						// Caso não seja nenhum dos dois tempos
						else begin
							nextstate <= E ;
						end
					end
				E:// No estado de erro
					nextstate <= I ;
					//OU ENTÃO É UM ESTADO TRANSITÓRIO QUE PULA PARA O INATIVO
					/**
					if (en)begin
						nextstate <= S0;
					end
					else begin
						nextstate <= E;
					end*/
			endcase
		
		end
	end
	 
endmodule
