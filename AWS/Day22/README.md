# ☁️ Day 22/90 — AWS Cloud Overview & Billing Safety

**DevOps Winter Arc | Beginner AWS Foundations**

> **Mission:** Understand AWS basics, secure an AWS account, review billing safeguards, and explore the AWS Console **without provisioning chargeable infrastructure**.

**Estimated duration:** 1.5–2 hours  
**Planned spend:** $0 (not a guarantee of zero charges)

## 🎯 Learning Objectives

- Explain cloud computing and core AWS services.
- Understand AWS Regions and Availability Zones (AZs).
- Know the difference between EC2 and S3.
- Recognize IAM, VPC, CloudWatch, and Billing & Cost Management.
- Review account security and root-user MFA.
- Understand budgets, cost alerts, and their limitations.
- Explore AWS Console pages without creating resources.

## 1. AWS Fundamentals

### What is cloud computing?

Cloud computing means using computing resources such as servers, storage, and databases over the internet rather than purchasing and maintaining all the hardware yourself.

### What is AWS?

**Amazon Web Services (AWS)** is a cloud platform offering compute, storage, databases, networking, monitoring, and many other services. It lets teams provision infrastructure when needed and pay according to applicable pricing models.

### Core terminology

| Term | Beginner-friendly explanation | Example / purpose |
|---|---|---|
| **Region** | Geographic area containing AWS infrastructure | `ap-south-1` (Mumbai) |
| **Availability Zone (AZ)** | Isolated infrastructure location within a Region | Deploy across AZs to improve availability |
| **IAM** | Identity and Access Management | Control who can do what |
| **EC2** | Elastic Compute Cloud | Run virtual servers |
| **S3** | Simple Storage Service | Store files, backups, and other objects |
| **VPC** | Virtual Private Cloud | Create a logically isolated network |
| **CloudWatch** | Monitoring and observability service | Metrics, logs, and alarms |
| **Billing & Cost Management** | Cost and usage tools | Bills, budgets, cost trends |

### Region vs Availability Zone

```text
AWS Cloud
└── Region: ap-south-1 (Mumbai)
    ├── Availability Zone A
    ├── Availability Zone B
    └── Availability Zone C
```

A **Region** is the broader geographic location. An **AZ** is an isolated location inside a Region. Multi-AZ architectures can reduce the impact of an AZ failure.

### EC2 vs S3

| Feature | EC2 | S3 |
|---|---|---|
| Primary purpose | Compute | Object storage |
| Typical use | Run a web application | Store images or backups |
| Analogy | A rented computer | A managed file/object store |

**In my own words:** AWS provides on-demand IT infrastructure through the cloud. Instead of maintaining physical servers, teams can use AWS services for compute, storage, networking, and monitoring. EC2 runs workloads; S3 stores objects.

## 2. AWS Account Security

The Day 22 assignment emphasizes account awareness and safe setup.

### Security checklist

- [ ] Review the current AWS Free Tier terms and service-specific limits.
- [ ] Use an account with accurate registration details.
- [ ] Use a strong, unique password.
- [ ] Enable MFA on the **root user**.
- [ ] Do **not** create root access keys.
- [ ] Locate the AWS account menu, Region selector, console search, and support area.
- [ ] Avoid creating a duplicate AWS account just for the challenge.

### Root user vs IAM identity

- **Root user:** Full account-level authority; reserve for tasks requiring root.
- **IAM user:** Long-lived identity with permissions controlled by policies.
- **IAM role:** Identity that authorized users or services assume to obtain temporary credentials.

**Security principle:** Use least privilege. Give identities only the permissions required for their work.

> **Practice note:** Root MFA was verified during subsequent IAM practice. This README does not assume all Day 22 account-security and billing tasks were completed unless checked below.

## 3. Billing Safety — Critical Section

**A $0 budget is not a hard spending cap.** Alerts may arrive after usage occurs, and AWS may still bill for resources.

### Billing review workflow

1. Open **AWS Console → Billing and Cost Management**.
2. Review current-month charges and usage.
3. Open **AWS Budgets**.
4. Create or review a monthly cost budget: **$0.00 if supported**, otherwise the smallest permitted amount.
5. Add actual-cost and forecasted-cost alert thresholds above $0 where available.
6. Add an email address you monitor and verify the alert recipient.
7. Review **Free Tier** usage.
8. If available, enable billing alerts or a CloudWatch billing alarm.

### What a budget does—and does not do

| Budget / alert | Reality |
|---|---|
| Shows spending trends | Yes, subject to data availability |
| Notifies you at configured thresholds | Yes, subject to delivery and processing delays |
| Automatically prevents charges | **No** |
| Guarantees a $0 bill | **No** |
| Replaces checking service pricing | **No** |

### Avoid during this orientation lab

**Do not launch or create** EC2 instances, NAT Gateways, load balancers, RDS databases, or other potentially billable resources simply to explore the console.

For future labs: check pricing first, follow resource cleanup instructions, review relevant Regions, and verify billing afterward.

## 4. AWS Console Exploration (Read-Only Tour)

Open the following service pages, but **do not click Create, Launch, Deploy, or other provisioning actions**.

| Service | What to explore | What not to do today |
|---|---|---|
| **IAM** | Users, roles, policies, MFA/security recommendations | Do not create broad permissions or root access keys |
| **EC2** | Instance dashboard, instance types, pricing links | Do not launch an instance |
| **S3** | Buckets, objects, access controls, pricing notes | Do not create buckets or upload sensitive data |
| **VPC** | VPCs, subnets, route tables, security groups | Do not provision networking resources |
| **Billing** | Bills, budgets, Free Tier usage | Do not assume an empty chart means future usage is free |

## 5. Beginner Knowledge Check — Questions & Answers

**Q1. What is cloud computing?**  
Using computing resources over the internet instead of owning and maintaining all physical hardware.

**Q2. What is an AWS Region?**  
A geographic area containing AWS infrastructure.

**Q3. What is an Availability Zone?**  
An isolated infrastructure location within an AWS Region. Multiple AZs can improve availability.

**Q4. EC2 vs S3?**  
EC2 provides virtual compute servers; S3 stores objects such as files and backups.

**Q5. What does IAM do?**  
Controls identities and permissions for AWS resources.

**Q6. Is everything free with an AWS Free Tier account?**  
No. Eligibility, quotas, time limits, and service-specific pricing apply. Check current terms.

**Q7. Does a $0 budget prevent charges?**  
No. It provides notifications rather than a hard spending cap, and alerts may be delayed.

**Q8. Why enable MFA?**  
It adds another verification step, reducing the risk of account takeover.

**Q9. What should you do after a future AWS lab?**  
Review resources across relevant Regions, clean up resources as instructed, and check usage and billing.

**Q10. What is the difference between a Region and an AZ?**  
A Region is a geographic area; an AZ is an isolated location inside that Region.

**Q11. What is a VPC?**  
A logically isolated network in AWS.

**Q12. What does CloudWatch do?**  
Provides metrics, logs, and alarms to help monitor AWS workloads.

## 6. Proof of Work

The Day 22 assignment says **no GitHub project is required**. This README is an optional learning journal.

Recommended screenshots, with sensitive information hidden:

- [ ] AWS Console home page (hide email/account identifiers).
- [ ] Budget configuration with amount and alert thresholds (hide email and account identifiers).
- [ ] Billing or Free Tier usage page, if available.

Suggested folder layout:

```text
DevopsLearningJourney/
└── AWS/
    └── Day22-AWS-Overview-Billing-Safety/
        ├── README.md
        └── screenshots/             # Optional; redact private details
```

## 7. Final Completion Checklist

Check items only after verifying them in your own AWS account.

- [ ] I can explain AWS, Region, AZ, IAM, EC2, S3, VPC, and CloudWatch.
- [ ] I checked my AWS account and root MFA status.
- [ ] I reviewed current charges and usage.
- [ ] I created or reviewed a budget and alert recipients.
- [ ] I understand budgets do not guarantee zero charges.
- [ ] I explored IAM, EC2, S3, VPC, and Billing pages without provisioning resources.

## 8. Git Commands (Optional)

From the root of your existing `DevopsLearningJourney` repository:

```bash
mkdir -p AWS/Day22-AWS-Overview-Billing-Safety
# Copy this README.md into that directory.
git add AWS/Day22-AWS-Overview-Billing-Safety/README.md
git commit -m "docs: add Day 22 AWS overview and billing safety notes"
git push
```

> Never commit AWS credentials, access keys, account identifiers, payment information, or unredacted screenshots.

---

### Key Takeaway

**Day 22 is about AWS awareness, root-account security, cost visibility, and safe console exploration—not deploying infrastructure.**

**Next:** Day 23 — AWS IAM & Access Management (users, groups, MFA, policies, roles, and AWS CLI).

*Prepared from the DevOps Winter Arc Day 22 assignment guide; completion boxes are intentionally unchecked unless independently verified.*
