# Cisco Prime Map export tool
This tool will export Cisco Prime maps and draw Wireless access points. 

![alt text](https://github.com/pieewiee/CiscoPrimeMapExport/blob/master/maps/exmaple.png?raw=true "example")


## Features: 
-	loop through a whole Cisco prime site
-	export as image file
-	draw all wireless Access Points and the names
-	Supported Version: Cisco Prime 3.7v


## How To Use:
At first you need to edit the config file and specify your cisco prime domain and credentials. See messages.log file for debugging purposes.
#### 
```powershell
powershell -f export_maps.ps1 -campus "your campus"
```


## Config:
the config is a json file located in the config folder.
#### 
```json
{
    "Domain": "https://your.cisco.prime",
    "username": "username",
    "password": "password",
}
```
