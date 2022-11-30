Param
(
   [Parameter(Mandatory=$false)]
     [String] $imgSource
)

#measure perf
$scriptStartTime = $(Get-Date)

#destination (hosting via IIS, locally, so this will change as you see fit)
$imgDestBase = "C:\dump"
$dumpUrlBase = "https://sunset.sidetime.org/temp"

#get image resolution via System.Drawing and hash via Get-FileHash
add-type -AssemblyName System.Drawing
$imgData = New-Object System.Drawing.Bitmap $imgSource
$imgHash = Get-FileHash $imgSource
$hashSuffix = $imgHash.Hash.Substring(0,5)

#get image file details
$imgProps = Get-ItemProperty $imgSource
$imgDest = "$($imgDestBase)\$($hashSuffix.ToLower())$($imgProps.Extension.ToLower())"
$imgUrl = "$($dumpUrlBase)/$($hashSuffix.ToLower())$($imgProps.Extension.ToLower())"
$imgUrlHTML = "$($dumpUrlBase)/$($hashSuffix.ToLower()).html"

#format some data for display in html
$imgPixels = "$([math]::Round(($imgData.Height * $imgData.Width) / 1000000, "2")) MP"
$imgSize =  "$([math]::Round(($imgProps.Length) / 1000000, "2")) MB"

#copy image over
Copy-Item -Path $imgSource -Destination $imgDest

#thumbnail
$thumbDest = "$($imgDestBase)\$($hashSuffix.ToLower())-thumb$($imgProps.Extension.ToLower())"
& C:\tools\ImageMagick\convert.exe $imgSource -resize 800x800 $thumbDest
$imgThumbUrl = "$($dumpUrlBase)/$($hashSuffix.ToLower())-thumb$($imgProps.Extension.ToLower())"

#thumb info
$thumbProps = Get-ItemProperty $thumbDest
$thumbSize =  "$([math]::Round(($thumbProps.Length) / 1000000, "2")) MB"

#thumb color info
$primaryColor = & C:\tools\ImageMagick\convert.exe $thumbDest -resize 1x1 txt:- | Out-String
$bgColor = $primaryColor.Split("#")[2].Substring(0,6)

# process time
$scriptEndTime = $(Get-Date)
$scriptRunTime = ($scriptEndTime - $scriptStartTime)
$scriptRunTimeSeconds = [math]::round($scriptRunTime.TotalSeconds,"2")

#html to use for image landing page
#img html
$imgHtml = @"
<html style='background-color: #$($bgColor)'>
    <head>
        <title>Temp</title>
        <meta charset='utf-8'>
            <style>
        * {
            margin: 0;
            padding: 0;
        }
        .imgbox {

            height: 100%;
        }
        .center-fit {
            max-width: 100%;
            max-height: 100vh;
            margin: auto;
        }
    </style>
    </head>
    <body style='color: white; font-family: Helvetica,Arial,sans-serif;'>
        <div style='padding: 0.5em; text-align: center'>
            <p style='font-size: 1.5em;
                margin: 0;
                margin-top: 0.5em;
                margin-bottom: 0.5em;'>
                Compressed version below - Click image to load <a href="$($imgUrl)" style="color: white">original</a>.
                <div class="imgbox">
                 <a href="$($imgUrl)"><img class="center-fit" src="$($imgThumbUrl)"></a>
                 <br><br>original name: $($imgProps.Name), resolution: $($imgPixels), size: $($imgSize) (preview size: $($thumbSize)) <br><br>** initial task processed in $($scriptRunTimeSeconds) seconds
                </div>         
            </p>
        </div>
    </body>
</html>
"@

#write out html
$imgHtml | Out-File "$($imgDestBase)\$($hashSuffix.ToLower()).html" -Force

#set clipboard with link for quick sharing
Set-Clipboard -Value "$imgUrlHTML"
