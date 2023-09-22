/** 
Este módulo é responsavel por pegar os dados nos buffers () dos 8 sensores e jogar no transmissor,
bem como garantir que somente um sensor vai poder utilizar o barramento para enviar dados por vez e 
que ficará até o final da transmissão na UART


Se sensor_ready[0] está 1, os dados transmitidos serão do sensor_bus[15:0]
Se sensor_ready[1] está 1, os dados transmitidos serão do sensor_bus[31:16]
...



*/


module ESCALONADOR_V3(clk, uart_tx_done, sensor_bus, sensor_ready, data_to_send, data_used, uart_tx_en);
	
	// Clock da placa 50 MHz
	input clk;
	// UART tx informa que encerrou a transmissão
	input uart_tx_done;
	// bit de cada controlador que diz se os bits do buffer estão prontos (Deve haver um bit no controlador que avisa se o Escalonador pode pegar os dados do buffer)
	input [7:0] sensor_ready;
	
	// Informa ao controlador do sensor que já usei os dados do buffer (Cada controlador deve receber esse bit do ESCALONADOR). Se for 1, o controlador poderá carregar outros dados no seu buffer
	output reg [7:0] data_used;
	
	// Preciso de um cara que vai jogar aqui todos os sensores em um barramento
	input [127:0] sensor_bus;// Todos os 8, cada um com (7 bits data + 5 ender  +4 comando = 16) 16*8
	// Do 15 ao 0 é um sensor
	// Do 127 ao 111 é outro ...
	
	// Habilita a transmissão do data_to_send na UART
	output uart_tx_en;
	
	// Saída com 16 bits. São os dados que vai para UART_TX
	output [15:0] data_to_send;
	wire [15:0] mux_out; //Saída do mux, é só um auxiliar 

	// Indica qual o sensor que terá a vez. Se o sensor estiver pronto para mandar, vai ter a vez até a transmissão ser concluída
	reg [2:0] sensor_num = 0;// Vai de 1 a 8
		
	reg state;
	
	parameter A = 1'b0; // Estado em que fica olhando cada sensor
	parameter T = 1'b1;	// Estado em que achei um sensor pronto e fico transmitindo até o tx falar que acabou
	
	
	initial begin
		state = A;
		data_used = 8'b0;
	end
	

	
	//reg aux;
	// Lógica para o próximo estado
	always @ (posedge clk) begin
	
		case (state)				
			A:
				begin
					data_used[sensor_num] <= 0;
					//aux = sensor_ready[sensor_num];
					if (sensor_ready[sensor_num]) begin
						state = T;
						//data_used[sensor_num] <= 1;// Falo pro sensor que já usei ele
					end
					else begin
						sensor_num <= sensor_num + 1'b1;
						state = A;
					end
				end
			
			T: 
				begin
					if (uart_tx_done) begin
						data_used[sensor_num] = 1;// Falo pro sensor que já usei ele e que pode já reescrever o buffer
						state = A;
					end
					else begin
						state = T;
					end
					
				end
		endcase
		
	end
	
	
	// Bloco de Multiplexadores para falar qual sensor do barramento vai poder usar o barramento para escrever na UART
	mux_8_to_1 m01(sensor_num, sensor_bus[127], sensor_bus[111], sensor_bus[95], sensor_bus[79], sensor_bus[63], sensor_bus[47], sensor_bus[31], sensor_bus[15], mux_out[15]);
	mux_8_to_1 m02(sensor_num, sensor_bus[126], sensor_bus[110], sensor_bus[94], sensor_bus[78], sensor_bus[62], sensor_bus[46], sensor_bus[30], sensor_bus[14], mux_out[14]);
	mux_8_to_1 m03(sensor_num, sensor_bus[125], sensor_bus[109], sensor_bus[93], sensor_bus[77], sensor_bus[61], sensor_bus[45], sensor_bus[29], sensor_bus[13], mux_out[13]);
	mux_8_to_1 m04(sensor_num, sensor_bus[124], sensor_bus[108], sensor_bus[92], sensor_bus[76], sensor_bus[60], sensor_bus[44], sensor_bus[28], sensor_bus[12], mux_out[12]);
	mux_8_to_1 m05(sensor_num, sensor_bus[123], sensor_bus[107], sensor_bus[91], sensor_bus[75], sensor_bus[59], sensor_bus[43], sensor_bus[27], sensor_bus[11], mux_out[11]);
	mux_8_to_1 m06(sensor_num, sensor_bus[122], sensor_bus[106], sensor_bus[90], sensor_bus[74], sensor_bus[58], sensor_bus[42], sensor_bus[26], sensor_bus[10], mux_out[10]);
	mux_8_to_1 m07(sensor_num, sensor_bus[121], sensor_bus[105], sensor_bus[89], sensor_bus[73], sensor_bus[57], sensor_bus[41], sensor_bus[25], sensor_bus[9], mux_out[9]);
	mux_8_to_1 m08(sensor_num, sensor_bus[120], sensor_bus[104], sensor_bus[88], sensor_bus[72], sensor_bus[56], sensor_bus[40], sensor_bus[24], sensor_bus[8], mux_out[8]);
	mux_8_to_1 m09(sensor_num, sensor_bus[119], sensor_bus[103], sensor_bus[87], sensor_bus[71], sensor_bus[55], sensor_bus[39], sensor_bus[23], sensor_bus[7], mux_out[7]);
	mux_8_to_1 m10(sensor_num, sensor_bus[118], sensor_bus[102], sensor_bus[86], sensor_bus[70], sensor_bus[54], sensor_bus[38], sensor_bus[22], sensor_bus[6], mux_out[6]);
	mux_8_to_1 m11(sensor_num, sensor_bus[117], sensor_bus[101], sensor_bus[85], sensor_bus[69], sensor_bus[53], sensor_bus[37], sensor_bus[21], sensor_bus[5], mux_out[5]);
	mux_8_to_1 m12(sensor_num, sensor_bus[116], sensor_bus[100], sensor_bus[84], sensor_bus[68], sensor_bus[52], sensor_bus[36], sensor_bus[20], sensor_bus[4], mux_out[4]);
	mux_8_to_1 m13(sensor_num, sensor_bus[115], sensor_bus[99],  sensor_bus[83], sensor_bus[67], sensor_bus[51], sensor_bus[35], sensor_bus[19], sensor_bus[3], mux_out[3]);
	mux_8_to_1 m14(sensor_num, sensor_bus[114], sensor_bus[98],  sensor_bus[82], sensor_bus[66], sensor_bus[50], sensor_bus[34], sensor_bus[18], sensor_bus[2], mux_out[2]);
	mux_8_to_1 m15(sensor_num, sensor_bus[113], sensor_bus[97],  sensor_bus[81], sensor_bus[65], sensor_bus[49], sensor_bus[33], sensor_bus[17], sensor_bus[1], mux_out[1]);
	mux_8_to_1 m16(sensor_num, sensor_bus[112], sensor_bus[96],  sensor_bus[80], sensor_bus[64], sensor_bus[48], sensor_bus[32], sensor_bus[16], sensor_bus[0], mux_out[0]);
	
	
	// Só habilita a saída se a transmissão uart estiver habilitada (Nem precisa disso, só botei para facilitar a visualização no waveform)
	assign data_to_send[0] = (mux_out[0]& uart_tx_en);
	assign data_to_send[1] = (mux_out[1]& uart_tx_en);
	assign data_to_send[2] = (mux_out[2]& uart_tx_en);
	assign data_to_send[3] = (mux_out[3]& uart_tx_en);
	assign data_to_send[4] = (mux_out[4]& uart_tx_en);
	assign data_to_send[5] = (mux_out[5]& uart_tx_en);
	assign data_to_send[6] = (mux_out[6]& uart_tx_en);
	assign data_to_send[7] = (mux_out[7]& uart_tx_en);
	assign data_to_send[8] = (mux_out[8]& uart_tx_en);
	assign data_to_send[9] = (mux_out[9]& uart_tx_en);
	assign data_to_send[10] = (mux_out[10]& uart_tx_en);
	assign data_to_send[11] = (mux_out[11]& uart_tx_en);
	assign data_to_send[12] = (mux_out[12]& uart_tx_en);
	assign data_to_send[13] = (mux_out[13]& uart_tx_en);
	assign data_to_send[14] = (mux_out[14]& uart_tx_en);
	assign data_to_send[15] = (mux_out[15]& uart_tx_en);
	
	// Habilita o transmissor da UART
	assign uart_tx_en = (state == T);
	
endmodule

