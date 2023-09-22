# Projeto de Sensor Digital em FPGA utilizando Comunicação Serial.

### Desenvolvedores
------------

- [Vanderleicio Junior](https://github.com/Vanderleicio)
- [Washington Oliveira Júnior](https://github.com/wlfoj#-washington-oliveira-junior-)
- [Wagner Alexandre](https://github.com/WagnerAlexandre)
- [Lucas Gabriel](https://github.com/lucasxgb)

### Tutor 
------------

- [Thiago Cerqueira de Jesus](https://github.com/thiagocj)

### Sumário 
------------
+ [Como Executar](#como-executar)
+ [Introdução](#introdução)
+ [Características da Solução](#características-da-solução)
+ &nbsp;&nbsp;&nbsp;[Materiais Utilizados](#materiais-utilizados)
+ &nbsp;&nbsp;&nbsp;[Módulo de Comunicação](#módulo-de-comunicação)
+ &nbsp;&nbsp;&nbsp;[Módulo FPGA](#módulo-FPGA)
+ &nbsp;&nbsp;&nbsp;[Módulo DHT11](#módulo-DHT11)
+ &nbsp;&nbsp;&nbsp;[Sistema em C](#sistema-em-c)
+ [Tabela de Comandos](#tabela-de-comandos)
+ [Testes](#testes)
+ [Síntese (LEs, LABs e Pinos)](#síntese)
+ [Conclusões](#conclusões)
+ [Referências](#referências)



## Como Executar

Para executar o projeto é necessário primeiramente baixá-lo e descomprimí-lo. Em seguida compile os arquivos "garcom.c" e "observer.c" em dois terminais diferentes usando o comando "gcc <NomeDoArquivo>.c -o <NomeDoObjeto> e executando o objeto gerado com o comando "./<NomeDoObjeto>". Para o projeto em Veriolog, é necessário abrí-lo usando o software de projetos Quartus II, usando o modelo de FPGA `Cyclone IV EP4CE30F23C7`, além disso é necessário realizar a pinagem da placa e em seguida programá-la.

## Introdução


Nos dias atuais a tecnologia passou a ser uma ferramenta indispensável na vida dos seres humanos, uma vez que o desenvolvimento tecnológico progressivamente trás consigo ferramentas facilitadoras, que contribuem não só no cunho pessoal, mas em diversas áreas da sociedade. Um grande exemplo disso é a Internet das Coisas (IOT), uma tecnologia que vem ganhando grande notoriedade nos últimos anos. tendo como princípio a conexão entre o mundo físico (veiculos, dispositivos, sensores) e o digital (internet). A partir da comunicação entre dispositvos é possível a transmissão e obtenção de dados.

Partindo desse pressuposto, foi solicitado aos autores desse documento o desenvolvimento gradual de um sistema digital para gestão de ambientes, salienta-se que tal projeto está dividido em etapas. O objetivo da primeira etapa é implementar um sensor que exerce aferições de temperatura e umidade, a confecção dos sensores deve ser realizada em uma FPGA (arranjo de portas programavéis) que receberá a conexão do sensor DHT11, o programa deve ser modular, e escalável, permitindo a adição de mais sensores a FPGA, além disso deve-se implementar o protocolo de comunicação serial UART, responsável pela comunicação entre o sistema de testes desenvolvido em C e a FPGA, o sistema de testes enviará comandos para a FPGA, que deve obter os dados de um sensor especifico e retornar a respectiva resposta. As demais seções descrevem como foi o desenvolvimento da solução proposta.


## Características da Solução


Para compreensão do desenvolvimento da solução, dividiremos a explicação em cinco subseções, a primeira seção descreve quais foram os materias utilizados no desenvolvimento do sistema, a seção de comunicação trata sobre implementação da comunicação UART, o módulo FPGA reponsável pelo controle tanto da comunicação em C, quanto a comunicação com o DHT11, o módulo DHT11, implementado também no FPGA, e por fim a implementação do sistema de testes em C. De inicio começaremos falando sobre a comunicação UART.

### Materiais utilizados
--------------


- Kit de desenvolvimento `Mercúrio IV`.
- FPGA `Cyclone IV EP4CE30F23C7`.
- Linguagem de Programação C.
- Linguagem de desenvolvimento de hardware Verilog.

### Módulo de Comunicação
--------------


O UART, Universal Asynchronous Receiver/Transmitter, é um protocolo de comunicação serial que define um conjunto de regras para a troca de dados entre dois dispositivos (R&S Essentials). Contendo um transmissor e um receptor, conectados por fios,  a comunicação uart pode ser *simplex:* apenas uma direção realiza o envio de dados, *half-duplex:* as duas direções enviam os dados, porém cada um por vez, e por fim, os dados podem ser *full-duplex:* ambas as direções enviam dados simultaneamente.

Na implementação desta solução, optou-se pelo uso de comunicação half-duplex, pois o sistema não permite que a FPGA e o computador enviem dados ao mesmo tempo. A seção referente ao [Módulo FPGA](#modulo-FPGA) fornece detalhes sobre como ocorre a alternância entre os sensores. Para assegurar a uniformidade dos dados compartilhados em ambas as extremidades da comunicação, é essencial que ambas operem com a mesma taxa de baud. Neste caso, foi selecionado o valor de 9.600 Hz.


A comunicação UART é estabelecida entre o código C e a FPGA. No que diz respeito ao código C, a explicação é bastante simples. São utilizadas três bibliotecas (*stdio.h*, *unistd.h* e *fcntl.h*), além da definição de tags de controle, entrada, saída e local. Estas flags são responsáveis por habilitar o código C a realizar a comunicação UART.

### Recebendo dados via UART através da FPGA
----------

O módulo Uart Receptor desempenha a função de receber dados na FPGA através da interface UART. Este módulo possui quatro parâmetros:

- `clk_9k6hz`: Refere-se ao clock de 9.600 Hz, utilizado para sincronizar o transmissor com o receptor, assegurando a integridade dos dados. Importante ressaltar que esse clock é obtido a partir da divisão do clock da placa (50MHz) por um valor aproximado a 9.600 Hz.
- `rx`: Corresponde aos dados recebidos de forma serial do PC.
- `data`: Enviará os dados recebidos para o decodificador.
- `concluded`: Este sinal informa aos outros módulos que os dois bytes de dados foram recebidos.

Dentro do módulo Uart Receptor, há uma máquina de estados finitos composta por três estados, encarregados do processo de recebimento dos dados (Comando + Endereço Sensor) provenientes do computador. Esses dados são utilizados para solicitar ao sensor a informação correspondente. Sobre os estados: 

+ **Start:** Estado inicial, este é o estado inicial da máquina. Aqui, a máquina aguarda a recepção do bit de início, bit 0. Assim que recebido, ela transita para o estado de "Data" para iniciar o compartilhamento de dados. Se continuar recebendo bit 1, permanece neste estado.

+ **Data:** Estado de transmissão, a comunicação UART permite apenas a transmissão de 8 bits de dados de cada vez. Caso seja necessário transmitir uma quantidade maior de dados, é possível fazê-lo em partes, em requisições separadas de 8bits de comprimento. Durante este estado, a FPGA verifica se o bit sendo recebido é o último. Esta verificação ocorre tanto para a sequência do 1º byte, quanto para o 2º byte. Caso seja o último bit, a máquina transita para o estado de "Stop". Caso contrário, permanece no estado "Data" e incrementa o contador em +1. Este contador serve para determinar a quantidade de dados recebidos e a posição desse dado. Quando a máquina conclui a transmissão de um byte, verifica-se qual byte ela transmitiu verificando o contador, caso seja o 1º byte, a máquina transita para o estado de Stop, desse estado, volta para o estado Start para receber o 2º byte. 

+ **Stop:** Estado de final, Neste estado, verifica-se se o último dado correspondente ao segundo byte foi recebido. Se sim, o valor do buffer é atribuído ao registrador de dados e o sinal concluído é definido como bit 1, indicando o término da transferência.

### Enviando dados via UART através da FPGA
----------

O módulo Uart Transmissor desempenha a função de transmitir os dados da FPGA através da interface UART. Este módulo possui cinco parâmetros:

- `clk_9k6hz`: Refere-se ao clock de 9.600 Hz.
- `tx`: Corresponde aos dados a serem transmitidos de forma serial.
- `data`: Dados a serem transmitidos, dados que vem do sensor e são tratados no código em C.
- `en`: Sinal que habilita a transmissão.
- `done`: Este sinal informa aos outros módulos que a transmissão foi concluída.


Dentro do módulo Uart Transmissor, uma máquina de estados finitos composta por quatro estados é empregada para gerenciar o processo de recebimento da resposta de dados do sensor e encaminhamento desses dados (Comando + Endereço Sensor) para o módulo solicitador. O funcionamento dos estados é o seguinte:

+ **Idle:** Estado de espera.

+ **Start:** Este é o estado inicial. Ele inicia a comunicação UART enviando o bit de início, sinalizando ao receptor que a transmissão está prestes a começar, e então avança para o próximo estado.

+ **Data:** Neste estado de transmissão, há um contador que é decrementado a cada iteração. O contador indica qual o bit de data está sendo transmitido. Assim como no receptor, este estado possui verificações para determinar qual byte está sendo transmitido. Se ainda houver bits a serem transmitidos, o estado permanece em modo de transmissão. Se a transmissão do 1º byte for concluída, é necessário repetir o processo para transmitir o 2º byte. Ao finalizar, o estado transita para o estado final.

+ **Stop:** Este é o estado final. Se apenas o primeiro bit foi enviado, a máquina retorna ao estado de start. Se a transmissão não foi concluída, o sinal de finalização é definido como 1, e a máquina retorna ao estado de espera.



### Módulo FPGA
--------------


O módulo FPGA desempenha o papel de controlador neste protótipo. Nele, ocorre tanto a recepção quanto o encaminhamento de dados, seja proveniente do sensor DHT11 [Módulo DHT11](#módulo-DHT11), ou sejam solicitações oriundas do PC. Todas essas operações passam pela FPGA. O módulo de comunicação, explicado na seção anterior, representa apenas uma parte menor do conjunto principal da FPGA.


#### Entregador

O receptor UART possui duas saídas de informação cruciais para esta estrutura: um sinal indicando a conclusão da recepção e os dados recebidos. Isso viabiliza que o entregador, fazendo um barramento dos dados (Comando + Endereço Sensor) provenientes da UART, identifique o endereço do sensor. Este endereço pode então ser vinculado a um pino que sinaliza se houve alguma requisição para o sensor DHT11..


## Módulo DHT11

- **Código do DHT11 adaptado do grupo: [José Gabriel, Thiago Pinto, Pedro Henrique e Luís Henrique](https://github.com/juserrrrr/DigitalSensorQuery/blob/main/fpgaProject/dht.v)**

<center>
  
![DHT11](https://github.com/Vanderleicio/ProjetoSD01/blob/main/imagens/dht11.png)
- **Figura 1:** *Funcionamento do sensor. [Components101](https://components101.com/sensors/dht11-temperature-sensor)*

</center>

O módulo DHT11 é responsável por implementar a lógica de funcionamento do sensor. Essa estrutura visa executar de maneira similar a imagem acima. Para isso o DHT11 conta com 10 estados, sendo eles:
+ **Idle:** O estado inicial do sensor é o estado de espera, no qual a máquina permanece até que o bit inicial seja recebido. Para iniciar a comunicação e ir para o próximo estado, o DHT11 aguarda a recepção de um bit em nível lógico baixo, pois seu estado de espera é sempre em nível lógico alto.
+ **Start:** Ao receber um sinal de início, o DHT11 aguarda por 19 ms em nível lógico baixo. Durante esse período, um contador é continuamente incrementado. Quando esse contador atinge o valor correspondente a 19.000 ciclos do clock de micro segundos, o sistema avança para o próximo estado.
+ **Detected_signal:** Estado de alternância, quando chega nesse estado, irá esperar 20µs, para que seja possível alternar a direção do sinal do pino inout utilizado no tri state, uma vez que agora quem irá assumir a comunicação é o sensor.
+ **Wait_dht11:** Estado de espera, ao chegar nesse estado irá aguardar mais 21µs, para poder receber do sensor o sinal de resposta que identifica que o sensor está pronto para transmitir os dados.
+ **dht11_response:** No estado de envio de sinal de resposta, o sensor deve emitir um sinal em nível lógico baixo com uma duração de 80µs. Se o sinal continuar baixo após os 80µs, é considerado um erro. Caso contrário, o sistema avança para o próximo estado.
+ **dht11_high_response:** No estado de envio de sinal de resposta alto, o sensor agora deve emitir um sinal em nível lógico alto com uma duração de 80µs, se atingir o tempo e o nível lógico ainda estiver alto, ocorreu um erro, caso o contrario, inicia-se a transmissão.
+ **transmit:** No estado de transmissão, após a emissão do sinal de resposta, se tudo transcorrer conforme o esperado, o sensor inicia a transmissão dos dados. Neste estágio, o sensor aguarda 50µs em nível lógico baixo. Se o tempo passar e o sensor ainda estiver em nível lógico baixo, ocorrerá um erro. Caso contrário, vai para o próximo estado verificar a duração do próximo sinal para determinar se o bit de dados é 1 ou 0. Este estado possui um buffer projetado para armazenar 40 bits de dados, sendo atualizado até que o valor de um contador alcance 40.
+ **detect_bit:** No estado de detecção de bits, verifica-se se o valor do contador é superior a 50µs para determinar se o bit é 1; caso contrário, o bit é considerado 0. Em seguida, o índice do buffer é incrementado em um bit. Este estado persiste em retornar para a fase de transmissão até que o índice alcance 40 bits, indicando que todos os dados foram transmitidos.
+ **wait_signal:** Estado de segurança, aguarda 100µs para garantir que o DHT11 esteja livre para uso novamente.
+ **stop:** Se chegou em stop, ou deu erro ou a transmissão foi um sucesso, e com isso retornar para o estado de espera.

#### Controlador

O módulo controlador possibilita a solicitação de diversas informações do sensor DHT11, como temperatura, umidade, ou a contínua atualização de uma dessas variáveis. Ele age como o coordenador dos dados, processando e enviando de volta ao PC apenas o que foi requisitado.

Essa estrutura é composta por uma máquina que possuí quatro estados distintos: 

+ **Espera Comando:** O estado inicial permanece em espera até receber um comando (sinal de requisição). Se a solicitação recebida for para monitoramento contínuo, é essencial alternar o registrador que armazena as informações do comando solicitado para o sensor selecionado e, em seguida, avançar para o próximo estado. Tal como, se a solicitação for para um dado específico. Por outro lado, ocorre um erro se o valor do contador for diferente de zero, pois ele implemente um tempo de espera de 2 segundos entre as solicitações ao sensor DHT11.

+ **Coletando:** No estado de coleta e tratamento das informações do sensor, primeiro verifica-se se o sensor correspondente à solicitação já obteve todos os dados necessários, se não, se mantém no estado. Se  for confirmado, o registrador info, com 16 bits, recebe a informação do endereço do sensor (5 bits). Após essa atribuição e na ausência de erros detectados no sensor, inicia-se o processo para determinar qual comando foi enviado. Recebemos dados do sensor de temperatura e umidade, tanto em formato inteiro quanto decimal, e o dado de checksum, com 8 bits cada. Todas essas informações são armazenadas no barramento saidaDHT, que possui 40 bits. Com base no comando recebido do PC, seleciona-se um intervalo de 8 bits no saidaDHT correspondente ao que foi requisitado. Por exemplo, quando se solicita o valor da temperatura atual, info além de guardar o endereço do sensor, recebe o comando de resposta, e também armazena o dado de saidaDHT[22:16], que representa o valor inteiro da temperatura. A estrutura de info[15:0] é composta por 5 bits de endereço, 4 bits representando comando de resposta e os 7 bits restantes referentes a informação solicitada, ocupando todos os 16 bits definidos para essa funcionalidade.

+ **Transmitir:** No estado de transmissão, a máquina aguarda até que o módulo [escalonador](#escalonador) sinalize que já retirou os dados do buffer. Caso isso ainda não tenha acontecido, ela permanece nesse estado.

+ **Resetar:** 
Ao chegar ao estado final, a máquina verifica se a solicitação é do tipo contínuo. Nesse caso, ela precisa repetir o processo até receber o comando para desativar esse monitoramento, para isso alterna o registrador "solicitação" que garante que solicitações atuais e solicitações de monitoramento contínuo sejam atendidas de maneira revezada.


#### Escalonador

É o módulo responsável por garantir que os dados, fornecidos pelo controlador, de todos os sensores sejam enviados plenamente pelo transmissor. Ele tem apenas 2 estados, sendo eles:
+ **A:** Estado durante o qual o escalonador alterna entre os módulos controladores checando se algum deles está sinalizando que a informação que ele precisa enviar já está armazenada no seu buffer.
+ **T:** Estado que transmite a informação correspendente e sinaliza para o controlador quando toda sua informação já tiver sido transmitida.
  
## Sistema de teste 

O sistema de teste feito em C foi dividido em duas partes: Observador e Garçom:

O Observador é responsável por ler as informações recebidas pela porta serial do computador, tratá-las e exibi-la em um terminal.

O Garçom é responsável por ler as entradas do usuário e enviá-las por UART para a placa FPGA.

Os códigos em C responsáveis por se comunicarem com a porta serial utilizam as seguintes bibliotecas:

<stdio.h> (Standard Input and Output): Esta biblioteca é essencial para operações de entrada e saída padrão. No código, ela é usada principalmente para exibir mensagens no terminal e para ler as entradas do usuário. As funções printf e scanf são usadas para exibir informações no terminal e coletar dados do usuário.

<string.h> (String Handling): A biblioteca <string.h> fornece funções e utilitários para manipulação de strings. No código, é utilizada para a função memset, que é responsável por preencher uma região da memória com um valor específico (usado para zerar o buffer “envio”).

<unistd.h> (Unix Standard): Essa biblioteca contém funções relacionadas a operações de sistema e entrada/saída não bloqueantes. No código, ela é usada principalmente para operações não bloqueantes de E/S, como a função sleep para introduzir um atraso durante a execução do observador para permitir a visualização dos dados.

<fcntl.h> (File Control): Essa biblioteca fornece constantes e funções para controlar a abertura e configuração de descritores de arquivo. No código, é usada para abrir a porta serial /dev/ttyS0 com as configurações desejadas, como escrita não bloqueante.

<termios.h> (Terminal I/O): A biblioteca <termios.h> é usada para configurar os parâmetros da porta serial, como velocidade de transmissão, bits de dados, paridade e outras opções de controle. No código, as estruturas e funções desta biblioteca são usadas para configurar a porta serial (fd) de acordo com as especificações desejadas.

## Tabela de Comandos

A transmissão de dados pela UART segue uma padronização que compreende duas possibilidades: o padrão de requisição e o padrão de resposta.

O padrão de requisição consiste em dois bytes (ou 16 bits) organizados do bit menos significativo (localizado à esquerda) para o mais significativo (localizado à direita). A [Tabela 1](#tabela-requisição) apresenta a codificação utilizada para os comandos de requisição em formato binário. O primeiro byte é formado por 5 bits que representam o endereço, complementado por 3 bits 0. O segundo byte é composto por 4 bits que representam o código da requisição, seguidos por outros 4 bits definidos como 0. Assim são formados os dois bytes da requisição.

![#tabela-requisição](https://github.com/Vanderleicio/ProjetoSD01/blob/main/imagens/requisicaoTabela.png "#tabela-requisição")
- **Tabela 1:** *Tabela de comandos de requisição*


A [Tabela 2](#tabela-resposta) exibe a codificação utilizada para os comandos de resposta segue o seguinte padrão: o primeiro byte é composto por 5 bits que representam o endereço, seguidos por 3 bits que fazem parte do código de resposta. O segundo byte é composto por 1 bit, que constitui o restante do código de resposta (sendo este o bit menos significativo do segundo byte), além de 7 bits destinados aos dados. Dessa forma, são formados os dois bytes de resposta.

![#tabela-resposta](https://github.com/Vanderleicio/ProjetoSD01/blob/main/imagens/respostasTabela.png "#tabela-resposta")
- **Tabela 2:** *Tabela de comandos de respostas*




## Teste

Algumas simulações e os resultados encontrados:

**Entrada:** Para endereço 0 e comando 0x01/ **Resposta:** Atualização do valor de temperatura do Sensor 0 para o valor medido;
**Entrada:** Para endereço 0 e comando 0x02/ **Resposta:** Atualização do valor de umidade do Sensor 0 para o valor medido;
**Entrada:** Para endereço 0 e comando 0x00/ **Resposta:** Mensagem informando que: sensor em pleno funcionamento (se houver sensor conectado), sensor não funciona (se não houver sensor conectado);
**Entrada:** Para endereço 5 (que não tenha sensor conectado) e comando 0x02/ **Resposta:** Mensagem informando que o sensor não funciona;
**Entrada:** Para endereço 0 e comando 0x03/ **Resposta:** Envio contínuo da temperatura do sensor 0;
**Entrada:** Para endereço 0 e comando 0x05/ **Resposta:** Mensagem informando que o monitoramento de temperatura contínua foi desativado;
**Entrada:** Para endereço 0, comando 1 0x03 e comando 2 0x02/ **Resposta:** Envio contínuo da temperatura com um envio da umidade;



## Resultados de Síntese

Ao observar a Figura 2 (sintese), nota-se que a implementação da solução proposta utiliza aproximadamente 8% dos elementos lógicos da placa e 10% dos seus LABs. Esses valores são consideráveis em comparação com as opções adotadas no projeto, como a utilização de muitas máquinas de estados. Outro ponto notório é a quantidade de pinos utilizado, apenas 11 pinos, utilizando cerca de 3% dos pinos totais da FPGA.

<center>
  
![Síntese (LEs, LABs, Pinos)](https://github.com/Vanderleicio/ProjetoSD01/blob/main/imagens/SINteseFig.png)
- **Figura 2:** *Resultados de sintése.*
</center>

## Conclusões

A solução apresentada cumpre com os requisitos solicitados no problema tanto do ponto de vista técnico, quanto do ponto de vista teórica. Através do desenvolvimento do sistema foi possível entender e aprimorar conceitos básicos de sistemas digitais, bem como conceitos novos, como por exemplo, a comunicação serial UART e o gerenciamento do envio de dados em paralelo. Através desta solução é possível solicitar e verificar os índices de temperatura e umidade medidos pelo sensor, ativar e desativar o sensoriamento contínuo desses índices, bem como confirmar a situação atual de cada sensor. Como eventual melhora futura, é possível implementar padrões de confirmação de recebimento e envio dos dados tanto entre o computador e a placa FPGA, bem como entre o sensor e placa. 

## Referências

[R&S®Essentials - Compreenda à Uart](https://www.rohde-schwarz.com/br/produtos/teste-e-medicao/essentials-test-equipment/digital-oscilloscopes/compreender-uart_254524.html "Uart")

[Johannes 4GNU_Linux - UART em C](https://www.youtube.com/watch?v=n2s8Y8slL28&t=676s "Access the UART (Serial Port) on GNU/Linux with a simple C program")
