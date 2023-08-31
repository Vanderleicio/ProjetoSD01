module transmissor(clk_115200hz, out, data, start, debug, debug2);

input clk_115200hz, start; // clock e sinal de enable vindo do modulo decodificador
input [0:15]data;  // dados a serem transmitidos
output out;  // pino de saída por onde trafegarão os bit em serial
output debug;
output debug2;

reg reset = 0;

reg debug2 = 1'b0;
reg debug = 1'b0;
reg out = 1'b1;
reg [1:0]state;
	parameter START=0,
				 DATA=1,
				 STOP=2;
					
integer counter = 15;

reg waitBit = 0; // Bit de aguardo antes do próximo byte.
integer counterWait = 1;

always @ (posedge clk_115200hz or posedge reset) begin
	if (reset == 1) begin
		reset = 0;
		waitBit = 0;
		counterWait = 1;
		state <= START;		
	end else begin
		case(state)
			START:
				begin
					if(start) begin // se houver sinal de start do controlador poe a saída em nivel baixo que indica um start bit
						
						if (waitBit) begin
							if (counterWait < 0) begin
								waitBit = 0;
								state <= DATA;
								out = 1'b0;
							end
							else begin
								out = 1'b1;
								counterWait = counterWait - 1;
							end
						end
						
						else begin
							out = 1'b0;
							state <= DATA;
						end
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
						if (counter == 7) begin
							out = data[7];
						end
						debug <= data[counter];
						counter <= counter - 1;
						
						if (counter == 7) begin
							debug2 <= 1'b1;
							waitBit = 1;
							out = 1'b1;
							state <= START;
						end 
						
						else begin
							debug2 <= 1'b0;
							state <= DATA;
						end
					end
				end
			STOP:     
				begin	
					counter = 15;       // reseta counter em 7
					reset = 1'b1;		// reset em 1 
					state <= START;     // volta para o estado star para aguardar a proxima transmissão
				end
		endcase
	end
end

endmodule 