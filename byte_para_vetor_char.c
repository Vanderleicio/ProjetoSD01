#include <stdio.h>
#include <string.h>

void printBinary(unsigned char byte) {
    for (int i = 7; i >= 0; i--) {
        printf("%d", (byte >> i) & 1);
    }
    printf("\n");
}


// ======================================================================================================================= //

/** Esta função recebe um caracter, e o byte que está sendo analisado. e coloca o binário em asc na string especificada
*/
void transforma_byte_em_bit(char byte, char *minhaString, int num_byte) {
	int pos_aux;
	int i;
	
	if (num_byte == 1){
		printf("\nNo %dº byte eu recebi o caracter %c \n", num_byte, byte);
		// O bit mais significativo vai ficar na posição 7
		for (i = 0; i < 8; i++) {
			minhaString[i] = (char) (((byte >> i) & 1) + '0'); 
			printf("%c ", (char) (((byte >> i) & 1) + '0'));
		}
	}
	else{
		// O bit mais significativo vai ficar na posição 7
		printf("\nNo %dº byte eu recebi o caracter %c \n", num_byte, byte);
		for (i = 0; i < 8; i++) {
			minhaString[i+8] = (char) (((byte >> i) & 1) + '0'); 
			printf("%c ", (char) (((byte >> i) & 1) + '0'));
		}
		minhaString[16] = '\0';//??
	}
	
}


int main(){
	//Z é o byte menos significativo
	char recebi_uart[2] = "Z0";//Simula oq se recebeu da uart
	
	char vetor_final[16];// Vetor de char com o binario, o MSB está em [15]
	printf("O binário de %c é: ", recebi_uart[0]);
	printBinary(recebi_uart[0]);
	printf("O binário de %c é: ", recebi_uart[1]);
	printBinary(recebi_uart[1]);
	///////////

	transforma_byte_em_bit(recebi_uart[0], vetor_final, 1);
	transforma_byte_em_bit(recebi_uart[1], vetor_final, 2);
	printf("\n\n\n\nE finalmente: ");
	printf("%s \n", vetor_final);
	
	return 0;
}


