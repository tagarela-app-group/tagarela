# PRODUCT — Tagarela

App pra aprender inglês com o que a pessoa vê e ouve no dia. Público: brasileiro, inglês básico ou intermediário, pouco tempo.

## Ideia

Captura na hora (foto, áudio, texto) → escolhe os termos → confirma → termo entra no vocabulário → pessoa organiza em grupos → revisão espaçada (SRS) até dominar.

## Conceitos

- **Captura**: texto, foto ou áudio no Inbox. Funciona sem internet. Texto da foto e do áudio sai no celular. Foto e áudio nunca sobem.
- **Termo**: palavra ou expressão. Um por pessoa (maiúscula e espaço não contam).
- **Grupo**: coleção criada pela pessoa (nome, ícone, cor). IA nunca escolhe grupo.
- **Sem grupo**: onde cai o termo confirmado. Pessoa move depois.
- **Nível**: 0 a 5. 4+ = dominado.
- **Palavra do dia**: um termo novo por dia.

## Telas

- Conta: login (e-mail, Google, Apple só no iOS), cadastro com código no e-mail, esqueci a senha.
- Início: saudação, palavra do dia, resumo do vocabulário, revisão de hoje.
- Vocabulário: Sem grupo no topo, grade de grupos, Novo grupo. Grupo: termos com filtro, mover termos com Desfazer.
- Inbox: capturas por estado (atenção, prontas, processando, analisadas). Escolher termos: toque = palavra, arrasto = expressão.
- Perfil: progresso, status do offline, conta, sair.
- Botão + central: Câmera, Áudio (até 1 min), Texto (até 500). Salvou: aviso "Salvo no Inbox".

Texto e estados de cada tela: no mockup e no código.

## Princípios

- Conversa, não aula. Tom de amigo, frases curtas, "você".
- Captura em um gesto. Funciona sem rede. Análise depois.
- Cor com significado.

## Estado atual

- Pronto: conta, captura (offline first), Inbox, escolher termos, vocabulário com grupos e mover.
- Vazio até a API ter: tradução e ficha do termo (IA), nível e revisão (SRS), palavra do dia.
- A definir: editar e apagar grupo.
