#!/bin/bash

ulimit -n 65535

# Verifica se recebeu um comando
if [ $# -eq 0 ]; then
  echo "Uso: ./mem_track.sh <comando>"
  echo "Exemplo: ./mem_track.sh cargo run --release --features mimalloc"
  exit 1
fi

# Variável para armazenar as leituras
declare -a LOGS=()
COUNTER=1

# Cabeçalho da tabela Markdown
HEADER="| # | RSS | VSZ |"
SEPARATOR="|---|------|--------|"

# Função para imprimir a tabela e sair
print_table_and_exit() {
  echo ""
  echo "$HEADER"
  echo "$SEPARATOR"
  for row in "${LOGS[@]}"; do
    echo "$row"
  done
  exit 0
}

# Captura interrupção manual também
trap print_table_and_exit SIGINT

# Executa o comando fornecido em background
"$@" &
child_pid=$!

echo "Comando iniciado: $*"
echo "PID do processo: $child_pid"
echo "Monitorando memória... Pressione Ctrl+C para interromper ou aguarde o processo finalizar."
echo ""

# Aguarda o processo compilar (caso seja cargo)
sleep 2

# Monitora enquanto o processo estiver ativo
while kill -0 "$child_pid" 2> /dev/null; do
  line=$(ps -o rss,vsz --no-headers -p "$child_pid")
  rss=$(echo "$line" | awk '{print $1}')
  vsz=$(echo "$line" | awk '{print $2}')
  LOGS+=("| $COUNTER | $rss | $vsz |")
  ((COUNTER++))
  sleep 1
done

print_table_and_exit
