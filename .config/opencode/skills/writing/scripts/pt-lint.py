#!/usr/bin/env python3
"""Linter deterministico para as regras estruturais do portugues controlado (SKILL.md).

Confere apenas regras verificaveis sem um dicionario aprovado, que nao existe
para o portugues. Por decisao de projeto nunca marca atenuacao nem modalidade
(pode, talvez, provavelmente): a skill trata confianca como conteudo, e um
linter que pressiona atenuacoes para fora reescreveria afirmacoes.

Uso:
    pt-lint.py ARQUIVO [ARQUIVO ...]
    echo "texto" | pt-lint.py [--json]
    pt-lint.py --baseline 5 ARQUIVO     # passa se as violacoes duras nao passarem de 5
    pt-lint.py --disable voz-passiva,locucao-verbal ARQUIVO
    pt-lint.py --selftest

Sai com 1 quando as violacoes duras (nivel "advisory-free") passam do baseline
(padrao 0). Achados consultivos (voz passiva, futuro perifrastico, locucao
verbal) nunca reprovam a execucao. Sai com 2 num erro de uso (flag desconhecida,
valor invalido, regra desconhecida, arquivo ilegivel).
"""
import argparse
import bisect
import contextlib
import io
import json
import os
import re
import sys
import tempfile

# Heuristicas de regex, nao um parser. Sem regra de grupo nominal: exigiria
# etiquetacao morfologica para evitar falso positivo constante.
# Sem regra de omissao: nao ha como detectar omissao de sujeito por regex.
RULES = [
    ("ponto-e-virgula", "advisory-free",
     re.compile(r";"),
     "Ponto e virgula nao e permitido. Separe em frases independentes."),
    ("gerundismo", "advisory-free",
     re.compile(r"\b(?:estou|está|esta|estão|estao|estamos|estava|estavam|estávamos|estavamos|estar|estivesse|estivessem|estiver|estiverem)\s+\w+ndo\b", re.I),
     "Gerundio encadeado. Use o verbo simples (envio, vou enviar)."),
    ("nominalizacao", "advisory-free",
     re.compile(r"\b(?:faz|fa[çc]a|fazer|realiz\w*|efetu\w*|execut\w*|proced\w*|promov\w*|d[êe]|dar|d[áa]|d[ãa]o)\s+(?:a|o|uma|um|as|os|umas|uns)\s+\w+(?:ção|cao|são|sao|mento|ncia|ência|encia|agem|dade|lise|ise|ura)\b", re.I),
     "Acao congelada em substantivo. Use o verbo (analise o log, nao realize uma analise do log)."),
    ("perifrase-vaga", "advisory-free",
     re.compile(r"(?:\b(?:dar uma olhada|dar um jeito|fazer uso de|fazer uso|entrar em contato|dar andamento|bater um papo|dar uma passada)\b|subir o servi[çc]o|rodar o servi[çc]o)", re.I),
     "Perifrase vaga. Use o verbo simples (ler, usar, contatar, iniciar)."),
    ("adjetivo-marketing", "advisory-free",
     re.compile(r"\b(?:robust(?:o|a|os|as)|inovador(?:a|es|as)?|poderos(?:o|a|os|as)|ágil|agil|ágeis|ageis|intuitiv(?:o|a|os|as)|escaláve(?:l|is)|escalave(?:l|is)|revolucionári(?:o|a)|líder de mercado|lider de mercado|sem esfor[çc]o|de ponta|world-class|state-of-the-art|game-chang\w+)\b", re.I),
     "Adjetivo de marketing. Apague ou troque pela medida que sustenta a afirmacao."),
    ("futuro-perifrastico", "advisory",
     re.compile(r"\b(?:vou|vai|vamos|vão|vao|irei|irá|ira|irão|irao|irás|iras|iremos)\s+\w+(?:ar|er|ir)\b", re.I),
     "Futuro perifrastico. Prefira o futuro simples ou o presente (enviarei, envio)."),
    ("voz-passiva", "advisory",
     re.compile(r"\b(?:foi|foram|é|são|sao|era|eram|será|sera|serão|serao|sendo|sido|está|esta|estão|estao|estava|estavam)\s+\w+(?:ado|ada|ados|adas|ido|ida|idos|idas)\b", re.I),
     "Possivel voz passiva. Nomeie quem age e use um verbo ativo, a menos que quem age seja desconhecido ou irrelevante."),
    ("locucao-verbal", "advisory",
     re.compile(r"\b(?:tenho|tem|temos|têm|tem|tinha|tinham|tínhamos|tinhamos|havia|haviam|houve|houveram)\s+(?:sido\s+)?\w+(?:ado|ada|ados|adas|ido|ida|idos|idas)\b", re.I),
     "Locucao verbal composta. Use o tempo simples, a menos que a relevancia atual seja o ponto (entao mantenha e sinalize)."),
]

# Marcadores de modalidade/atenuacao que protegem a locucao verbal seguinte.
MODAL_PERFECT_PREFIX = re.compile(
    r"\b(?:pode|podem|podia|podiam|poderia|poderiam|deve|devem|devia|deviam|"
    r"deveria|deveriam|talvez|possivelmente|provavelmente|acaso)\s+$", re.I,
)

# Uma palavra, um sentido: grupos de verbos comumente alternados para a mesma acao.
# So entram pares realmente intercambiaveis. erro/falha/problema sao conceitos
# distintos e ficam fora.
SYNONYM_GROUPS = [
    ("verifi\\w*", "conf(?:ir|er)\\w*", "chec\\w*|check\\w*", "valid\\w*", "certific\\w*"),
    ("apag\\w*", "delet\\w*", "exclu\\w*", "remov\\w*"),
    ("inici\\w*", "come[çc]\\w*", "lan[çc]\\w*", "start\\w*"),
    ("encerr\\w*", "finaliz\\w*", "termin\\w*", "interromp\\w*"),
    ("mostr\\w*", "exib\\w*", "apresent\\w*"),
    ("utiliz\\w*", "empreg\\w*", "usar|usa|usamos|uso|usou|usado"),
    ("corrig\\w*", "consert\\w*", "repar\\w*"),
    ("envi\\w*", "transmit\\w*", "mand\\w*"),
    ("obt\\w*", "peg\\w*", "busc\\w*", "recuper\\w*"),
    ("alter\\w*", "modific\\w*", "mud\\w*"),
]

MAX_WORDS = 25  # limite para descricoes. Instrucoes: 20, mas nao da para detectar sem contexto.

CODE_FENCE = re.compile(r"^(```|~~~)")
INLINE_CODE = re.compile(r"`[^`]*`")
LIST_ITEM_START = re.compile(
    r"^(?P<indent> {0,3})(?P<marker>[-*+]|[0-9]+[.)])(?P<gap> +)(?P<body>.*)$"
)
CONJUNCTION_END = re.compile(r"\b(?:e|ou)\s*$", re.I)
TABLE_SEPARATOR_CELL = re.compile(r"^:?-{3,}:?$")
STANDALONE_LINE = re.compile(r"^ {0,3}(?:#|<|(?:[-*_=] *){3,}$)")
BLOCKQUOTE_PREFIX = re.compile(r"^ {0,3}(?:> ?)+")
ANY_LIST_ITEM = re.compile(r"^\s*(?:[-*+]|[0-9]+[.)])(?:\s|$)")
SENTENCE_END = re.compile(r"[.!?][\"'”’)\]*_]*$")
OPENERS = "\"'“‘([*_"
ABBREVIATIONS = {"vs.", "etc.", "p.ex.", "ex.", "sr.", "sra.", "dr.", "dra.",
                 "fig.", "no.", "art.", "pag.", "pág.", "cap.", "min.",
                 "máx.", "max.", "obs."}
DOTTED_ABBREVIATION = re.compile(r"(?:[a-z]\.){2,}", re.I)


def _word_re(base):
    return re.compile(r"\b(?:" + base + r")\b", re.I)


def _mask_inline_code(text):
    """Troca trechos de codigo por espacos de mesmo tamanho, para as colunas baterem."""
    return INLINE_CODE.sub(lambda match: " " * len(match.group(0)), text)


def _sentence_starts(text):
    """Devolve o deslocamento do inicio de cada frase em text.

    Uma frase termina numa palavra que acaba em pontuacao final, depois de
    aspas ou parenteses de fechamento. Abreviacoes conhecidas nao terminam
    frase. Uma passada pelas palavras mantem o custo linear.
    """
    words = list(re.finditer(r"\S+", text))
    if not words:
        return [0]
    starts = [words[0].start()]
    for word, next_word in zip(words, words[1:]):
        end = SENTENCE_END.search(word.group())
        if not end:
            continue
        core = word.group()[:end.start() + 1].lstrip(OPENERS)
        if core.lower() in ABBREVIATIONS:
            continue
        if (DOTTED_ABBREVIATION.fullmatch(core)
                and not next_word.group().lstrip(OPENERS)[:1].isupper()):
            continue
        starts.append(next_word.start())
    return starts


def _long_sentence_findings(pieces, filename):
    """Marca frases longas em um bloco de prosa.

    pieces e uma lista de (lineno, source_column, text). Os textos sao unidos
    por espacos, entao uma frase quebrada em varias linhas conta uma vez, e
    cada achado aponta a linha e a coluna onde a frase comeca.
    """
    offsets, position = [], 0
    for _, _, text in pieces:
        offsets.append(position)
        position += len(text) + 1
    joined = " ".join(text for _, _, text in pieces)
    findings = []
    starts = _sentence_starts(joined)
    for start, end in zip(starts, starts[1:] + [len(joined)]):
        n = len(joined[start:end].split())
        if n <= MAX_WORDS:
            continue
        index = bisect.bisect_right(offsets, start) - 1
        offset = offsets[index]
        lineno, source_column, _ = pieces[index]
        findings.append({"file": filename, "line": lineno,
                         "col": source_column + start - offset + 1,
                         "rule": "frase-longa", "level": "advisory-free",
                         "match": f"{n} palavras",
                         "message": f"Frase com {n} palavras (limite {MAX_WORDS}). Divida."})
    return findings


def _leading_spaces(line):
    return len(line) - len(line.lstrip(" "))


def _is_list_continuation(line, content_indent):
    if not line.strip():
        return True
    if LIST_ITEM_START.match(line):
        return False
    return _leading_spaces(line) >= content_indent


def _split_table_row(line):
    """Devolve celulas de uma linha de tabela, sem espacos, e suas colunas.

    Um pipe precisa separar ao menos duas celulas. Pipes escapados ficam na
    celula. Implementa so a forma comum de tabela Markdown, o suficiente para
    distinguir uma tabela de prosa que por acaso tem um pipe.
    """
    left = len(line) - len(line.lstrip())
    right = len(line.rstrip())
    content = line[left:right]
    if "|" not in content:
        return None
    if content.startswith("|"):
        content = content[1:]
        left += 1
    if content.endswith("|"):
        content = content[:-1]
    raw_cells = re.split(r"(?<!\\)\|", content)
    if len(raw_cells) < 2:
        return None

    cells = []
    column = left
    for raw_cell in raw_cells:
        leading = len(raw_cell) - len(raw_cell.lstrip())
        cells.append((raw_cell.strip(), column + leading))
        column += len(raw_cell) + 1
    return cells


def _markdown_table_cells(lines):
    """Mapeia linhas de tabela Markdown para suas celulas de prosa.

    A linha separadora ancora a deteccao, entao prosa com pipe nao vira tabela.
    Estilos com e sem pipe inicial sao aceitos quando cabecalho e corpo usam o
    mesmo numero de celulas.
    """
    table_cells = {}
    index = 1
    while index < len(lines):
        separator = _split_table_row(lines[index])
        header = _split_table_row(lines[index - 1])
        if (not separator or not header or len(separator) != len(header)
                or not all(TABLE_SEPARATOR_CELL.fullmatch(cell)
                           for cell, _ in separator)):
            index += 1
            continue

        table_cells[index - 1] = header
        table_cells[index] = []
        index += 1
        while index < len(lines):
            row = _split_table_row(lines[index])
            if not row or len(row) != len(separator):
                break
            table_cells[index] = row
            index += 1
    return table_cells


def _dangling_conjunction_findings(text, filename):
    lines = text.splitlines()
    findings = []
    in_fence = False
    index = 0
    while index < len(lines):
        line = lines[index]
        stripped = line.strip()
        if CODE_FENCE.match(stripped):
            in_fence = not in_fence
            index += 1
            continue
        if in_fence:
            index += 1
            continue
        start = LIST_ITEM_START.match(line)
        if not start:
            index += 1
            continue

        content_indent = (len(start.group("indent"))
                          + len(start.group("marker"))
                          + len(start.group("gap")))
        item_lines = [(index, start.group("body"))]
        next_index = index + 1
        item_fence = False
        while next_index < len(lines):
            candidate = lines[next_index]
            candidate_stripped = candidate.strip()
            if CODE_FENCE.match(candidate_stripped):
                item_fence = not item_fence
                next_index += 1
                continue
            if item_fence:
                next_index += 1
                continue
            if not _is_list_continuation(candidate, content_indent):
                break
            item_lines.append((next_index, candidate))
            next_index += 1

        meaningful = []
        for line_index, item_line in item_lines:
            cleaned = INLINE_CODE.sub(" CODE ", item_line).strip()
            if cleaned:
                meaningful.append((line_index, cleaned))
        if meaningful:
            end_line_index, end_line = meaningful[-1]
            conjunction = CONJUNCTION_END.search(end_line)
        else:
            end_line_index, end_line, conjunction = None, None, None
        if conjunction:
            if end_line_index == index:
                finding_line = index + 1
                finding_col = start.start("marker") + 1
            else:
                raw_end_line = next(
                    raw for line_index, raw in item_lines
                    if line_index == end_line_index
                )
                masked_end_line = INLINE_CODE.sub(
                    lambda match: " " * len(match.group(0)), raw_end_line
                )
                raw_conjunction = CONJUNCTION_END.search(masked_end_line)
                finding_line = end_line_index + 1
                finding_col = raw_conjunction.start() + 1 if raw_conjunction else 1
            findings.append({
                "file": filename,
                "line": finding_line,
                "col": finding_col,
                "rule": "conjuncao-solta",
                "level": "advisory-free",
                "match": end_line,
                "message": "Item de lista termina com conjuncao. Complete o item ou junte ao proximo.",
            })
        index = next_index
    return findings


def lint(text, filename="<stdin>"):
    findings = []
    words_total = 0
    in_fence = False
    lines = text.splitlines()
    table_cells = _markdown_table_cells(lines)
    seen_synonyms = {}
    block = []
    in_quote = False

    def flush():
        findings.extend(_long_sentence_findings(block, filename))
        block.clear()

    for lineno, raw_line in enumerate(lines, 1):
        if CODE_FENCE.match(raw_line.strip()):
            flush()
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        segments = table_cells.get(lineno - 1, [(raw_line, 0)])
        is_table = (lineno - 1) in table_cells
        quote = BLOCKQUOTE_PREFIX.match(raw_line)
        is_quote = bool(quote)
        content = raw_line[quote.end():] if quote else raw_line
        standalone = STANDALONE_LINE.match(content)
        if (is_table or not content.strip() or standalone
                or ANY_LIST_ITEM.match(content) or is_quote != in_quote):
            flush()
        in_quote = is_quote
        for segment, source_column in segments:
            line = _mask_inline_code(segment)
            words_total += len(line.split())
            for rule_id, level, pattern, msg in RULES:
                for m in pattern.finditer(line):
                    if rule_id == "locucao-verbal" and MODAL_PERFECT_PREFIX.search(
                        line[:m.start()]
                    ):
                        continue
                    findings.append({"file": filename, "line": lineno,
                                     "col": source_column + m.start() + 1,
                                     "rule": rule_id, "level": level,
                                     "match": m.group(0), "message": msg})
            for gi, group in enumerate(SYNONYM_GROUPS):
                for base in group:
                    if (gi, base) in seen_synonyms:
                        continue
                    m = _word_re(base).search(line)
                    if m:
                        seen_synonyms[(gi, base)] = (
                            lineno, source_column + m.start() + 1, m.group(0)
                        )
            skip = quote.end() if quote and not is_table else 0
            if line[skip:].strip():
                block.append((lineno, source_column + skip, line[skip:]))
            if is_table:
                flush()
        if standalone:
            flush()
    flush()
    for gi, group in enumerate(SYNONYM_GROUPS):
        present = [(seen_synonyms[(gi, b)], b) for b in group if (gi, b) in seen_synonyms]
        if len(present) > 1:
            present.sort()
            first_base = present[0][1]
            first_match = present[0][0][2]
            for (lineno, col, match), base in present[1:]:
                findings.append({"file": filename, "line": lineno, "col": col,
                                 "rule": "rotacao-de-sinonimos", "level": "advisory-free",
                                 "match": match,
                                 "message": f"'{match}' e '{first_match}' nomeiam a mesma acao. Escolha um e use sempre."})
    findings.extend(_dangling_conjunction_findings(text, filename))
    findings.sort(key=lambda f: (f["line"], f["col"]))
    return findings, words_total


def report(findings, words_total, as_json, hard_count, baseline):
    rate = round(len(findings) * 100 / words_total, 1) if words_total else 0.0
    if as_json:
        print(json.dumps({"violations": findings, "count": len(findings),
                          "hard_count": hard_count, "baseline": baseline,
                          "words": words_total, "per_100_words": rate}, indent=2))
        return
    for f in findings:
        print(f"{f['file']}:{f['line']}:{f['col']} {f['rule']}: {f['message']} [{f['match']}]")
    print(f"\n{len(findings)} violacoes ({hard_count} duras, baseline {baseline}), "
          f"{words_total} palavras, {rate} por 100 palavras")
    print("Atenuacao e modalidade (pode, talvez, provavelmente) nunca sao marcadas: confianca e conteudo.")


def selftest():
    bad = ("O painel foi removido; vou estar rodando o job. "
           "Realize uma analise do log robusto. "
           "Temos recebido o relatorio.")
    findings, _ = lint(bad)
    rules = {f["rule"] for f in findings}
    for expected in ("ponto-e-virgula", "gerundismo", "nominalizacao",
                     "adjetivo-marketing", "voz-passiva", "locucao-verbal"):
        assert expected in rules, (expected, sorted(rules))
    # atenuacoes nunca sao marcadas, inclusive modal + locucao
    findings, _ = lint("A requisicao pode ter falhado. Pode ser um timeout. "
                       "O disco talvez tenha enchido. Isso deve ter ajudado.")
    assert findings == [], findings
    # variacoes de modal com espacos e negacao
    for modal in ("pode", "podem", "poderia", "deve", "deveria"):
        findings, _ = lint(f"A tarefa {modal} ter rodado.")
        assert not any(f["rule"] == "locucao-verbal" for f in findings), (modal, findings)
    # locucao real e marcada
    findings, _ = lint("O job tem rodado. Nos temos enviado. Havia terminado.")
    assert sum(1 for f in findings if f["rule"] == "locucao-verbal") == 3, findings
    # futuro perifrastico e voz passiva sao consultivos
    findings, _ = lint("Vou enviar o relatorio. O arquivo foi apagado.")
    assert any(f["rule"] == "futuro-perifrastico" for f in findings), findings
    assert any(f["rule"] == "voz-passiva" for f in findings), findings
    assert all(f["level"] == "advisory" for f in findings
               if f["rule"] in ("futuro-perifrastico", "voz-passiva")), findings
    # gerundio como substantivo tecnico nao e gerundismo
    findings, _ = lint("O processamento leva dois segundos.")
    assert not any(f["rule"] == "gerundismo" for f in findings), findings
    # simplifica o texto do fixture de borda do linter de ingles
    findings, _ = lint("```\nx = a; y = b\n```")
    assert findings == []
    # todos os marcadores de lista, variantes e espaco a direita
    findings, _ = lint(
        "- Confirme o alvo e\n"
        "* Registre o resultado OU  \n"
        "+ Feche o painel\n"
        "1. Inicie a tarefa e\n"
        "2) Pare a tarefa OU"
    )
    dangling = [f for f in findings if f["rule"] == "conjuncao-solta"]
    assert len(dangling) == 4, dangling
    assert [f["line"] for f in dangling] == [1, 2, 4, 5], dangling
    assert all(f["level"] == "advisory-free" for f in dangling), dangling
    # continuacao valida nao e conjuncao solta
    findings, _ = lint("- Confirme o alvo e\n  registre o resultado.")
    assert not any(f["rule"] == "conjuncao-solta" for f in findings), findings
    # "e" dentro de palavra comum nao conta como conjuncao solta
    findings, _ = lint("- O nome")
    assert not any(f["rule"] == "conjuncao-solta" for f in findings), findings
    findings, _ = lint("~~~\n- codigo e\n~~~")
    assert not any(f["rule"] == "conjuncao-solta" for f in findings), findings
    # frase longa
    findings, _ = lint(("palavra " * 30).strip() + ".")
    assert any(f["rule"] == "frase-longa" for f in findings), findings
    # tabela: cada celula e lida, cabecalho curto nao dispara frase longa
    findings, _ = lint(
        "| Rotulo | Detalhe |\n"
        "| --- | --- |\n"
        f"| Claro | {' '.join('t' + str(n) for n in range(1, 20))} |"
    )
    assert not any(f["rule"] == "frase-longa" for f in findings), findings
    # rotacao de sinonimos: segundo membro marcado, primeiro nomeado como o mantido
    findings, _ = lint("Verifique o arquivo. Depois confira a saida. Confira de novo.")
    rot = [f for f in findings if f["rule"] == "rotacao-de-sinonimos"]
    assert len(rot) == 1 and "confir" in rot[0]["match"].lower(), rot
    assert "verif" in rot[0]["message"].lower(), rot
    # termo unico e consistente: nao marca
    findings, _ = lint("Verifique o arquivo. Verifique a saida.")
    assert not any(f["rule"] == "rotacao-de-sinonimos" for f in findings), findings
    # rotulos por arquivo e mascaramento de codigo inline
    findings, _ = lint("a; b", filename="x.md")
    assert findings[0]["file"] == "x.md"
    findings, _ = lint("Rode `make all` depois subir o servico.")
    per = [f for f in findings if f["rule"] == "perifrase-vaga"]
    assert len(per) == 1 and per[0]["col"] == 24, per
    # bloco de prosa e cortado por linha em branco, titulo, regra, lista, citacao
    twenty = " ".join(["palavra"] * 20)
    for sep in ("\n\n", "\n# Titulo\n", "\n---\n", "\n- ", "\n> "):
        findings, _ = lint(f"Primeira {twenty} linha{sep}Segunda {twenty} linha.")
        assert not any(f["rule"] == "frase-longa" for f in findings), (sep, findings)
    # frase quebrada em varias linhas conta uma vez, na linha inicial
    findings, _ = lint(f"Texto inicial.\nA {twenty}\ncontinuacao da frase aqui agora.")
    long_sentences = [f for f in findings if f["rule"] == "frase-longa"]
    assert len(long_sentences) == 1, long_sentences
    assert (long_sentences[0]["line"], long_sentences[0]["col"]) == (2, 1), long_sentences
    # flags podem vir entre caminhos de arquivo
    with tempfile.TemporaryDirectory() as tmp:
        paths = [os.path.join(tmp, name) for name in ("a.md", "b.md")]
        for path in paths:
            with open(path, "w", encoding="utf-8") as fh:
                fh.write("Linha curta aqui.\n")
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            assert main([paths[0], "--json", paths[1]]) == 0
        assert json.loads(out.getvalue())["words"] == 6, out.getvalue()
    # parsing de linha de comando rejeita erro de digitacao e valor invalido
    for bad_args in (["--basline", "3"], ["--baseline"], ["--baseline", "x"],
                     ["--baseline", "-1"], ["--disable", "voz"], ["--base", "3"]):
        try:
            with contextlib.redirect_stderr(io.StringIO()):
                main(bad_args)
        except SystemExit as e:
            assert e.code == 2, (bad_args, e.code)
        else:
            raise AssertionError(bad_args)
    assert _rule_list("voz-passiva,locucao-verbal") == {"voz-passiva", "locucao-verbal"}
    print("selftest OK")


RULE_IDS = {rule_id for rule_id, *_ in RULES} | {
    "frase-longa", "rotacao-de-sinonimos", "conjuncao-solta"}


def _rule_list(value):
    rules = {r for r in value.split(",") if r}
    unknown = rules - RULE_IDS
    if unknown:
        raise argparse.ArgumentTypeError(
            f"regra(s) desconhecida(s): {', '.join(sorted(unknown))}. "
            f"Conhecidas: {', '.join(sorted(RULE_IDS))}")
    return rules


def _non_negative_int(value):
    try:
        n = int(value)
    except ValueError:
        n = -1
    if n < 0:
        raise argparse.ArgumentTypeError(f"esperado inteiro nao negativo, recebi {value!r}")
    return n


def main(argv):
    parser = argparse.ArgumentParser(
        prog="pt-lint.py", allow_abbrev=False,
        description="Linter deterministico para as regras estruturais do "
                    "portugues controlado. Le stdin quando nao ha ARQUIVO.")
    parser.add_argument("paths", nargs="*", metavar="ARQUIVO")
    parser.add_argument("--json", action="store_true", help="imprime achados como JSON")
    parser.add_argument("--baseline", type=_non_negative_int, default=0, metavar="N",
                        help="passa se as violacoes duras nao passarem de N (padrao 0)")
    parser.add_argument("--disable", type=_rule_list, default=set(), metavar="REGRAS",
                        help="IDs de regra a silenciar, separados por virgula")
    parser.add_argument("--selftest", action="store_true", help="roda os testes internos")
    args = parser.parse_intermixed_args(argv)
    if args.selftest:
        selftest()
        return 0
    as_json, baseline, disabled, paths = args.json, args.baseline, args.disable, args.paths

    findings, words_total = [], 0
    if paths:
        for p in paths:
            try:
                with open(p, encoding="utf-8") as fh:
                    text = fh.read()
            except OSError as e:
                parser.error(f"nao consegui ler {p}: {e.strerror}")
            f, w = lint(text, filename=p)
            findings.extend(f)
            words_total += w
    else:
        findings, words_total = lint(sys.stdin.read())

    findings = [f for f in findings if f["rule"] not in disabled]
    hard_count = sum(1 for f in findings if f["level"] == "advisory-free")
    report(findings, words_total, as_json, hard_count, baseline)
    return 1 if hard_count > baseline else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
