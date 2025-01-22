# Projeto: Máquina de Café

## Descrição Geral do Sistema
O objetivo deste projeto é desenvolver um programa em Assembly no processador MIPS (usando o simulador MARS) para realizar o controle de uma máquina de café para uso em ambientes comerciais/empresariais. 

A máquina oferece três tipos de café (café puro, com leite e Mochaccino) em dois tamanhos de copos (pequeno e grande). Além disso, o usuário pode optar por colocar automaticamente açúcar no preparo da bebida, se desejar.

### Operação básica da máquina:
- **Escolha da bebida**:
  - `1`: Café puro
  - `2`: Café com leite
  - `3`: Mochaccino
- **Tamanho da bebida**:
  - `g`: Copo grande
  - `p`: Copo pequeno
- **Opção de açúcar**:
  - `s`: Sim
  - `n`: Não
- **Preparo da bebida**:
  - Uso de timer.
- **Geração de cupom fiscal**:
  - Um arquivo `.txt` descrevendo a bebida solicitada e o preço cobrado será gerado.

---

## Estrutura Interna da Máquina
A máquina possui quatro contêineres internos que armazenam quatro tipos de pós:
- **CAFÉ**
- **LEITE**
- **CHOCOLATE**
- **AÇÚCAR**

### Detalhes de Operação:
- Para o preparo de uma bebida pequena, é necessário **1 dose** do pó correspondente.
- Para um copo grande, são necessárias **2 doses**.
  - Exemplo: Café com leite grande sem açúcar → 2 doses de café + 2 doses de leite em pó.
- Cada dose de pó contabiliza **1 segundo** de operação.

- **Válvula de água**:
  - Bebida pequena: liberar água por **5 segundos**.
  - Bebida grande: liberar água por **10 segundos**.
- **Capacidade dos contêineres**:
  - Cada contêiner armazena **20 doses**.
  - As doses utilizadas devem ser subtraídas do total do contêiner.

### Bloqueio da Máquina:
A máquina deve ser bloqueada caso não haja quantidade suficiente de um determinado tipo de pó. Por exemplo:
- Se o contêiner de CAFÉ tiver apenas **1 dose**, será possível preparar apenas um café pequeno.
- Se a escolha for um café grande, a máquina deve bloquear e informar que o contêiner de CAFÉ precisa ser reabastecido.

---

## Premissas
- **Uso de timer**:
  - Chamada de sistema `syscall` (comando 30), que lê o relógio do sistema operacional a cada 1 ms.
- **Entrada de teclado e display**:
  - Utilizar a ferramenta Digital Lab Sim como entrada de teclado e display.
- **Reabastecimento dos contêineres**:
  - Deve ser realizado pelo teclado.
  - Exemplo: Digitar código `5` seguido do número do pó a ser reposto (`1` para CAFÉ, `2` para LEITE, etc.).
- **Programação orientada a componentes**:
  - Uso obrigatório de chamadas de procedimentos na implementação do projeto.
