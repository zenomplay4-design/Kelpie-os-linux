#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST="${1:-$ROOT/config/package-lists/kelpie.list.chroot}"

if [[ ! -f "$LIST" ]]; then
  echo "ERRO: lista de pacotes não encontrada: $LIST" >&2
  exit 2
fi

mapfile -t PACKAGES < <(sed -E 's/#.*$//; s/[[:space:]]+$//; /^[[:space:]]*$/d' "$LIST")

if (("${#PACKAGES[@]}" == 0)); then
  echo "ERRO: lista de pacotes vazia." >&2
  exit 2
fi

duplicates="$(printf '%s\n' "${PACKAGES[@]}" | sort | uniq -d)"
if [[ -n "$duplicates" ]]; then
  echo "ERRO: pacotes duplicados:" >&2
  printf '%s\n' "$duplicates" >&2
  exit 1
fi

invalid=0
echo "Validando ${#PACKAGES[@]} pacotes no repositório configurado..."
for package in "${PACKAGES[@]}"; do
  if ! [[ "$package" =~ ^[a-z0-9][a-z0-9+.-]*$ ]]; then
    echo "ERRO: nome de pacote inválido: $package" >&2
    invalid=1
  elif ! apt-cache show "$package" 2>/dev/null | grep -q "^Package: ${package}$"; then
    echo "AUSENTE: $package"
    invalid=1
  else
    echo "OK: $package"
  fi
done

if ((invalid)); then
  echo "Falha: corrija os pacotes marcados antes de compilar a ISO." >&2
  exit 1
fi

echo "Verificando resolução de dependências (simulação)..."
if ! apt-get -s install --no-install-recommends "${PACKAGES[@]}"; then
  echo "ERRO: o conjunto de pacotes possui dependências conflitantes ou irresolvíveis." >&2
  exit 1
fi

echo "SUCESSO: nomes e dependências dos pacotes foram validados."
