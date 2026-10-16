# Regras de escrita: resumo e fontes

Este arquivo resume a descricao publica e oficial do ASD-STE100 (Simplified Technical English) e lista as adaptacoes feitas para o portugues. Ele parafraseia categorias de regra. Nao reproduce o texto do padrao nem o dicionario oficial de cerca de 900 palavras. Para o documento autoritativo, peca o download gratuito no site oficial.

## O que e o ASD-STE100

O ASD-STE100 e uma linguagem natural controlada, lancada em 1986 (como AECMA Document PSC-85-16598) pelo que hoje e a ASD (AeroSpace and Defense Industries Association of Europe). Foi criado a pedido de companhias aereas europeias, muitas com equipes que nao falavam ingles nativamente, que precisavam de documentacao de manutencao impossivel de ler errado, porque uma instrucao mal lida em uma aeronave pode matar. O padrao e mantido pelo Simplified Technical English Maintenance Group (STEMG) e e gratuito para download desde a Issue 6 (2013). A edicao atual e a Issue 9 (janeiro de 2025).

## Estrutura

- **53 regras de escrita em 9 secoes**, cobrindo escolha de palavra, gramatica, estrutura de frase e estilo.
- **Um dicionario** de cerca de 900 palavras aprovadas, cada uma restrita a um sentido e uma classe gramatical, mais cerca de 1.200 palavras a evitar com substituicoes sugeridas.
- **Uma permissao de terminologia**: uma organizacao pode definir o proprio dicionario de substantivos e verbos tecnicos aprovados, alem das 900 palavras base, para vocabulario de dominio que a base nao cobre.

## Categorias de regra (parafraseadas)

**Escolha de palavra**
- Use palavras aprovadas apenas no sentido e na classe gramatical aprovados.
- Cada palavra tem exatamente um sentido. Nao conte com o contexto para desambiguar uma palavra com varios sentidos.
- Prefira a palavra mais simples, mais curta e mais comum no lugar de um sinonimo formal ou raro.
- Use um verbo aprovado para uma acao, nao um substantivo derivado desse verbo (Rule 3.7).
- Nao forme phrasal verbs juntando verbo e preposicao (Rule 9.3). O sentido nao e previsivel pelas partes.

**Formas verbais**
- Formas permitidas: infinitivo, imperativo, presente, preterito simples (perfeito), futuro simples e participio usado so como adjetivo.
- Proibido o present perfect, o past perfect e outras construcoes compostas. "We have received" nao e permitido. "We received" e permitido.
- Formas em "-ing" so valem como substantivo tecnico ou parte de um, nunca como forma verbal.

**Voz**
- Voz ativa e obrigatoria em procedimentos e instrucoes.
- Voz passiva so em texto descritivo, e so quando quem age e genuinamente desconhecido ou irrelevante para o leitor.

**Estrutura de frase**
- Uma instrucao por frase.
- No maximo cerca de 20 palavras por frase em procedimentos e instrucoes. No maximo cerca de 25 em texto descritivo.
- Nao omita partes da frase (verbo, sujeito, artigo) so para encurtar. O padrao avisa que isso cria ambiguidade, nao clareza.
- Grupos nominais (nomes empilhados como modificador) ficam limitados a 3 palavras.
- Ponto e virgula nao sao permitidos (Rule 8.1): "You can use all standard English punctuation marks but not the semicolon (;)". Escreva frases separadas. Todo outro sinal padrao, inclusive o travessao, continua permitido.

**Estrutura de paragrafo e documento**
- Um topico por paragrafo.
- No maximo cerca de 6 frases por paragrafo.
- Use listas verticais (numeradas ou com marcadores) para sequencias, condicoes ou enumeracoes complexas, em vez de enterra-las na prosa.

**Instrucoes de seguranca**
- Instrucoes criticas de seguranca devem comecar com um comando ou uma condicao clara, nao ficar no meio da frase.

## Adaptacoes para o portugues

O ASD-STE100 define regras so para o ingles. O portugues nao tem um dicionario aprovado oficial. As regras abaixo aplicam o mesmo principio e sao a adaptacao usada nesta skill.

- **Voz ativa** e obrigatoria em instrucoes. A passiva com "ser" mais participio ("foi apagado") so em descricao, e so com agente desconhecido ou irrelevante.
- **Tempos simples**: infinitivo, imperativo, presente, preterito perfeito, futuro do presente e participio como adjetivo. Evite locucoes verbais ("tenho recebido", "havia terminado") quando o simples carrega o sentido.
- **Sem gerundio encadeado**. "Vou estar enviando" e "estou enviando para voce" viram "vou enviar" ou "envio". O gerundio como substantivo tecnico ("o processamento", "a leitura") continua valido.
- **Sem ponto e virgula**. Separe em frases independentes.
- **Verbo no lugar do substantivo**. "Realizar uma analise de" vira "analisar". "Fazer a verificacao de" vira "verificar". "Efetuar o pagamento" vira "pagar".
- **Uma palavra, um sentido**. Escolha um verbo para uma acao e nao alterne com sinonimos. Nao misture "verificar", "conferir", "checar", "validar" e "certificar" para a mesma acao.
- **Sem adjetivos de marketing**: robusto, inovador, poderoso, agil, intuitivo, de ponta, sem esforco, completo, moderno, escalavel.
- **Sem perifrases vagas**: "dar uma olhada" vira "ler". "Fazer uso de" vira "usar". "Entrar em contato" vira "contatar". "Subir o servico" vira "iniciar o servico".
- **Grupos nominais ate 3 palavras**. Encadeie com preposicoes: "valvula da bomba de combustivel" e aceitavel, "valvula de entrada da bomba de combustivel de alta pressao" nao e.
- **Nao omita sujeito, verbo e artigo** para encurtar.
- **Preserve a modalidade**. "Pode ter falhado" nao vira "falhou". "Pode ser causado por X" nao vira "X e a causa".
- **Um topico por paragrafo**, ate 6 frases.
- **Listas verticais** para 3 ou mais passos ou condicoes.
- **Defina termos tecnicos** uma vez, num glossario do projeto, quando nao forem portugues comum.

## Por que esta adaptacao serve para saida de agente

O padrao foi desenhado para eliminar ambiguidade para um leitor que nao pode fazer uma pergunta de acompanhamento: um tecnico na pista, trabalhando com um manual, sem autor para chamar. Um agente de IA interpretando a saida de outro agente, a descricao de uma ferramenta ou uma mensagem de sistema esta na mesma posicao, sem canal de volta para resolver se uma frase na voz passiva significa que quem chama faz X ou que quem responde faz X. O mesmo conjunto de regras que protege um mecanico de ler errado uma especificacao de torque protege um agente a jusante de ler errado uma instrucao.

## Fontes

- [ASD-STE100 official site](https://www.asd-ste100.org/)
- [ASD-STE100: About STE](https://www.asd-ste100.org/about_STE.html)
- [ASD Europe: Simplified Technical English](https://www.asd-europe.org/standards-specifications/simplified-technical-english/)
- [Simplified Technical English: Wikipedia](https://en.wikipedia.org/wiki/Simplified_Technical_English)
- [TechScribe: ASD-STE100 Simplified Technical English](https://www.techscribe.co.uk/techw/asd-simplified-technical-english.htm)
- [SKYbrary: Simplified Technical English (STE)](https://skybrary.aero/articles/simplified-technical-english-ste)
- [asd-ste100-skill (skill em ingles)](https://github.com/danyuchn/asd-ste100-skill)
