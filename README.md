# Projeto de Sensor Digital em FPGA utilizando Comunicação Serial.

### Desenvolvedores
------------

[Vanderleicio Junior](https://github.com/Vanderleicio)
[Washington Oliveira Júnior](https://github.com/wlfoj#-washington-oliveira-junior-)
[Wagner Alexandre](https://github.com/WagnerAlexandre)
[Lucas Gabriel](https://github.com/lucasxgb)

### Tutor 
------------

[Thiago Cerqueira de Jesus](https://github.com/thiagocj)

### Sumário 
------------
[1. Como Executar](#como-executar)
[2. Introdução](#introdução)
[3. Características da solução](#características)
&nbsp;&nbsp;&nbsp;[3.1. Materiais utilizados](#comunicação)
&nbsp;&nbsp;&nbsp;[3.2. Módulo de Comunicação](#comunicação)
&nbsp;&nbsp;&nbsp;[3.3. Módulo FPGA](#modulo-FPGA)
&nbsp;&nbsp;&nbsp;[3.4. Módulo DHT11](#modulo-DHT11)
&nbsp;&nbsp;&nbsp;[3.5. Sistema de teste](#modulo-FPGA)
[4. Tabela de Comandos](#tabela-de-domandos)
[5. Testes](#testes)
[6. Resultados de síntese](#resultados-de-síntese)
[7. Como Executar](#resultados) 
[8. Conclusões](#conclusões) 
[9. Referências](#referências) 



## 1. Como Executar

## 2. Introdução


Nos dias atuais a tecnologia passou a ser uma ferramenta indispensável na vida dos seres humanos, uma vez que o desenvolvimento tecnológico progressivamente trás consigo ferramentas facilitadoras, que contribuem não só no cunho pessoal, mas em diversas áreas da sociedade. Um grande exemplo disso é a Internet das Coisas (IOT), uma tecnologia que vem ganhando grande notoriedade nos últimos anos. tendo como princípio a conexão entre o mundo físico (veiculos, dispositivos, sensores) e o digital (internet). A partir da comunicação entre dispositvos é possível a transmissão e obtenção de dados.

Partindo desse pressuposto, foi solicitado aos autores desse documento o desenvolvimento gradual de um sistema digital para gestão de ambientes, salienta-se que tal projeto está dividido em etapas. O objetivo da primeira etapa é implementar um sensor que exerce aferições de temperatura e umidade, a confecção dos sensores deve ser realizada em uma FPGA (arranjo de portas programavéis) que receberá a conexão do sensor DHT11, o programa deve ser modular, e escalável, permitindo a adição de mais sensores a FPGA, além disso deve-se implementar o protocolo de comunicação serial UART, responsável pela comunicação entre o sistema de testes desenvolvido em C e a FPGA, o sistema de testes enviará comandos para a FPGA, que deve obter os dados de um sensor especifico e retornar a respectiva resposta. As demais seções descrevem como foi o desenvolvimento da solução proposta.


## 3. Características da Solução


Para compreensão do desenvolvimento da solução, dividiremos a explicação em cinco subseções, a primeira seção descreve quais foram os materias utilizados no desenvolvimento do sistema, a seção de comunicaçãotrata sobre implementação da comunicação UART, o módulo FPGA reponsável pelo controle tanto da comunicação em C, quanto a comunicação com o DHT11, o módulo DHT11, implementado também no FPGA, e por fim a implementação do sistema de testes em C. De inicio começaremos falando sobre a comunicação UART.

### 3.1 Materiais utilizados
--------------


- Kit de desenvolvimento `Mercúrio IV`.
- FPGA `Cyclone IV EP4CE30F23C7`.
- Linguagem de Programação C.
- Linguagem de desenvolvimento de hardware verilog.

### 3.2 Comunicação
--------------


O UART, Universal Asynchronous Receiver/Transmitter, é um protocolo de comunicação serial que define um conjunto de regras para a troca de dados entre dois dispositivos (R&S Essentials). Contendo um transmissor e um receptor, conectados por fios,  a comunicação uart pode ser *simplex:* apenas uma direção realiza o envio de dados, *half-duplex:* as duas direções enviam os dados, porém cada um por vez, e por fim, os dados podem ser *full-duplex:* ambas as direções enviam dados simultaneamente.

Na implementação desta solução, optou-se pelo uso de comunicação full-duplex, pois o sistema requer monitoramento contínuo dos dados, sem, no entanto, impedir a realização de novas solicitações a outros sensores. A seção referente ao [Módulo FPGA](#modulo-FPGA) fornece detalhes sobre como ocorre a alternância entre os sensores. Para assegurar a uniformidade dos dados compartilhados em ambas as extremidades da comunicação, é essencial que ambas operem com a mesma taxa de baud. Neste caso, foi selecionado o valor de 9.600.


A comunicação UART é estabelecida entre o código C e a FPGA. No que diz respeito ao código C, a explicação é bastante simples. São utilizadas três bibliotecas (*stdio.h*, *unistd.h* e *fcntl.h*), além da definição de tags de controle, entrada, saída e local. Estas flags são responsáveis por habilitar o código C a realizar a comunicação UART.

#### Recebendo dados via UART através da FPGA
----------

O módulo Uart rx é responsável por receber dados na FPGA atráves da UART. Esse módulo possui quarto parâmetros, sendo eles:
    + `clk_9k6hz:` Clock de 9.600 hz, que serve para sincronizar o transmissor com o receptor, para que não se perca os dados, Vale salientar que esse clock é decorrente de uma divisão que ocorre no módulo BaudGenerator ,
    + `rx:`, 
    + `buffer:`, 
    + `concluded:`


#### Enviando dados via UART através da FPGA
----------




### 9. Referências

[R&S®Essentials - Compreenda à Uart](https://www.rohde-schwarz.com/br/produtos/teste-e-medicao/essentials-test-equipment/digital-oscilloscopes/compreender-uart_254524.html "Uart")
