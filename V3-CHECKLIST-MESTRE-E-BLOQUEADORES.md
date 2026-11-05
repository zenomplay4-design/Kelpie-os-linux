# Kelpie OS Linux V3 — checklist mestre de conclusão

Este documento é a fonte oficial do que falta antes de declarar a V3 pronta.
**Regra:** código presente não significa recurso testado. Só marcar como concluído depois de teste reproduzível e evidência registrada.

Legenda:
- [x] Implementado no repositório (ainda pode exigir teste de runtime).
- [ ] Pendente de implementação, integração ou teste.

## 1. Base, inicialização e instalação
- [x] Base Debian 13 Trixie amd64 e GNOME declarados na configuração.
- [x] Imagem híbrida ISO definida no processo live-build.
- [x] Idioma pt_BR e layout de teclado brasileiro definidos no boot.
- [x] Adicionar Calamares, configurações Debian de módulos, identidade Kelpie e confirmação antes da fase de instalação.
- [x] Criar plano documentado de testes seguros do Calamares em VMs descartáveis, com critérios para discos-alvo, confirmação e cancelamento.
- [ ] Validar a configuração Calamares em execução e executar a matriz do plano em UEFI/BIOS.
- [ ] Testar instalação em disco virtual vazio, particionamento manual, dual boot simulado e cancelamento sem perda de dados.
- [ ] Testar inicialização UEFI e BIOS legado em máquinas reais/VMs.
- [ ] Verificar boot em UEFI sem Secure Boot no computador-alvo e documentar limitações com Secure Boot.
- [ ] Validar modo Live, reinicialização, desligamento e remoção segura do USB.
- [ ] Criar sessão de recuperação e procedimento de reparo do boot.

## 2. Hardware e drivers
- [x] Firmware Linux e NVIDIA incluídos como base.
- [x] Pacotes de firmware Wi-Fi Intel, Realtek, Atheros, Broadcom e MediaTek declarados.
- [x] Microcode Intel incluído em lista adicional.
- [x] Nouveau definido como fallback gráfico.
- [x] Criar matriz padronizada de validação de hardware e coleta de evidências para o perfil-alvo.
- [ ] Testar detecção de CPU, RAM, placa-mãe, discos, USB, áudio, rede, Bluetooth e monitores em VM/hardware real.
- [ ] Testar GTX 750 2 GB (Maxwell) com Nouveau em sessão GNOME, conforme matriz de hardware.
- [ ] Validar um driver NVIDIA proprietário compatível, mantido e seguro para Maxwell; não instalar automaticamente antes dessa validação.
- [ ] Testar aceleração 3D, Vulkan/OpenGL, reprodução de vídeo e suspensão/resume com a GTX 750.
- [ ] Testar Wi-Fi, Ethernet, Bluetooth, áudio, impressoras, scanners e dispositivos USB em hardware real.
- [ ] Confirmar microcode Intel ativo após boot e documentar CPU suportada.

## 3. Ambiente GNOME e identidade visual
- [x] Tema escuro Adwaita definido como padrão.
- [x] Dash to Dock do Debian incluído, configurado fixo na parte inferior e com transparência leve.
- [x] Hook de build compila o banco dconf para aplicar as preferências padrão aos novos usuários.
- [ ] Validar visualmente o dock no primeiro login GNOME, com reinício de sessão e resolução 1366×768/1920×1080.
- [x] Paleta escura com detalhes cobre no CSS da extensão.
- [x] Pata branca criada pelo processo de build para o menu.
- [x] Wallpaper de constelação provisório gerado no build.
- [x] Integrar wallpaper oficial de constelação canina em céu azul-escuro, 16:9, sem texto; renderizar em 1920×1080 durante o build e validar o SVG no CI.
- [ ] Integrar pata no menu de boot/GRUB, não apenas no painel do GNOME.
- [ ] Adicionar mascote preto com marcações caramelo e peito branco nos locais aprovados, sem substituir a pata como logo.
- [ ] Implementar blur/glassmorphism real e configurável em painel, dock, menus e central de controle.
- [ ] Incluir opção para reduzir/desativar transparência e blur por desempenho/acessibilidade.
- [x] Adicionar no Kelpie Tweaks um controle ajustável de opacidade do dock inferior, com restauração do padrão (0,28).
- [ ] Implementar dock coerente com o design aprovado.
- [x] Configurar wallpaper oficial do Kelpie no perfil dconf do GDM para a tela de login/bloqueio; blur, relógio e controles ainda exigem validação visual em sessão.
- [ ] Testar extensão do menu em GNOME 48 e garantir fallback se ela falhar.
- [ ] Testar escala, HiDPI, múltiplos monitores, fontes e temas de alto contraste.

## 4. Aplicativos e formatos
- [x] Firefox ESR, VLC, GIMP, LibreOffice, GNOME Software e Timeshift incluídos.
- [x] Suporte DEB/APT via GNOME Software.
- [x] Flatpak, plugin Flatpak e registro do Flathub configurados.
- [x] Snapd e plugin Snap declarados para teste.
- [ ] Testar instalação, atualização e remoção de apps DEB, Flatpak e Snap em sistema instalado.
- [ ] Confirmar inicialização e atualização do serviço Snap em instalação limpa.
- [ ] Criar política para avisos de origem, assinatura e permissões de aplicativos.
- [ ] Não anunciar suporte AUR nativo: AUR pertence ao ecossistema Arch Linux.
- [x] Expandir o Kelpie Monitor em GTK4 com CPU, RAM, GPU, temperaturas, disco, swap, tempo ligado e lista de processos ordenada por CPU/RAM, com proteção contra reutilização de PID.
- [ ] Testar Kelpie Monitor em sessão GNOME real, inclusive com Nouveau, sem sensor de temperatura, swap desativada e processos encerrados durante a leitura.
- [x] Criar primeira versão do Kelpie Update em GTK4, com verificação, confirmação, autenticação administrativa e logs locais.
- [ ] Testar Kelpie Update em sistema instalado, incluindo cancelamento, falha de rede, autenticação negada e atualização concluída.
- [x] Criar primeira versão do Kelpie Tweaks em GTK4 para tema claro/escuro, animações, alto contraste e escala de texto, com restauração de padrões.
- [ ] Testar Kelpie Tweaks em GNOME 48 e validar persistência das preferências após reiniciar a sessão.
- [x] Criar primeira versão do Kelpie Disk em GTK4, com inventário somente leitura de discos, partições, tamanho, sistema de arquivos e pontos de montagem.
- [ ] Testar Kelpie Disk em máquinas com discos SATA, NVMe, USB removível e partições criptografadas.
- [ ] Projetar operações de montagem/gerenciamento somente após testes, com confirmação explícita e proteção contra seleção errada.
- [ ] Adicionar metadados AppStream, ícones, traduções pt_BR e testes para cada aplicativo Kelpie.

## 5. Segurança, privacidade e manutenção
- [x] AppArmor incluído e habilitado para iniciar.
- [x] unattended-upgrades e configuração periódica de atualização incluídos.
- [x] UFW e GUFW incluídos.
- [x] Política inicial do UFW definida: entrada bloqueada, saída permitida, IPv6 protegido e serviço habilitado para o primeiro boot.
- [x] debsums, apt-listchanges e needrestart incluídos.
- [ ] Testar a política inicial do firewall em sessão real, incluindo navegação, DNS, VPN, descoberta de dispositivos e compartilhamento LAN; documentar exceções necessárias.
- [ ] Testar atualizações automáticas de segurança, reinicializações pendentes e falhas de atualização.
- [ ] Validar AppArmor em modo enforce e revisar perfis.
- [ ] Validar assinatura APT e integridade de pacotes e ISO.
- [ ] Definir política de telemetria/relatórios de erro com consentimento explícito e documentação.
- [ ] Testar criptografia de disco no instalador e recuperação de senha/chaves.
- [ ] Definir permissões padrão, contas administrativas e autenticação polkit.
- [ ] Rever serviços habilitados, portas abertas, privacidade e hardening.
- [ ] Testar restauração Timeshift e recuperação de sistema em ambiente descartável.

## 6. Sistema e experiência diária
- [x] PipeWire, gerenciamento de energia, sensores e ferramentas de discos declarados.
- [x] CUPS, scanner, Bluetooth e NetworkManager incluídos.
- [ ] Testar suspensão, retomada, perfis de energia e desligamento.
- [ ] Testar codecs multimídia com formatos comuns e licenças adequadas.
- [ ] Testar impressão, digitalização, compartilhamento de rede e descoberta de dispositivos.
- [ ] Testar leitor de tela, lupa, teclado virtual, navegação por teclado e mouse acessível.
- [ ] Verificar limpeza de temporários sem apagar dados do usuário.
- [ ] Verificar consumo de RAM/CPU em repouso e definir metas de desempenho.
- [ ] Testar atualização do kernel e rollback seguro.

## 7. Compilação, qualidade e distribuição
- [x] Workflow manual direcionado à branch v3-development.
- [x] Pré-verificação estrutural conectada ao processo de build.
- [x] Validação APT de nomes e resolução de dependências conectada ao build.
- [x] Executar pré-verificação no ambiente real de CI: workflow de validação concluído com sucesso.
- [x] Executar validação APT de metadados e resolução de dependências: workflow de validação concluído com sucesso.
- [x] Validar wallpaper oficial 16:9 no workflow de testes estáticos (run 70, sucesso).
- [x] Validar sintaxe Python, scripts shell, testes unitários, sequência Calamares e metadados AppStream no workflow estático (run 70, sucesso).
- [x] Compilar ISO candidata no GitHub Actions: build #66 (run 41754353319), commit `a860bf0`, concluído com sucesso em 04/11/2026; artefato `13287734605` contém a ISO candidata e `SHA256SUMS`, com checksum conferido no build.
- [x] Adicionar validação pós-build do conteúdo essencial da ISO (kernel, initrd e filesystem.squashfs), catálogo El Torito e verificação SHA256; execução real ainda depende da nova ISO.
- [ ] Inspecionar partições, bootloader e entradas UEFI/BIOS da ISO candidata gerada; o script de validação já verifica o catálogo El Torito e arquivos essenciais.
- [ ] Testar ISO em máquinas virtuais UEFI e BIOS, incluindo instalação.
- [ ] Testar no hardware-alvo: Xeon E5-2640 v3, 16 GB RAM, X99 e GTX 750 2 GB.
- [ ] Criar matriz de testes, registrar logs, defeitos e correções.
- [ ] Gerar documentação de instalação, recuperação, solução de problemas e notas de versão.
- [ ] Só criar tag/release pública depois da aprovação explícita do responsável.

## Bloqueadores de lançamento atuais

1. A ISO candidata da revisão `a860bf0` já foi compilada e publicada (build #66/run `41754353319`; artefato `13287734605`; ISO SHA-256 `a1198cece40d0b418bbbdc7ab94f6afd76420bf25f4708873f265ff028f2ffc7`). O checksum passou no build. O bloqueio atual é validar boot Live e instalação em VM/hardware; não é ISO final nem release.
2. O Calamares personalizado foi integrado ao código e tem plano de teste seguro documentado, mas ainda precisa de teste de instalação em VM e hardware.
3. Wallpaper oficial já foi integrado e validado no CI; GDM agora recebe a configuração do wallpaper Kelpie, mas blur, relógio e controles ainda precisam de teste visual.
4. Kelpie Monitor e Kelpie Update já têm primeiras versões de código; Kelpie Disk já tem uma primeira versão de inventário somente leitura; Monitor, Update, Tweaks e Disk precisam de testes em sessão GNOME real.
5. Compatibilidade NVIDIA da GTX 750 ainda não foi validada no hardware.
6. Segurança, acessibilidade, recuperação e formatos de apps ainda não passaram por testes de instalação.
7. Não há relatório de testes em VM nem no computador-alvo.

A V3 permanece em desenvolvimento até que todos os itens obrigatórios sejam implementados, testados e documentados.

## Evidências CI mais recentes (03/11/2026)

- Branch: `v3-development`; commit observado antes do ajuste de recuperação: `176dd094`; ajuste do workflow registrado no commit `93ba1ec`.
- Testes estáticos run 70: sucesso.
- Validação Debian Trixie/APT run 93: concluída com sucesso.
- Build ISO run 36: cancelado após ficar sem atualização. Workflow ajustado para isolar o grupo de recuperação, cancelar concorrentes e limitar cada build a 240 minutos. Builds 39–40 foram cancelados por commits sucessivos durante a correção; build 41 (SHA e6909b00) é a execução de recuperação que incorpora o validador pós-build. A revisão atual inclui ainda lint explícito do validador no workflow estático.
- A aprovação dos workflows não substitui os testes de boot, instalação, sessão GNOME ou hardware real.


## Validação automatizada da ISO (03/11/2026)

- Criado `debian-live/validate-iso.sh`: exige ISO não vazia e maior que 500 MB, catálogo El Torito, kernel, initrd e `filesystem.squashfs`; gera e confere `SHA256SUMS`.
- O build agora executa esse validador antes de enviar o artefato.
- O preflight verifica a presença e a sintaxe do validador; o workflow estático também faz lint do script.
- Essa validação é estrutural. Não prova boot real, instalação Calamares nem compatibilidade com a GTX 750.


## Evidências do build candidato (04/11/2026)

- Branch: `v3-development`; HEAD `a860bf02a65a48da8ce1726ac3802d9ad1e7aa76`.
- Build ISO #66, run `41754353319`: concluído com sucesso; job `build` e as etapas de compilação e upload concluíram sem falha.
- Testes estáticos #105, run `41754353321`: sucesso em sintaxe Python/Shell, testes unitários, sequência Calamares, AppStream, wallpaper e metadados da extensão GNOME.
- Validação de configuração #121, run `41754353454`: sucesso na validação de metadados de pacotes e resolução de dependências Debian Trixie/APT.
- Artefato candidato `kelpie-os-linux-v3-candidate-amd64`, ID `13287734605`, publicado em 04/11/2026 e com expiração em 18/11/2026 às 01:54:30 UTC. Tamanho do ZIP: 3.456.106.873 bytes.
- O passo de upload terminou com sucesso e incluiu `dist/kelpie-os-linux-v3-amd64.iso` e `dist/SHA256SUMS`, com `if-no-files-found: error`.
- ISO: 3.456.106.496 bytes. SHA-256 registrado em `SHA256SUMS`: `a1198cece40d0b418bbbdc7ab94f6afd76420bf25f4708873f265ff028f2ffc7`; `sha256sum --check` retornou `kelpie-os-linux-v3-amd64.iso: OK`.
- SHA-256 do ZIP do artefato, informado pelo GitHub Actions: `b1befcc7495e352d4e78cff901cd85d35d2d97d31cdfe02973d1dcbe50936f8d`.
- `xorriso` registrou entradas El Torito BIOS e UEFI e o comando `file` identificou uma ISO 9660 inicializável. Isso é validação estrutural, não teste de boot.
- Avisos não fatais a acompanhar nos testes: o initramfs registrou que o cryptsetup não conseguiu determinar o dispositivo raiz; o live-build também removeu pacotes GRUB EFI/shim assinados ao registrar que Secure Boot não estava habilitado. Apesar da entrada UEFI no catálogo El Torito, o boot UEFI/BIOS continua pendente de validação em VM.
- Nenhuma release foi publicada. A V3 permanece bloqueada para lançamento até os testes de instalação, sessão GNOME e hardware serem concluídos.
