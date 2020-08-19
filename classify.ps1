function Remove-File {
    param (
        [string]$FileName
    )
    if (Test-Path "$FileName") {
        Remove-Item "$FileName"
        return 1
    }
    else {
        return 0
    }
}

$BlockSet = @()
$AllowSet = @()
$NeutralSet = @()

$RawDataArray = [IO.File]::ReadAllLines(".\raw.txt") | Sort-Object

Remove-File "./block.txt"   | Out-Null
Remove-File "./allow.txt"   | Out-Null
Remove-File "./neutral.txt" | Out-Null

New-Item "./block.txt"   -ItemType File | Out-Null
New-Item "./allow.txt"   -ItemType File | Out-Null
New-Item "./neutral.txt" -ItemType File | Out-Null

$RawDataArray | ForEach-Object {
    if (!$_.StartsWith("#") -and $_.Trim() -ne "") {
        $v = $_.Split(':')
        switch ($v.Length) {
            1 {
                $NeutralSet += $v[0].Trim()
                break
            }
            2 {
                switch ($v[1].Trim().SubString(0, 1)) {
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
                        Write-Output "Unknown input"
                        break
                    }
                }
                break
            }
            default {
                Write-Output "Unknown input"
                break
            }
        }
    }
}

[IO.File]::WriteAllLines("./block.txt"  , $BlockSet  )
[IO.File]::WriteAllLines("./allow.txt"  , $AllowSet  )
[IO.File]::WriteAllLines("./neutral.txt", $NeutralSet)
