# Projeto de Sensor Digital em FPGA utilizando Comunicação Serial.

### Desenvolvedores
------------

[Vanderleicio Junior](https://github.com/Vanderleicio).
[Washington Oliveira Júnior](https://github.com/wlfoj#-washington-oliveira-junior-).
[Wagner Alexandre](https://github.com/WagnerAlexandre).
[Lucas Gabriel](https://github.com/lucasxgb).

### Tutor 
------------

[Thiago Cerqueira de Jesus](https://github.com/thiagocj).

### Sumário 
------------
+ [Como Executar](#como-executar).
+ [Introdução](#introdução).
+ [Características da solução](#características).
+ &nbsp;&nbsp;&nbsp;[Materiais utilizados](#materiais).
+ &nbsp;&nbsp;&nbsp;[Módulo de Comunicação](#comunicação).
+ &nbsp;&nbsp;&nbsp;[Módulo FPGA](#módulo-FPGA).
+ &nbsp;&nbsp;&nbsp;[Módulo DHT11](#módulo-DHT11).
+ &nbsp;&nbsp;&nbsp;[Sistema de teste](#módulo-C).
+ [Tabela de Comandos](#tabela-de-domandos).
+ [Testes](#testes).
+ [Síntese (LEs, LABs e Pinos)](#síntese).
+ [Como Executar](#resultados).
+ [Conclusões](#conclusões).
+ [Referências](#referências). 



## Como Executar

## Introdução


Nos dias atuais a tecnologia passou a ser uma ferramenta indispensável na vida dos seres humanos, uma vez que o desenvolvimento tecnológico progressivamente trás consigo ferramentas facilitadoras, que contribuem não só no cunho pessoal, mas em diversas áreas da sociedade. Um grande exemplo disso é a Internet das Coisas (IOT), uma tecnologia que vem ganhando grande notoriedade nos últimos anos. tendo como princípio a conexão entre o mundo físico (veiculos, dispositivos, sensores) e o digital (internet). A partir da comunicação entre dispositvos é possível a transmissão e obtenção de dados.

Partindo desse pressuposto, foi solicitado aos autores desse documento o desenvolvimento gradual de um sistema digital para gestão de ambientes, salienta-se que tal projeto está dividido em etapas. O objetivo da primeira etapa é implementar um sensor que exerce aferições de temperatura e umidade, a confecção dos sensores deve ser realizada em uma FPGA (arranjo de portas programavéis) que receberá a conexão do sensor DHT11, o programa deve ser modular, e escalável, permitindo a adição de mais sensores a FPGA, além disso deve-se implementar o protocolo de comunicação serial UART, responsável pela comunicação entre o sistema de testes desenvolvido em C e a FPGA, o sistema de testes enviará comandos para a FPGA, que deve obter os dados de um sensor especifico e retornar a respectiva resposta. As demais seções descrevem como foi o desenvolvimento da solução proposta.


## Características da Solução


Para compreensão do desenvolvimento da solução, dividiremos a explicação em cinco subseções, a primeira seção descreve quais foram os materias utilizados no desenvolvimento do sistema, a seção de comunicaçãotrata sobre implementação da comunicação UART, o módulo FPGA reponsável pelo controle tanto da comunicação em C, quanto a comunicação com o DHT11, o módulo DHT11, implementado também no FPGA, e por fim a implementação do sistema de testes em C. De inicio começaremos falando sobre a comunicação UART.

### Materiais utilizados
--------------


- Kit de desenvolvimento `Mercúrio IV`.
- FPGA `Cyclone IV EP4CE30F23C7`.
- Linguagem de Programação C.
- Linguagem de desenvolvimento de hardware verilog.

### Comunicação
--------------


O UART, Universal Asynchronous Receiver/Transmitter, é um protocolo de comunicação serial que define um conjunto de regras para a troca de dados entre dois dispositivos (R&S Essentials). Contendo um transmissor e um receptor, conectados por fios,  a comunicação uart pode ser *simplex:* apenas uma direção realiza o envio de dados, *half-duplex:* as duas direções enviam os dados, porém cada um por vez, e por fim, os dados podem ser *full-duplex:* ambas as direções enviam dados simultaneamente.

Na implementação desta solução, optou-se pelo uso de comunicação full-duplex, pois o sistema requer monitoramento contínuo dos dados, sem, no entanto, impedir a realização de novas solicitações a outros sensores. A seção referente ao [Módulo FPGA](#modulo-FPGA) fornece detalhes sobre como ocorre a alternância entre os sensores. Para assegurar a uniformidade dos dados compartilhados em ambas as extremidades da comunicação, é essencial que ambas operem com a mesma taxa de baud. Neste caso, foi selecionado o valor de 9.600 Hz.


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

O módulo DHT11 é responsável por implementar a lógica de funcionamento do sensor. 

[![DHT11]](https://github.com/Vanderleicio/ProjetoSD01/blob/main/imagens/dht11.png)

Funcionamento do sensor [Components101](https://components101.com/sensors/dht11-temperature-sensor)
#### Controlador

O módulo controlador possibilita a solicitação de diversas informações do sensor DHT11, como temperatura, umidade, ou a contínua atualização de uma dessas variáveis. Ele age como o coordenador dos dados, processando e enviando de volta ao PC apenas o que foi requisitado.

Essa estrutura é composta por uma máquina de estados que possui quatro estados distintos: 

+ **Espera Comando:** Estado inicial, verifica se houve alguma solicitação, se chegou algum comando real

+ **Coletando:**

+ **Transmitir:**

+ **Enviada:**









## Resultados de Síntese (Falar dos pinos)

Ao observar a Figura ... (sintese), nota-se que a implementação da solução proposta utiliza aproximadamente 8% dos elementos lógicos da placa e 10% dos seus LABs. Esses valores são consideráveis em comparação com as opções adotadas no projeto, como a utilização de muitas máquinas de estados.

[![Síntese (LEs, LABs, Pinos)](#sintese "Síntese (LEs, LABs, Pinos)")](http://https://github.com/Vanderleicio/ProjetoSD01/blob/main/imagens/resultadoDeSintese.png "Síntese (LEs, LABs, Pinos)")

## Como Executar

## Conclusões


## Referências

[R&S®Essentials - Compreenda à Uart](https://www.rohde-schwarz.com/br/produtos/teste-e-medicao/essentials-test-equipment/digital-oscilloscopes/compreender-uart_254524.html "Uart")

[Johannes 4GNU_Linux - UART em C](https://www.youtube.com/watch?v=n2s8Y8slL28&t=676s "Access the UART (Serial Port) on GNU/Linux with a simple C program")
