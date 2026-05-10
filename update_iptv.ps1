# 进入仓库目录
cd D:\Temp\iptv\iptv-api

Write-Host ""
Write-Host "=== Generate IPTV locally ==="
Write-Host ""

py -m pipenv run dev

Write-Host ""
Write-Host "=== Copy result files ==="
Write-Host ""

copy .\output\result.m3u .\result.m3u
copy .\output\epg\epg.gz .\epg.gz
copy .\output\epg\epg.xml .\epg.xml

Write-Host ""
Write-Host "=== Fix EPG URL in result.m3u ==="
Write-Host ""

$targetEpgUrl = "https://seudyjp.github.io/iptv-api/epg.gz"
$content = Get-Content .\result.m3u -Raw -Encoding UTF8

$content = $content -replace 'x-tvg-url="[^"]+"', "x-tvg-url=`"$targetEpgUrl`""

Set-Content .\result.m3u -Value $content -Encoding UTF8

$firstLine = Get-Content .\result.m3u -TotalCount 1
Write-Host "Current first line:"
Write-Host $firstLine

if ($firstLine -notmatch [regex]::Escape($targetEpgUrl)) {
    Write-Error "EPG URL replacement failed. Stop."
    exit 1
}

Write-Host ""
Write-Host "=== Git push ==="
Write-Host ""

git add .
git commit -m "Update local IPTV result"
git push

Write-Host ""
Write-Host "=== Finished ==="
Write-Host ""