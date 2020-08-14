class WebRequest {
    

    [string]$url
    [string]$LogoutUrl
    [System.Collections.Hashtable]$header
    [String]$body
    [String]$Method
    [System.Object]$session

    WebRequest($header, $LogoutUrl, $Method)
    {
        $this.header = @{ }
        $header.psobject.properties | Foreach-Object { $this.header[$_.Name] = $_.Value }
        $this.Method = $Method
        $this.LogoutUrl = $LogoutUrl
        $this.session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }
    WebRequest($Method, $LogoutUrl)
    {
        $this.Method = $Method
        $this.LogoutUrl = $LogoutUrl
        $this.session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }

    HasBody([boolean]$Method)
    {
        if ($Method)
        {
            $this.Method = "Post"
        }
        else {
            $this.Method = "Get"
        }
    }

    SetHeader($header)
    {
        $this.header = @{ }
        $header.psobject.properties | Foreach-Object { $this.header[$_.Name] = $_.Value }
    }
    

    [String]send([string]$url) {

        $response = try {

            [system.Text.Encoding]::UTF8.GetString((Invoke-WebRequest -Method $this.Method -Uri $url -header $this.header -WebSession $this.session -TimeoutSec 900 -ErrorAction Stop).RawContentStream.ToArray())
        }
        catch [System.Net.WebException]{
            ErrorStop "$url --> $($_.Exception.Response.statusCode)"
        }

        return $response
    }

    [String]sendBody([string]$url, $body) {

        $this.HasBody($true)

        $response = try {

            (Invoke-WebRequest -Method $this.Method -Uri $url -body $body -header $this.header -WebSession $this.session -TimeoutSec 900 -ErrorAction Stop)
        }
        catch [System.Net.WebException]{
            ErrorStop "$url --> $($_.Exception.Response.statusCode)" 
        }

        return $response
    }

    [String]Download([string]$url, [string]$path) {

        $response = try {

            (Invoke-WebRequest -Method $this.Method -Uri $url -header $this.header -WebSession $this.session -TimeoutSec 10 -OutFile $path -ErrorAction Stop)
        }
        catch [System.Net.WebException]{
            ErrorStop "$url --> $($_.Exception.Response.statusCode)"
        }

        return $response
    }


}