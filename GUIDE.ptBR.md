# Guia do Panorama

Como usar o Panorama no WoW Forever e como configurar o HDR no Windows.

**Faça antes um backup das suas configurações.** O Panorama altera configurações do jogo, e remover o addon não as desfaz. Antes de mudar qualquer coisa, feche o jogo e copie a pasta `WTF` da sua instalação do jogo para um lugar seguro. Para voltar atrás, feche o jogo e coloque essa cópia de volta no lugar.

## 1. Abrir a janela

- Digite `/pano`, ou clique com o botão esquerdo no botão do Panorama no minimapa.
- Opções > AddOns > Panorama também tem um botão que a abre.
- Arraste a barra de título para mover a janela. Esc ou o botão de fechar a fecha.

O botão do minimapa:

- Clique esquerdo abre ou fecha a janela.
- Clique direito mostra as predefinições, o desfazer, o refazer e a reinicialização gráfica.
- Arraste-o para movê-lo ao redor do minimapa. `/pano minimap` o mostra ou oculta.

## 2. A janela

| Parte | O que faz |
|---|---|
| Caixa de busca (canto superior direito) | Digite uma palavra para listar as configurações correspondentes de todas as abas. Limpe-a para voltar. |
| Abas | Qualidade, Interface, Avançado (configurações do jogo), depois Filtros, Meus filtros, Ambiente (efeitos do Panorama). A aba aberta é lembrada. |
| Configurações avançadas (sob o título) | Desmarcada: sem abas, uma única página com as predefinições, as principais configurações de qualidade (distância de visão, neblina volumétrica, sombras, oclusão de ambiente, detalhe da água, antisserrilhamento, atenuação da nitidez), a saída HDR e o brilho de pico, o contraste, o brilho, a distância da câmera, o filtro, a intensidade do filtro e o modo de ambiente. Marcada: todas as abas e todas as configurações. Na primeira instalação fica desmarcada; se você já usava o Panorama, fica marcada. A busca sempre encontra todas as configurações. |
| Desfazer, Refazer (sob as abas, à direita) | Desfazer cancela sua última alteração: controle deslizante, caixa, predefinição, filtro, ambiente ou Redefinir tudo. Refazer a recoloca. As últimas 20 alterações ficam guardadas até `/reload`. |
| Seletor de idioma (à direita das abas) | Idioma do jogo ou um de dez idiomas. Mudar o idioma recarrega a interface. |
| Guia (à esquerda da caixa de busca) | Abre este guia no jogo. |
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
  névoa volumétrica, a intensidade da tonalidade sem tonalidade). A linha indica qual configuração mudar.
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

Mudou de ideia? **Desfazer** (sob as abas, ou `/pano undo`) restaura as configurações de
antes da predefinição.

## 4. Filtros

A aba Filtros adiciona efeitos sobre a imagem. Eles não mudam nenhuma configuração do jogo.

- **Tonalidade**: clique em uma miniatura para aplicá-la na hora (sépia, quente, fria, noite, esmeralda, crepúsculo).
  **Intensidade da tonalidade** define a força.
- **Meu filtro**: usa um dos seus filtros da aba Meus filtros. Ele substitui a tonalidade, a vinheta e a granulação.
- **Céu**: as mesmas cores em gradiente, cheias no alto da tela e mais claras embaixo.
  **Intensidade do céu** define a força.
- **Vinheta**: escurece as bordas da tela.
- **Granulação**: granulação animada.
- **Barras pretas**: barras em cima e embaixo, de 0 a 20 % da tela cada uma. O jogo ainda renderiza o que elas
  escondem, então não aumentam a taxa de quadros.

### Ambiente

A aba Ambiente muda sozinha o tom, o céu, a vinheta e a granulação conforme o lugar onde você está.

- **Modo** (topo da aba): **Desligado** (a aba Filtros vale em toda parte), **Dia e noite automáticos** (veja Dia e noite abaixo) ou **Ambiente automático**. Desligado por padrão.
- **Ambiente automático**: esses filtros seguem o lugar e a hora do dia.
  Os valores da aba Filtros continuam salvos e voltam quando você muda o modo.
  Sem Configurações avançadas, a página única mostra só o modo e o lugar detectado; marque Configurações avançadas para editar os contextos.
- **Lugar**: define o tom, a vinheta e a granulação. Ordem: masmorra ou raide, interior, clima (chuva,
  neve, tempestade de areia), depois o tipo de zona: terras temperadas, desertos e terras áridas,
  terras nevadas, selva e pântano, terras corrompidas, terras vulcânicas, florestas arcanas. Uma zona
  ainda desconhecida conta como temperada. O clima só conta quando Intensidade do clima é maior que
  0.
- **Hora do dia**: define o céu (dia, amanhecer e entardecer, noite). A noite segue o dia e a noite
  do jogo; o amanhecer e o entardecer seguem a hora do servidor. Sem céu em interiores nem em
  masmorras.
- A linha à direita mostra o lugar e a hora do dia detectados agora. Quando uma masmorra, um
  interior ou o clima vem antes de uma zona que você ajustou, ela indica isso.
- **Contexto a editar**: escolha um contexto e ajuste seus filtros abaixo. O botão Padrão devolve o
  valor fornecido para esse contexto.
  O menu tem cinco grupos: **Zonas** (a zona em que você está e as que você ajustou), **Masmorra e interior**, **Clima**, **Tipo de zona** e **Céu (hora)**.
  Os quatro primeiros ajustam o tom, a vinheta, a granulação e uma predefinição gráfica: só um lugar se aplica por vez, na ordem indicada acima.
  O último ajusta o céu. Não é preciso ajustar nada para começar: cada contexto já tem seus valores.
- **Esta zona**: primeira opção do mesmo menu, com o nome da zona em que você está. Escolha-a para dar
  a esta zona seu próprio tom, vinheta e granulação, partindo do seu tipo de zona. Ela passa então
  antes do tipo de zona, mas depois de masmorra, interior e clima. As zonas que você ajusta
  continuam no menu. **Tipo de zona** remove os valores da zona: ela volta a seguir seu tipo de zona.
- **Todas as zonas**: submenu do mesmo menu, com todas as zonas conhecidas. Escolha uma para ajustá-la sem estar lá. As zonas são organizadas por continente.
- **Predefinição** e **Distância do cenário** (primeiras linhas de um lugar ou de uma zona): elas se aplicam enquanto você está nesse lugar, por cima dos seus próprios ajustes, com o ambiente automático ligado ou não. A distância do cenário do lugar vem antes da distância da predefinição. Seus próprios ajustes são mantidos e voltam quando você sai. **Meus ajustes** não muda nada. Exemplo: Baixa em masmorras, Extra em uma zona de que você gosta. Em uma masmorra ou raide, a primeira opção do menu ajusta só essa masmorra. Na aba Qualidade, o botão **Por lugar** abre essas linhas para o lugar onde você está; ele mostra **Aqui: …** enquanto um lugar aplica os seus. Em combate, a mudança espera o fim do combate.
- **Meu filtro** (primeira linha dos filtros de um lugar ou de uma zona): esse lugar usa um dos seus filtros da aba Meus filtros, com o contraste, o brilho e a gama dele, enquanto o ambiente automático estiver ligado.
- **Dia e noite** (modo **Dia e noite automáticos**): o Panorama aplica a **Tonalidade diurna** de dia e a **Tonalidade noturna** à noite,
  segundo o dia e a noite do jogo. Elas substituem a tonalidade da aba Filtros. A mudança é gradual das 19h às 21h e das 5h
  às 7h (horário do servidor). As tonalidades diurna e noturna e suas intensidades são definidas com Configurações avançadas.

## 5. Meus filtros

A aba Meus filtros (visível com Configurações avançadas) serve para criar quantos filtros seus você quiser. **Novo** adiciona um, **Excluir** remove o filtro aberto: a aba Filtros, os lugares e as zonas que o usavam voltam para Nenhum.

- **Filtro a editar**: escolhe o filtro que as linhas abaixo ajustam. **Nome**: dê um nome a ele (Enter para confirmar).
- **Vermelho**, **Verde**, **Azul** (em %): cor da tonalidade do filtro. **Intensidade da tonalidade**: a força dela.
- **Vinheta** e **Granulação**: as do filtro.
- **Contraste**, **Brilho**, **Gama**: ajustes de imagem que o filtro dá ao jogo enquanto está aplicado; depois voltam os seus próprios valores. Meus ajustes: nada muda. Dependendo do modo de exibição, podem não ter efeito.
- Enquanto a aba está aberta, o filtro exibido aparece ao vivo no jogo.
- Para usar um filtro: escolha-o na linha **Meu filtro** da aba Filtros (em todo lugar), ou de um lugar ou de uma zona na aba Ambiente (ambiente automático ligado). Ele substitui então a tonalidade, a vinheta e a granulação, cujas linhas ficam acinzentadas. Nenhum: nada muda.

## 6. Seus valores e o jogo

- Na primeira instalação, o Panorama lê suas configurações atuais do jogo. Nada muda até você mexer em um controle.
- Uma mudança feita no menu Gráficos do jogo ou com `/console` aparece na janela.
- **Aplicar a cada conexão** (rodapé, ligado por padrão): as configurações que você mudou no Panorama são gravadas de novo
  a cada conexão. As outras seguem o menu Gráficos do jogo.
- Uma mudança feita durante o combate é aplicada quando o combate termina.
- Algumas configurações, como o MSAA, exigem a reinicialização gráfica. Clique em **Reiniciar** no rodapé, ou digite
  `/pano restart`. A tela pisca por um segundo.

## 7. HDR no Windows

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

## 8. Comandos

| Comando | Ação |
|---|---|
| `/pano` | Abre ou fecha a janela |
| `/pano low`, `/pano medium`, `/pano high`, `/pano extra` | Aplica uma predefinição |
| `/pano undo` | Desfaz a última alteração |
| `/pano redo` | Refaz a alteração que você acabou de desfazer |
| `/pano reset` | Volta cada configuração e cada filtro ao padrão |
| `/pano status` | Mostra no chat o lugar e o momento detectados e os filtros aplicados agora (durante uma transição, os valores de destino) |
| `/pano apply` | Grava de novo as configurações mudadas no Panorama |
| `/pano restart` | Reinicia o motor gráfico |
| `/pano minimap` | Mostra ou oculta o botão do minimapa |
| `/pano blackbars 10` | Faixas pretas a 10% da altura da tela (0 a 20). `off` as remove |
| `/pano grain 10` | Granulação em 10 (0 a 100). `off` a remove |
| `/pano vignette 10` | Vinheta em 10 (0 a 100). `off` a remove |

## 9. Redefinição

- O botão **Padrão** de cada linha redefine essa configuração.
- O botão **Padrões** do menu Gráficos do jogo redefine apenas as configurações que esse menu gerencia,
  e o Panorama o acompanha. Use os botões Padrão em `/pano` para as outras e para os filtros.
- **Redefinir tudo** (rodapé, com confirmação) ou `/pano reset`: volta cada configuração alterada no
  Panorama e cada filtro ao padrão. **Desfazer** a cancela até `/reload`.
  A aba Ambiente e as zonas ajustadas também são redefinidas. Seus filtros da aba Meus filtros também são apagados.
