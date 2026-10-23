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
- **Inbox**: termos capturados aguardando análise ou revisão do usuário.
- **Palavra do dia**: um termo novo por dia, com fonética, tradução e exemplo.

## Telas

| Tela | Conteúdo |
| --- | --- |
| Login | E-mail + senha, Google, Apple (só iOS), esqueci senha, criar conta. |
| Criar conta | Nome, e-mail, senha (mín. 8). Google/Apple. Depois: código no e-mail. |
| Código | 6 dígitos do e-mail (confirmar cadastro ou trocar senha). Reenviar após 1 min. Trocar e-mail. |
| Esqueci a senha | E-mail → código → nova senha → já entra. |
| Início | Saudação pelo primeiro nome conforme a hora (bom dia, boa tarde, boa noite) com a foto do Google ou as iniciais (primeiro e último nome), palavra do dia, resumo do vocabulário (total, aprendendo, dominado), revisão de hoje. Sem sequência de dias. |
| Vocabulário | Grade de grupos (% dominado). Busca e filtros: a definir. |
| Grupo | Termos do grupo: tipo, tradução, status, nível. Filtro todos/aprendendo/dominado. |
| Inbox | Prontos para revisar (adicionar/descartar) e em análise (analisando, na fila sem rede). |
| Perfil | Dados do usuário, sair. |

Botão + central (todas as abas): menu em arco com Câmera, Áudio, Texto. Captura vai pro Inbox.

## Princípios

- Conversa, não aula. Tom de amigo, frases curtas, "você".
- Captura em um gesto. Funciona sem rede; análise depois.
- Cor com significado (ver `DESIGN.md`).

## Estado atual

Conta real: login, cadastro, código e nova senha falam com a API Django (`api/`). Sessão fica salva (sai só no "Sair" ou com sessão recusada). Resto das telas: dados mock (json-server, `server/db.json`). Perfil ainda mostra o usuário mock. Sem captura real.
