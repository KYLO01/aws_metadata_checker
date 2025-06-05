# AWS EC2 Instance Metadata Fetcher (PowerShell)

This project is a PowerShell script that retrieves metadata from an AWS EC2 instance using IMDSv2 (Instance Metadata Service Version 2). It returns a JSON-formatted output of all available metadata, and also allows fetching a specific metadata key.

# Features

- Fetch all available metadata recursively (up to 10 levels deep)
- Retrieve a specific metadata key (e.g., "instance-id", "hostname")
- Uses IMDSv2 token-based authentication
- Graceful error handling
- Supports CI/CD and unit testing in future versions

# Getting Started

This script is designed to be run **inside an EC2 instance** on AWS.

# Prerequisites

- AWS EC2 instance (Amazon Linux or similar)
- PowerShell installed ("pwsh" for Linux or Windows PowerShell 5.1+)
- Internet access (for updates and GitHub)
- Git
- GitHub
- Visual Studio Code

# Installation

Clone the repository or download the script:

bash
git clone https://github.com/KYLO01/aws_metadata_checker.git
cd aws_metadata_checker

# Usage

To fetch all metadata
./Get-AWSMetadata.ps1

To fetch a specific key
./Get-AWSMetadata.ps1 -Key "hostname"

# Example

Json formatted output
{
  "ami-id": "ami-006b4a3ad5f56fbd6",
  "instance-action": "none",
  "local-hostname": "ip-172-31-43-104.eu-north-1.compute.internal",
 ...
}

# Folder Structure

aws_metadata_checker/
│
├── aws-ec2-key.pem           # AWS key pair
├── Get-AWSMetadata.ps1       # Main script
├── README.md                 # This file
├── tests/                    # (Optional) Unit test scripts
└── .github/workflows/        # (Optional) CI/CD pipelines

# Author

Kei Yip Lo (known as Timothy)
www.linkedin.com/in/timothy-kylo
