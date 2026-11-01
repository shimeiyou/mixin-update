# mixin-update for Windows：检测 → 推荐 → 安装/更新 Mixin Messenger 桌面版
# 用法：
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/shimeiyou/mixin-update/main/install.ps1).TrimStart([char]0xFEFF))) install
#   .\install.ps1 [install|update|check|recommend|help] [-Silent] [-Force]
param([string]$Command = "install", [switch]$Silent, [switch]$Force)
$ErrorActionPreference = "Stop"
$Repo = "MixinNetwork/flutter-app"

function Show-Help {
@"
mixin-update (Windows) — Mixin Messenger 桌面版 安装 / 更新 / 检查

用法: .\install.ps1 [命令] [-Silent] [-Force]
  install    安装（已装则检查更新），默认命令
  update     有新版则下载官方安装包并安装
  check      只检查，不下载
  recommend  显示系统/架构与推荐方式
  help       显示本帮助
  -Silent    静默安装（Inno Setup /VERYSILENT），默认显示安装向导
  -Force     即使已是最新也重新安装

说明: 仅支持 x64（官方只发布 mixin_desktop_windows_setup_amd64.exe）；ARM64 Windows 可经 x64 仿真运行。
字体/主题: 应用内 设置→外观 可切换深浅色与聊天字号；字体跟随系统（Windows 无 fontconfig 定制）。
回滚: 设置→应用→Mixin 卸载，再从 https://github.com/$Repo/releases 装旧版。
"@
}
function Get-Arch { if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE } }
function Get-Installed {
  $keys = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
  Get-ItemProperty $keys -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "Mixin*" } | Select-Object -First 1
}
function Get-Latest {
  $r = Invoke-RestMethod -Headers @{ "User-Agent" = "mixin-update" } "https://api.github.com/repos/$Repo/releases/latest"
  $a = $r.assets | Where-Object { $_.name -eq "mixin_desktop_windows_setup_amd64.exe" } | Select-Object -First 1
  if (-not $a) { throw "最新 release 没有 Windows 安装包，请查看 https://github.com/$Repo/releases" }
  [pscustomobject]@{ Version = $r.tag_name.TrimStart("v"); Url = $a.browser_download_url; Size = $a.size; Sha = ($a.digest -replace "^sha256:", "") }
}
function ConvertTo-Ver([string]$s) { $n = @([regex]::Matches($s, '\d+') | ForEach-Object { [int]$_.Value }); while ($n.Count -lt 3) { $n += 0 }; [version]::new($n[0], $n[1], $n[2]) }
function Test-Newer([string]$a, [string]$b) { (ConvertTo-Ver $a) -gt (ConvertTo-Ver $b) }
function Recommend {
  "系统: Windows / $(Get-Arch)"
  "推荐: 官方 Inno Setup 安装包 mixin_desktop_windows_setup_amd64.exe（按用户安装，通常无需管理员）"
}

switch ($Command.ToLower()) {
  { $_ -in "help","-h","--help" } { Show-Help; return }
  "recommend" { Recommend; return }
}
$arch = Get-Arch
if ($arch -notin "AMD64","ARM64") { throw "不支持的架构 $arch" }
Recommend
$latest = Get-Latest
$inst = Get-Installed
$cur = if ($inst) { $inst.DisplayVersion } else { "0" }
"当前: $cur  最新: $($latest.Version)"
if ($inst -and -not $Force -and -not (Test-Newer $latest.Version $cur)) { "✅ 已是最新"; return }
if ($Command -eq "check") { "⬆️ 有更新/未安装：运行 .\install.ps1 install"; return }

$tmp = Join-Path $env:TEMP "mixin_setup_$($latest.Version).exe"
"下载 $($latest.Url)"
Invoke-WebRequest -UseBasicParsing -Uri $latest.Url -OutFile $tmp
if ((Get-Item $tmp).Length -ne $latest.Size) { Remove-Item $tmp; throw "大小不符，已取消" }
if ($latest.Sha) {
  if ((Get-FileHash $tmp -Algorithm SHA256).Hash.ToLower() -ne $latest.Sha.ToLower()) { Remove-Item $tmp; throw "sha256 校验失败，已取消" }
  "sha256 校验通过"
}
Get-Process | Where-Object { $_.ProcessName -like "mixin*" } | ForEach-Object { "ℹ️ 关闭正在运行的 Mixin…"; $_.CloseMainWindow() | Out-Null }
$setupArgs = if ($Silent) { "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART" } else { "" }
if ($setupArgs) { Start-Process -FilePath $tmp -ArgumentList $setupArgs -Wait } else { Start-Process -FilePath $tmp -Wait }
Remove-Item $tmp -ErrorAction SilentlyContinue
"✅ 已安装 $($latest.Version)"
