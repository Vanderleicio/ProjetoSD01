#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <termios.h>
#include <string.h>

/* Struct que representa um sensor
*	Atributos: 
*	*	temp = temperatura
*	*	humidity = umidade
*/
typedef struct sensor{
	char temp;
	char humidity;
} sensor;

/* Procedimento de limpeza do terminal
* 	contido no header stdlib, chama funcao de limpeza
* 	do terminal do SO UBUNTU
*/
void limpaTela() {
    system("clear");
}

/* Procedimento que imprime no terminal as informacoes de cada sensor
* 	Adaptado de: https://github.com/juserrrrr/DigitalSensorQuery/tree/main
*/
void printAllSensors(sensor *sensorArray) {
    printf("\nSituacao atual dos sensores:\n");
    printf("\n----------------   ----------------   ----------------   ----------------\n");

    for (int i = 0; i < 32; i++) {
        // i = numero do sensor;
        printf("|%2d|T:%-2iC H:%-2i%%|", i, sensorArray[i].temp, sensorArray[i].humidity);
		printf("   "); // Adicionar 4 espaços entre conjuntos de informações

        if ((i + 1) % 4 == 0) {	// a cada 4 sensores, quebra a linha
            if (i != 31) {
                printf("\n|--|-----------|   |--|-----------|   |--|-----------|   |--|-----------|\n");
            } else {
                printf("\n----------------   ----------------   ----------------   ----------------\n");
            }
        }
    }
}
/* 	Troca as informacoes do sensor dentro da lista de sensores
*	E tambem aponta problema ou resposta desconhecida
*/
void refreshSensors(sensor *reading,int srs_address,int info, int comando){
	switch (comando){
	case 7:		// sensor com problema
		printf("Problema no sensor N:%i\n",srs_address);
		break;
	case 1:		// sensor funcionando normalmente
		printf("Sensor %i Operando normalmente.\n",srs_address);
		break;
	case 2:		// requesitar umidade
		printf("Umidade do sensor N %i: %i\n",srs_address, info);
		reading[srs_address].humidity = info; 
		break;
	case 3:		// requesitar temperatura
		printf("Temperatura do sensor N %i: %i\n",srs_address, info);
		reading[srs_address].temp = info;
		break;
	case 4:		// desativacao do monitoramento continuo de temperatura
		printf("Monitoramento continuo de temperatura do sensor N %i desativado.\n",srs_address);
		break;
	case 5:		// desativacao do monitoramento continuo de umidade
		printf("Monitoramento continuo de umidade do sensor N %i desativado.\n",srs_address);
		break;
	default:		// resposta nao conhecida
		printf("Codigo de resposta nao conhecido. COD RECEBIDO: %i\nEndereco: %i\nInfo: %i\n",comando,srs_address,info);
		break;
	}
}

int main (){
	sensor arrayE[32];	// lista de sensores que guarda a ultima informacao recebida de cada sensor
	for (size_t i = 0; i < 32; i++)	// zerando lixo na memoria
	{
		arrayE[i].temp = 0;
		arrayE[i].humidity = 0;
	}

	struct termios options; /* abre as configuracoes da porta serial */
	int numBytes = 2; // numero de bytes a serem recebidos
	int fd;		// file descriptor, identificador de um fluxo de dados
	char text[numBytes];// só salvo dois bytes(char) por vez

	// Informando a porta, que é somente leitura, sem delay
	//	O_RDONLY e flag de somente leitura ; O_NDLEAY = sem delay; 
	// 	O_N0CTTY =  evita que a porta serial se torne o terminal de controle do processo
	fd = open("/dev/ttyS0", O_RDONLY | O_NDELAY | O_NOCTTY);	
	if (fd < 0) {
		perror("Error opening serial port");
		return -1;
	};
	
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
	
	tcflush(fd, TCIFLUSH); /* descarta dados nao lidos da porta serial */
	tcsetattr(fd, TCSANOW, &options); /* Aplica as configuracoes */
    
	/* endereco | informacao | comando */
	unsigned int address,info,comand;
	
	unsigned char *pRT;	/* Ponteiro para informacoes lidas */

    /* Enquanto a porte estiver aberta:	*/
	while (fd > 0){
		memset(text, 0, numBytes);	// define todos os bits como 0
		read(fd, text, numBytes);	// le os dados da porta e os copia para text

		if(fd){	
			pRT = (unsigned char *)&text;	// ponteiro para o endereco de onde esta salvo os dados lidos

			// trate variavel pRT e separe as informacoes recebidas:
			info = pRT[1] >> 1;		// ignora bit menos significativo (usado como comeco do comando)
									// desloca um bit para a direta
			comand = (pRT[0]>>5);	// comando e os 3 bits mais significativos do primeiro byte recebido
									// desloca cinco bits para a direita 
			address = (pRT[0] & 0x1F); 	// endereco do sensor dono das informacoes e os 5 bits menos
										// significativos
			
			// chame as funcoes que irao atualizar as informacoes dos sensores
			
			printAllSensors(arrayE);
			sleep(1); // deve chamar funcao de sleep para tornar possivel leitura das informacoes
			limpaTela();
			if (pRT[0]!= 0 || pRT[1] != 0){ // se alguma informacao foi recebida:
				// atualiza situacao ou chama mensagem de erro
				refreshSensors(arrayE,address,info,comand);
				}
		};
	}
	close(fd);
	return 0;
}
