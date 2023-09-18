/** Este módulo indica qual sensor irá receber os dados presentes no buffer do receptor do uart 
A idéia é que quando o uart falar que terminou de receber algo, o despachante olhe o endereço e assim diga 
ao módulo de sensoriamento que pode começar a ler os dados que estão no barramento. (a saída do uart rx vai
para a entrada de todos os sensores) aí ele olha oq o comando pede e faz oq precisa ser feito

- Cada 'pin_to_module' vai em um módulo de sensoriamento*/

module ENTREGADOR(input uart_rx_ready, // Pino do Uart RX que indica quando terminou o processo de recebimento de dados
						input [4:0] addres_req,// Parte dos dados recebidos pela uart que indica o endereço 
						output [31:0] pin_to_module);// Um pino para cada módulo dos 32 sensores

		assign pin_to_module[0] = (addres_req == 5'b00000) & uart_rx_ready;
		assign pin_to_module[1] = (addres_req == 5'b00001) & uart_rx_ready;
		assign pin_to_module[2] = (addres_req == 5'b00010) & uart_rx_ready;
		assign pin_to_module[3] = (addres_req == 5'b00011) & uart_rx_ready;
		assign pin_to_module[4] = (addres_req == 5'b00100) & uart_rx_ready;
		assign pin_to_module[5] = (addres_req == 5'b00101) & uart_rx_ready;
		assign pin_to_module[6] = (addres_req == 5'b00110) & uart_rx_ready;
		assign pin_to_module[7] = (addres_req == 5'b00111) & uart_rx_ready;
		assign pin_to_module[8] = (addres_req == 5'b01000) & uart_rx_ready;

	
endmodule
