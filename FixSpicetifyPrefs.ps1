function Set-SpicePaths {
     if (-not [System.IO.File]::Exists("$($env:APPDATA)\Spotify\Spotify.exe")){
        Write-Host ""
        Write-Host ">  Seems like you have installed Microsoft Store Version of Spotify. Please install desktop version." -ForegroundColor DarkRed
        Write-Host ""
        Write-Host "Do you want to be redirected to download page? (Y/N)"
        if ((Read-Host) -eq 'Y') {
            Start-Process "https://www.spotify.com/us/download/windows/"
        }
    }

    $configPath = "${HOME}\.spicetify\config-xpui.ini"

    Write-Host ""
    Write-Host ">  Looking for config file..."
    Write-Host ""

    if (-not [System.IO.File]::Exists($configPath)) {
        Write-Host "Couldn't find config file. Check if spicetify is installed properly." -ForegroundColor Red
        return
    }

    Write-Done -Message "Found config file. Writing values..."

    $spicetifyConfig = Get-IniContent -FilePath $configPath

    $spicetifyConfig.Setting.spotify_path = $env:APPDATA + "\Spotify"

    $spicetifyConfig.Setting.prefs_path = $env:APPDATA + "\Spotify\prefs"

    Write-IniContent -InputObject $spicetifyConfig -file $configPath

    Write-Done -Message "Fixed config file. Do you want to apply spicetify now? (Y/N)"

    if ((Read-Host) -eq 'Y'){
        if ((Get-Process).ProcessName -contains 'Spotify') {
            Write-Verbose -Message "Stopping Spotify..."
            Stop-Process -Name 'Spotify' -Force
        }
        try { 
            spicetify -v | Out-Null
        }
        catch {
            Write-Host "Couldn't find 'spicetify'. Check if it is installed correctly!" -ForegroundColor Red
            return
        }

        spicetify upgrade

        spicetify backup

        spicetify apply
    }
}

function Get-IniContent {
    param(
        [Parameter(Mandatory)]
        [string]
        $FilePath
    )

    $ini = @{}
    switch -regex -file $FilePath
    {
        “^\[(.+)\]” # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        “^(;.*)$” # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = “Comment” + $CommentCount
            $ini[$section][$name] = $value
        }
        “(.+?)\s*=(.*)” # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

function Write-IniContent {
    param(
        [Parameter(Mandatory)]
        [hashtable]
        $InputObject,
        [Parameter(Mandatory)]
        [string]
        $FilePath
    )
    
    if (-not [System.IO.File]::Exists($FilePath))
    {
        New-Item $FilePath.Replace('\\[^\\]+$', '') -Name $FilePath.Replace('^(.+)\\([^\\]+?)$', '$2') -Value ''
    }else {
        Clear-Content $FilePath
    }
    
    foreach ($i in $InputObject.keys)
    {
        if (!($($InputObject[$i].GetType().Name) -eq “Hashtable”))
        {
            #No Sections
            Add-Content -Path $FilePath -Value “$i=$($InputObject[$i])”
        } else {
            #Sections
            Add-Content -Path $FilePath -Value “[$i]”
            Foreach ($j in ($InputObject[$i].keys | Sort-Object))
            {
                if ($j -match “^Comment[\d]+”) {
                    Add-Content -Path $FilePath -Value “$($InputObject[$i][$j])”
                } else {
                    Add-Content -Path $FilePath -Value “$j=$($InputObject[$i][$j])”
                }

            }
            Add-Content -Path $FilePath -Value “”
        }
    }
}

function Write-Done {
    param(
        [Parameter(Mandatory)]
        [string]
        $message
    )

    Write-Host '>  ' -NoNewline -ForegroundColor Green
    Write-Host $message -ForegroundColor Green
    Write-Host ''
}

Set-SpicePaths
