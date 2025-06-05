<#
************************************************************************************************************************
FileName.....: Get-AWSMetadata.ps1
CreatedDate..: 05/06/2025 (DD/MM/YYYY)
Creator......: Timothy Lo
Synopsis.....: Retrieve EC2 instance metadata in JSON format.
Description..: This script queries AWS EC2 instance metadata and returns all data in JSON format,
.............: or a specific value when a key is provided as input.
Parameter Key: (Optional) The metadata key to retrieve (e.g., 'hostname', 'instance-id').
Usage........: .\Get-EC2Metadata.ps1
.............: .\Get-EC2Metadata.ps1 -Key "hostname"
Error Return.: E1) Invoke-RestMethod : Unable to connect to the remote server
.............: E2) Error retrieving value
.............: E3) Key '$RequestedKey' not found or unreachable.
Resolution...: S1) The metadata URL http://169.254.169.254/latest/meta-data/ is accessible only within an EC2 instance. 
.............: If you try it from outside (e.g., local laptop), it won't work as expected.
.............: Even, by using AWS PowerShell Cmdlets like Get-EC2Instance (get data from AWS API)
.............: Or, IMDSv2 token-based metadata URLs (like http://169.254.169.254/latest/meta-data/)
.............: If running inside AWS, check if accessing to appropriate server
.............: S2) Check if any typo (e.g. with space, additional dot) on base URL or it is not IPv4 but IPv6
.............: S3) Check if any typo (e.g. with space, wrong name) on requested key name or it is invalid/not existed key name
************************************************************************************************************************
#>

# Input Parameter Key
param (
    [string]$Key
)

# Base URL for Instance Metadata Service (IMDS), IPv4
# For IPv6, http://[fd00:ec2::254]/latest/meta-data/
$baseUrl = "http://169.254.169.254/latest/meta-data/"

# Functions to get all Metadata
function Get-AllMetadata {
    $metadata = @{}
    $keys = Invoke-RestMethod -Uri $baseUrl
    foreach ($k in $keys) {
        try {
            $value = Invoke-RestMethod -Uri "$baseUrl$k"
            $metadata[$k] = $value
        } catch {
            $metadata[$k] = "Error retrieving value"
            #Even if some fail or return nothing, it can still output a partial list
        }
    }
    return $metadata
}

# Functions to get Metadata by requested Key
function Get-MetadataByKey {
    param (
        [string]$RequestedKey
    )

    try {
        $result = Invoke-RestMethod -Uri "$baseUrl$RequestedKey"
        return $result
    } catch {
        Write-Error "Key '$RequestedKey' not found or unreachable."
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
    $jsonOutput = $allData | ConvertTo-Json -Depth 5
    Write-Output $jsonOutput
}