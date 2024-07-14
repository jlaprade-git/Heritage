# in/out
$inputFile = "C:\temp\ip_addresses.csv"
$outputFile = "C:\temp\geolocated_ips.csv"
$logFile = "C:\temp\geolocation_log.txt"

# ipapi
$API_KEY = "CHANGEME"

# Logger
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

# geolocate function
function Get-Geolocation {
    param (
        [string]$ip
    )
    try {
        $url = "https://ipapi.co/$ip/json/?key=$API_KEY"
        $response = Invoke-RestMethod -Uri $url -Method Get
        return $response
    } catch {
        Log-Message ("Error fetching data for IP {0}: {1}" -f $ip, $_.Exception.Message)
        return $null
    }
}

# Init logging
Log-Message "Starting geolocation lookup."

# Read the input CSV, process each IP, and write results to the output CSV
$ipAddresses = Get-Content -Path $inputFile

# Check if output file exists, if not create it and add headers
if (-Not (Test-Path $outputFile)) {
    $headers = "IP,City,Region,Region_Code,Country_Name,Latitude,Longitude"
    $headers | Out-File -FilePath $outputFile
}

foreach ($ip in $ipAddresses) {
    $trimmedIP = $ip.Trim()
    if (-not [string]::IsNullOrWhiteSpace($trimmedIP)) {
        Log-Message ("Processing IP: {0}" -f $trimmedIP)
        $geoData = Get-Geolocation -ip $trimmedIP
        
        # response logger because the api was failing
        if ($geoData) {
            Log-Message "Full geolocation data for IP {0}: {1}" -f $trimmedIP, ($geoData | ConvertTo-Json -Depth 4)
        }

        if ($geoData -and -not $geoData.error) {
            $result = [PSCustomObject]@{
                IP           = $trimmedIP
                City         = $geoData.city
                Region       = $geoData.region
                Region_Code  = $geoData.region_code
                Country_Name = $geoData.country_name
                Latitude     = $geoData.latitude
                Longitude    = $geoData.longitude
            }
            # Append result to CSV file
            $resultLine = "$($result.IP),$($result.City),$($result.Region),$($result.Region_Code),$($result.Country_Name),$($result.Latitude),$($result.Longitude)"
            $resultLine | Out-File -FilePath $outputFile -Append
            Log-Message ("Successfully processed IP: {0}" -f $trimmedIP)
        } else {
            Log-Message ("Failed to process IP: {0}" -f $trimmedIP)
        }
    } else {
        Log-Message "Skipping empty or whitespace IP entry."
    }
}

Log-Message "Geolocation lookup completed. Results saved to $outputFile"
Write-Host "Geolocation lookup completed. Results saved to $outputFile"
