# Kelpie OS V3 — plano de testes GNOME e instalador

Este plano separa verificações estáticas de testes que só podem ser aprovados depois de iniciar uma ISO candidata. Nenhum item abaixo deve ser marcado como aprovado apenas por existir código no repositório.

## Ambiente de referência
- Debian 13 Trixie amd64 com GNOME 48.
- Sessão Wayland e, quando necessário, sessão X11 para comparação.
- Resoluções: 1366×768 e 1920×1080.
- Hardware-alvo: Xeon E5-2640 v3, 16 GB DDR4, X99 e NVIDIA GTX 750 2 GB.
- Firmware UEFI sem Secure Boot.

## Primeiro login e dock
1. Iniciar a ISO em modo Live e concluir o primeiro login.
2. Confirmar que o painel e o dock aparecem sem erros da extensão Kelpie.
3. Confirmar dock fixo na parte inferior, sem ocultação automática.
4. Abrir o menu Kelpie, iniciar Arquivos, Firefox, GNOME Software e os quatro utilitários Kelpie.
5. Reiniciar a sessão e confirmar persistência das preferências dconf.
6. Repetir em 1366×768, 1920×1080 e com dois monitores.

## Kelpie Tweaks
1. Alternar tema escuro/claro e confirmar aplicação imediata.
2. Desativar e reativar animações.
3. Ativar alto contraste e validar legibilidade.
4. Alterar escala de texto entre 0,8× e 1,5×.
5. Alterar transparência do dock e confirmar persistência após sair e entrar na sessão.
6. Restaurar padrões e confirmar os valores iniciais: tema padrão, animações ligadas, contraste desligado, escala 1,0× e opacidade do dock 0,28.
7. Testar comportamento seguro caso a extensão Dash to Dock ou seu schema GSettings não esteja disponível.

## Kelpie Monitor
1. Confirmar leitura de CPU, RAM, uso do sistema de arquivos e processos.
2. Testar sem privilégios administrativos e com processos protegidos.
3. Testar ausência de sensores de temperatura sem travar a interface.
4. Testar GPU com Nouveau, sem NVIDIA proprietária e com NVIDIA proprietária quando houver driver validado.
5. Confirmar que a interface continua responsiva durante atualizações periódicas.

## Calamares e proteção de dados
1. Confirmar identificação clara do disco de destino, modelo, capacidade e dispositivo.
2. Testar cancelamento antes da gravação de alterações.
3. Testar particionamento automático somente em disco virtual descartável.
4. Testar particionamento manual em discos virtuais com múltiplas partições.
5. Testar UEFI com GPT e BIOS legado em VM separada.
6. Confirmar criação de usuário, idioma pt_BR, teclado brasileiro e bootloader.
7. Confirmar que o pendrive da ISO não é selecionado como destino por padrão.
8. Nunca executar teste destrutivo no computador principal; usar discos virtuais ou hardware de laboratório.

## Evidências exigidas
Para cada teste aprovado, registrar data, commit, hash SHA256 da ISO, configuração da VM/hardware, passos executados, resultado e logs relevantes. Falha ou teste não executado permanece pendente.
