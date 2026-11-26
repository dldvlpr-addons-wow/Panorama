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
| **Simples**, **Avançado** (ao lado do título) | Simples: cada aba mostra uma lista curta das configurações principais, sem seções. Avançado: todas as configurações, por seção, com as regras por lugar e a seção Especialistas. Na primeira instalação fica Simples; se você já usava o Panorama, fica Avançado. A busca sempre encontra todas as configurações. |
| Guia (canto superior direito) | Abre este guia no jogo. |
| Menu **Opções** (canto superior direito) | **Idioma** (idioma do jogo ou um de dez idiomas; mudá-lo recarrega a interface), **Aplicar a cada conexão**, **Botão do minimapa**, **Redefinir tudo…**. |
| **Visual atual:** (barra sob o título) | O visual no mundo agora, e quem o define: você, Dia e noite ou o lugar. O botão dela (**Editar**, **Editar esta regra**) abre onde mudá-lo. Passe o mouse sobre a barra para ver qual vem primeiro. |
| Abas | **Imagem** (qualidade gráfica), **HDR**, **Ambiente** (visual do mundo), **Meus filtros**. A aba aberta é lembrada. |
| Caixa de busca (à direita das abas) | Digite uma palavra para listar as configurações correspondentes de todas as abas. Limpe-a para voltar. |
| Predefinições (aba Imagem) | Baixa, Média, Alta, Extra. A predefinição que combina com suas configurações fica destacada. |
| Rodapé | **Desfazer** cancela sua última alteração: controle deslizante, caixa, predefinição, filtro, ambiente ou Redefinir tudo. **Refazer** a recoloca. As últimas 20 alterações ficam guardadas até `/reload`. **Reiniciar** reinicia o motor gráfico. |

No modo Avançado, clique no título de uma seção para recolhê-la ou expandi-la. A seção **Especialistas (só console)** começa recolhida. O título de uma seção mostra quantas das suas configurações você mudou.

### Uma linha de configuração

- **Controle deslizante**: o valor é gravado quando você solta o botão do mouse, não enquanto arrasta.
- **Caixa de valor** ao lado do controle: digite um valor, depois pressione Enter ou clique em outro lugar. Esc cancela,
  Tab vai para a próxima caixa. A vírgula funciona como separador decimal. O valor fica dentro do intervalo do controle.
- **Botão Padrão**: devolve essa configuração ao valor padrão. Passe o mouse sobre ele para ver o valor.
- **Marca dourada** à esquerda: você mudou essa configuração.
- **Menu do jogo**: quando um menu do jogo também define esse valor, a ajuda do rótulo o cita. Esse menu
  não lê o valor de volta, então pode mostrar outro nível.
- **Linha acinzentada**: depende de outra configuração que está desligada (por exemplo, **Qualidade da neblina volumétrica** sem
  **Neblina volumétrica**, a intensidade da tonalidade sem tonalidade), ou um modo a define.
  Passe o mouse sobre o rótulo para ver o motivo. Uma linha que depende de outra fica deslocada para a direita, logo abaixo dela.
- Passe o mouse sobre um rótulo para ler a ajuda completa.

## 3. Predefinições

| Predefinição | Resultado |
|---|---|
| Baixa | Desempenho máximo. Visão curta, sem sombras. |
| Média | Equilibrado. Bom desempenho e sombras razoáveis. |
| Alta | Nível Alto do jogo. Sombras completas, todos os efeitos. |
| Extra | Alta, com a maior distância de visão. |

As predefinições mudam apenas as configurações de qualidade gráfica da aba Imagem. Elas não mexem na câmera,
no mouse, na interface, na nitidez, na baixa latência, no HDR nem nos filtros.

Mudou de ideia? **Desfazer** (rodapé, ou `/pano undo`) restaura as configurações de
antes da predefinição.

## 4. Ambiente

A aba Ambiente define o visual do mundo: efeitos sobre a imagem. Eles não mudam nenhuma configuração do jogo.

- **Modo** (topo da aba): **Fixo** (o mesmo filtro em todo lugar), **Dia e noite** (uma tonalidade diurna e uma
  noturna) ou **Por lugar** (veja abaixo). Fixo por padrão.
- **Aqui**: o lugar e a hora do dia detectados agora. Quando uma masmorra, um
  interior ou o clima vem antes de uma zona que você ajustou, ela indica isso.
- **Filtro** (modos Fixo e Dia e noite): **Base** usa as linhas abaixo. Um dos seus filtros
  (aba Meus filtros) substitui a tonalidade, a vinheta e a granulação, e traz o seu contraste,
  o seu brilho e a sua gama. **Editar filtro** o abre na aba Meus filtros.
- **Tonalidade**: clique em uma miniatura para aplicá-la na hora (sépia, quente, fria, noite, esmeralda, crepúsculo).
  **Intensidade da tonalidade** define a força.
- **Vinheta**: escurece as bordas da tela.
- **Granulação**: granulação animada.
- **Tonalidade diurna** e **Tonalidade noturna** (modo Dia e noite): o Panorama aplica a tonalidade diurna de dia e a tonalidade noturna
  à noite, segundo o dia e a noite do jogo. Elas substituem a tonalidade. A mudança é gradual das 19h às 21h e das 5h
  às 7h (horário do servidor). Um dos seus filtros escolhido na linha Filtro as substitui.
- **Céu**: as mesmas cores em gradiente, cheias no alto da tela e mais claras embaixo.
  **Intensidade do céu** define a força.
- **Barras pretas**: barras em cima e embaixo, de 0 a 20 % da tela cada uma, em todos os modos. O jogo ainda renderiza o que elas
  escondem, então não aumentam a taxa de quadros.

No modo Simples, a aba mostra o modo, o lugar, o filtro, a tonalidade e sua intensidade, e as
tonalidades diurna e noturna. Vinheta, granulação, céu e barras pretas ficam no modo Avançado.

### Por lugar

No modo **Por lugar**, a tonalidade, o céu, a vinheta e a granulação mudam sozinhos, conforme o lugar onde você está.

- As linhas do modo Fixo ficam ocultas: a regra do lugar as substitui. Só as barras pretas permanecem.
  Os valores delas continuam salvos e voltam quando você muda o modo.
  No modo Simples, as regras fornecidas se aplicam; escolha Avançado para editá-las.
- **Lugar**: define o tom, a vinheta e a granulação. Ordem: masmorra ou raide, interior, clima (chuva,
  neve, tempestade de areia), depois o tipo de zona: terras temperadas, desertos e terras áridas,
  terras nevadas, selva e pântano, terras corrompidas, terras vulcânicas, florestas arcanas. Uma zona
  ainda desconhecida conta como temperada. O clima só conta quando Intensidade do clima é maior que
  0.
- **Hora do dia**: define o céu (dia, amanhecer e entardecer, noite). A noite segue o dia e a noite
  do jogo; o amanhecer e o entardecer seguem a hora do servidor. Sem céu em interiores nem em
  masmorras.
- **Regra** (modo Avançado): escolha uma regra e ajuste-a abaixo. O botão Padrão devolve o
  valor fornecido para essa regra. Na primeira vez que a janela abre, a regra do lugar onde você está fica aberta.
  O menu tem cinco grupos: **Zonas** (a zona em que você está e as que você ajustou), **Masmorra e interior**, **Clima**, **Tipo de zona** e **Céu (hora)**.
  Os quatro primeiros ajustam o tom, a vinheta, a granulação e uma predefinição gráfica: só um lugar se aplica por vez, na ordem indicada acima.
  O último ajusta o céu. Não é preciso ajustar nada para começar: cada regra já tem seus valores.
- **Esta zona**: primeira opção do mesmo menu, com o nome da zona em que você está. Escolha-a para dar
  a esta zona seu próprio tom, vinheta e granulação, partindo do seu tipo de zona. Ela passa então
  antes do tipo de zona, mas depois de masmorra, interior e clima. As zonas que você ajusta
  continuam no menu. **Voltar ao tipo de zona** (ao lado do menu) remove os valores da zona: ela volta a seguir seu tipo de zona.
- **Todas as zonas**: submenu do mesmo menu, com todas as zonas conhecidas. Escolha uma para ajustá-la sem estar lá. As zonas são organizadas por continente.
- **Predefinição** e **Distância do cenário** (seção **Imagem** de um lugar ou de uma zona): elas se aplicam enquanto você está nesse lugar, por cima dos seus próprios ajustes, qualquer que seja o modo de ambiente. A distância do cenário do lugar vem antes da distância da predefinição. Seus próprios ajustes são mantidos e voltam quando você sai. **Meus ajustes** não muda nada. Exemplo: Baixa em masmorras, Extra em uma zona de que você gosta. Em uma masmorra ou raide, a primeira opção do menu ajusta só essa masmorra. Na aba Imagem, **Aqui: …** aparece ao lado das predefinições enquanto um lugar aplica as suas; no modo Avançado, ele abre essa regra. Em combate, a mudança espera o fim do combate.
- **Filtro** (primeira linha da seção **Visual** de um lugar ou de uma zona): esse lugar usa um dos seus filtros da aba Meus filtros, com o contraste, o brilho e a gama dele. **Ajustes abaixo**: a tonalidade, a vinheta e a granulação da regra. A seção Visual só se aplica no modo Por lugar.

## 5. Meus filtros

A aba Meus filtros permite criar quantos filtros seus você quiser. O filtro aberto aparece no mundo só como pré-visualização; o que vale é escolhido na aba Ambiente. **Novo** adiciona um e o abre, **Excluir** remove o filtro aberto: o filtro da aba Ambiente e as regras que o usavam voltam para nenhum filtro. Sempre resta um filtro.

- **Filtro**: escolhe o filtro que as linhas abaixo ajustam. **Nome**: dê um nome a ele (Enter para confirmar).
- **Tonalidade**: clique em uma miniatura para dar essa cor ao filtro. **Vermelho**, **Verde**, **Azul** (em %): a cor exata dele. **Intensidade da tonalidade**: a força dela.
- **Vinheta** e **Granulação**: as do filtro.
- **Contraste**, **Brilho**, **Gama**: ajustes de imagem que o filtro dá ao jogo enquanto está aplicado; depois voltam os seus próprios valores. Meus ajustes: nada muda. Dependendo do modo de exibição, podem não ter efeito.
- No modo Simples, a aba mostra só a tonalidade e a intensidade da tonalidade.
- Enquanto a aba está aberta, o filtro exibido aparece ao vivo no jogo. A barra **Visual atual:** indica quando é apenas uma prévia.
- Para usar um filtro: escolha-o na linha **Filtro** da aba Ambiente (modos Fixo e Dia e noite), ou de um lugar ou de uma zona (modo Por lugar). Ele substitui então a tonalidade, a vinheta e a granulação. **Base** ou **Ajustes abaixo**: nada muda.

## 6. Seus valores e o jogo

- Na primeira instalação, o Panorama lê suas configurações atuais do jogo. Nada muda até você mexer em um controle.
- Uma mudança feita no menu Gráficos do jogo ou com `/console` aparece na janela.
- **Aplicar a cada conexão** (menu Opções, ligado por padrão): as configurações que você mudou no Panorama são gravadas de novo
  a cada conexão. As outras seguem o menu Gráficos do jogo.
- Uma mudança feita durante o combate é aplicada quando o combate termina.
- Algumas configurações, como o MSAA, exigem a reinicialização gráfica. Clique em **Reiniciar** no rodapé, ou digite
  `/pano restart`. A tela pisca por um segundo.

## 7. HDR no Windows

As configurações de HDR existem apenas como comandos de console no jogo. O Panorama as mostra na aba **HDR**.
Você precisa de um monitor compatível com HDR.

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

Abra `/pano`, aba **HDR**. No modo Simples, a aba mostra só as três primeiras linhas abaixo: escolha
**Avançado** para ver **Intensidade HDR** e o brilho de referência.

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
- **Redefinir tudo…** (menu Opções, com confirmação) ou `/pano reset`: volta cada configuração da janela,
  alterada no Panorama ou não, e cada filtro ao padrão. **Desfazer** a cancela até `/reload`.
  A aba Ambiente e as zonas ajustadas também são redefinidas. Seus filtros da aba Meus filtros também são apagados.
