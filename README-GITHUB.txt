KELPIE OS LINUX — BUILD REMOTO

Base: Debian 13 Trixie, amd64, GNOME.

Compile pela aba Actions > Build Kelpie OS ISO > Run workflow. O workflow cria uma ISO híbrida e publica o artefato kelpie-os-linux-debian13-amd64 com SHA256SUMS.

Teste primeiro em modo Live/VM. A extensão GNOME precisa ser validada no GNOME da imagem. A GTX 750 2 GB usa Nouveau/Mesa por padrão; nvidia-detect apenas ajuda a identificar opções de driver proprietário após a instalação.