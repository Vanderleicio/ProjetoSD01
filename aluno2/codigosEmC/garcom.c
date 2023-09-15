#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>


int main(){
	int fd, len, resp;
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
        while (getchar() != '\n'); // Limpar o buffer de entrada

        printf("Digite um comando: ");
        scanf("%2s\n",&comando);


        // Simulação de escrita na porta (substitua por sua implementação real)
        printf("\n\nEndereco do sensor: %d\n", srsAddress);
        printf("Comando:  0x%02hhX\n", comando);

        // Agora você pode escrever os dados na porta real, substitua esta parte pelo seu código real

        printf("Digite o endereco de um sensor ou -1 para sair\nAguardando: ");
        scanf("%d\n", &srsAddress);
    }

    close(fd);
    return 0;
}
