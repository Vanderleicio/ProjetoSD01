#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>


int selector(char *comando){
    int resp;
    if (strcmp(comando,"0x00")==0){
        resp = 0;        
    }else if (strcmp(comando,"0x01")==0){
        resp = 1;   
    }else if (strcmp(comando,"0x02")==0){
        resp = 2;
    }else if (strcmp(comando,"0x03")==0){
        resp = 3;
    }else if (strcmp(comando,"0x04")==0){
        resp = 4;
    }else if (strcmp(comando,"0x05")==0){
        resp = 5;
    }else if (strcmp(comando,"0x06")==0){
        resp = 6;
    };
    return resp;


};

int main(){
    char comando[5]; // entrada do usuario
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

    while (comando!=NULL){
        printf("Digite um comando: ");
        fgets(comando, sizeof(comando), stdin);

        size_t len = strlen(comando);
        if (len > 0 && comando[len - 1] == '\n') {
            comando[len - 1] = '\0';
        }
        resp = selector(comando);



        strcpy(text, resp);
        len = strlen(text);
        // ESCREVE NA PORTA
        //len = write(fd, text, len);
    };
    return 0;
}
