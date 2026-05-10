cd D:\Temp\iptv\iptv-api

Write-Host "`n=== Generate IPTV locally ===`n"
py -m pipenv run dev

Write-Host "`n=== Copy result files ===`n"
Copy-Item .\output\result.m3u .\result.m3u -Force
Copy-Item .\output\epg\epg.gz .\epg.gz -Force
Copy-Item .\output\epg\epg.xml .\epg.xml -Force

Write-Host "`n=== Fix EPG URL in result.m3u ===`n"
$targetEpgUrl = "https://seudyjp.github.io/iptv-api/epg.gz"
$lines = Get-Content .\result.m3u -Encoding UTF8

if ($lines[0] -match '^#EXTM3U') {
    $lines[0] = '#EXTM3U x-tvg-url="' + $targetEpgUrl + '"'
} else {
    Write-Error "result.m3u first line is not #EXTM3U. Stop."
    exit 1
}

Set-Content .\result.m3u -Value $lines -Encoding UTF8

Write-Host "Fixed first line:"
Get-Content .\result.m3u -TotalCount 1

Write-Host "`n=== Git commit and push ===`n"
git add .

$status = git status --porcelain
if ($status) {
    git commit -m "Update local IPTV result"
    git push
} else {
    Write-Host "No changes to commit."
}

Write-Host "`n=== Finished ===`n"