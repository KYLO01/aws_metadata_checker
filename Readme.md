# AWS EC2 Instance Metadata Checker (PowerShell)

This project is a PowerShell script that retrieves metadata from an AWS EC2 instance using IMDSv2 (Instance Metadata Service Version 2). It returns a JSON-formatted output of all available metadata, and also allows fetching a specific metadata key.

# Features

- Fetch all available metadata recursively (up to 10 levels deep)
- Retrieve a specific metadata key (e.g., "instance-id", "hostname")
- Uses IMDSv2 token-based authentication
- Graceful error handling
- Supports CI/CD and unit testing 

# Getting Started

This script is designed to be run **inside an EC2 instance** on AWS.

# Prerequisites

- AWS EC2 instance (Amazon Linux or similar)
- PowerShell installed ("pwsh" for Linux or Windows PowerShell 5.1+)
- Internet access (for updates and GitHub)
- Git
- GitHub
- Visual Studio Code
- Pester 3.4 version

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

To fetch metadata json format output manually by the script via your AWS EC2 instance
1. SSH into AWS EC2 Instance via your Public IP (it will be changed everytime start/stop instance)/Elastic IP (better) with ec2-user (Amazon Linux default user - non-root), i.e. ec2-user@[your EC2 Public IP or Elastic IP]
(Git Bash Terminal 1) ssh -i "[File path]\aws-ec2-key.pem" ec2-user@[your EC2 Public IP or Elastic IP]

2. Open another Git Bash and copy the powershell script file from laptop to AWS EC2 instance
(Git Bash Terminal 2) scp -i "[File path]\aws-ec2-key.pem" Get-AWSMetadata.ps1 ec2-user@[your EC2 Public IP or Elastic IP]:/home/ec2-user/

3. Back to the SSH connected terminal and see if the file exist or not
(Git Bash Terminal 1 - EC2 connected) pwd
(Git Bash Terminal 1 - EC2 connected) ls

4. Change the file to executable
(Git Bash Terminal 1 - EC2 connected) chmod +x Get-AWSMetadata.ps1

5. Install PowerShell (Optional/First time only)
(Git Bash Terminal 1 - EC2 connected) sudo yum install -y https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-1.rh.x86_64.rpm 
(Git Bash Terminal 1 - EC2 connected) sudo yum install -y powershell

6. Launch PowerShell
(Git Bash Terminal 1 - EC2 connected with PS) pwsh

7. Run ./Get-AWSMetadata.ps1 to output json format metadata and metadata.json file will be generated
(Git Bash Terminal 1 - EC2 connected with PS) ./Get-AWSMetadata.ps1

8. ./Get-AWSMetadata.ps1 -Key "[key name, e.g. hostname]" to output data value correspondingly
(Git Bash Terminal 1 - EC2 connected with PS) ./Get-AWSMetadata.ps1 -Key "hostname"

To run CI CD pipeline
1. Open Git Bash
(Git Bash Terminal 3 ) git clone https://github.com/KYLO01/aws_metadata_checker.git

2. Setup two Repository secrets on your github
a. Click on Settings → Secrets and variables → Actions
b. Under Repository secrets, click “New repository secret”
c. Name it AWS_EC2_PUBLIC_IP
e. Paste your EC2 instance’s current public IP address as the value
f. Click Add secret
g. Click “New repository secret” again
h. Name it AWS_EC2_PRIVATE_KEY
i. Paste your EC2 instance’s PEM private key content as the value
j. Click Add secret

3. Install PowerShell on your AWS EC2 instance (it does not include this task on CD pipeline)
sudo yum install -y https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-1.rh.x86_64.rpm 
sudo yum install -y powershell

4. Change something on a file under aws_metadata_checker folder project

5. Run git add
(Git Bash Terminal 3 ) git add .

6. Run git commit
(Git Bash Terminal 3 ) git commit -m "[commit message]"

7. Run git push
(Git Bash Terminal 3 ) git push -u origin main

8. Check the result on GitHub -> Actions -> Jobs -> CI CD pipeline workflow

# Example

Json formatted output
{
  "ami-id": "ami-006b4a3ad5f56fbd6",
  "instance-action": "none",
  "local-hostname": "ip-172-31-43-104.eu-north-1.compute.internal",
 ...
}

# Folder Structure

- aws_metadata_checker/
- │
- ├── aws-ec2-key.pem                               # AWS private key pair for ec2-user@16.171.26.83 access
- ├── Get-AWSMetadata.ps1                           # Main script to fetch AWS EC2 metadata with json formatted output
- ├── README.md                                     # This file
- ├── test-Get-AWSMetadata.ps1                      # Pester Unit test script
- ├── metatdata_20250606.json                       # Actual result of AWS EC2 metadata with json formatted output file via ec2-user@16.171.26.83
- ├── metadata.json                                 # Output file from Pester test
- ├── .github/workflows/                            # CI/CD pipelines
- ├── .github/workflows/CI-Pipeline-AWSMetadata.yml # CI pipeline
- └── .github/workflows/CD-Pipeline-AWSMetadata.yml # CD pipeline

# Author

Kei Yip Lo (known as Timothy)
www.linkedin.com/in/timothy-kylo
