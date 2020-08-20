function Remove-File {
    param (
        [string] $FileName
    )
    if (Test-Path "$FileName") {
        Remove-Item "$FileName"
        return 1
    }
    else {
        return 0
    }
}

function New-RobotsTxt {
    param (
        [string[]] $Array,
        [bool] $BlockList
    )

    $target = ""
    if ($BlockList) {
        $target = "./result/robots-block.txt"
    } else {
        $target = "./result/robots-allow.txt"
    }

    Remove-File $target             | Out-Null
    New-Item $target -ItemType File | Out-Null

    $config = "User-agent:"
    $Array | ForEach-Object {
        $config += $_ + ","
    }
    $config = $config.Substring(0, $config.Length - 1)

    if ($BlockList) {
        $config += "`nDisallow: /"
    } else {
        $config += "`nAllow: /"
    }

    [IO.File]::WriteAllText("$target", "$config")
}

$BlockSet = @()
$AllowSet = @()
$NeutralSet = @()

$BlockTxtPath = "./result/block.txt"
$AllowTxtPath = "./result/allow.txt"
$NeutralTxtPath = "./result/neutral.txt"
$RawTxtPath = "./raw.txt"

if (!(Test-Path "./result")) {
    New-Item "result" -ItemType Directory | Out-Null
}

$RawDataArray = [IO.File]::ReadAllLines("$RawTxtPath") | Sort-Object

Remove-File "$BlockTxtPath"   | Out-Null
Remove-File "$AllowTxtPath"   | Out-Null
Remove-File "$NeutralTxtPath" | Out-Null

New-Item "$BlockTxtPath"   -ItemType File | Out-Null
New-Item "$AllowTxtPath"   -ItemType File | Out-Null
New-Item "$NeutralTxtPath" -ItemType File | Out-Null

$RawDataArray | ForEach-Object {
    if (!$_.StartsWith("#") -and $_.Trim() -ne "") {
        $v = $_.Split(':')
        switch ($v.Length) {
            1 {
                $NeutralSet += $v[0].Trim()
                break
            }
            2 {
                switch ($v[1].Trim().SubString(0, 1).ToLower()) {
                    "a" {
                        $AllowSet += $v[0].Trim()
                        break
                    }
                    "n" {
                        $NeutralSet += $v[0].Trim()
                        break
                    }
                    "b" {
                        $BlockSet += $v[0].Trim()
                        break
                    }
                    default {
                        Write-Output "Unknown input: $v"
                        break
                    }
                }
                break
            }
            default {
                Write-Output "Unknown input: $v"
                break
            }
        }
    }
}

[IO.File]::WriteAllLines("$BlockTxtPath"  , $BlockSet  )
[IO.File]::WriteAllLines("$AllowTxtPath"  , $AllowSet  )
[IO.File]::WriteAllLines("$NeutralTxtPath", $NeutralSet)

New-RobotsTxt $AllowSet 0
New-RobotsTxt $BlockSet 1