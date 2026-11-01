# mixin-update

在 Linux（x86_64，如 Arch）上检查并更新 [Mixin Messenger 桌面版](https://github.com/MixinNetwork/flutter-app) AppImage 的小脚本。无需 sudo。

## 安装

```bash
curl -fsSLo ~/.local/bin/mixin-update https://raw.githubusercontent.com/shimeiyou/mixin-update/main/mixin-update
chmod +x ~/.local/bin/mixin-update
```

依赖：`bash` `curl` `python3` `sha256sum`。

约定的文件位置：

| 用途 | 路径 |
|---|---|
| AppImage | `~/Applications/mixin-<版本>-x86_64.AppImage` |
| 启动项 | `~/.local/share/applications/mixin-desktop.desktop`（示例见 `mixin-desktop.desktop.example`） |
| 可选字体配置 | `~/.config/mixin-fonts/fonts.conf`（示例见 `fonts.conf.example`） |

## 用法

```
mixin-update                检查更新；有新版则下载并替换安装
mixin-update --check        只检查，不下载
mixin-update --delete-old   更新后删除旧版 AppImage（默认保留上一版用于回滚）
mixin-update --force        即使已是最新也重新下载安装
mixin-update -h | --help | help   显示帮助
```

更新流程：读取启动项中的当前版本 → 查 GitHub Releases 最新 `mixin_desktop_linux_amd64.AppImage` → 下载为 `.part` → 校验大小与 sha256 → `chmod +x` 并改名 → 备份启动项为 `.bak-update` 后只替换其中的 AppImage 路径。任一步失败，原版本不变。

## 字体（只对 Mixin 生效）

Flutter 版 Mixin 没有字体设置，使用 fontconfig 的 `sans-serif`。`fonts.conf.example` 引入系统配置后把 `sans-serif` 首选改为 HarmonyOS Sans SC（可换成任意已装字体），表情用 Noto Color Emoji。放到 `~/.config/mixin-fonts/fonts.conf`，启动项中用 `env FONTCONFIG_FILE=...` 指向它。`mixin-update` 更新时会原样保留这段。

## 回滚

```bash
mv ~/.local/share/applications/mixin-desktop.desktop.bak-update \
   ~/.local/share/applications/mixin-desktop.desktop
```

然后重开 Mixin（前提：更新时未用 `--delete-old`，旧 AppImage 仍在）。

## License

MIT
