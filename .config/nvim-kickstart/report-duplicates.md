# Relatório: Specs Duplicadas de Plugins

## Resumo

Alguns plugins são declarados em mais de um arquivo de configuração.
O `vim.pack` lida bem com duplicação (não instala duas vezes), mas
ter specs espalhadas dificulta a manutenção e pode gerar lockfile
imprevisível.

## Duplicatas Encontradas

### 1. `plenary.nvim` — declarado em 3 lugares

| Arquivo | Linha |
|---|---|
| `lua/plugins/harpoon.lua` | 2 |
| `lua/plugins/lazygit.lua` | 2 |
| `lua/plugins/telescope.lua` | 27 |

**Impacto:** Baixo. `plenary` é dependência comum. Mas se um dia
houver necessidade de configurar ou forçar uma versão específica,
a configuração estará replicada.

### 2. `harpoon` — declarado em 2 lugares

| Arquivo | Linha |
|---|---|
| `lua/plugins/harpoon.lua` | 3 |
| `lua/plugins/onioncrab.lua` | 3 |

**Observação:** A spec em `onioncrab.lua` está agora dentro de um
bloco condicional (`if vim.uv.fs_stat(...)`), então só é registrada
se o diretório `~/onioncrab.nvim` existir. Ainda assim, é redundante:
a spec principal já está em `harpoon.lua`.

**Impacto:** Baixo/médio. Pode causar confusão sobre onde está a
configuração "verdadeira" do Harpoon.

### 3. `mason.nvim` — declarado em 2 lugares

| Arquivo | Linha |
|---|---|
| `lua/plugins/lsp.lua` | 170 |
| `lua/plugins/debug.lua` | 13 |

**Impacto:** Médio. A configuração do Mason está em `lsp.lua`
(`require("mason").setup({})`), mas o `debug.lua` também declara
o plugin como dependência. Se a ordem de carregamento mudar,
pode haver conflito sutil de inicialização.

## Sugestão de Resolução

1. **Criar um arquivo central de dependências comuns**
   (ex.: `lua/plugins/deps.lua`) que declare `plenary.nvim` uma
   única vez.

2. **Remover `harpoon` de `onioncrab.lua`** já que a configuração
   principal está em `harpoon.lua`.

3. **Remover `mason.nvim` de `debug.lua`** e documentar que DAP
   depende do Mason configurado em `lsp.lua`, ou migrar a config
   do Mason para um lugar compartilhado.
