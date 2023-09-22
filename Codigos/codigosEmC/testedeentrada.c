#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>


typedef struct sensor{
	char temp;
	char humidity;
} sensor;


// fatia a string recebida nos vetores usaveis
char recConvert(char *recived){
	char* address;
	char comand[4];
	char info[8];

        


	return *address,*comand,*info;
}

void terminalprinter(int srs_address, sensor* reading,char info, int n_humi){
	// troca as informacoes
	reading[srs_address].temp = info;
	reading[srs_address].humidity;
	
	printf("\033[J");; // chama funcao de limpar terminal

	// print do array de sensores atualizado com as novas informações	
	printf("SENSOR");
	printf("TEMP %d | HUMI %d",reading[srs_address].temp,reading[srs_address].humidity);
}



int main() {
    char comando[5]; // entrada do usuário
    int srsAddress;  // endereço do sensor

    printf("Digite o endereco de um sensor ou -1 para sair\nAguardando: ");
    scanf("%i", &srsAddress);

    while (srsAddress != -1) {
        while (getchar() != '\n'); // Limpar o buffer de entrada

        printf("Digite um comando: ");
        fgets(comando, sizeof(comando), stdin);

        // Remova a quebra de linha do comando, se presente
        size_t len = strlen(comando);
        if (len > 0 && comando[len - 1] == '\n') {
            comando[len - 1] = '\0';
        }

        // Simulação de escrita na porta (substitua por sua implementação real)
        printf("Endereco do sensor: %i\n", srsAddress);
        printf("Comando: %s\n", comando);

        // Agora você pode escrever os dados na porta real, substitua esta parte pelo seu código real

        printf("Digite o endereco de um sensor ou -1 para sair\nAguardando: ");
        scanf("%i", &srsAddress);
    }

    return 0;
}
