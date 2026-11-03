#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if (($#)); then
  LISTS=("$@")
else
  mapfile -t LISTS < <(find "$ROOT/config/package-lists" -maxdepth 1 -type f -name '*.list.chroot' -print | sort)
fi

if (("${#LISTS[@]}" == 0)); then
  echo "ERRO: nenhuma lista de pacotes encontrada." >&2
  exit 2
fi

declare -A SEEN=()
PACKAGES=()
invalid=0

for LIST in "${LISTS[@]}"; do
  if [[ ! -f "$LIST" ]]; then
    echo "ERRO: lista de pacotes não encontrada: $LIST" >&2
    exit 2
  fi
  echo "Lendo: $LIST"
  while IFS= read -r package; do
    [[ -n "$package" ]] || continue
    if ! [[ "$package" =~ ^[a-z0-9][a-z0-9+.-]*$ ]]; then
      echo "ERRO: nome de pacote inválido: $package" >&2
      invalid=1
      continue
    fi
    if [[ -n "${SEEN[$package]:-}" ]]; then
      echo "ERRO: pacote duplicado entre listas: $package" >&2
      invalid=1
      continue
    fi
    SEEN["$package"]=1
    PACKAGES+=("$package")
  done < <(sed -E 's/#.*$//; s/[[:space:]]+$//; /^[[:space:]]*$/d' "$LIST")
done

if (("${#PACKAGES[@]}" == 0)); then
  echo "ERRO: nenhuma entrada de pacote encontrada." >&2
  exit 2
fi

echo "Validando ${#PACKAGES[@]} pacotes nos repositórios configurados..."
for package in "${PACKAGES[@]}"; do
  # Capture full output before grep: grep -q on a pipe can trigger SIGPIPE
  # under pipefail and incorrectly report a package as missing.
  package_info="$(apt-cache show "$package" 2>/dev/null || true)"
  if ! grep -Fqx "Package: $package" <<< "$package_info"; then
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

echo "Verificando resolução de dependências (simulação APT)..."
if ! apt-get -s install --no-install-recommends "${PACKAGES[@]}"; then
  echo "ERRO: o conjunto de pacotes possui dependências conflitantes ou irresolvíveis." >&2
  exit 1
fi

echo "SUCESSO: todas as listas e dependências foram validadas."
