# Kelpie OS Linux

Projeto de distribuição Linux instalável, baseado em Debian 13 Trixie, GNOME e arquitetura amd64.

## Estado atual: V3 em desenvolvimento

A branch de desenvolvimento é `v3-development`. A V3 ainda **não está pronta para lançamento** e não existe ISO final validada.

A meta é entregar um sistema completo com:
- GNOME escuro, detalhes cobre, identidade da pata branca e wallpaper oficial da constelação canina.
- Instalador gráfico seguro, sessão Live e suporte UEFI/BIOS.
- DEB/APT, Flatpak/Flathub e Snap, cada um testado em instalação real.
- Firmware e detecção de hardware, com validação específica da GTX 750.
- Segurança, atualizações, AppArmor, firewall, backup e recuperação.
- Acessibilidade, áudio, rede, Bluetooth, impressão e gerenciamento de energia.
- Aplicativos Kelpie próprios para monitoramento, atualização, ajustes e discos.

## Acompanhamento

Consulte [V3-CHECKLIST-MESTRE-E-BLOQUEADORES.md](V3-CHECKLIST-MESTRE-E-BLOQUEADORES.md) para ver todos os requisitos, o que já está no código e os bloqueadores de lançamento.

A compilação candidata é feita manualmente pelo GitHub Actions:
1. Abra a aba Actions.
2. Execute **Build Kelpie OS Linux V3 ISO** na branch `v3-development`.
3. Aguarde as verificações estruturais, validação APT e compilação.
4. Baixe o artefato somente se o job terminar com sucesso.

## Política de lançamento

Não criar release, tag final ou declarar 100% até que:
- a ISO seja compilada e seu SHA256 conferido;
- o boot Live e o instalador sejam testados;
- a instalação seja validada em UEFI/BIOS;
- o hardware-alvo e os recursos críticos sejam testados;
- os bloqueadores obrigatórios do checklist estejam resolvidos;
- o responsável pelo projeto aprove explicitamente o lançamento.

## Base técnica

- Debian 13 Trixie amd64
- GNOME 48 (alvo inicial)
- live-build e GitHub Actions
