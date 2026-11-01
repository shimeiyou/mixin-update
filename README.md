# mixin-update

一键 **检测设备 → 推荐安装方式 → 自动安装 / 更新** [Mixin Messenger 桌面版](https://github.com/MixinNetwork/flutter-app)（官方 Releases）。支持 Linux、macOS、Windows。

| 平台 | 官方包 | 本工具做法 | 需要管理员 |
|---|---|---|---|
| Linux x86_64 / arm64 | AppImage（另有 deb/snap/tar.gz） | AppImage **解包**到 `~/Applications/mixin-<版本>/`，启动项运行其中 `AppRun`（免 FUSE 挂载，启动快），生成菜单启动项和图标 | 否 |
| macOS | `.dmg`（部分版本才附带；也在 Mac App Store） | 取最近一个带 dmg 的版本，装到 `/Applications`（不可写时 `~/Applications`） | 一般否 |
| Windows x64（ARM64 走仿真） | Inno Setup 安装包 `.exe` | 下载、校验后运行安装向导（可静默） | 一般否 |

所有下载都校验 **文件大小 + GitHub 提供的 sha256**，校验失败不会动现有安装。

## 安装

**Linux / macOS**

```bash
curl -fsSL https://raw.githubusercontent.com/shimeiyou/mixin-update/main/install.sh | sh
# 带 Mixin 专用字体（Linux）：
curl -fsSL https://raw.githubusercontent.com/shimeiyou/mixin-update/main/install.sh | sh -s -- --font "HarmonyOS Sans SC"
```

它会把 `mixin-update` 放到 `~/.local/bin/`，显示推荐方式，然后执行 `mixin-update install`。想先看脚本：把 URL 下载下来读一遍再运行。

**Windows（PowerShell）**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/shimeiyou/mixin-update/main/install.ps1).TrimStart([char]0xFEFF))) install
```

或下载 `install.ps1` 后：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 install          # 显示安装向导
powershell -ExecutionPolicy Bypass -File .\install.ps1 install -Silent  # 静默安装
```

## 更新 / 检查 / 帮助

**Linux / macOS**

```
mixin-update                    = update（兼容旧用法）
mixin-update recommend          检测系统/架构，给出推荐安装方式
mixin-update install [--font 字体名]   安装（已装则等同 update）
mixin-update update             有新版则下载替换
mixin-update check              只检查，不下载（旧写法 --check 也可）
mixin-update help | -h | --help 显示帮助
  --delete-old   (Linux) 更新后删除上一版，默认保留上一版回滚
  --keep-appimage (Linux) 解包后保留下载的 AppImage（默认删除）
  --force        即使已是最新也重新安装
```

**Windows**：`.\install.ps1 [install|update|check|recommend|help] [-Silent] [-Force]`

## 字体与显示

- **应用内（三平台通用）**：设置 → 外观：跟随系统 / 浅色 / 深色，聊天字号（-2 ~ +4），消息头像开关。没有字体选项，界面字体跟随系统。
- **Linux 自定义字体（只对 Mixin 生效）**：`mixin-update install --font "HarmonyOS Sans SC"` 会写 `~/.config/mixin-fonts/fonts.conf`（示例见 `fonts.conf.example`），启动项变为 `Exec=env FONTCONFIG_FILE=~/.config/mixin-fonts/fonts.conf ~/Applications/mixin-<版本>/AppRun %U`。之后每次 `update` 只替换程序路径，这段原样保留。字体需先装好（`fc-list | grep 字体名` 能查到）。
- **macOS / Windows**：跟随系统字体，无单独定制；可用系统的显示缩放/文字大小。

## 为什么默认解包安装（Linux）
直接运行 AppImage 每次都要用 FUSE 挂载约 112MB 的 squashfs 镜像，启动明显变慢。本工具下载 AppImage 后执行 `--appimage-extract`，解到 `~/Applications/mixin-<版本>/`，启动项和 Hyprland 快捷键（`~/.config/hypr/custom/keybinds.lua` 中已有的 Mixin 绑定）都改为运行 `AppRun`，保留 AppImage 自带的运行环境，只是去掉了挂载开销。下载的 AppImage 解包后默认删除（`--keep-appimage` 保留）。以前用 AppImage 直跑安装的，下次 `mixin-update update` 会自动转换。

## 回滚

- **Linux**：`mv ~/.local/share/applications/mixin-desktop.desktop.bak-update ~/.local/share/applications/mixin-desktop.desktop`，重开 Mixin（未用 `--delete-old` 时上一版目录仍在）。若同步过 Hyprland 快捷键：`mv ~/.config/hypr/custom/keybinds.lua.bak-update ~/.config/hypr/custom/keybinds.lua && hyprctl reload`。
  完全卸载：删 `~/Applications/mixin-*`（解包目录和 AppImage）、`~/.local/share/applications/mixin-desktop.desktop`、`~/.local/share/icons/mixin-desktop.png`、`~/.config/mixin-fonts`、`~/.local/bin/mixin-update`。
- **macOS**：更新前旧版被改名为 `Mixin.app.bak-update`；删掉新 `Mixin.app` 再把备份改回原名即可。
- **Windows**：设置 → 应用 → Mixin 卸载，再从 [Releases](https://github.com/MixinNetwork/flutter-app/releases) 装旧版。

## 文件

- `mixin-update` — Linux/macOS 主脚本（bash，需要 curl、python3）
- `install.sh` — Linux/macOS 一键引导
- `install.ps1` — Windows 脚本
- `fonts.conf.example`、`mixin-desktop.desktop.example` — Linux 字体与启动项示例

## License

MIT
