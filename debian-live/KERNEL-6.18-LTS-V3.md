# Kelpie OS V3 — Kernel Linux 6.18 LTS

## Decisão técnica

A V3 passa a incluir o kernel Debian 6.18.15+deb13-amd64, obtido de `trixie-backports`, junto com seus headers. O Manjaro publica o kernel 6.18.55 na mesma linha principal 6.18 LTS; não copiamos o pacote binário do Manjaro porque ele é construído para o ecossistema Arch/Manjaro.

O kernel Debian está integrado como kernel adicional. O kernel padrão da base Debian permanece instalado como opção de recuperação no GRUB.

## NVIDIA GTX 750 (Maxwell)

O driver proprietário NVIDIA 550 precisa vir da variante `trixie-backports`, com patches para kernels backports até a linha 6.18. A configuração dá prioridade a esses pacotes NVIDIA e mantém Nouveau disponível como fallback. Não usar o flavor open: ele não suporta Maxwell.

**Limitação importante:** a série NVIDIA 550 está sem manutenção de segurança. A integração é uma opção de compatibilidade para a GTX 750, não uma recomendação de segurança permanente. Não declarar suporte validado até o DKMS compilar para 6.18.15 e a sessão gráfica ser testada em hardware real.

## Critérios para aprovar

1. APT resolve o kernel 6.18.15 e headers a partir de trixie-backports.
2. APT seleciona a variante backports do driver NVIDIA 550.
3. DKMS compila o módulo proprietário para 6.18.15.
4. O kernel padrão Debian continua presente no menu de inicialização como recuperação.
5. ISO inicia em UEFI; GNOME abre com GTX 750; validar `lspci -nnk`, `dkms status`, `nvidia-smi` e `glxinfo -B`.
6. Se o DKMS ou a sessão gráfica falhar, manter Nouveau e/ou reverter o kernel padrão como opção inicial.

## Precisão de versão

O Manjaro lista 6.18.55, enquanto o pacote Debian backports atualmente selecionado é 6.18.15. Ambos pertencem à série 6.18; portanto, isto entrega a mesma linha LTS, mas **não** a mesma revisão pontual do Manjaro.
