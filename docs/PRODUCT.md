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
| Início | Saudação pelo primeiro nome conforme a hora (bom dia, boa tarde, boa noite) com a foto do Google ou as iniciais (primeiro e último nome), palavra do dia, resumo do vocabulário (total, aprendendo, dominado), revisão de hoje. Sem sequência de dias. |
| Vocabulário | Grade de grupos (% dominado). Sem termos: "Nenhum termo ainda". Busca e filtros: a definir. |
| Grupo | Termos do grupo: tipo, tradução, status, nível. Filtro todos/aprendendo/dominado. |
| Inbox | Abas Todas, Prontas, Pendentes, Analisadas. Seções: precisa de atenção (erro: descartar ou processar agora), prontas (descartar ou escolher termos; com termos: editar ou confirmar análise), processando, esperando envio, analisadas (apagadas, no fim). Foto em miniatura; áudio com player. Puxar a lista sincroniza. Vazio: "Inbox zerado". |
| Perfil | Dados do usuário, sair. |

Botão + central (todas as abas): menu em arco com Câmera, Áudio, Texto. Captura vai pro Inbox.

## Princípios

- Conversa, não aula. Tom de amigo, frases curtas, "você".
- Captura em um gesto. Funciona sem rede; análise depois.
- Cor com significado (ver `DESIGN.md`).

## Estado atual

Tudo fala com a API Django (`api/`), sem mock. Conta real (sessão salva; expirou = volta pro login com aviso). Inbox real, offline first, sincroniza quando a pessoa age. Home e Vocabulário vazios até a API ter vocabulário (palavra do dia e revisão somem). Telas de captura e de escolher termos: próximos passos.
