class logging {
    [string]$filepath
    [array]$levels
    [String]$level
    [string]$message
    [string]$dateFormat
    [string]$mode
    [string]$computer
    [string]$user

    logging([psobject]$config, $dir) {
        $this.filepath = "$($global:dir)\$($config.filename)"
        $this.levels = $config.LogTypes
        $this.level = $config.LogTypes[0]
        $this.dateFormat = $config.DateFormat
        $this.mode = "default"
        $this.user = $env:UserName
        $this.computer = $env:ComputerName
    }
    create() {
        if (!(Test-Path $this.filepath)) {
            New-Item $this.filepath > $null
        }
    }
    SetLogLevel([String]$CurrentLoglevel) {
        if ($CurrentLoglevel -in $this.levels) {
            $this.level = $CurrentLoglevel
        }
    }
    hidden [boolean]GetLogLevel([String]$CurrentLoglevel) {
        if ($CurrentLoglevel -in $this.levels) {
            return $true
        }
        else { return $false }
        
    }

    Writelog([String]$message) {
        if ($null -ne $message) {
            $Line = "$($this.SettimeStamp())	$($this.Level)	$message"
            SET-Content -Path $this.filepath -Value "$line`n$(Get-Content $this.filepath)`n"
        }
    }
    Writelog([String]$loglevel, [String]$Message) {

        if (($null -ne $message) -and $this.GetLoglevel($loglevel)) {
            $Line = "$($this.SettimeStamp())	$($loglevel)	$Message"
            Set-Content -NoNewline -Path $this.filepath -Value "$line`n$(Get-Content $this.filepath -RAW)"
        }
    }

    WritelogDetail([String]$loglevel, [String]$Message) {

        if (($null -ne $message) -and $this.GetLoglevel($loglevel)) {
            $Line = "$($this.SettimeStamp())	$($this.computer)	$($this.user)	$($this.mode)	$($loglevel)	$Message"
            Set-Content -NoNewline -Path $this.filepath -Value "$line`n$(Get-Content $this.filepath -RAW)"
        }
    }

    Setmode([String]$mode) {
        $this.mode = $mode
    }


    hidden [string]SettimeStamp() {
        return (Get-Date).toString($this.dateFormat)
    }


}