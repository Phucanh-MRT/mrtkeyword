# Keyword FX - cai dat tu dong (Windows 10/11). Chay bang CAI-DAT.bat.
# Cai: Node.js, Python 3.12, FFmpeg (qua winget, neu chua co) -> moi truong Python rieng cho skill
# (faster-whisper, torch, opencv) -> mo hinh nghe loi + tach nguoi -> thu vien dung video (Remotion)
# -> lien ket skill vao Claude (%USERPROFILE%\.claude\skills\keyword-fx).
$ErrorActionPreference = "Stop"
$Pkg   = Split-Path -Parent $MyInvocation.MyCommand.Path
$Skill = Join-Path $Pkg "keyword-fx"
$Tools = Join-Path $Skill "tools"
$Venv  = Join-Path $Tools ".venv"
$Py    = Join-Path $Venv "Scripts\python.exe"

function Step($n, $msg) { Write-Host ""; Write-Host "[$n/8] $msg" -ForegroundColor Cyan }
function Have($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function RefreshPath {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
}
function WingetInstall($id, $label) {
  if (-not (Have "winget")) { throw "Khong tim thay winget. Hay cai '$label' bang tay roi chay lai CAI-DAT.bat." }
  Write-Host "  dang cai $label ..."
  winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements | Out-Host
  RefreshPath
}

Step 1 "Node.js"
if (-not (Have "node")) { WingetInstall "OpenJS.NodeJS.LTS" "Node.js LTS" }
Write-Host "  node $(node -v)"

Step 2 "Python 3.12"
$BasePy = $null
if (Have "py") { try { & py -3.12 --version *> $null; if ($LASTEXITCODE -eq 0) { $BasePy = @("py", "-3.12") } } catch {} }
if (-not $BasePy) {
  WingetInstall "Python.Python.3.12" "Python 3.12"
  if (Have "py") { $BasePy = @("py", "-3.12") } else { $BasePy = @("python") }
}
Write-Host "  $(& $BasePy[0] $BasePy[1..9] --version)"

Step 3 "FFmpeg"
if (-not (Have "ffmpeg")) { WingetInstall "Gyan.FFmpeg" "FFmpeg" }
if (-not (Have "ffmpeg")) { throw "FFmpeg da cai nhung chua vao PATH. Dong cua so nay, mo lai CAI-DAT.bat." }
Write-Host "  ffmpeg ok"

Step 4 "Moi truong Python cho skill (lan dau mat 5-15 phut)"
New-Item -ItemType Directory -Force $Tools | Out-Null
if (-not (Test-Path $Py)) { & $BasePy[0] $BasePy[1..9] -m venv $Venv }
& $Py -m pip install --upgrade pip --quiet
& $Py -m pip install faster-whisper soundfile numpy "opencv-python-headless<5"
$Gpu = Have "nvidia-smi"
if ($Gpu) {
  Write-Host "  co card NVIDIA -> cai torch ban CUDA"
  & $Py -m pip install torch --index-url https://download.pytorch.org/whl/cu126
} else {
  Write-Host "  khong thay card NVIDIA -> cai torch ban CPU (van chay duoc, cham hon)"
  & $Py -m pip install torch --index-url https://download.pytorch.org/whl/cpu
}

Step 5 "Mo hinh tach nguoi (RobustVideoMatting, ~15 MB)"
$Rvm = Join-Path $Tools "models\rvm"
New-Item -ItemType Directory -Force $Rvm | Out-Null
$RvmFile = Join-Path $Rvm "rvm_mobilenetv3_fp32.torchscript"
if (-not (Test-Path $RvmFile)) {
  Invoke-WebRequest "https://github.com/PeterL1n/RobustVideoMatting/releases/download/v1.0.0/rvm_mobilenetv3_fp32.torchscript" -OutFile $RvmFile
}
Write-Host "  ok"

Step 6 "Mo hinh nghe loi (Whisper large-v3-turbo, ~1.6 GB)"
$env:HF_HOME = Join-Path $Tools "models\hf"
& $Py -c "from faster_whisper import WhisperModel; WhisperModel('large-v3-turbo', device='cpu', compute_type='int8'); print('  ok')"

Step 7 "Thu vien dung video (Remotion)"
Push-Location (Join-Path $Skill "template")
npm install --no-audit --no-fund
Pop-Location

Step 8 "Lien ket skill vao Claude"
$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force $SkillsDir | Out-Null
$Link = Join-Path $SkillsDir "keyword-fx"
if (Test-Path $Link) {
  $item = Get-Item $Link -Force
  if ($item.LinkType -eq "Junction") { cmd /c rmdir "$Link" | Out-Null }
  else { throw "Da co thu muc $Link (khong phai lien ket). Doi ten hoac xoa no roi chay lai." }
}
cmd /c mklink /J "$Link" "$Skill" | Out-Null
New-Item -ItemType Directory -Force (Join-Path $env:USERPROFILE "Videos\Keyword FX\Thanh pham") | Out-Null
Write-Host "  $Link -> $Skill"

Write-Host ""
Write-Host "XONG! Mo Claude (tab Code), gui video hoac file am thanh va go: /keyword-fx dung video nay" -ForegroundColor Green
Write-Host "Thanh pham nam trong: $env:USERPROFILE\Videos\Keyword FX\Thanh pham"
