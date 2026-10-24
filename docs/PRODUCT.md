# PRODUCT — Tagarela

## Problema

Pessoa ouve/lê inglês no dia a dia (série, trabalho, viagem) e esquece termo. Curso tradicional não usa vida real dela.

## Proposta

Capturar termo na hora (foto, áudio, texto). App analisa, sugere tradução e grupo. Termo entra no vocabulário e volta em revisão espaçada (SRS) até dominar.

## Usuário

Brasileiro, inglês básico/intermediário, celular na mão, pouco tempo.

## Conceitos

- **Termo**: palavra solta ou expressão.
- **Grupo**: coleção de termos por tema (Viagem, Trabalho...).
- **Nível**: 0 a 5 (SRS). Nível 4+ = dominado. Abaixo = aprendendo.
- **Inbox**: capturas (texto, foto, áudio) até a pessoa escolher os termos e confirmar a análise.
- **Palavra do dia**: um termo novo por dia, com fonética, tradução e exemplo.

## Telas

| Tela | Conteúdo |
| --- | --- |
| Login | E-mail + senha, Google, Apple (só iOS), esqueci senha, criar conta. |
| Criar conta | Nome, e-mail, senha (mín. 8). Google/Apple. Depois: código no e-mail. |
| Código | 6 dígitos do e-mail (confirmar cadastro ou trocar senha). Reenviar após 1 min. Trocar e-mail. |
| Esqueci a senha | E-mail → código → nova senha → já entra. |
| Início | Saudação pelo primeiro nome conforme a hora (bom dia, boa tarde, boa noite) com a foto do Google ou as iniciais (primeiro e último nome), palavra do dia, resumo do vocabulário (total, aprendendo, dominado), revisão de hoje. Sem sequência de dias. Sem nada (zero termos, sem palavra do dia, sem revisão): aviso centralizado "Seu inglês começa aqui" com "Fazer a primeira captura" (abre o menu +). |
| Vocabulário | Grade de grupos (% dominado). Sem termos: "Nenhum termo ainda". Busca e filtros: a definir. |
| Grupo | Termos do grupo: tipo, tradução, status, nível. Filtro todos/aprendendo/dominado. |
| Inbox | Abas Todas, Prontas, Pendentes, Analisadas. Seções: precisa de atenção (erro: descartar ou processar agora; sem texto = "Não achei texto na foto" / "Não ouvi fala em inglês"), prontas (descartar ou escolher termos; com termos: editar ou confirmar análise), processando (áudio antes do modelo baixar: "Esperando o modelo de áudio baixar…", transcreve sozinho quando termina), analisadas (apagadas, no fim). Foto em miniatura; áudio com player. Puxar a lista sincroniza. Vazio: "Inbox zerado". |
| Escolher termos | Abre pelo card pronto (Escolher termos ou Editar). Toque numa palavra marca só ela; arrastar marca a expressão; palavra dentro de expressão vale. Termo aparece como escrito, sem a pontuação da ponta. Lista "Termos escolhidos" com X. "Editar texto" corrige no próprio card; termos fora do trecho mudado continuam. "Confirmar análise · N termos" (sem termo: "Escolha pelo menos um termo"). Voltar descarta o que foi marcado; lixeira descarta a captura. |
| Perfil | Topo centralizado: foto grande (ou iniciais), nome e e-mail. Card de progresso: capturas, termos e dominados. "Funciona sem internet": texto de fotos (pronto) e áudio em inglês (pronto, baixando com %, ou esperando internet; sem botão). "Conta": e-mail e privacidade (foto e áudio ficam só no celular). Sair. |

Botão + central (todas as abas): menu em arco com Câmera, Áudio, Texto. Cada um abre um painel de baixo:

| Painel | Conteúdo |
| --- | --- |
| Texto | Campo de até 500 caracteres. "Salvar no Inbox" só com texto. |
| Foto | Tirar foto ou escolher da galeria → prévia com "Trocar foto" e "Salvar no Inbox". Foto fica só no celular. |
| Áudio | Abre gravando (até 1 min, toca pra parar) → ouvir, "Regravar" ou "Salvar no Inbox". Áudio fica só no celular. |

Fechar descarta sem perguntar. Sem permissão de microfone ou câmera: aviso com "Abrir configurações". Salvou: aviso "Salvo no Inbox" com "Ver" (abre o Inbox). Texto do aviso: enviou o texto = "Pronto pra escolher os termos."; foto/áudio = "Já está processando."; texto sem internet = "Puxe a lista no Inbox quando tiver internet.".

Texto da foto e do áudio sai no próprio celular, sem internet (foto: ML Kit no Android, Apple Vision no iOS; áudio em inglês: Moonshine, modelo de 45 MB que o app baixa sozinho ao entrar, em qualquer rede). Só o texto vai pra API; foto e áudio nunca sobem.

## Princípios

- Conversa, não aula. Tom de amigo, frases curtas, "você".
- Captura em um gesto. Funciona sem rede; análise depois.
- Cor com significado (ver `DESIGN.md`).

## Estado atual

Tudo fala com a API Django (`api/`), sem mock. Conta real (sessão salva; expirou = volta pro login com aviso). Inbox real, offline first, sincroniza quando a pessoa age. Home e Vocabulário vazios até a API ter vocabulário (Home com o aviso de primeira captura, Vocabulário com "Nenhum termo ainda"). Captura por texto, foto e áudio. Escolher termos e confirmar análise. Ficha do termo (IA): a definir.
