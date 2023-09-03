module UART (
	input clk_9k6,// Clock do Baud Rate
	input rx, // Pino para recebimento de dados
	input enable_transmiter,//Pino para informar ao transmissor que já pode enviar os dados
	input [15:0] data_to_send, // Dados que serão enviados
	output [15:0] data_recevied, // Dados recebidos pela UART
	output tx,// Pino para transmitir os dados
	output data_ready_to_read// Informa que no buffer do receptor há dados prontos para serem usado (o processo de recebimento acabou)
	);

	UART_tx receptor(clk_9k6, rx, data_recevied, data_ready_to_read);
	UART_tx transmissor(clk_9k6, tx, data_to_send, enable_transmiter);

endmodule
