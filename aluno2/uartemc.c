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
	int fd, len;
	char text[255];
	struct termios options; /* Serial ports setting */

	fd = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY);
	if (fd < 0) {
		perror("Error opening serial port");
		return -1;
	}

	/* Read current serial port settings */
	// tcgetattr(fd, &options);
	
	/* Set up serial port */
	options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
	options.c_iflag = IGNPAR;
	options.c_oflag = 0;
	options.c_lflag = 0;

	/* Apply the settings */
	tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, &options);

	/* Write to serial port */
	strcpy(text, "1");
	len = strlen(text);
	// escREVE
	len = write(fd, text, len);
	printf("Wrote %d bytes over UART\n", len);
	
	//Testes loucos alucinados
    	unsigned char *ptr = (unsigned char *)&text;
    
    	for (int i = 0; i < sizeof(char); i++) {
        	printf("Byte %d: ", i + 1);
        	printBinary(ptr[i]);
        	printf("\n");
    	}
	
	//Fim dos testes loucos alucinados
	
	printf("You have 5s to send me some input data...\n");
	sleep(5);

	/* Read from serial port 
	memset(text, 0, 255);
	len = read(fd, text, 255);
	printf("Received %d bytes\n", len);
	printf("Received string: %s\n", text);
*/

	close(fd);
	return 0;
}
