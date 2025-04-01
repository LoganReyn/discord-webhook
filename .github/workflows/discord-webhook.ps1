# 
# Schnookems Webhook for Discord Channel "weeno-chat"
# 

###### URL'S ###################
$DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1350904669521842236/KW0RJA3FxFJBcFqaruy2eOaNOPUIDbu-AxBTFBC9bRtSkjyjx5W9Kmfpr2NZSqWzeO9R"
$BIBLEVERSEAPI   = "https://bible-api.com/data/web/random"
###########################
function Get-RandomVerse {

    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$True)]
        [string]$VerseUrl
    )

    try {
        $Verse = Invoke-RestMethod -Uri "$VerseUrl" -Method Get -ErrorAction Stop
        Write-Verbose "[Got the Verse!]"
        return $Verse
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "ERM . . [$_]"
    }
}

function Format-Message {

    [CmdLetBinding()]
    param(
        [Parameter (Mandatory=$True)]
        [PSCustomObject]$VerseData
    )

    try {
        # String Extraction
        $Location = "$($VerseData.book) $($VerseData.chapter):$($VerseData.verse)"
        $Text = $VerseData.text
        
        $Message = "**Out of the hat came this one . . .** `n`n`n$($Text)_~$($Location)~_ `n`n`n Does this surprise you? `n"

        $Content = @{
            content = $Message
        }

        # Convert to JSON
        $ContentJson = $Content | ConvertTo-Json -Depth 3
        Return $ContentJson
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "ERMs . . [$_]"
    }
}

function Send-ToDiscord {

    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$True)]
        [string]$DiscordUrl,

        [Parameter (Mandatory=$True)]
        [string]$content
    )

    Write-Verbose $content

    try {
        Invoke-RestMethod -Uri "$DiscordUrl" -Method Post -ContentType 'application/json' -Body $content -ErrorAction Stop
        Write-Verbose "[Content Sent!]"
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "ERM . . [$_]"
    }
}


# 'Get' response from API
$TheGoods = Get-RandomVerse -Verbose -VerseUrl $BIBLEVERSEAPI | Select-Object -ExpandProperty random_verse

# Formating payload
$Message = Format-Message -VerseData $TheGoods

# Sending payload to Discord
Send-ToDiscord -DiscordUrl $DISCORD_WEBHOOK -content $Message -Verbose
