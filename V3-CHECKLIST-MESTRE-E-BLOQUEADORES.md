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
- [ ] Personalizar tela de bloqueio com wallpaper oficial desfocado, relógio, data e controles nativos.
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
- [ ] Compilar ISO candidata no GitHub Actions (nova execução disparada após ajuste de recuperação do workflow).
- [ ] Conferir checksum SHA256 e integridade da ISO.
- [ ] Inspecionar partições, bootloader, entradas UEFI/BIOS e conteúdo da ISO.
- [ ] Testar ISO em máquinas virtuais UEFI e BIOS, incluindo instalação.
- [ ] Testar no hardware-alvo: Xeon E5-2640 v3, 16 GB RAM, X99 e GTX 750 2 GB.
- [ ] Criar matriz de testes, registrar logs, defeitos e correções.
- [ ] Gerar documentação de instalação, recuperação, solução de problemas e notas de versão.
- [ ] Só criar tag/release pública depois da aprovação explícita do responsável.

## Bloqueadores de lançamento atuais

1. Ainda não existe build de ISO V3 confirmado.
2. O Calamares personalizado foi integrado ao código e tem plano de teste seguro documentado, mas ainda precisa de teste de instalação em VM e hardware.
3. Wallpaper oficial já foi integrado e validado no CI; a tela de bloqueio final ainda não foi personalizada nem testada.
4. Kelpie Monitor e Kelpie Update já têm primeiras versões de código; Kelpie Disk já tem uma primeira versão de inventário somente leitura; Monitor, Update, Tweaks e Disk precisam de testes em sessão GNOME real.
5. Compatibilidade NVIDIA da GTX 750 ainda não foi validada no hardware.
6. Segurança, acessibilidade, recuperação e formatos de apps ainda não passaram por testes de instalação.
7. Não há relatório de testes em VM nem no computador-alvo.

A V3 permanece em desenvolvimento até que todos os itens obrigatórios sejam implementados, testados e documentados.

## Evidências CI mais recentes (03/11/2026)

- Branch: `v3-development`; commit observado antes do ajuste de recuperação: `176dd094`; ajuste do workflow registrado no commit `93ba1ec`.
- Testes estáticos run 70: sucesso.
- Validação Debian Trixie/APT run 93: concluída com sucesso.
- Build ISO run 36: permaneceu sem atualização após iniciar a etapa de build; sem artefato ISO. Workflow ajustado para cancelar execuções anteriores concorrentes e limitar cada build a 240 minutos; nova execução deve confirmar recuperação.
- A aprovação dos workflows não substitui os testes de boot, instalação, sessão GNOME ou hardware real.
