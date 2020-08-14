
class FileSystem {
    
    static [string]IllegalCharacter([string]$filename)
    {
        $IllegalCharacters = @("`"","<",">",":","/","\","|","?","*")

        foreach ($IllegalCharacter in $IllegalCharacters) {
            $filename = $filename.replace($IllegalCharacter, "")
        }
        return $filename
    }

    static Rename([string]$OldFilename, [string]$NewFileName)
    {

        try {
            Rename-Item -Path $OldFilename -NewName $NewFileName -ErrorAction stop
        }
        catch {
            ErrorStop "Could not rename File: $OldFilename"
        }
    }

    static Remove([string]$Filename)
    {

        try {
            Remove-Item -Path $Filename -ErrorAction stop
        }
        catch {
            ErrorStop "Could not delete File: $Filename"
        }
    }

    static CreateFolder([string]$FolderName)
    {
        if (!$(Test-Path -Path $FolderName -PathType Container )) { 

            try {
                New-Item -path $FolderName -ItemType directory -ErrorAction stop
            }
            catch {
                ErrorStop "Could not create Folder: $FolderName"
            }
            
        }
    }

    static [boolean]FileExists([string]$Filename)
    {

        if (Test-Path -Path $Filename -PathType Leaf ) { 

            return $true
        }
        else {
            return $false
        }
    }
    
}