#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

void printBinary(unsigned char byte) {
    for (int i = 7; i >= 0; i--) {
        printf("%d", (byte >> i) & 1);
    }
}

int main() {
	int numBytes = 2;
	int fd, len;
	char text[numBytes];// só salvo dois bytes(char) por vez
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
	///**
	strcpy(text, "0Z");
	len = strlen(text);
	// ESCREVE NA PORTA
	len = write(fd, text, len);
	//
	printf("Você vai escrever os caracteres %s\n", text);
	printf("Que representam %d bytes\n", len);
	
	// INFORMANDO O BINÁRIO doq foi enviado
    	unsigned char *ptr = (unsigned char *)&text;
    	for (int i = 0; i < numBytes*sizeof(char); i++) {
        	printf("Byte %d: ", i + 1);
        	printBinary(ptr[i]);
        	printf("\n");
    	}
    	//*/
	/** ######### FIM TRECHO PARA ENVIAR ######### */
	
	
	
	
	/** ######### TRECHO PARA RECEBER ######### */
	///**
	//*
	printf("Tem 5s para mandar os dados, corre!\n");
	sleep(1);

	// Read from serial port 
	memset(text, 0, numBytes);
	len = read(fd, text, numBytes);
	printf("===================\n");
	printf("Recebi %d bytes\n", len);
	printf("Recebi as strings: %s\n", text);
	
	unsigned char *pST = (unsigned char *)&text;
    
    	for (int i = 0; i < numBytes * sizeof(char); i++) {
        	printf("Byte %d: ", i + 1);
        	printBinary(pST[i]);
        	printf("\n");
    	}
    	
	/** ######### FIM TRECHO PARA RECEBER ######### */
	close(fd);// fecha a porta
	return 0;
}
