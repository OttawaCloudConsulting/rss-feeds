# RSS Feeds Collection

This repository contains a curated collection of RSS feeds organized by technology domains and focus areas. The feeds are maintained in OPML format for easy import into RSS readers and feed aggregators.

- [RSS Feeds Collection](#rss-feeds-collection)
  - [Feed Categories](#feed-categories)
    - [AWS General Feeds](#aws-general-feeds)
    - [AWS Solution Specific Feeds](#aws-solution-specific-feeds)
    - [Kubernetes Feeds](#kubernetes-feeds)
    - [Crossplane Feeds](#crossplane-feeds)
    - [Cyber Feeds](#cyber-feeds)
    - [Government of Canada Feeds](#government-of-canada-feeds)
  - [Files](#files)
  - [Usage](#usage)
    - [Importing into RSS Readers](#importing-into-rss-readers)
    - [Using with Feed Aggregators](#using-with-feed-aggregators)
  - [Updates](#updates)
  - [Contributing](#contributing)
  - [Contact](#contact)

## Feed Categories

### AWS General Feeds

A comprehensive collection of AWS service and solution blogs covering the breadth of Amazon Web Services offerings:

- **AWS Architecture Blog** - Best practices and patterns for building on AWS
- **AWS Business Productivity Blog** - Workplace productivity solutions and strategies
- **AWS Cloud Financial Management** - Cost optimization and financial management guidance
- **AWS Management & Governance Blog** - Tools and practices for managing AWS environments
- **AWS Compute Blog** - EC2, Lambda, and other compute service updates
- **AWS Containers** - ECS, EKS, Fargate, and containerization strategies
- **AWS Database Blog** - RDS, DynamoDB, and database service insights
- **AWS Developer Tools Blog** - CodeCommit, CodeBuild, CodeDeploy, and development workflows
- **AWS DevOps & Developer Productivity Blog** - CI/CD, automation, and productivity enhancements
- **AWS Enterprise Strategy Blog** - Enterprise adoption strategies and case studies
- **AWS Industries Blog** - Industry-specific solutions and use cases
- **AWS Infrastructure & Automation** - CloudFormation, CDK, and infrastructure as code
- **AWS Marketplace Blog** - Third-party solutions and marketplace updates
- **AWS Network & Content Delivery Blog** - VPC, CloudFront, and networking solutions
- **AWS News Blog** - Official AWS announcements and product launches
- **AWS Open Source Blog** - Open source projects and contributions from AWS
- **AWS Partner Network (APN) Blog** - Partner solutions and collaboration updates
- **AWS Public Sector Blog** - Government and public sector cloud adoption
- **AWS Security Bulletins** - Critical security updates and patches
- **AWS Security, Identity & Compliance Blog** - IAM, security best practices, and compliance
- **AWS Storage Blog** - S3, EBS, EFS, and storage solutions
- **AWS Training & Certification Blog** - Learning resources and certification updates

### AWS Solution Specific Feeds

Targeted feeds for specific AWS solutions and security updates:

- **Amazon Linux2 AMI Security Bulletins** - Security patches and updates for AL2
- **Amazon Linux 2022 Security Bulletins** - Security patches and updates for AL2022
- **AWS Landing Zone Accelerator Updates** - Multi-account environment setup guidance

### Kubernetes Feeds

Container orchestration and cloud-native technology updates:

- **Kubernetes Blog** - Official Kubernetes project news and updates
- **Argo Project Blog** - GitOps, CD, and workflow automation with Argo

### Crossplane Feeds

Infrastructure as code and multi-cloud management:

- **Crossplane Blog** - Cloud infrastructure provisioning and management
- **Upbound Status - Incident History** - Service status and incident reports

### Cyber Feeds

Cybersecurity intelligence and threat information:

- **CISA Cybersecurity Advisories** - US government cybersecurity alerts and guidance
- **NIST Cybersecurity Insights** - Standards and best practices from NIST
- **SANS Internet Storm Center** - Threat intelligence and security research

### Government of Canada Feeds

Canadian cybersecurity and government technology updates:

- **CCCS Cyber Alerts & Advisories** - Canadian Centre for Cyber Security updates

## Files

- `AllFeeds.opml` - Main OPML file containing all RSS feed subscriptions
- `rss-test.sh` - Validation script for testing RSS feed availability

## Usage

### Importing into RSS Readers

1. Download the `AllFeeds.opml` file
2. Import it into your preferred RSS reader:
   - [**Fluent Reader**:](https://hyliu.me/fluent-reader/) Sources → Import from OPML
   - [**Inoreader**:](https://www.inoreader.com/) Settings → Import/Export → Import from OPML
   - [**Reeder App**:](https://reederapp.com) Import → Upload OPML file
   - [**Microsoft Outlook Desktop**:](https://support.microsoft.com/en-us/office/import-a-collection-of-rss-feeds-56c8c59d-e6af-4442-a09c-22a7e594a08e) File → Open & Export → Import/Export → Import RSS Feeds from an OPML file

### Using with Feed Aggregators

The OPML file can be used with various feed aggregation tools and services that support OPML import functionality.

## Updates

The RSS feeds in this collection are automatically validated through GitHub Actions to ensure they remain accessible and functional. The repository is regularly updated to:

- Add new relevant feeds
- Remove discontinued or broken feeds
- Reorganize feeds for better categorization
- Update feed URLs when they change

## Contributing

To suggest new feeds or report issues:

1. Create an issue describing the feed or problem
2. For new feeds, include:
   - Feed URL
   - Brief description
   - Appropriate category
3. For broken feeds, include error details or alternative URLs

## Contact

This collection is maintained by [Ottawa Cloud Consulting](https://github.com/OttawaCloudConsulting) as part of our commitment to staying current with cloud technology and cybersecurity developments.

---

Last updated: August 2025
