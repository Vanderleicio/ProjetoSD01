#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

/*
* Recebe codigo hex
* e devolve cod binario do comando, pronto para uart 
*/
int selector(char *comando){   
    if (strcmp(comando,"0x00")==0){
        return 0;        
    }else if (strcmp(comando,"0x01")==0){
        return 1;   
    }else if (strcmp(comando,"0x02")==0){
        return 2;
    }else if (strcmp(comando,"0x03")==0){
        return 3;
    }else if (strcmp(comando,"0x04")==0){
        return 4;
    }else if (strcmp(comando,"0x05")==0){
        return 5;
    }else if (strcmp(comando,"0x06")==0){
        return 6;
    };
    return -1; // erro, comando nao especificado
};

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
    int srsAddress;  // endereco do sensor
    while (srsAddress!=-1){
        printf("Digite o endereco de um sensor ou -1 para sair\n Aguardando: ");
        scanf("%i",&srsAddress);
    
        while (comando!=NULL){
            printf("Digite um comando: ");
            fgets(comando, sizeof(comando), stdin);

            resp = selector(comando);


            printf("%c", resp);

            strcpy(text, resp);
            len = strlen(text);
            // ESCREVE NA PORTA
            len = write(fd, text, len);
        };
    };

    close(fd);
    return 0;
}
