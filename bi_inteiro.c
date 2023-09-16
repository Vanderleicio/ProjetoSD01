// Compilar com gcc bi_inteiro.c -o obj -lm


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

int bit_to_int(char *bits){
	int value = 0;
	int length = (int) strlen(bits)-1;
	
	for (int i = 0; bits[i] != '\0'; i++) {
		value = value + (bits[i]-'0')*pow(2,length-i);
	}
	return value;

}

int main(){
	char bits[] = "00011";
	printf("%d\n", bit_to_int(bits));
	return 0;
}
