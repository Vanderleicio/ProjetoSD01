#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>


int main(){
    char comando[4]; // entrada do usuario
	int fd, len, resp;
	char text[2];// só salvo dois bytes(char) por vez
	struct termios options; /* Serial ports setting */
	// Informando a porta, que é de leitura e escrita, sem delay
	fd = open("/dev/ttyS0", O_WRONLY | O_NDELAY | O_NOCTTY);
	if (fd < 0) {
		perror("Error opening serial port");
		return -1;
	}

	/* Read current serial port settings */
	// tcgetattr(fd, &options);
	
	/* Set up serial port */
	// baud rate 9k6, caractere de 8bits, n sei, ativa leitura de porta serial
	options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
	options.c_iflag = IGNPAR;
	options.c_oflag = 0;
	options.c_lflag = 0;

	/* Apply the settings */
	tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, &options);

	/** ######### TRECHO PARA ENVIAR ######### */
	///**
    int srsAddress;  // endereco do sensor
        while (srsAddress != -1) {
        while (getchar() != '\n'); // Limpar o buffer de entrada

        printf("Digite um comando: ");
        fgets(comando, sizeof(comando), stdin);

        // Remova a quebra de linha do comando, se presente
        size_t len = strlen(comando);
        if (len > 0 && comando[len - 1] == '\n') {
            comando[len - 1] = '\0';
        }

        printf("Digite o endereco de um sensor ou -1 para sair\nAguardando: ");
        scanf("%d", &srsAddress);

        // escrita na porta 
        text[0] = comando; text[1] = srsAddress;
        len = strlen(text);
        len = write(fd, text, len);
    }

    close(fd);
    return 0;
}
