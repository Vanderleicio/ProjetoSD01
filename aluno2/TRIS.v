/**Módulo para realizar a mudança de modo (In e out) de port
O controle é feito por dir*/
module TRIS(inout io_port, input t_dir, input i_send, output o_read);
	// Quando dir é 1, o pino send é conectado ao pino port. Ou seja, port estará no modo output pq vai receber o send
	// Se for 0, o pino port fica em alta impedância
	assign port = dir ? send : 1'bZ;
	
	// quando dir é 0, copia o valor de port para read
	assign read = dir ? 1'bZ : port;
endmodule
