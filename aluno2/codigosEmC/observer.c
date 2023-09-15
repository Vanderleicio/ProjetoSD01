#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>

typedef struct sensor{
	char temp;
	char humidity;
} sensor;


void binToInt(char binary[], int rec){
		for(int i = 0; i<8; i++){
			rec = rec + (binary[i] * (pow(2, i)));
		};
	};

void terminalprinter(int srs_address, sensor* reading,char info, int n_humi){
	// troca as informacoes
	reading[srs_address].temp = info;
	reading[srs_address].humidity;
	
	printf("\033[J");; // chama funcao de limpar terminal

	// print do array de sensores atualizado com as novas informações	
	printf("SENSOR");
	printf("TEMP %d | HUMI %d",reading[srs_address].temp,reading[srs_address].humidity);
}

int main (){
	sensor arrayE[31];
	int numBytes = 2;
	int fd, len;
	char text[numBytes];// só salvo dois bytes(char) por vez
	struct termios options; /* Serial ports setting */

	char* address,comand,info;

	int fresh = 0;
	unsigned char *pST = (unsigned char *)&text;

	// Informando a porta, que é de leitura e escrita, sem delay
	//O_RDONLY e flag de somente leitura
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
	
	/* Apply the settings */
	tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, &options);
    
    
	// bloco de leitura continua da porta de conexao, bloco de excecao dedicado a nao subir db.lock
	// 16 bits
	// 
	// +			-
	//0			0
	
	while (fd > 0){
		// Read from serial port 
		for (fresh <= 31;fresh++;){
			memset(text, 0, numBytes);
			len = read(fd, text, numBytes);
			unsigned char *pST = (unsigned char *)&text;

				// chame a funcao que ira atualizar as informacoes dos sensores
				// e imprimir no terminal
			address,comand,info = recConvert(pST);
			terminalprinter(address,comand,arrayE,info);
		}

		// deve chamar funcao de sleep para tornar possivel leitura das informacoes
		//sleep = (int number); number = milisegundo
		sleep(200*1000);	// quando em linux
	};

	
	close(fd);
	return 0;
	}
	
/*
* usar as informacoes recebidas pela uart
* trocar a informacao do sensor dentro da leitura (reading) pelo novo dado
* limpar a tela
* printar array com informacoes atualizadas
* utiliza ponteiros para manipular valores originais do vetor de sensores.
* srs_address = Endeço do sensor (0 a 31)
* reading = vetor de sensores
* newInfor = vetor com as informacoes a serem atualizadas
*/
