#!/usr/bin/env pwsh
# 独立压缩测试脚本：提取/增强 Invoke-ZipArchive，可压缩目录或单个文件
# 兼容 Windows PowerShell 5.1

param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    [string]$DestinationZip,
    [ValidateSet('Optimal','Fastest','NoCompression')]
    [string]$CompressionLevel = 'Fastest',
    [ValidateSet('Auto','SevenZip','Tar','CompressArchive')]
    [string]$ZipTool = 'Auto',
    # IncludeRoot 仅对目录有效：
    #  - $true  => ZIP 里包含目录本身
    #  - $false => 仅包含目录内容
    [switch]$IncludeRoot
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

function Format-Bytes([long]$bytes) {
    if ($bytes -le 0) { return '0 B' }
    $units = 'B','KB','MB','GB','TB'
    $power = [Math]::Min([Math]::Floor([Math]::Log($bytes,1024)), $units.Length - 1)
    $value = $bytes / [Math]::Pow(1024, $power)
    return "{0:N2} {1}" -f $value, $units[$power]
}

function Get-SevenZipPath {
    $paths = @(
        (Get-Command '7z.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source),
        'C:\\Program Files\\7-Zip\\7z.exe',
        'C:\\Program Files (x86)\\7-Zip\\7z.exe'
    ) | Where-Object { $_ }
    foreach ($p in $paths) { if ($p -and (Test-Path $p)) { return $p } }
    return $null
}

function Get-TarPath {
    $cmd = Get-Command 'tar.exe' -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Resolve-ZipTool {
    param([string]$Preference)
    switch ($Preference) {
        'SevenZip' {
            $path = Get-SevenZipPath
            if ($path) { return @{ Name='SevenZip'; Path=$path } }
            throw '未找到 7-Zip，请安装 7-Zip 或使用 ZipTool=Auto/CompressArchive'
        }
        'Tar' {
            $path = Get-TarPath
            if ($path) { return @{ Name='Tar'; Path=$path } }
            throw '未找到 tar.exe，请安装或改用 ZipTool=Auto'
        }
        'CompressArchive' { return @{ Name='CompressArchive'; Path=$null } }
        'Auto' {
            $path = Get-SevenZipPath; if ($path) { return @{ Name='SevenZip'; Path=$path } }
            $path = Get-TarPath;      if ($path) { return @{ Name='Tar'; Path=$path } }
            return @{ Name='CompressArchive'; Path=$null }
        }
        default { throw "未知 ZipTool: $Preference" }
    }
}

function Test-ZipHasEntries([string]$ZipPath) {
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue | Out-Null
        $fs = [System.IO.File]::OpenRead($ZipPath)
        try {
            $archive = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Read)
            return ($archive.Entries.Count -gt 0)
        } finally { $fs.Dispose() }
    } catch { return $false }
}

function Invoke-ZipArchive {
    param(
        [string]$SourcePath,
        [string]$Destination,
        [string]$CompressionLevel,
        [hashtable]$ResolvedTool,
        [switch]$IncludeRoot
    )

    if (-not (Test-Path -LiteralPath $SourcePath)) {
        throw "SourcePath 不存在: $SourcePath"
    }
    if (Test-Path -LiteralPath $Destination) { Remove-Item -LiteralPath $Destination -Force }

    $isFile = Test-Path -LiteralPath $SourcePath -PathType Leaf

    switch ($ResolvedTool.Name) {
        'SevenZip' {
            $mx = switch ($CompressionLevel) { 'Optimal' {9} 'NoCompression' {0} default {3} }
            if ($isFile) {
                $fileName = Split-Path $SourcePath -Leaf
                $parent   = Split-Path $SourcePath -Parent
                $zipArgs = @('a','-tzip',"-mx=$mx",$Destination,$fileName)
                $proc = Start-Process -FilePath $ResolvedTool.Path -ArgumentList $zipArgs -Wait -PassThru -NoNewWindow -WorkingDirectory $parent
                if ($proc.ExitCode -ne 0) { throw "7-Zip 压缩文件失败，退出码 $($proc.ExitCode)" }
            } else {
                if ($IncludeRoot) {
                    $leaf = Split-Path $SourcePath -Leaf
                    $parent = Split-Path $SourcePath -Parent
                    $zipArgs = @('a','-tzip',"-mx=$mx",$Destination,$leaf)
                    $proc = Start-Process -FilePath $ResolvedTool.Path -ArgumentList $zipArgs -Wait -PassThru -NoNewWindow -WorkingDirectory $parent
                    if ($proc.ExitCode -ne 0) { throw "7-Zip 压缩目录失败，退出码 $($proc.ExitCode)" }
                } else {
                    Push-Location $SourcePath
                    try {
                        $zipArgs = @('a','-tzip',"-mx=$mx",$Destination,'*')
                        $proc = Start-Process -FilePath $ResolvedTool.Path -ArgumentList $zipArgs -Wait -PassThru -NoNewWindow
                        if ($proc.ExitCode -ne 0) { throw "7-Zip 压缩目录内容失败，退出码 $($proc.ExitCode)" }
                    } finally { Pop-Location | Out-Null }
                }
            }
        }
        'Tar' {
            if ($isFile) {
                $fileName = Split-Path $SourcePath -Leaf
                $parent   = Split-Path $SourcePath -Parent
                $zipArgs = @('-a','-c','-f',$Destination,'-C',$parent,$fileName)
                $proc = Start-Process -FilePath $ResolvedTool.Path -ArgumentList $zipArgs -Wait -PassThru -NoNewWindow
                if ($proc.ExitCode -ne 0) { throw "tar 压缩文件失败，退出码 $($proc.ExitCode)" }
            } else {
                $leaf = Split-Path $SourcePath -Leaf
                $parent = Split-Path $SourcePath -Parent
                if ($IncludeRoot) {
                    $zipArgs = @('-a','-c','-f',$Destination,'-C',$parent,$leaf)
                } else {
                    # 仅目录内容：在目录下打包 .
                    $zipArgs = @('-a','-c','-f',$Destination,'-C',$SourcePath,'.')
                }
                $proc = Start-Process -FilePath $ResolvedTool.Path -ArgumentList $zipArgs -Wait -PassThru -NoNewWindow
                if ($proc.ExitCode -ne 0) { throw "tar 压缩目录失败，退出码 $($proc.ExitCode)" }
            }
        }
        'CompressArchive' {
            if ($isFile) {
                Compress-Archive -Path $SourcePath -DestinationPath $Destination -Force -CompressionLevel $CompressionLevel
            } else {
                if ($IncludeRoot) {
                    Compress-Archive -Path $SourcePath -DestinationPath $Destination -Force -CompressionLevel $CompressionLevel
                } else {
                    Compress-Archive -Path (Join-Path $SourcePath '*') -DestinationPath $Destination -Force -CompressionLevel $CompressionLevel
                }
            }
        }
        default { throw "未实现的压缩工具: $($ResolvedTool.Name)" }
    }
}

# 归一化输入/默认输出路径
$SourcePath = (Resolve-Path -LiteralPath $SourcePath).Path
if (-not $DestinationZip) {
    $leaf = Split-Path $SourcePath -Leaf
    $parent = Split-Path $SourcePath -Parent
    $DestinationZip = Join-Path $parent ("{0}.zip" -f $leaf)
}
$destParent = Split-Path $DestinationZip -Parent
$destLeaf = Split-Path $DestinationZip -Leaf
if ([string]::IsNullOrWhiteSpace($destParent)) { $destParent = (Get-Location).Path }
$resolvedParent = $null
try { $resolvedParent = (Resolve-Path -LiteralPath $destParent -ErrorAction Stop).Path } catch { $resolvedParent = $destParent }
$DestinationZip = Join-Path $resolvedParent $destLeaf

# 压缩
$tool = Resolve-ZipTool -Preference $ZipTool
Write-Host ("[信息] 压缩源: {0}" -f $SourcePath) -ForegroundColor Cyan
Write-Host ("[信息] 输出 ZIP: {0}" -f $DestinationZip) -ForegroundColor Cyan
Write-Host ("[信息] 压缩工具: {0} (CompressionLevel={1})" -f $tool.Name, $CompressionLevel) -ForegroundColor Cyan

$sw = [System.Diagnostics.Stopwatch]::StartNew()
Invoke-ZipArchive -SourcePath $SourcePath -Destination $DestinationZip -CompressionLevel $CompressionLevel -ResolvedTool $tool -IncludeRoot:$IncludeRoot
$sw.Stop()

# 校验
if (-not (Test-Path -LiteralPath $DestinationZip)) { throw "未生成 ZIP 文件: $DestinationZip" }
$nonEmpty = Test-ZipHasEntries -ZipPath $DestinationZip
$size = (Get-Item -LiteralPath $DestinationZip).Length

if (-not $nonEmpty) {
    Write-Host ("[失败] ZIP 为空，文件大小 {0}" -f (Format-Bytes $size)) -ForegroundColor Red
    exit 2
}

Write-Host ("[成功] ZIP 生成完成，大小 {0}，耗时 {1}" -f (Format-Bytes $size), $sw.Elapsed.ToString('mm\:ss')) -ForegroundColor Green
exit 0
