Class Torrent{
    [string]$Title
    [string]$Url
}

while(1){
    del .\File.torrent -ErrorAction SilentlyContinue
    Write-Host 'What movie would you like to download? ' -foregroundcolor "Cyan" -NoNewline
    $search=  Read-Host
    if($search -ne ""){
        $search = $search.Replace(" ","%20")
        $xmlContent = [xml]($(curl "https://yts.ag/rss/$search/1080p/all/0").content)
        [System.Collections.ArrayList]$finalList = @();$i = 0
        foreach ($element in $xmlContent.rss.channel.item){ 
            $torrent = New-Object Torrent
            $i++
            if($element.enclosure.url){
                $torrent.Title = [string]$element.title.'#cdata-section'
                Write-Host $i : $torrent.Title -foregroundcolor "Green"
                $torrent.Url = [string]$element.enclosure.url
                $finalList.Add($torrent) | Out-Null
            }
        }
        if($finalList.Count -gt 1){
            try{
                Write-Host 'Please enter a number for the movie above: ' -foregroundcolor "Magenta" -NoNewline
                $num =  [int](Read-Host) #Prompt if there is more than one item found
                if($num -lt 1){ Write-Host "That wasn't a number, idiot" -foregroundcolor "Red"}
                Write-Host $finalList[($num-1)].Url
                wget $finalList[($num-1)].Url -OutFile File.torrent #We need this to get the torrent file from the rss feed url
                Invoke-Item .\File.torrent #Opens torrent with default client
            }catch{
                Write-Host "Failed in download! File may no longer be available!" -foregroundcolor "Red"
            }
        }elseif($finalList.Count -eq 1){
            try{
                wget $finalList[0].Url -OutFile File.torrent #We need this to get the torrent file from the rss feed url
                Invoke-Item .\File.torrent #Opens torrent with default client
            }catch {
                Write-Host "Failed in download! File may no longer be available!" -foregroundcolor "Red"
            }
        }elseif($finalList.Count -eq 0){
            Write-Host "No Movies Found!" -foregroundcolor "Red"
        }
    }
}