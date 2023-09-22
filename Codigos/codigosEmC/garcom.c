#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

int main() {
    int fd;         /* file descriptor, identificador de um fluxo de dados */
	struct termios options; /* abre as configuracoes da porta serial */

	// Informando a porta, que é somente escrita, sem delay
	//	O_RDONLY e flag de somente escrita ; O_NDLEAY = sem delay; 
	// O_N0CTTY =  evita que a porta serial se torne o terminal de controle do processo
	fd = open("/dev/ttyS0", O_WRONLY | O_NDELAY | O_NOCTTY);
	if (fd < 0)
	{
		perror("Error opening serial port");
		return -1;
	}

	/* solicita as configuracoes da porta */
	tcgetattr(fd, &options);

	/* Configura a porta serial 
	*	B9600 = baud rate 9k6 | CS = 8bits | CLOCAL = conexão local | CREAD = Flag de somente leitura
	*	IGNPAR = Ignorar erros paridade, continua mesmo que ocorra erros
	*	c_oflag = out flag igual a 0, nenhum controle de saída específica aplicado
	*	c_lflag = in flag igual a 0, nenhum processamento especial e aplicado
	*/
	options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
	options.c_iflag = IGNPAR;
	options.c_oflag = 0;
	options.c_lflag = 0;

	/* Aplica as configuracoes 
	* 	descarta dados nao lidos da porta serial e depois aplica configuracoes definidas
	*	acima
	*/
	tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, &options);

	/** ######### TRECHO PARA ENVIAR ######### */
    unsigned char envio[2]; /* string a ser enviada (conjunto de dois char)*/
	unsigned char comando; 	/* Comando a enviar */
	int srsAddress;		   	/* Endereco do sensor */

	printf("Digite o endereco de um sensor ou -1 para sair\nAguardando: ");
	scanf("%i", &srsAddress);

	while (srsAddress != -1) {
        while (srsAddress < -1 || srsAddress >= 31) {
            printf("Endereco de sensor invalido. Digite um endereco entre 0 e 31 ou -1 para sair.\nAguardando: ");
            scanf("%i", &srsAddress);
            continue;
        }
		printf("TABELA DE COMANDOS:\n"
				"0x00 - REQUISITAR ESTADO ATUAL DO SENSOR\n"
				"0x01 - REQUISITAR TEMPERATURA ATUAL DO SENSOR\n"
                "0x02 - REQUISITAR HUMIDADE ATUAL DO SENSOR\n"
                "0x03 - ATIVAR SENSORIAMENTO CONTINUO DE TEMPERATURA\n"
                "0x04 - ATIVAR SENSORIAMENTO CONTINUO DE HUMIDADE\n"
                "0x05 - DESATIVAR SENSORIAMENTO CONTINUO DE TEMPERATURA\n"
                "0x06 - DESATIVAR SENSORIAMENTO CONTINUO DE HUMIDADE\n");
        printf("Digite um comando: ");
        scanf("%hhx", &comando);

        while (comando < -0x01 || comando > 0x07) {
            printf("Comando invalido. Digite um dos seguintes comandos:\n");
            printf("TABELA DE COMANDOS:\n"
				"0x00 - REQUISITAR ESTADO ATUAL DO SENSOR\n"
				"0x01 - REQUISITAR TEMPERATURA ATUAL DO SENSOR\n"
                "0x02 - REQUISITAR HUMIDADE ATUAL DO SENSOR\n"
                "0x03 - ATIVAR SENSORIAMENTO CONTINUO DE TEMPERATURA\n"
                "0x04 - ATIVAR SENSORIAMENTO CONTINUO DE HUMIDADE\n"
                "0x05 - DESATIVAR SENSORIAMENTO CONTINUO DE TEMPERATURA\n"
                "0x06 - DESATIVAR SENSORIAMENTO CONTINUO DE HUMIDADE\n");
            printf("Digite um comando: ");
            scanf("%hhx", &comando);
        }
		/* Monta a string de envio (char de comando + char de endereco)*/
        envio[1] = comando ; envio[0] = srsAddress; envio[2] = '\0';
		write(fd, envio, 2); // escreve na porta 

        printf("Digite o endereco de um sensor entre 0 e 31 ou -1 para sair\nAguardando: ");
        scanf("%i", &srsAddress);
    }
    return 0;
}
