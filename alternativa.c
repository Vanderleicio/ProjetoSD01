#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>


int main() {
	int numBytes = 2;
	int fd, len;
	char text[numBytes];// só salvo dois bytes(char) por vez
	
	int sensor_endereco; 
	int opcao_comando;

	struct termios options; /* Serial ports setting */
	// Informando a porta, que é de leitura e escrita, sem delay
	fd = open("/dev/ttyS0", O_RDWR); // | O_NDELAY | O_NOCTTY);
	if (fd < 0) {
		perror("Error opening serial port");
		return -1;
	}

	/* Read current serial port settings */
	// tcgetattr(fd, &options);
	
	/* Set up serial port */
	// baud rate 9k6, 8bits, n sei, n sei
	options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
	options.c_iflag = IGNPAR;
	options.c_oflag = 0;
	options.c_lflag = 0;

	/* Apply the settings */
	tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, &options);

	/** ######### TRECHO PARA ENVIAR ######### */
	// RECEBENDO AS ENTRADAS
	printf("Digite 1 para o comando xxxx\n 2 para o comando yyyyy \n 3 para o comando zzzz: ");
	scanf("%i", &opcao_comando); 
	printf("\n");
	printf("Digite o número do sensor (0 a 31)");
	scanf("%i", &endereco); 
	printf("\n");
	
	// Obtendo o cod binário de 8 bits que será enviado
	text[0] = endereco*0b01;
	text[1] = opcao_comando*0b01;


	printf("\033[H\033[J"); // Limpa a tela no terminal Unix/Linux
	system("cls");// Limpa a tela no Windows
	
	len = strlen(text);
	// ESCREVE NA PORTA
	len = write(fd, text, len);
	//
	printf("Você vai escrever os caracteres %s\n", text);
	printf("Que representam %d bytes\n", len);
	
	/** ######### FIM TRECHO PARA ENVIAR ######### */
	
	close(fd);// fecha a porta
	return 0;
}