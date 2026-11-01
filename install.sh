#!/usr/bin/env sh
# 一键安装：下载 mixin-update 到 ~/.local/bin，然后执行 mixin-update install（Linux / macOS）
# 用法：curl -fsSL https://raw.githubusercontent.com/shimeiyou/mixin-update/main/install.sh | sh
#       额外参数透传，例如 ... | sh -s -- --font "HarmonyOS Sans SC"
set -eu
BIN="$HOME/.local/bin"; mkdir -p "$BIN"
curl -fsSL -o "$BIN/mixin-update" https://raw.githubusercontent.com/shimeiyou/mixin-update/main/mixin-update
chmod +x "$BIN/mixin-update"
echo "已安装工具: $BIN/mixin-update"
"$BIN/mixin-update" recommend || true
"$BIN/mixin-update" install "$@"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "提示：把 $BIN 加入 PATH：export PATH=\"$BIN:\$PATH\"";; esac
