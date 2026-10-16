# Antes e depois

Exemplos trabalhados para o portugues. Cada bloco mostra o texto original, o texto controlado e a regra aplicada. Os dois primeiros sao adaptacoes dos exemplos oficiais do ASD-STE100. Os demais sao saidas tipicas de agente.

## Descricao de ferramenta

Antes:

> Esta ferramenta vai tentar sincronizar o estado entre os varios backends que foram configurados, e se um conflito for detectado ela pode resolve-lo automaticamente dependendo da estrategia que foi definida, ou entao vai expor o conflito para revisao manual.

Depois:

> A ferramenta tenta sincronizar o estado entre os backends configurados. Se ela encontra um conflito, le a estrategia configurada. Se a estrategia permite resolucao automatica, a ferramenta pode resolver o conflito sem um usuario. Se ela nao resolve o conflito, reporta o conflito para revisao manual.

Regras: locucao verbal ("vai tentar"), voz passiva ("foram configurados", "for detectado", "foi definida"), frase longa com virgulas encadeadas, perifrase ("expõe o conflito" virou "reporta").

## Mensagem de erro

Antes:

> Um erro pode ter ocorrido ao processar sua requisicao devido a uma possivel incompatibilidade no formato de dados esperado, que pode ser causada por uma versao desatualizada do cliente.

Depois:

> Sua requisicao pode ter falhado. A causa pode ser um formato de dados que nao bate com o que o servidor espera. Uma versao desatualizada do cliente pode causar essa incompatibilidade. Confira a versao do cliente.

Regras: nominalizacao ("ao processar" virou frase ativa), frase longa dividida, atenuacao preservada ("pode ter", "pode ser"). Veja que "pode ter ocorrido" nao virou "ocorreu".

## Instrucao entre agentes

Antes:

> Voce vai estar verificando o diretorio de saida e, caso os arquivos necessarios estejam presentes, realizar a compactacao dos mesmos antes de dar andamento no upload, senao fazer uso do fallback.

Depois:

> Verifique o diretorio de saida. Se os arquivos necessarios estao presentes, compacte os arquivos. Depois, inicie o upload. Se os arquivos nao estao presentes, use o fallback.

Regras: gerundismo ("vai estar verificando"), nominalizacao ("realizar a compactacao" virou "compacte"), perifrase ("dar andamento", "fazer uso de"), uma instrucao por frase, sinonimos fixados.

## Relatorio de status

Antes:

> O pipeline robusto e de ponta ja finalizou com sucesso e os artefatos foram gerados de forma automatizada; a equipe vai estar monitorando.

Depois:

> O pipeline terminou. Ele gerou os artefatos. A equipe vai monitorar.

Regras: adjetivos de marketing ("robusto", "de ponta"), voz passiva ("foram gerados de forma automatizada"), ponto e virgula, gerundismo ("vai estar monitorando").

## Verdadeiro negativo: ja esta bom

Antes:

> Abra o arquivo. Leia a linha 3. Se a linha estiver vazia, pare.

Depois: sem alteracao.

Motivo: frases curtas, uma instrucao por frase, voz ativa, sem nominalizacao nem atenuacao. Nenhuma regra quebrada.

## Verdadeiro negativo: atenuacao preservada

Antes:

> O disco pode ter enchido. Isso pode ser a causa do erro.

Depois: sem alteracao.

Motivo: o linter nunca marca "pode ter". A atenuacao carrega a confianca do autor, e transforma-la em fato ("o disco encheu") seria outra afirmacao. O texto fica mais longo e continua correto.
