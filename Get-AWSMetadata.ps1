<#
************************************************************************************************************************
FileName.....: Get-AWSMetadata.ps1
CreatedDate..: 05/06/2025 (DD/MM/YYYY)
Creator......: Timothy Lo
Synopsis.....: Retrieve EC2 instance metadata in JSON format.
Description..: This script queries AWS EC2 instance metadata and returns all data in JSON format,
.............: or a specific value when a key is provided as input.
Parameter Key: (Optional) The metadata key to retrieve (e.g., 'hostname', 'instance-id').
Usage........: .\Get-AWSMetadata.ps1
.............: .\Get-AWSMetadata.ps1 -Key "hostname"
Error Return.: E1) Invoke-RestMethod : Unable to connect to the remote server
.............: E2) Error retrieving value
.............: E3) Key '$RequestedKey' not found or unreachable.
Resolution...: - The metadata URL http://169.254.169.254/latest/meta-data/ is accessible only within an EC2 instance. 
.............: If you try it from outside (e.g., local laptop), it won't work as expected.
.............: Even, by using AWS PowerShell Cmdlets like Get-EC2Instance (get data from AWS API)
.............: Or, IMDSv2 token-based metadata URLs (like http://169.254.169.254/latest/meta-data/)
.............: If running inside AWS, check if accessing to appropriate server
.............: - Check if any typo (e.g. with space, additional dot) on base URL or it is not IPv4 but IPv6
.............: - Check if any typo (e.g. with space, wrong name) on requested key name or it is invalid/not existed key name
************************************************************************************************************************
#>

# Input Parameter Key
param (
    [string]$Key
)

# Base URL for Instance Metadata Service (IMDS), IPv4
# For IPv6, http://[fd00:ec2::254]/latest/meta-data/
$baseUrl = "http://169.254.169.254/latest/meta-data/"
# Token URI for IMDSv2 as IMDSv1 causes 401 error
$tokenUri = "http://169.254.169.254/latest/api/token"

# Function to get IMDSv2 Token
function Get-IMDSToken {
    try {
        return Invoke-RestMethod -Method Put -Uri $tokenUri -Headers @{
            "X-aws-ec2-metadata-token-ttl-seconds" = "21600"
        }
    } catch {
        Write-Error "Failed to get IMDSv2 token: $_"
        # Exit the script immediately and signal that an error occurred.
        exit 1
    }
}

# Function Recursive to traverse all keys (with nested keys) recursively
# Nested keys, e.g. events/maintenance/history, events/maintenance/scheduled, etc.
function Get-MetadataRecursive {
    param (
        [string]$baseUrl,
        [string]$path = "",
        [hashtable]$headers
    )
    $metadata = @{}

    try {
        $items = Invoke-RestMethod -Headers $headers -Method GET -Uri "$baseUrl$path"
        $keys = $items -split "`n"

        foreach ($key in $keys) {
            if ($key.EndsWith("/")) {
                # It is a subdirectory, recurse
                $subPath = "$path$key"
                $metadata[$key.TrimEnd('/')] = Get-MetadataRecursive -baseUrl $baseUrl -path $subPath -headers $headers
            } else {
                # It's a value, fetch it
                try {
                    $value = Invoke-RestMethod -Headers $headers -Method GET -Uri "$baseUrl$path$key"
                    $metadata[$key] = $value
                } catch {
                    $metadata[$key] = "Error retrieving value"
                    #Even if some fail or return nothing, it can still output a partial list
                }
            }
        }
    } catch {
        return "Error reading metadata path: $path"
        #Even if some fail or return nothing, it can still output a partial list
    }

    return $metadata
}

# Function to get all Metadata
function Get-AllMetadata {
    $token = Get-IMDSToken
    $headers = @{
        "X-aws-ec2-metadata-token" = $token
    }

    $metadata = Get-MetadataRecursive -baseUrl $baseUrl -headers $headers

    return $metadata
}

# Function to get Metadata by requested Key
function Get-MetadataByKey {
    param (
        [string]$RequestedKey
    )

    $token = Get-IMDSToken
    $headers = @{
        "X-aws-ec2-metadata-token" = $token
    }
    
    try {
        $result = Invoke-RestMethod -Headers $headers -Method GET -Uri "$baseUrl$RequestedKey"
        return $result
    } catch {
        Write-Error "Key: '$RequestedKey' not found or unreachable."
        # Exit the script immediately and signal that an error occurred.
        exit 1
    }
}

# If there is an input parameter Key, return data value
# Otherwise, return all Metadata in json format
if ($Key) {
    $value = Get-MetadataByKey -RequestedKey $Key
    Write-Output $value
} else {
    $allData = Get-AllMetadata

    # -Depth 10 can hanlde even the most deeply nested EC2 metadata
    $jsonOutput = $allData | ConvertTo-Json -Depth 10
    Write-Output $jsonOutput

    # Also output json file
    $allData | ConvertTo-Json -Depth 10 | Out-File "metadata.json"
}