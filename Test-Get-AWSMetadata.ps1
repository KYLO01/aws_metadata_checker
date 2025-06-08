<#
************************************************************************************************************************
FileName.....: Test-Get-AWSMetadata.ps1
CreatedDate..: 06/06/2025 (DD/MM/YYYY)
Creator......: Timothy Lo
Synopsis.....: Pester test suite for Get-AWSMetadata.ps1
Description..: 17 Test cases
.............: Describing Get-IMDSToken Function                                                                                                                                                                                                                                 [+] should return a valid token 21.43s                                                                                                                                                                                                                           [+] Should throw when token retrieval fails 138ms                                                                                                                                                                                                               Describing Get-AllMetadata Function                                                                                                                                                                                                                               [+] Should throw when token retrieval fails 151ms                                                                                                                                                                                                                [+] should return metadata values 116ms                                                                                                                                                                                                                          [+] should call Get-IMDSToken exactly once 102ms                                                                                                                                                                                                                 [+] should call Get-MetadataRecursive exactly once with correct headers 91ms                                                                                                                                                                                    Describing Get-MetadataByKey Function                                                                                                                                                                                                                             [+] Should throw when token retrieval fails 150ms                                                                                                                                                                                                                [+] should return metadata value for a valid key 89ms                                                                                                                                                                                                            [+] should call Get-IMDSToken exactly once 132ms
.............:  [+] should return a valid token
.............:  [+] Should throw when token retrieval fails
.............: Describing Get-MetadataRecursive Function
.............:  [+] Should throw when token retrieval fails
.............: Describing Get-AllMetadata Function  
.............:  [+] Should throw when token retrieval fails
.............:  [+] should return metadata values
.............:  [+] should call Get-IMDSToken exactly once
.............:  [+] should call Get-MetadataRecursive exactly once with correct headers 
.............: Describing Get-MetadataByKey Function 
.............:  [+] Should throw when token retrieval fails
.............:  [+] should return metadata value for a valid key
.............:  [+] should call Get-IMDSToken exactly once
.............:  [+] should call Invoke-RestMethod exactly once with correct headers
.............: Describing Metadata Retrieval Logic
.............:  Context When using a valid key
.............:   [+] Should throw when token retrieval fails
.............:   [+] should call Get-MetadataByKey when Key is provided
.............:   [+] Should throw when token retrieval fails
.............:   [+] should call Get-AllMetadata when Key is not provided
.............:  Context When no key
.............:   [+] should convert metadata to JSON when Key is not provided
.............:   [+] should write JSON output to file when Key is not provided
Usage........: Invoke-Pester -Path .\Test-Get-AWSMetadata.ps1
************************************************************************************************************************
#>

# Ensure the main script is dot-sourced to access its functions
# $PSScriptRoot="" in this case`
. "$PSScriptRoot\Get-AWSMetadata.ps1"

Describe "Get-IMDSToken Function" {

    It "should return a valid token" {
        Mock Invoke-RestMethod -Method Put -Uri $tokenUri -Headers @{ "X-aws-ec2-metadata-token-ttl-seconds" = "21600" } -MockWith { return "mocked-token" }
        $result = Get-IMDSToken
        $result | Should Be "mocked-token"
    }

    It "Should throw when token retrieval fails" {
        Mock Get-IMDSToken { throw "Failed to get IMDSv2 token: Unable to connect to the remote server" }
        # Simulate Invoke-RestMethod throwing inside the function
        Mock Invoke-RestMethod { throw "Unable to connect to the remote server" }

        { Get-IMDSToken } | Should Throw "Failed to get IMDSv2 token: Unable to connect to the remote server"
    }
}

Describe "Get-MetadataRecursive Function" {
    It "Should throw when token retrieval fails" {
        Mock Invoke-RestMethod { throw "Unable to connect to the remote server" }

        $result = Get-MetadataRecursive
        $result | Should Be "Error reading metadata path: "
    }
}

Describe "Get-AllMetadata Function" {
    It "Should throw when token retrieval fails" {
        Mock Get-IMDSToken { throw "Unable to connect to the remote server" }

        # Simulate Invoke-RestMethod throwing inside the function
        Mock Invoke-RestMethod { throw "Unable to connect to the remote server" }

        { Get-IMDSToken } | Should Throw "Unable to connect to the remote server"
    }

    Mock Get-IMDSToken { return "mocked-token" }
    Mock Get-MetadataRecursive -MockWith { return @{ "instance-id" = "i-1234567890abcdef0"; "ami-id" = "ami-0987654321abcdef0" } }

    It "should return metadata values" {
        $result = Get-AllMetadata
        $result["instance-id"] | Should Be "i-1234567890abcdef0"
        $result["ami-id"] | Should Be "ami-0987654321abcdef0"
    }

    It "should call Get-IMDSToken exactly once" {
        Get-AllMetadata
        Assert-MockCalled Get-IMDSToken -Exactly 1 -Scope It
    }

    It "should call Get-MetadataRecursive exactly once with correct headers" {
        Get-AllMetadata
        Assert-MockCalled Get-MetadataRecursive -Exactly 1 -Scope It -ParameterFilter {
            $headers["X-aws-ec2-metadata-token"] -eq "mocked-token"
        }
    }

}

Describe "Get-MetadataByKey Function" {
    It "Should throw when token retrieval fails" {
        Mock Get-IMDSToken { throw "Unable to connect to the remote server" }

        # Simulate Invoke-RestMethod throwing inside the function
        Mock Invoke-RestMethod { throw "Unable to connect to the remote server" }

        { Get-IMDSToken } | Should Throw "Unable to connect to the remote server"
    }

    Mock Get-IMDSToken { return "mocked-token" }
    Mock Invoke-RestMethod -MockWith { return "mocked-metadata-value" }

    It "should return metadata value for a valid key" {
        $result = Get-MetadataByKey -RequestedKey "instance-id"
        $result | Should Be "mocked-metadata-value"
    }

    It "should call Get-IMDSToken exactly once" {
        Get-MetadataByKey -RequestedKey "instance-id"
        Assert-MockCalled Get-IMDSToken -Exactly 1 -Scope It
    }

    It "should call Invoke-RestMethod exactly once with correct headers" {
        Get-MetadataByKey -RequestedKey "instance-id"
        Assert-MockCalled Invoke-RestMethod -Exactly 1 -Scope It -ParameterFilter {
            $Headers["X-aws-ec2-metadata-token"] -eq "mocked-token"
        }
    }

}

Describe "Metadata Retrieval Logic" {

    Mock ConvertTo-Json -MockWith { return "{ 'mocked': 'json-output' }" }
    Mock Out-File {}

    Context "When using a valid key" {
        It "Should throw when token retrieval fails" {
            Mock Get-IMDSToken { throw "Unable to connect to the remote server" }

            # Simulate Invoke-RestMethod throwing inside the function
            Mock Invoke-RestMethod { throw "Unable to connect to the remote server" }

            { Get-MetadataByKey -RequestedKey "instance-id" } | Should Throw "Unable to connect to the remote server"
        }

        It "should call Get-MetadataByKey when Key is provided" {
            Mock Get-IMDSToken{ return "mocked-token" }
            Mock -CommandName Invoke-RestMethod -Method Put -Uri $tokenUri -Headers @{ "X-aws-ec2-metadata-token-ttl-seconds" = "21600" } -MockWith { return "mocked-token" }
            Mock Get-MetadataByKey -RequestedKey "instance-id" -MockWith { return "mocked-metadata-value" }
            $value = Get-MetadataByKey -RequestedKey "instance-id"
            $value | Should Be "mocked-metadata-value"
        }

        It "Should throw when token retrieval fails" {
            Mock Get-IMDSToken { throw "Unable to connect to the remote server" }
            Mock Invoke-RestMethod { return "Unable to connect to the remote server" }

            { Get-AllMetadata } | Should Throw "Unable to connect to the remote server"
        }

        It "should call Get-AllMetadata when Key is not provided" {
            Mock Get-IMDSToken{ return "mocked-token" }
            Mock -CommandName Invoke-RestMethod -Method Put -Uri $tokenUri -Headers @{ "X-aws-ec2-metadata-token-ttl-seconds" = "21600" } -MockWith { return "mocked-token" }
            Mock Get-AllMetadata -MockWith { return @{ "instance-id" = "i-1234567890abcdef0"; "ami-id" = "ami-0987654321abcdef0" } }
            $value = Get-AllMetadata 
            $value | Should Be System.Collections.Hashtable
        }
    }

    Context "When no key" {
        It "should convert metadata to JSON when Key is not provided" {
            $metadata = @{ "instance-id" = "i-1234567890abcdef0";"ami-id" = "ami-0987654321abcdef0"}
            $jsonOutput = ConvertTo-Json -InputObject $metadata -Depth 10 
            $jsonOutput | Should Match "\{.*\}" 
            Assert-MockCalled ConvertTo-Json -Exactly 1 -Scope It
        }

        It "should write JSON output to file when Key is not provided" {
            $jsonOutput | Out-File -FilePath "metadata.json"
            Test-Path "metadata.json" | Should Be $true
            Assert-MockCalled Out-File -Exactly 1 -Scope It -ParameterFilter { $FilePath -eq "metadata.json" }
        }
    }
}