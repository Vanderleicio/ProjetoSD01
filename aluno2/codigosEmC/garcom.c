#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>


int main(){
	int fd, len, resp;
	unsigned char envio[2]; // vetor que e enviado
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
	unsigned char comando; // entrada do usuário
    int srsAddress;  // endereço do sensor

    printf("Digite o endereco de um sensor ou -1 para sair\nAguardando: ");
    scanf("%d", &srsAddress);

    while (srsAddress != -1) {
        printf("Digite um comando: ");
        scanf("%d",&comando);

        // Simulação de escrita na porta (substitua por implementação)
        envio[0] = srsAddress; envio[1] =comando; envio[2] = '\0';
        printf("\n\nEndereco do sensor: %s\n", envio);

        printf("Digite o endereco de um sensor ou -1 para sair\nAguardando: ");
        scanf("%d", &srsAddress);
    }

    close(fd);
    return 0;
}
