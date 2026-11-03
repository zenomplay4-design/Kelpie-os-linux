# Kelpie OS Linux V3 — estado e validação

## Plataforma-alvo

- Debian 13 Trixie, arquitetura amd64.
- GNOME, idioma padrão pt_BR e teclado brasileiro.
- Imagem Live híbrida para teste em UEFI e BIOS legado.
- A ISO gerada pelo workflow é uma **candidata de desenvolvimento**, não uma versão final.

## Formatos de aplicativos

| Formato | Situação planejada | Observações |
|---|---|---|
| DEB / APT | Nativo | Instalação e atualização pelo Debian e GNOME Software. |
| Flatpak / Flathub | Integrado | O remoto Flathub é registrado durante a configuração. |
| Snap | Pacotes incluídos para teste | O serviço snapd e a integração GNOME Software precisam ser verificados em uma sessão instalada. |
| AUR | Não nativo | AUR depende do ecossistema Arch Linux; não será apresentado como compatível com Debian. |

## Gráficos NVIDIA

A imagem mantém Nouveau como fallback. O driver proprietário NVIDIA não é instalado automaticamente nesta fase: a GTX 750 é Maxwell e exige validação do pacote, do kernel e do funcionamento gráfico no hardware real antes de definir um driver padrão. Não misturar versões de drivers nem prometer compatibilidade sem teste.

## Segurança configurada

- Atualização periódica das listas APT.
- Instalação automática de atualizações permitidas pela configuração padrão Debian de unattended-upgrades.
- AppArmor incluído e habilitado para iniciar no primeiro boot.
- UFW/GUFW incluídos, mas o firewall não é ativado automaticamente nesta fase para evitar bloquear conexões e compartilhamentos sem uma política definida.

## Compilação de desenvolvimento

1. Abra a aba Actions do repositório.
2. Execute manualmente **Build Kelpie OS Linux V3 ISO** na branch `v3-development`.
3. O job executa `preflight.sh`, instala as ferramentas de build, valida os nomes e dependências dos pacotes e só então chama `lb build`.
4. O artefato esperado é `kelpie-os-linux-v3-candidate-amd64`, contendo a ISO e `SHA256SUMS`.

## Critérios para considerar a V3 concluída

- Build no GitHub Actions concluído sem erros.
- ISO e checksum gerados e checksum conferido.
- Boot Live validado em UEFI e BIOS legado, quando disponível.
- Instalação em disco testada sem tocar em unidades USB de origem.
- GNOME, áudio, rede, Bluetooth, impressão, suspensão e múltiplos monitores testados.
- GTX 750 testada com Nouveau e, separadamente, com um driver proprietário compatível e mantido.
- Flatpak, Snap e DEB testados em sistema instalado.
- Atualizações, AppArmor, recuperação e acessibilidade verificados.
- Nenhuma release/tag final antes da aprovação explícita do responsável pelo projeto.

## Limitações conhecidas

A arte definitiva do wallpaper ainda precisa substituir o desenho temporário gerado no build. A extensão de menu GNOME também precisa de teste em sessão real do GNOME 48. A geração da ISO, por si só, não comprova que o instalador ou todos os dispositivos funcionam no computador-alvo.
