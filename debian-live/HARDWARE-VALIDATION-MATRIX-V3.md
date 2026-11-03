# Kelpie OS V3 — matriz de validação de hardware

Objetivo: validar a imagem em hardware real e virtual sem presumir compatibilidade apenas porque um pacote está na ISO. Registrar cada execução com ISO/commit, máquina, firmware, logs e resultado.

## Perfil de referência do projeto

- CPU: Intel Xeon E5-2640 v3
- Memória: 16 GB DDR4 (configuração atual informada: 1×16 GB)
- GPU: NVIDIA GeForce GTX 750 2 GB
- Placa-mãe: plataforma X99 (modelo exato a confirmar)
- Firmware: UEFI; Secure Boot indisponível/desativado segundo o relato do proprietário

## Matriz de testes

| Área | Verificação | Evidência mínima | Estado |
|---|---|---|---|
| CPU | Identificação, microcode e estabilidade | lscpu, dmesg, journalctl | Pendente |
| RAM | Capacidade, canais reportados e teste de memória | lsmem, BIOS/UEFI, memtest | Pendente |
| GPU | GTX 750 identificada, sessão GNOME e aceleração | lspci -nnk, glxinfo -B, journalctl | Pendente |
| NVIDIA | Avaliar driver proprietário compatível com Maxwell | nvidia-detect, pacote Debian, versão suportada | Pendente |
| Fallback | Inicializar com Nouveau se driver proprietário ausente/falhar | lspci -nnk, glxinfo -B | Pendente |
| Vídeo | Reprodução VLC, resolução e aceleração disponível | teste de vídeo + logs VLC | Pendente |
| Armazenamento | SATA, NVMe, USB, SMART e montagem | lsblk -f, smartctl, nvme list | Pendente |
| Rede | Ethernet, Wi-Fi e DNS | nmcli, ping, journalctl | Pendente |
| Bluetooth | Pareamento, áudio e reconexão | bluetoothctl, journalctl | Pendente |
| Áudio | Entrada, saída, microfone e PipeWire | wpctl status, teste gravar/reproduzir | Pendente |
| USB | Teclado, mouse, armazenamento e hotplug | lsusb, journalctl -f | Pendente |
| Monitores | Resolução, escala, multi-monitor e hotplug | gnome-control-center + evidência visual | Pendente |
| Energia | Suspensão, retomada e desligamento | journalctl -b, testes repetidos | Pendente |
| Impressão | CUPS, descoberta e impressão de página de teste | fila CUPS e página impressa | Pendente |
| Acessibilidade | Orca, lupa, teclado virtual e contraste | roteiro manual com resultados | Pendente |

## Coleta padronizada

Executar no sistema instalado, não durante o build:

```bash
mkdir -p ~/kelpie-hardware-report
{
  date -Is
  cat /etc/os-release
  uname -a
  lscpu
  lsmem
  lspci -nnk
  lsusb
  lsblk -o NAME,MODEL,SIZE,TYPE,FSTYPE,MOUNTPOINTS
  nmcli device status
  wpctl status
  glxinfo -B 2>&1 || true
  nvidia-detect 2>&1 || true
  sensors 2>&1 || true
  systemctl --failed
} > ~/kelpie-hardware-report/inventory.txt
journalctl -b -p warning > ~/kelpie-hardware-report/warnings.txt
```

Antes de compartilhar os relatórios, revisar e remover nomes de usuário, endereços IP, SSIDs, números de série e outros dados pessoais.

## Política NVIDIA para GTX 750

A GTX 750 é da geração Maxwell. Não assumir que qualquer versão recente do driver NVIDIA ainda a suporta. O driver proprietário só poderá ser incluído por padrão depois de confirmar no Debian 13 Trixie a disponibilidade, manutenção, compatibilidade da GPU, integração com o kernel e funcionamento do GNOME. Até lá, manter Nouveau como caminho de inicialização seguro e documentar a aceleração observada.

## Critério de aprovação

Um item só muda para aprovado após teste executado e evidência anexada. A ausência de hardware no ambiente de CI não conta como teste. Falhas gráficas ou de boot bloqueiam a ISO de lançamento até existir fallback funcional.
