
module main(clk, rx, tx, pino_inout);

	input  clk; // Clock da placa 50MHz
	input  rx;  // Canal Receptor RX da UART
	
	inout [7:0]pino_inout;
	
	output tx;  // Canal transmissor TX da UART 
	
	// ### !!!!!!!! Verificar qual pedaço é o comando e qual é o endereço !!!!!!!! ###
	wire [15:0] u_data_r;// Dados que são recebidos pela UART -> !!! [15:8] está o comando [7:0] está o endereço
	wire control;// Um pulso que é ALTO quando a UART termina de receber 2 bytes, BAIXO no tempo restante
	wire clk_bdg;// Clock dividido pelo baud rate para a uart
	
	wire uart_tx_en;
	wire [127:0] sensorBus;
	wire doneT;
	wire [7:0] bufferPronto;
	wire [7:0] bufferUsado;
	wire [15:0] info;
	wire [31:0] pinModule;
	

	baudRateGenerator gerador(clk, 1, clk_bdg);
	
	receptor receptor_UART(clk_bdg, rx, u_data_r, control);	
	
	ENTREGADOR despachante(control, u_data_r[4:0], pinModule);
	
	controlDHT11 cntDHT0(clk, pinModule[0], u_data_r, bufferUsado[0], pino_inout[0], bufferPronto[0], sensorBus[15:0]);
	controlDHT11 cntDHT1(clk, pinModule[1], u_data_r, bufferUsado[1], pino_inout[1], bufferPronto[1], sensorBus[31:16]);
	controlDHT11 cntDHT2(clk, pinModule[2], u_data_r, bufferUsado[2], pino_inout[2], bufferPronto[2], sensorBus[47:32]);
	controlDHT11 cntDHT3(clk, pinModule[3], u_data_r, bufferUsado[3], pino_inout[3], bufferPronto[3], sensorBus[63:48]);
	controlDHT11 cntDHT4(clk, pinModule[4], u_data_r, bufferUsado[4], pino_inout[4], bufferPronto[4], sensorBus[79:64]);
	controlDHT11 cntDHT5(clk, pinModule[5], u_data_r, bufferUsado[5], pino_inout[5], bufferPronto[5], sensorBus[95:80]);
	controlDHT11 cntDHT6(clk, pinModule[6], u_data_r, bufferUsado[6], pino_inout[6], bufferPronto[6], sensorBus[111:96]);
	controlDHT11 cntDHT7(clk, pinModule[7], u_data_r, bufferUsado[7], pino_inout[7], bufferPronto[7], sensorBus[127:112]);
	
	ESCALONADOR_V3 escal(clk, doneT, sensorBus, bufferPronto, info, bufferUsado, uart_tx_en);
	
	UART_tx transmissor_UART(clk_bdg, tx, info, uart_tx_en, doneT);

	
endmodule