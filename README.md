# Configurações de dotfiles

A ideia deste repo é que ele seja clonado na home com o nome .dotfiles, seja rodado o script de instalação dos programas base para desenvolvimento, feitas configurações e que todos os arquivos de configuração, como o .zshrc sejam armazenados aqui e tenham um link simbolico desta pasta, para sua HOME

## Passo a passo

1. Baixe o repositório
2. Escolha o script associado à sua distro
3. Dê permissão e execute o script escolhido

### Exemplo

Baixe o repositório zipado, extraia para a home do seu SO

Dê a permissão para o arquivo

```chmod + ~/.dotfiles/scripts/arch.sh```

Execute o arquivo

```~/.dotfiles/scripts/arch.sh```

## Configuração ssh github

```ssh-keygen```

Marque as opções padrões, sem senha (só dar enter)

Deve ter criado um arquivo em ~/.ssh com a chave privada e a publica

Para visualizar a chave publica execute

```cat ~/.ssh/*.pub```

Caso queira ser mais especifico, substitua o \* pelo nome do arquivo gerado