# Relatório: Conflito `<Tab>` entre Sidekick NES e Completion/Snippets

## Resumo

Há sobreposição na tecla `<Tab>` entre três sistemas diferentes, o que pode
causar comportamento inesperado na navegação de snippets e na sugestão
Next Edit Suggestion (NES) do Sidekick.

## Envolvidos

### 1. LuaSnip (`completion.lua:5-6`)
- Navegação de snippets via `<Tab>` / `<S-Tab>` é esperada pelo usuário
  após expandir um snippet.
- O preset `"default"` do Blink (`completion.lua:40`) documenta que
  `<Tab>/<S-Tab>` move para direita/esquerda dentro do snippet.

### 2. Blink (`completion.lua:16-40`)
- Preset `"default"` usa `<C-y>` para aceitar completions.
- `<Tab>` fica livre para snippet jumping — essa é a intenção do preset.

### 3. Sidekick (`sidekick.lua:20-26`)
- Captura `<Tab>` em insert mode para tentar `nes_jump_or_apply()`.
- Se o Sidekick não consumir o `<Tab>`, ele retorna `"<Tab>"` (pass-through).
- Isso depende de timing: o Sidekick tem `debounce = 500ms`, o que pode
  atrasar ou engolir o Tab esperado pelo LuaSnip.

## Problema Potencial

```
Insert mode → usuário expande snippet → precisa de <Tab> para pular placeholder
```

Fluxo do `<Tab>`:

1. Sidekick `nes_jump_or_apply()` é chamado primeiro.
2. Se retorna `false`, o Tab passa para o próximo handler (Blink/LuaSnip).
3. Mas se o Sidekick estiver processando (debounce de 500ms), pode haver
   conflito entre o NES e o snippet jump.

## Risco

- **Médio.** O pass-through (`return "<Tab>"`) deve funcionar na maioria dos
  casos, mas a latência do debounce e a ordem de processamento podem
  fazer com que snippets não naveguem corretamente em cenários de
  uso intenso de IA + snippets.

## Sugestão de Validação

1. Abrir um arquivo Lua, digitar `fun` e expandir snippet.
2. Tentar navegar pelos placeholders com `<Tab>`.
3. Repetir com Sidekick ativo e com Sidekick desabilitado.
4. Se houver diferença, mover Sidekick NES para `<M-Tab>` ou `<C-Tab>`.
