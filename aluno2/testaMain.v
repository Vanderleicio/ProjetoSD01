module testaMain(input clk, output tx, output done, input [15:0] data);

UART_tx TTsX		(clk, tx, data, 1'b1, done);
//transmissor TTX	(clk, tx, data, 1'b1, done);

endmodule
//00011100 10010101