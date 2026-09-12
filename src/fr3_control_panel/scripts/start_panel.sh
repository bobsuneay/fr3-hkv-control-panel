#!/usr/bin/env bash
set -euo pipefail

# One-command launcher for the FR3 + HKV panel.
# Usage:
#   bash start_panel.sh                 # mock robot + MoveIt + RViz + UI
#   bash start_panel.sh --real          # real bringup + UI (requires real.yaml)
#   bash start_panel.sh --ui-only       # UI only, no robot backend

MODE="mock"
for arg in "$@"; do
  case "$arg" in
    --mock) MODE="mock" ;;
    --real) MODE="real" ;;
    --ui-only) MODE="ui-only" ;;
    -h|--help) sed -n '1,14p' "$0"; exit 0 ;;
    *) echo "未知参数: $arg" >&2; exit 2 ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WS_ROOT="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"

source_if_exists() {
  if [[ -f "$1" ]]; then
    # shellcheck disable=SC1090
    source "$1"
  else
    echo "缺少环境文件: $1" >&2
    exit 1
  fi
}

source_if_exists /opt/ros/humble/setup.bash
source_if_exists "$WS_ROOT/install/setup.bash"

if [[ "$MODE" == "ui-only" ]]; then
  exec ros2 run fr3_control_panel panel --demo
fi

if [[ "$MODE" == "mock" ]]; then
  exec ros2 launch fr3_control_panel mock_panel.launch.py
fi

REAL_CONFIG="${FR3_REAL_CONFIG:-$HOME/fr3_config/real.yaml}"
CELL_CONFIG="${FR3_CELL_CONFIG:-$WS_ROOT/install/fr3_real_bringup/share/fr3_real_bringup/config/cell.yaml}"
SERIAL_PORT="${HKV_SERIAL_PORT:-/dev/ttyACM0}"
BAUD_RATE="${HKV_BAUD_RATE:-1000000}"
if [[ ! -f "$REAL_CONFIG" ]]; then
  echo "缺少真实设备配置: $REAL_CONFIG" >&2
  echo "请先复制 real.example.yaml 并完成现场验收，或使用 --mock。" >&2
  exit 1
fi

exec ros2 launch fr3_real_bringup bringup.launch.py \
  mode:=real confirm_real:=true enable_execution:=true rviz:=true \
  real_config:="$REAL_CONFIG" cell:="$CELL_CONFIG" \
  serial_port:="$SERIAL_PORT" baud_rate:="$BAUD_RATE"
