module transmissor(clk_115200hz, out, data, start);

	input clk_115200hz, start; // clock e sinal de enable vindo do modulo decodificador
	input [0:7]data;  // dados a serem transmitidos
	output out;  // pino de saída por onde trafegarão os bit em serial


	reg reset = 0;


	reg out = 1'b1;
	reg [1:0]state;
		parameter START=0,
					 DATA=1,
					 STOP=2;
						
	integer counter = 7;

	always @ (posedge clk_115200hz or posedge reset) begin
		if (reset == 1) begin
			reset = 0;
			state <= START;		
		end else begin
			case(state)
				START:
					begin
						if(start) begin // se houver sinal de start do controlador poe a saída em nivel baixo que indica um start bit
							out = 1'b0;
							state <= DATA;
						end
						else begin
							out = 1'b1; // enquanto não houver sinal de start do decodificador manter no estado start
							state <= START;
						end
					end
				DATA:
					begin
						if (counter < 0) begin // se counter < 0 indica que acabaou a transmissão
							out = 1'b1;
							state <= STOP;
						end
						else begin     // se counter > 0 poe o bit data[counter] na saída e decrementa o counter
							out = data[counter];
							counter = counter - 1;
							state <= DATA;
						end
					end
				STOP:     
					begin	
						counter = 7;       // reseta counter em 7
						reset = 1'b1;		// reset em 1 
						state <= START;     // volta para o estado star para aguardar a proxima transmissão
					end
			endcase
		end
	end

endmodule 