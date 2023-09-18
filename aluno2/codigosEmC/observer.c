#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <termios.h>

// bloco para detectar sistema operacional (usado no procedimento limpaTela())
#if defined(_WIN32) || defined(_WIN64)
    #define OS_WINDOWS
#elif defined(__linux__)
    #define OS_LINUX
#endif

typedef struct sensor{
	char temp;
	char humidity;
} sensor;

void limpaTela() {
    #ifdef OS_WINDOWS
        system("cls"); // Limpar terminal
    #elif OS_LINUX
        system("clear");
    #endif
}

void printAllSensors(sensor *sensorArray) {

    printf("\nSituacao atual dos sensores:\n");
    printf("\n----------------   ----------------   ----------------   ----------------\n");

    for (size_t i = 0; i < 32; i++) {
        // i = numero do sensor;
        printf("|%2d|T:%-2iC H:%-2i%%|", i, sensorArray[i].temp, sensorArray[i].humidity);
		printf("   "); // Adicionar 4 espaços entre conjuntos de informações

        if ((i + 1) % 4 == 0) {
            if (i != 31) {
                printf("\n|--|-----------|   |--|-----------|   |--|-----------|   |--|-----------|\n");
            } else {
                printf("\n----------------   ----------------   ----------------   ----------------\n");
            }
        }
    }
}

void refreshSensors(sensor *reading,int srs_address,int info, int comando){
	switch (comando)
	{
	case 8:		// sensor com problema
		printf("Problema no sensor N:%i\n",srs_address);
		break;
	case 9:		// sensor funcionando normalmente
		printf("Sensor %i Operando normalmente.\n",srs_address);
		break;
	case 10:		// requesitar umidade
		printf("Umidade do sensor N %i: %i\n",srs_address, info);
		reading[srs_address].humidity = info; 
		break;
	case 11:		// requesitar temperatura
		printf("Temperatura do sensor N %i: %i\n",srs_address, info);
		reading[srs_address].temp = info;
		break;
	case 12:		// desativacao do monitoramento continuo de temperatura
		printf("\n");
		break;
	case 13:		// desativacao do monitoramento continuo de umidade
		printf("\n");
		break;
	default:		// resposta nao conhecida
		printf("\n");
		break;
	}
}

int main (){
	sensor arrayE[32];
	for (size_t i = 0; i < 32; i++)	// zerando lixo na memoria
	{
		arrayE[i].temp = 0;
		arrayE[i].humidity = 0;
	}
	
	int numBytes = 2;
	int fd, len;
	char text[numBytes];// só salvo dois bytes(char) por vez
	struct termios options; /* Serial ports setting */

	//	  endereco | informacao | comando
	unsigned int address,info,comand;


	int fresh = 0;
	unsigned char *pST = (unsigned char *)&text;

	// Informando a porta, que é somente leitura, sem delay
	//	O_RDONLY e flag de somente leitura ; O_NDLEAY = sem delay; O_N0CTTY = porta
	fd = open("/dev/ttyS0", O_RDONLY | O_NDELAY | O_NOCTTY);
	if (fd < 0) {
		perror("Error opening serial port");
		return -1;
	};
	
	/* Read current serial port settings */
	tcgetattr(fd, &options);
	
	/* Set up serial port */
	// baud rate 9k6, 8bits | conexão local | Flag de somente leitura
	options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
	options.c_iflag = IGNPAR;
	options.c_oflag = 0;
	options.c_lflag = 0;
	
	/* Aplica as configuracoes */
	tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, &options);
    
	while (fd > 0){
		// Ler a porta serial
		memset(text, 0, numBytes);
		len = read(fd, text, numBytes);
		if(fd){	
			*pST = (unsigned char *)&text;

			// trate variavel pST e separe as informacoes recebidas
			// se endereco e informacao sao inteiros e comando um char:
			info = pST[0] -'0';
			address = (pST[1] << 4) - '0';
			comand = (pST[1] >> 4) - '0';
			// chame a funcao que ira atualizar as informacoes dos sensores
			refreshSensors(arrayE,address,info,comand);
		}
		// deve chamar funcao de sleep para tornar possivel leitura das informacoes
		//sleep = (int number); number = milisegundo
		printAllSensors(arrayE);
		sleep(0.5);
		limpaTela();
		};


	
	close(fd);
	return 0;
	}
	
