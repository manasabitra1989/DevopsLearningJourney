# Day 23 — AWS IAM & Access Management 🔐

> **DevOps Winter Arc — 90 Days Challenge**  
> **AWS Week — Day 1** | Beginner | Estimated lab time: 2–3 hours  
> **Focus:** IAM users, groups, policies, roles, MFA, least privilege, access troubleshooting  
> **Cost target:** $0 planned AWS resource spend

## 🎯 Learning objectives

- Understand authentication versus authorization.
- Secure the AWS root account and a daily-use IAM identity with MFA.
- Explain IAM users, groups, roles, permissions policies, and trust policies.
- Apply the principle of least privilege.
- Explore AWS-managed policies and draft a scoped S3 policy in JSON.
- Recognize common `AccessDenied` situations and safely inspect CLI identity.

## ✅ What I actually practiced

| Activity | Status | Notes |
|---|---|---|
| Sign in as AWS root and verify root MFA | ✅ Completed | Root used for initial IAM setup |
| Create IAM user `devops-learner` | ✅ Completed | Console access enabled |
| Sign in as IAM user | ✅ Completed | Corrected IAM sign-in details |
| Verify IAM-user MFA | ✅ Completed | Successfully authenticated with MFA |
| Attach and inspect `ReadOnlyAccess` | ✅ Completed | AWS-managed broad read-only policy |
| Inspect `IAMUserChangePassword` | ✅ Completed | Automatically attached during console user setup |
| Create `Auditors` group | ✅ Completed | `ReadOnlyAccess`, initially empty |
| Create `Developers` group | ✅ Completed | `ReadOnlyAccess`, initially empty |
| Review sample S3 policy in JSON editor | ✅ Completed | **Reviewed only; not attached** |
| Inspect EC2 IAM role creation flow | 📖 Explained / not confirmed completed | No EC2 role creation confirmed |
| AWS CLI identity checks | ⏳ Optional / not confirmed | No credentials or keys created for this exercise |
| Create `Admins` group | 📝 Design exercise only | Not confirmed created |

**Scope note:** This README records the hands-on steps confirmed in the learning conversation. Do not interpret examples or interview answers as proof that AWS resources were created.

---

## 1. IAM basics in plain English

**IAM (Identity and Access Management)** controls **who** can access AWS and **what** actions they can perform.

- **Authentication:** Prove *who you are* (password, MFA, federation).
- **Authorization:** Determine *what you are allowed to do* (policies and other access controls).
- **IAM user:** An identity that can have long-term credentials, including a console password.
- **IAM user group:** A collection of IAM users sharing permissions. Groups cannot be assumed as roles.
- **IAM role:** An assumable identity that provides temporary credentials.
- **Permissions policy:** JSON rules defining actions on resources, possibly with conditions.
- **Trust policy:** Specifies which principals may assume an IAM role.
- **MFA:** Multi-factor authentication; an extra verification factor.
- **Least privilege:** Grant only the permissions required to do a job.

### Mental model

```text
AWS account
├── Root identity (protect with MFA; avoid daily use)
├── IAM users
│   └── devops-learner (console login + MFA)
├── IAM user groups
│   ├── Auditors    -> ReadOnlyAccess
│   ├── Developers  -> ReadOnlyAccess
│   └── Admins      -> proposed design, not created
├── Permissions policies -> WHAT can be done?
└── IAM roles
    ├── Trust policy       -> WHO may assume the role?
    └── Permissions policy -> WHAT may the role do?
```

**Important:** Users receive the union of applicable identity-based permissions from their direct policies and group policies, subject to explicit denies and other applicable AWS controls. A group does not itself authenticate or log in.

---

## 2. Root versus IAM user

| Feature | Root identity | IAM user |
|---|---|---|
| Created | With the AWS account | By an authorized administrator |
| Privilege | Full account-level authority | Defined by effective permissions |
| Typical use | Rare account-level/security tasks | Limited daily operations |
| MFA | Essential | Strongly recommended |
| Long-term access keys | Avoid creating | Avoid unless a genuine need exists |

**My lab:** Root MFA was already enabled. I created `devops-learner`, enabled console access, verified MFA, and successfully signed in.

### Console access versus permissions

A successful login confirms **console sign-in access**. It does **not** mean permission to perform every AWS operation. An IAM user with `ReadOnlyAccess` can inspect many resources but generally cannot create or delete them.

### IAM-user sign-in troubleshooting

I initially received **“Authentication failed — Your authentication information is incorrect.”**

**Cause found during troubleshooting:** The IAM sign-in form's **Account ID or alias** field had been filled with the root email address.

**Correct IAM sign-in fields:**

1. **Account ID or alias:** The 12-digit AWS account ID or a configured account alias.
2. **IAM user name:** `devops-learner`.
3. **Password:** That IAM user's console password (not the root password).
4. **MFA:** The IAM user's registered authenticator code when prompted.

**Shortcut:** Use the IAM-user sign-in URL displayed in the AWS IAM dashboard. Do not publish account IDs, sign-in URLs, passwords, QR codes, recovery codes, or tokens in public screenshots.

---

## 3. MFA: what I verified

**MFA = Multi-Factor Authentication.** It requires an additional factor beyond a password, reducing the risk of account compromise if the password is exposed.

**Observed:** My IAM user was assigned an MFA device during setup and MFA worked when I logged in as `devops-learner`.

**Where to inspect MFA:**

- Administrator: **IAM → Users → devops-learner → Security credentials → MFA**.
- User: **Account menu → Security credentials**, if the identity has permission to view/manage its credentials.

**Typical authenticator enrollment:** Choose an authenticator app, scan the QR code privately, enter two consecutive time-based codes, and verify the device appears under MFA. The exact interface may vary.

**Security:** Never publish MFA QR codes, seed keys, backup codes, passwords, or AWS credentials.

---

## 4. AWS-managed versus customer-managed policies

| Type | Who maintains it? | Example | When useful |
|---|---|---|---|
| AWS-managed | AWS | `ReadOnlyAccess` | Standard AWS-provided permissions |
| Customer-managed | Your account | Custom scoped S3 policy | Fine-grained team/application access |
| Inline | Embedded in one identity | Inline user/role policy | Special one-to-one permissions, when justified |

### Policies I encountered

**`ReadOnlyAccess`** is an AWS-managed policy giving broad read-only visibility across many AWS services. It is **not** the same as every possible data-read operation, and it is broader than a tightly scoped production permission set.

**`IAMReadOnlyAccess`** is a different AWS-managed policy focused on IAM information. It is **not** a substitute for account-wide `ReadOnlyAccess` if the goal is broad resource visibility.

**`IAMUserChangePassword`** permits a user to change their own IAM console password. It may be attached automatically when a console user is required to change their password. It does **not** grant administrator privileges and did not prevent my lab.

### Doubt: “Why can't I find the exact ReadOnlyAccess policy?”

There are many service-specific policies ending in `ReadOnlyAccess` (for example, `IAMReadOnlyAccess`). The exact AWS-managed policy is:

```text
Policy name: ReadOnlyAccess
Policy ARN:  arn:aws:iam::aws:policy/ReadOnlyAccess
```

**How to identify it:** Use **IAM → Policies**, filter to **AWS managed**, and verify the exact policy name/ARN. Avoid choosing a similarly named service-specific policy accidentally.

---

## 5. IAM groups: hands-on lab

### Group 1: Auditors — completed

1. Opened **IAM → User groups → Create group**.
2. Named it `Auditors`.
3. Left membership empty.
4. Attached AWS-managed `ReadOnlyAccess`.
5. Created the group.

### Group 2: Developers — completed

1. Opened **IAM → User groups → Create group**.
2. Named it `Developers`.
3. Left membership empty.
4. Attached AWS-managed `ReadOnlyAccess`.
5. Created the group.

**Why create empty groups?** To practice group/policy organization without changing the effective permissions of any user.

### Permission matrix: three-team scenario

| Team | Intended access | Should not be able to do |
|---|---|---|
| Admins | Administrative tasks for designated administrators | Use root for routine work; bypass security controls |
| Developers | Read-only baseline for this exercise; object read/write on **one future lab S3 bucket** | Manage IAM or unrelated production resources |
| Auditors | Read-only inspection | Modify or delete resources |

**Production caution:** Even the broad `ReadOnlyAccess` policy can reveal more information than a real developer needs. Prefer custom least-privilege permissions after identifying the actual job requirements.

**Why not give developers `AdministratorAccess`?** It could allow changes to IAM, security, infrastructure, and billing-related resources unrelated to their work. Compromised developer credentials would then have a much larger impact.

**Admins group:** Included in the assignment's design; no creation was confirmed.

---

## 6. JSON permissions policy: S3 example

**Lab status:** Reviewed in IAM's JSON policy editor. No bucket was created and the policy was **not attached**.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::YOUR-LAB-BUCKET/*"
    }
  ]
}
```

### Explain each element

- `Version`: IAM policy language version, not the policy's revision number.
- `Statement`: One or more permission rules.
- `Effect`: `Allow` or `Deny`.
- `Action`: AWS API operations to match.
- `Resource`: ARN(s) of the resource(s) the actions apply to.
- `Condition` (optional): Further restrictions, such as tags or request context.

**ARN** = Amazon Resource Name. In this example, `arn:aws:s3:::YOUR-LAB-BUCKET/*` refers to **objects inside** the named bucket.

### Why can GetObject work while ListBucket fails?

Object actions and bucket actions target different ARN shapes:

| Operation | Required action | Resource shape |
|---|---|---|
| Download an object | `s3:GetObject` | `arn:aws:s3:::bucket-name/*` |
| Upload an object | `s3:PutObject` | `arn:aws:s3:::bucket-name/*` |
| List bucket contents | `s3:ListBucket` | `arn:aws:s3:::bucket-name` |

**Example for learning only:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListOnlyLabBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::YOUR-LAB-BUCKET"
    },
    {
      "Sid": "ReadWriteObjectsOnlyInLabBucket",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::YOUR-LAB-BUCKET/*"
    }
  ]
}
```

**Do not attach the sample as-is.** Replace the placeholder with a specific authorized lab bucket only in a future exercise. Additional controls such as bucket policies, encryption-key permissions, service control policies, and explicit denies can still affect access.

### IAM policy evaluation — essential interview concept

1. AWS begins from **implicit/default deny**.
2. A relevant **Allow** must exist for the action and resource.
3. An applicable **explicit Deny overrides Allow**.
4. Other applicable controls (for example, permissions boundaries, SCPs, session policies, and resource-based policies) can further affect the final decision.

**Common interview trap:** A policy with `Action: "*"` and `Resource: "*"` is extremely broad. Even if technically valid, it usually violates least privilege.

---

## 7. IAM roles: conceptual lab (not confirmed executed)

**Role:** An assumable IAM identity that supplies temporary credentials. Unlike a user, a role is not a normal permanent login identity with its own long-term password.

### Real DevOps example: EC2 application reads S3

```text
Application running on EC2
           |
           v
EC2 instance profile / IAM role
           |
           v
Temporary credentials available to application
           |
           v
AWS S3 API checks effective permissions
           |
           v
Requested object is returned if authorized
```

**Why use a role?** It avoids embedding long-lived access keys in application configuration or server files. AWS SDKs/CLI can automatically obtain and refresh temporary credentials from the instance metadata service when configured correctly.

### Trust policy: WHO may assume the role?

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Permissions policy: WHAT can the role do?

For an EC2 workload that only reads objects from one bucket, a separate policy could grant `s3:GetObject` on that bucket's object ARN.

**Remember:** Trust policy does not grant S3 access. Permissions policy does not by itself establish who can assume the role.

### Explore without creating resources

**IAM → Roles → Create role → AWS service → EC2**. Inspect the workflow, then cancel without creating the role. This was suggested as the next practical task; its completion was **not confirmed**.

---

## 8. Optional AWS CLI identity checks

> Only run these if AWS CLI is already installed and configured with an authorized **non-root** identity. Do not create root access keys or long-lived keys just for this exercise.

```bash
aws --version
# Check installed AWS CLI version.

aws sts get-caller-identity
# Show current AWS principal and account context.

aws configure list
# Show active configuration/profile and credential source.

aws iam get-account-summary
# Read IAM account statistics, if authorized.
```

**Privacy:** Redact account IDs and other identifying information before sharing terminal screenshots. `aws configure list` may expose sensitive context even when credentials are masked.

**What does STS mean?** AWS Security Token Service, used to issue temporary security credentials and identify the caller.

---

## 9. My doubts and answers — FAQ

### Q1. “I don't have any IAM user. What should I do?”
Create a dedicated, limited IAM identity for routine practice rather than using root for everything. Enable console access and MFA; grant only necessary permissions.

### Q2. “Why can't I find a policy named exactly ReadOnlyAccess?”
The console lists many similarly named policies. Check the exact policy name and AWS-managed ARN: `arn:aws:iam::aws:policy/ReadOnlyAccess`.

### Q3. “I found IAMReadOnlyAccess. Is it the same?”
No. `IAMReadOnlyAccess` focuses on IAM. `ReadOnlyAccess` provides broad read access across many services.

### Q4. “Why was IAMUserChangePassword automatically selected?”
AWS can attach it when console-password change is enabled. It lets the user change their own password and does not grant general administrative rights.

### Q5. “Why does IAM-user login fail even when my password is correct?”
The IAM sign-in page needs an **AWS account ID or alias**, not the root account's email address. Also verify the IAM username, password, and MFA.

### Q6. “How can I tell whether my IAM user has console access?”
Successfully signing into the AWS Management Console as that IAM user confirms console access. Individual service actions still depend on authorization.

### Q7. “Do I need to enable MFA again?”
No. I had already enrolled MFA while setting up the IAM user and successfully authenticated with it during sign-in.

### Q8. “Why can't my ReadOnlyAccess user create a group?”
Read-only permissions generally do not include `iam:CreateGroup`. An authorized administrator must create the group.

### Q9. “Why do we create IAM groups?”
To manage common team permissions consistently instead of duplicating the same policies on each user.

### Q10. “Why are my new groups empty?”
This was intentional for the lab. Empty groups let me inspect permission design without changing existing users' access.

### Q11. “Can Developers have AdministratorAccess?”
Not as a default. It grants far more authority than a normal development task requires and increases risk.

### Q12. “Why doesn't GetObject allow listing an S3 bucket?”
`GetObject` acts on object ARNs; `ListBucket` is a separate permission on the bucket ARN.

### Q13. “What is the difference between an IAM user and role?”
Users may have long-term credentials; roles are assumed to obtain temporary credentials.

### Q14. “Why should EC2 use an IAM role?”
The application can access AWS services without storing long-lived access keys on the instance.

### Q15. “Does IAM itself cost money?”
IAM user/group/role/policy management generally has no separate IAM charge. **Permissions can allow creation of chargeable resources**, and AWS budget alerts are **not** hard spending caps.

---

## 10. Troubleshooting scenarios

| Symptom | Likely cause | What to check |
|---|---|---|
| IAM user sign-in fails | Wrong account ID/alias, username, password, or MFA | IAM-specific sign-in URL and credential fields |
| Can view IAM but cannot create user | Missing `iam:CreateUser` or restrictive control | Error message, effective policies, explicit denies |
| Can download S3 object but cannot list bucket | Missing `s3:ListBucket` | Bucket ARN versus object ARN |
| EC2 cannot access S3 | Missing role, wrong permissions, bucket/key restrictions | Instance profile, role policy, S3 bucket policy, KMS |
| Cannot assume a role | Trust policy or caller authorization issue | Principal, role ARN, `sts:AssumeRole`, explicit denies |
| Policy seems to allow an action but access is denied | Another applicable deny or missing resource-level permission | SCP, permissions boundary, session/resource policies |
| Can't assign MFA to own IAM user | Missing self-service IAM permissions | Ask authorized administrator to enroll MFA |
| AWS CLI says no credentials found | CLI not configured for authorized identity | Profile/credential source; do not create root keys |

**Safe troubleshooting order:** Identify the caller → identify the attempted action → identify the resource ARN → inspect the error → inspect applicable policies/conditions → make the smallest necessary change.

---

## 11. Interview questions and model answers

### Fundamentals

**1. What is IAM?**  
AWS Identity and Access Management controls identities and their permissions to access AWS resources.

**2. Authentication versus authorization?**  
Authentication verifies identity; authorization checks permitted actions.

**3. IAM user versus group?**  
A user is an individual identity; a group organizes users and grants common permissions.

**4. IAM user versus role?**  
A user may have long-term credentials; a role is assumed and provides temporary credentials.

**5. AWS-managed versus customer-managed policy?**  
AWS maintains the former; your account creates and maintains the latter.

**6. What is least privilege?**  
Grant only the permissions needed for the intended job.

**7. Why is MFA important?**  
It reduces reliance on a single password for account access.

**8. What is default deny?**  
An action is denied unless the relevant authorization rules permit it.

**9. What is an explicit deny?**  
A matching Deny that overrides applicable Allow statements.

**10. What is an ARN?**  
An Amazon Resource Name, used to identify AWS resources.

### Scenario-based

**11. A developer needs access to one S3 bucket. What do you do?**  
Create a scoped policy granting only the necessary bucket/object actions and ARNs, then attach it to the appropriate identity or role.

**12. Why can a user open EC2 but not launch an instance?**  
Console navigation and read permissions are different from `ec2:RunInstances` authorization.

**13. How do you give 20 auditors the same permissions?**  
Use an IAM group with appropriate read-only policies; manage membership centrally.

**14. What is a role trust policy?**  
A resource-based policy identifying principals allowed to assume the role.

**15. What is `sts:AssumeRole`?**  
An STS operation that obtains temporary credentials for an assumable role, subject to authorization.

**16. How should an EC2 application authenticate to S3?**  
Use an IAM role via an EC2 instance profile and the AWS SDK's default credential provider chain.

**17. Why avoid access keys stored on EC2?**  
Long-lived secrets can be leaked, copied, or forgotten; temporary role credentials reduce that risk.

**18. What does `aws sts get-caller-identity` tell you?**  
The current principal's account, ARN, and user identifier; useful before making changes.

**19. Does `ReadOnlyAccess` mean the user can read all data?**  
No. It grants many read/list permissions, but some sensitive data operations and additional resource controls are excluded or restricted.

**20. How do you troubleshoot AccessDenied?**  
Check caller identity, action, resource ARN, identity policies, resource policies, boundaries, SCPs, session policies, conditions, and explicit denies.

**21. Are IAM groups the same as roles?**  
No. Groups aggregate IAM users; roles are assumed for temporary credentials.

**22. Does a role's trust policy grant S3 permissions?**  
No. It defines who may assume the role. A separate permissions policy governs S3 actions.

**23. What is the difference between `s3:ListBucket` and `s3:GetObject`?**  
ListBucket lists keys in a bucket; GetObject reads a specific object.

**24. Why avoid root for routine work?**  
Root has exceptional privileges; using limited identities reduces accidental and malicious impact.

**25. How do you enforce least privilege in production?**  
Start with required tasks, scope actions/resources/conditions, use roles and short-lived credentials, review access, and remove unused grants.

---

## 12. Interview cheat sheet: memorize these

```text
IAM             = Identity and Access Management
MFA             = Multi-Factor Authentication
STS             = Security Token Service
ARN             = Amazon Resource Name
IAM user        = Identity; may have long-term credentials
IAM group       = Users sharing policies
IAM role        = Assumable identity; temporary credentials
Policy          = Defines permissions
Trust policy    = Who can assume a role?
Permissions     = What can the principal do?
Implicit deny   = Default starting point
Explicit deny   = Overrides allow
GetObject       = Read S3 object
PutObject       = Write S3 object
ListBucket      = List objects in S3 bucket
ReadOnlyAccess  = Broad AWS-managed read permissions
```

## 13. Security reminders

- Use root only when necessary; prefer an authorized administrative identity for routine IAM administration.
- Protect root and IAM identities with MFA.
- Avoid storing or publishing access keys, passwords, QR codes, account IDs, or MFA recovery information.
- Never give `AdministratorAccess` merely to fix a permissions error.
- Treat `Action: "*"` and `Resource: "*"` as red flags.
- Scope policies to exact resources wherever possible.
- Remember that read-only access can still expose sensitive metadata.
- Budget alerts notify; they do **not** guarantee a zero-cost account.
- This lab did **not** require EC2, RDS, EKS, NAT gateways, load balancers, or an S3 bucket.

## 14. Remaining Day 23 review / optional practice

- [x] Verify root MFA.
- [x] Create an IAM user and verify console access.
- [x] Verify IAM-user MFA.
- [x] Inspect attached AWS-managed policies.
- [x] Create `Auditors` and `Developers` groups.
- [x] Review S3 policy JSON without attaching it.
- [x] Explain the proposed three-team permission matrix.
- [ ] Inspect EC2 role creation and trust relationship in console (not confirmed).
- [ ] Run optional AWS CLI identity checks using an authorized non-root profile (not confirmed).
- [ ] Review IAM policy evaluation and troubleshooting questions.

## 15. Useful official AWS documentation

- [IAM user guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
- [IAM policies and permissions](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)
- [How AWS evaluates policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
- [IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
- [IAM MFA](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa.html)
- [AWS CLI `get-caller-identity`](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html)

---

## 16. GitHub push commands

Save this file as `README.md` in your Day 23 folder, then from your existing repository:

```bash
cd ~/DevopsLearningJourney
mkdir -p AWS/Day23-IAM-Access-Management
# Place this README.md inside AWS/Day23-IAM-Access-Management/

git status
git add AWS/Day23-IAM-Access-Management/README.md
git commit -m "docs: complete Day 23 AWS IAM learning notes"
git push
```

If your local repository has a different folder structure, adjust the destination path. Never commit AWS credential files such as `~/.aws/credentials`, access keys, or screenshots with unredacted account information.

---

### Key takeaway

> **Authentication answers “Who are you?” Authorization answers “What can you do?” IAM groups organize permissions; IAM roles provide temporary access; least privilege and MFA protect the account.**

**Learning log:** Day 23 of the DevOps Winter Arc challenge — AWS IAM & Access Management.
