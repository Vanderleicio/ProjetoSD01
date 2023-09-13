
module main(clk, rx, tx, ch1, ch2, ch3, pino_inout, colum, linhas);

	input  clk; // Clock da placa 50MHz
	input  rx;  // Canal Receptor RX da UART
	input ch1;
	input ch2;
	input ch3;
	
	inout pino_inout;
	
	output colum;
	output [7:0]linhas;
	output tx;  // Canal transmissor TX da UART 
	
	// ### !!!!!!!! Verificar qual pedaço é o comando e qual é o endereço !!!!!!!! ###
	wire [15:0] u_data_r;// Dados que são recebidos pela UART -> !!! [15:8] está o comando [7:0] está o endereço
	wire control;// Um pulso que é ALTO quando a UART termina de receber 2 bytes, BAIXO no tempo restante
	wire clk_bdg;// Clock dividido pelo baud rate para a uart
	
	wire [39:0] data_out;
	wire [7:0] tempINT;
	wire WAIT;
	wire error, done, doneT;
	wire bufferPronto;
	wire [15:0] info;
	
	baudRateGenerator gerador(clk, 1, clk_bdg);
	
	receptor receptor_UART(clk_bdg, rx, u_data_r, control);	
	
	controlDHT11 cntDHT0(clk, 16'b1000000011110010, doneT, pino_inout, bufferPronto, info);
	
	
	transmissor transmissor_UART(clk_bdg, tx, info, ch3, doneT);
	//DHT11 infosDHT(clk, ch1, ch2, pino_inout, data_out, WAIT, error, done);
	//39 MSB DO INT HUM 0 LSB DO CHEK
	assign colum = 0;
	assign linhas = info[8:0]; //data_out
	
	
	
endmodule
