# Guia do Panorama

Como usar o Panorama no WoW Forever e como configurar o HDR no Windows.

## 1. Abrir a janela

- Digite `/pano`, ou clique com o botão esquerdo no botão do Panorama no minimapa.
- Opções > AddOns > Panorama também tem um botão que a abre.
- Arraste a barra de título para mover a janela. Esc ou o botão de fechar a fecha.

O botão do minimapa:

- Clique esquerdo abre ou fecha a janela.
- Clique direito mostra as predefinições, o desfazer e a reinicialização gráfica.
- Arraste-o para movê-lo ao redor do minimapa. `/pano minimap` o mostra ou oculta.

## 2. A janela

| Parte | O que faz |
|---|---|
| Caixa de busca (canto superior direito) | Digite uma palavra para listar as configurações correspondentes de todas as abas. Limpe-a para voltar. |
| Abas | Qualidade, Filtros, Interface, Avançado. A aba aberta é lembrada. |
| Seletor de idioma (à direita das abas) | Idioma do jogo ou um de dez idiomas. Mudar o idioma recarrega a interface. |
| Guia (à esquerda do seletor de idioma) | Abre este guia no jogo. |
| Predefinições (aba Qualidade) | Baixa, Média, Alta, Extra. A predefinição que combina com suas configurações fica destacada. |
| Rodapé | Aplicar a cada conexão, botão do minimapa, Redefinir tudo, reinicialização do motor gráfico. |

Clique no título de uma seção para recolhê-la ou expandi-la.

### Uma linha de configuração

- **Controle deslizante**: o valor é gravado quando você solta o botão do mouse, não enquanto arrasta.
- **Caixa de valor** ao lado do controle: digite um valor, depois pressione Enter ou clique em outro lugar. Esc cancela,
  Tab vai para a próxima caixa. A vírgula funciona como separador decimal. O valor fica dentro do intervalo do controle.
- **Botão Padrão**: devolve essa configuração ao valor padrão. Passe o mouse sobre ele para ver o valor.
- **Marca dourada** à esquerda: você mudou essa configuração.
- **Estrela amarela**: um menu do jogo também define esse valor. Passe o mouse sobre ela para ver qual. Esse menu
  não lê o valor de volta, então pode mostrar outro nível.
- **Linha acinzentada**: depende de outra configuração que está desligada (por exemplo, a densidade da névoa sem
  névoa volumétrica, a intensidade da tonalidade sem tonalidade).
- Passe o mouse sobre um rótulo para ler a ajuda completa.

## 3. Predefinições

| Predefinição | Resultado |
|---|---|
| Baixa | Desempenho máximo. Visão curta, sem sombras. |
| Média | Equilibrado. Bom desempenho e sombras razoáveis. |
| Alta | Nível Alto do jogo. Sombras completas, todos os efeitos. |
| Extra | Qualidade máxima. Maior distância de visão, tudo ligado. |

As predefinições mudam apenas as configurações de qualidade gráfica da aba Qualidade. Elas não mexem na câmera,
no mouse, na interface, na nitidez, na baixa latência, no HDR nem nos filtros.

Mudou de ideia? **Desfazer a última predefinição** (botão ao lado das predefinições, ou `/pano undo`) restaura as configurações de
antes da última predefinição.

## 4. Filtros

A aba Filtros adiciona efeitos sobre a imagem. Eles não mudam nenhuma configuração do jogo.

- **Tonalidade**: clique em uma miniatura para aplicá-la na hora (sépia, quente, fria, noite, esmeralda, crepúsculo).
  **Intensidade da tonalidade** define a força.
- **Vinheta**: escurece as bordas da tela.
- **Granulação**: granulação animada.
- **Barras pretas**: barras em cima e embaixo, de 0 a 20 % da tela cada uma. O jogo ainda renderiza o que elas
  escondem, então não aumentam a taxa de quadros.

## 5. Seus valores e o jogo

- Na primeira instalação, o Panorama lê suas configurações atuais do jogo. Nada muda até você mexer em um controle.
- Uma mudança feita no menu Gráficos do jogo ou com `/console` aparece na janela.
- **Aplicar a cada conexão** (rodapé, ligado por padrão): as configurações que você mudou no Panorama são gravadas de novo
  a cada conexão. As outras seguem o menu Gráficos do jogo.
- Uma mudança feita durante o combate é aplicada quando o combate termina.
- Algumas configurações, como o MSAA, exigem a reinicialização gráfica. Clique em **Reiniciar** no rodapé, ou digite
  `/pano restart`. A tela pisca por um segundo.

## 6. HDR no Windows

As configurações de HDR existem apenas como comandos de console no jogo. O Panorama as mostra na aba **Avançado**,
seção **HDR (só console)**. Você precisa de um monitor compatível com HDR.

### Passo 1: ativar o HDR no Windows

Windows 11:

1. Abra **Configurações > Sistema > Vídeo**.
2. Selecione o monitor HDR, se você tiver mais de um.
3. Ative **Usar HDR**. O atalho **Win + Alt + B** também o liga ou desliga.

Windows 10: **Configurações > Sistema > Vídeo > Configurações de Cores HD do Windows** (Windows HD Color settings), depois ative
**Reproduzir jogos e aplicativos em HDR** (Play HDR games and apps).

Verifique também se o HDR está ativado no menu do próprio monitor, se ele tiver essa opção.

Desative o **HDR automático** (Auto HDR) do Windows 11: **Configurações > Sistema > Vídeo > HDR**. Ele serve para jogos sem HDR. O WoW gera a própria imagem HDR.

### Passo 2: descobrir o brilho de pico do seu monitor

Instale o aplicativo gratuito **Calibragem HDR do Windows** (Windows HDR Calibration) da Microsoft Store e execute-o. A luminância
máxima que ele encontra é o brilho de pico do seu monitor, em nits.

Sem o aplicativo, use a classificação HDR do monitor: DisplayHDR 400 significa cerca de 400 nits, DisplayHDR 600
cerca de 600, DisplayHDR 1000 cerca de 1000.

### Passo 3: configurar o HDR no Panorama

Abra `/pano`, aba **Avançado**, seção **HDR (só console)**.

1. Marque **Saída HDR**.
2. Marque **Usar brilho de pico** ou **Usar brilho de referência**: um ou outro, nunca os dois. Sem um deles, a imagem fica escura.

**Modo de brilho de pico (recomendado)**

- Marque **Usar brilho de pico**.
- Defina **Brilho de pico (nits)** com o valor encontrado no passo 2.
- **Intensidade HDR** só funciona nesse modo. O padrão do jogo é 2. Mude-o em pequenos passos e
  compare: a Blizzard não documenta o efeito exato.

**Modo de brilho de referência**

- Marque **Usar brilho de referência**.
- **Brilho de referência (nits)** é o brilho do branco na cena. 203 é o valor padrão.
  Aumente-o se a imagem parecer escura demais em um ambiente claro. Intensidade HDR não tem efeito nesse modo.

Se a imagem não mudar, clique em **Reiniciar** no rodapé.

### Solução de problemas de HDR

| Problema | Solução |
|---|---|
| Imagem muito escura | Marque um dos dois modos de brilho. |
| Imagem cinza ou desbotada | Ative o HDR no Windows (passo 1) e no menu do monitor. |
| HDR automático ligado no Windows | Desative-o (passo 1). |
| Realces muito brilhantes ou achatados | Defina o brilho de pico com o valor real do seu monitor (passo 2). |
| Você quer o HDR desligado | Desmarque **Saída HDR**. |

Cada linha de HDR tem um botão Padrão que devolve o valor do jogo.

## 7. Comandos

| Comando | Ação |
|---|---|
| `/pano` | Abre ou fecha a janela |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Aplica uma predefinição |
| `/pano undo` | Restaura as configurações de antes da última predefinição |
| `/pano reset` | Volta cada configuração e cada filtro ao padrão |
| `/pano apply` | Grava de novo as configurações mudadas no Panorama |
| `/pano restart` | Reinicia o motor gráfico |
| `/pano minimap` | Mostra ou oculta o botão do minimapa |

## 8. Redefinição

- O botão **Padrão** de cada linha redefine essa configuração.
- O botão **Padrões** do menu Gráficos do jogo redefine apenas as configurações que esse menu gerencia,
  e o Panorama o acompanha. Use os botões Padrão em `/pano` para as outras e para os filtros.
- **Redefinir tudo** (rodapé, com confirmação) ou `/pano reset`: volta cada configuração alterada no
  Panorama e cada filtro ao padrão. Não pode ser desfeito.
