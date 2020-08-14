#title           :export_maps.ps1
#description     :Cisco Prime Map Export - Version 3.7
#author          :pieewiee
#licence         :WTFPL
#date            :2020-08-14
#version         :1.0
#usage           :powershell -f export_maps.ps1 -campus
#notes           :
#powershell_version    :5.1.15063.1478
#==============================================================================

using module '.\modules\logging.psm1'
using module '.\modules\WebRequest.psm1'
using module '.\modules\FileSystem.psm1'
using module '.\modules\ImageHandler.psm1'

param(
    [string]$Campus
)

$global:scriptpath = $MyInvocation.MyCommand.Path
$global:Dir = Split-Path $global:scriptpath
$global:DirConfig = "$Dir\config"
$global:ImageDir = "$Dir\maps\"

$global:config = Get-Content "$DirConfig\config.json" | ConvertFrom-Json


if (!$config) {
    Write-Error "No Valid Config File"
    exit
}


$logging = [logging]::new($config.logging, $global:Dir) #init class logparameters are seperated by tabstop
$logging.create() #creates logfile if not created 


Function ErrorStop($message)
{
    $logging.writelog("Error", $message)
}


$webrequest = [webrequest]::new($config.Cprime.headerLogin, "$($config.Domain)$($config.cprime.logout)", "Post")

$webrequest.sendBody("$($config.Domain)$($config.cprime.login)", "j_username=$($config.username)&j_password=$($config.password)" + $config.cprime.LoginPayload) > $null
$webrequest.HasBody($false)


$sites = $webrequest.send("$($config.Domain)$($config.cprime.sites)") | ConvertFrom-Json
$sites = $sites.items | Where-Object { $_.name -eq $global:Campus }

if ($null -eq $sites.id)
{
    $webrequest.send("$($config.Domain)$($config.cprime.logout)") > $null
    $logging.writelog("Error", "No valid Campus found")
    write-host "No valid Campus found"
    exit
}

[FileSystem]::CreateFolder("$ImageDir\$global:Campus") 


# --- Loop through all buildings ---
$buildings = $webrequest.send("$($config.Domain)$($config.cprime.Domains.replace("{id}", $sites.id))") | ConvertFrom-Json


foreach ($building in $buildings.items) {

        $image_path = "$($ImageDir)$($global:Campus)\$([FileSystem]::IllegalCharacter($building.name))"
        [FileSystem]::CreateFolder($image_path) 

        # --- Loop through all building levels ---
        $levels = $webrequest.send("$($config.Domain)$($config.cprime.Domains.replace("{id}", $building.id))") | ConvertFrom-Json
        foreach ($level in $levels.items) {

            $image_name = [FileSystem]::IllegalCharacter($level.name) + ".png"
            $image_new = [FileSystem]::IllegalCharacter($level.name) + "_new.png"

            if (!$([FileSystem]::FileExists("$image_path/$image_name"))) { 
                $webrequest.Download("$($config.Domain)/webacs$($level.image)", "$($image_path)\$($image_name)")
            }


            $NewMap = [System.Drawing.Image]::FromFile("$image_path/$image_name")

            if ($NewMap.PixelFormat -ne "Format24bppRgb")
            {
                $image_name_temp = $image_name.Replace(".png","temp.png");
                $NewMap.Save("$image_path/$image_name_temp", [System.Drawing.Imaging.ImageFormat]::jpeg);
            
                $NewMap.Dispose(); 
                [FileSystem]::Remove($("$image_path/$image_name"))
                [FileSystem]::Rename($("$image_path/$image_name_temp"), $("$image_path/$image_name"))
        
                $NewMap = [System.Drawing.Image]::FromFile("$image_path/$image_name")
            }

            # Setup Image and Calculate Accesspoints Positions
            $graphics = [System.Drawing.Graphics]::FromImage($NewMap)
            $ImageHandler = [ImageHandler]::new($NewMap.Width, $NewMap.Height, $level.geometry.width, $level.geometry.length)

            # Setup Font and Brush
            $font = new-object System.Drawing.Font("Consolas", $ImageHandler.FontZize(), "Bold", "Pixel")
            $brushFg = [System.Drawing.Brushes]::red

            $AccesPoints = $webrequest.send("$($config.Domain)$($config.cprime.AccessPoints.replace("{id}", $level.id))") | ConvertFrom-Json

            # --- Loop through Access Points ---
            foreach ($AccesPoint in $AccesPoints.items) {

                $graphics.DrawString($AccesPoint.attributes.name, $font, $brushFg, $ImageHandler.APPos($AccesPoint.position)[0], $ImageHandler.APPos($AccesPoint.position)[1])
                $graphics.FillRectangle($brushFg, $ImageHandler.APPos($AccesPoint.position)[2], $ImageHandler.APPos($AccesPoint.position)[3], $ImageHandler.PointSize(), $ImageHandler.PointSize())

            }
            $NewMap.Save("$image_path/$image_new")
            $NewMap.Dispose()
            $graphics.Dispose()
        }
}


$webrequest.send("$($config.Domain)$($config.cprime.logout)") > $null