# NVIDIA GTX 750 — Kelpie OS V3

## Integração candidata

A lista de pacotes da imagem V3 agora solicita os seguintes componentes Debian:

- `nvidia-driver`
- `nvidia-kernel-dkms` (módulo proprietário fechado; não usar o módulo open para Maxwell)
- `nvidia-settings`
- `dkms`
- `linux-headers-amd64`
- `nvidia-detect`
- `xserver-xorg-video-nouveau` como alternativa de inicialização

A GTX 750 pertence à arquitetura Maxwell. O pacote `nvidia-driver` 550.163.01-2 de Debian 13 Trixie lista suporte a Maxwell, portanto é uma opção compatível com a GPU.

## Aviso de manutenção

A versão Debian 13 550.x está sem manutenção de segurança upstream. A documentação Debian consultada em 2026-11-03 alerta que ela contém problemas de segurança conhecidos e recomenda restringir seu uso a ambientes confiáveis/isolados. Por isso, esta integração é uma candidata técnica para a GTX 750, não uma certificação de segurança nem uma garantia de funcionamento.

Não migrar automaticamente para drivers 590+: eles não suportam Maxwell. O driver NVIDIA de código aberto também não atende Maxwell.

## Critérios obrigatórios antes de declarar suporte concluído

1. Confirmar no log do build que os pacotes foram resolvidos e instalados.
2. Confirmar que DKMS compila o módulo para o kernel incluído na ISO.
3. Inicializar a ISO em UEFI com a GTX 750 e verificar `lspci -nnk`.
4. Confirmar `nvidia-smi`, `glxinfo -B` e sessão GNOME sem erros.
5. Testar reinicialização e atualização de kernel.
6. Confirmar que Nouveau continua disponível como fallback se o módulo proprietário não carregar.

Se DKMS falhar ou o driver impedir o boot, retirar o driver proprietário da instalação padrão e manter Nouveau, sem bloquear o lançamento por uma configuração gráfica quebrada.

## Fontes

- Debian Wiki — NVIDIA Graphics Drivers: https://wiki.debian.org/NvidiaGraphicsDrivers
- Debian Packages — nvidia-driver em Trixie: https://packages.debian.org/trixie/nvidia-driver
- Debian Packages — Xorg NVIDIA driver: https://packages.debian.org/trixie/amd64/x11/xserver-xorg-video-nvidia
