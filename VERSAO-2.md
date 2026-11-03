# Kelpie OS Linux V2

**Base:** Debian GNU/Linux 13 (Trixie), GNOME, amd64, UEFI live ISO.

## O que entrou na V2
- Identificação do sistema como Kelpie OS Linux V2.
- Tema escuro com detalhes cobre na interface GNOME, menus e painel.
- Botão do menu com a pata branca oficial.
- Wallpaper 16:9 azul-escuro com constelação estilizada de cão, gerado durante a compilação.
- Firefox ESR, VLC, GIMP, LibreOffice, GNOME Software, Flatpak e Flathub.
- Timeshift, GNOME Disks, Monitor do Sistema, impressão e digitalização.
- UFW/GUFW e firmware de rede.
- Pacotes NVIDIA proprietários e ferramenta nvidia-detect, além do driver Nouveau como alternativa.
- Idioma e layout inicial configurados para português do Brasil.

## Limitações conhecidas
- A imagem de constelação gerada pelo build é uma primeira arte vetorial, não substitui a imagem original aprovada pelo proprietário do projeto.
- A tela de bloqueio ainda usa o comportamento padrão do GNOME; avatar, controles e composição exclusivos do conceito ainda precisam de integração e teste no GDM.
- Glassmorphism depende do suporte do GNOME/Mutter; o CSS adiciona transparência e cores, mas não garante desfoque real em todos os menus.
- Driver NVIDIA precisa ser validado no hardware-alvo GTX 750 2 GB. Nouveau permanece disponível como fallback.
- A ISO deve ser compilada, verificada por SHA256 e testada em máquina virtual e no PC real antes de ser considerada lançamento estável.

## Compilar
O workflow Build Kelpie OS ISO no GitHub Actions gera kelpie-os-linux-v2-amd64.iso e SHA256SUMS.
VERSAO-2.md descreve a configuração pretendida; não significa que a ISO já passou nos testes.
