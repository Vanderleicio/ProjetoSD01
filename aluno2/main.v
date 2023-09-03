
module main(clk, rx, tx);

	input  clk; // Clock da placa 50MHz
	input  rx;  // Canal Receptor RX da UART
	output tx;  // Canal transmissor TX da UART 
	
	// ### !!!!!!!! Verificar qual pedaço é o comando e qual é o endereço !!!!!!!! ###
	wire [15:0] u_data_r;// Dados que são recebidos pela UART -> !!! [15:8] está o comando [7:0] está o endereço
	wire control;// Um pulso que é ALTO quando a UART termina de receber 2 bytes, BAIXO no tempo restante
	wire clk_bdg;// Clock dividido pelo baud rate para a uart
	
	
	baudRateGenerator gerador(clk, 1, clk_bdg);
	
	receptor receptor_UART(clk_bdg, rx, u_data_r, control);
	
	transmissor transmissor_UART(clk_bdg, tx, u_data_r, control);
	
endmodule
