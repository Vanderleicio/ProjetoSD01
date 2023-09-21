module testa_Escalonador(input clk, output tx, output done, input [7:0] sensor_ready, output [7:0] data_used, output[2:0] sensor_num, output state, input [127:0] sensor_bus);

	wire uart_tx_en;//habilita o transmissor
	wire [15:0] data_to_send;
	

	UART_tx			transmissor(clk, tx, data_to_send, uart_tx_en, done);
	ESCALONADOR_V3 escalona(clk, done, sensor_bus, sensor_ready, data_to_send, data_used, uart_tx_en, sensor_num, state);
	
	
endmodule
