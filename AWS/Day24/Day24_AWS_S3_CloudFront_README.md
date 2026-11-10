# Day 24 — AWS S3 + CloudFront (Floci Local Lab)

**DevOps Winter Arc · 90 Days Challenge · AWS Week**

## Objective

Host a static HTML website in a **private, versioned S3 bucket**, configure a **CloudFront distribution** with **Origin Access Control (OAC)**, and test the website through a **local Floci emulator** without creating billable AWS resources.

> **Scope:** This lab was performed using Floci and AWS CLI in a Debian WSL2 environment. Successful emulator requests do **not** prove production AWS IAM enforcement, TLS/HTTPS, global CDN caching, or invalidation behavior.

## Architecture

```text
Visitor (curl / browser)
         |
         | Local HTTP request to Floci
         v
Floci CloudFront distribution
ID: EHKUO5KLRYQOOJ
         |
         | OAC configured: SigV4 / always
         v
Private S3 bucket: manasa-day24-training
         |-- index.html
         `-- error.html
```

**Production design:** Visitor → HTTPS → CloudFront edge → OAC-signed origin request → private S3 bucket. The S3 *REST* origin is used, not the public S3 static-website endpoint.

## Tools

- Debian under WSL2
- Docker and Floci (`http://localhost.floci.io:4566`)
- AWS CLI v2
- `curl`, `python3`, shell

## Project structure

```text
AWS/Day24/
├── day24-site/
│   ├── index.html
│   └── error.html
├── oac-config.json
├── distribution-config.json
├── bucket-policy.json
└── README.md
```

> Do not commit real AWS credentials, tokens, or secret configuration files.

## Lab walkthrough

### 1. Start Floci and configure AWS CLI

```bash
floci status
# Start Floci if needed using your installed Floci CLI.
eval "$(floci env)"
echo "$AWS_ENDPOINT_URL"   # Must be http://localhost.floci.io:4566
export BUCKET=manasa-day24-training
```

**Safety:** Verify `AWS_ENDPOINT_URL` before running AWS commands to avoid operating on a real AWS account by mistake.

### 2. Create private bucket and enable versioning

```bash
aws s3 mb "s3://$BUCKET"
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled
aws s3api get-public-access-block --bucket "$BUCKET"
aws s3api get-bucket-versioning --bucket "$BUCKET"
```

**Observed:** All four public-access-block settings were `true`; versioning status was `Enabled`.

### 3. Upload static website

The `day24-site/` directory contains `index.html` and `error.html`.

```bash
aws s3 sync ./day24-site "s3://$BUCKET"
aws s3 ls "s3://$BUCKET"
aws s3api head-object --bucket "$BUCKET" --key index.html
```

### 4. Test object versioning

Edit `day24-site/index.html`, upload it again, then list versions:

```bash
aws s3 cp ./day24-site/index.html "s3://$BUCKET/index.html"
aws s3api list-object-versions --bucket "$BUCKET" \
  --prefix index.html --no-cli-pager
```

**Observed:** Two versions of `index.html`:

| Version | Version ID | Size | Latest |
|---|---|---:|---|
| Original | `0280d742-8540-4aa2-8cab-d05675664a1c` | 265 bytes | No |
| Updated | `3a0feb08-5fb3-450b-8e13-4cb58d421e81` | 287 bytes | Yes |

Retrieve the previous version without overwriting the current website:

```bash
aws s3api get-object --bucket "$BUCKET" --key index.html \
  --version-id '0280d742-8540-4aa2-8cab-d05675664a1c' \
  /tmp/index-v1.html
cat /tmp/index-v1.html
```

### 5. Create CloudFront OAC

`oac-config.json`:

```json
{
  "Name": "day24-s3-oac",
  "Description": "Day 24 Floci CloudFront practice",
  "SigningProtocol": "sigv4",
  "SigningBehavior": "always",
  "OriginAccessControlOriginType": "s3"
}
```

```bash
aws cloudfront create-origin-access-control \
  --origin-access-control-config file://oac-config.json
aws cloudfront list-origin-access-controls
```

**Observed OAC ID:** `0c009240-0aed-4651-91c9-f0130df49878`.

### 6. Create CloudFront distribution

The `distribution-config.json` defines:

- S3 REST origin: `manasa-day24-training.s3.amazonaws.com`
- OriginAccessControlId: `0c009240-0aed-4651-91c9-f0130df49878`
- Default root object: `index.html`
- Viewer protocol policy: `redirect-to-https` (production intent)
- Allowed/cached methods: `GET`, `HEAD`
- TTLs: minimum `0`, default `60`, maximum `300` seconds
- Compression enabled

```bash
python3 -m json.tool distribution-config.json
aws cloudfront create-distribution \
  --distribution-config file://distribution-config.json
export DIST_ID=EHKUO5KLRYQOOJ
aws cloudfront get-distribution --id "$DIST_ID"
```

**Observed:** Distribution ID `EHKUO5KLRYQOOJ`, status `Deployed`, reported domain `ehkuo5klryqooj.cloudfront.net`.

### 7. Configure bucket policy for OAC

`bucket-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontRead",
      "Effect": "Allow",
      "Principal": { "Service": "cloudfront.amazonaws.com" },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::manasa-day24-training/*",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:cloudfront::000000000000:distribution/EHKUO5KLRYQOOJ"
        }
      }
    }
  ]
}
```

```bash
aws s3api put-bucket-policy --bucket "$BUCKET" \
  --policy file://bucket-policy.json
aws s3api get-bucket-policy --bucket "$BUCKET"
aws s3api get-public-access-block --bucket "$BUCKET"
```

**Note:** The `000000000000` account number is Floci's simulated account. Use your own account ID when deploying to real AWS. Policy application and final post-policy privacy checks were instructed but their outputs were not captured in the conversation.

### 8. Test local CloudFront endpoint

```bash
curl -i http://ehkuo5klryqooj.cloudfront.localhost.floci.io:4566/
```

**Observed successful response:**

```text
HTTP/1.1 200 OK
Content-Length: 287
Content-Type: text/html
ETag: "9f472d58fcacc50c8448972c8b4105fc"
```

The returned HTML contained:

```html
<h1>Hello from AWS Week - Version 2!</h1>
<h2>DevOps Winter Arc - Day 24</h2>
<p>My website has been updated.</p>
<p>Practicing S3 Object Versioning with Floci.</p>
```

This verifies that the Floci CloudFront-style endpoint served the latest HTML object. It does **not** independently prove HTTPS redirection, cache hits, or enforcement of OAC/bucket policies.

### 9. Cleanup

Stop Floci after finishing the lab:

```bash
floci stop
```

This preserves local project files. It may preserve emulator resources depending on persistence settings. To clear **all** simulated resources, inspect `floci reset --help` before using `floci reset`. Do not reset if other local labs must be retained.

For real AWS, cleanup would require disabling and deleting the distribution, removing the OAC after disassociation, deleting all S3 object versions/delete markers, and deleting the bucket; do not use emulator reset as a substitute for real AWS cleanup.

## Key learnings

1. **S3 bucket:** Stores website objects such as HTML and images.
2. **Block Public Access:** Helps prevent accidental public exposure.
3. **Versioning:** Preserves earlier object versions for recovery.
4. **CloudFront:** A CDN that serves and caches content at edge locations in real AWS.
5. **OAC:** Enables signed CloudFront origin requests to private S3.
6. **Bucket policy:** Grants `s3:GetObject` to a specific CloudFront distribution via `AWS:SourceArn`.
7. **Caching:** TTLs define intended cache lifetimes; invalidations can force refresh in real CloudFront.
8. **Emulator limits:** Local API success is not a substitute for production verification.

## Troubleshooting reminders

| Symptom | Check |
|---|---|
| AWS CLI cannot connect | `floci status`, `echo "$AWS_ENDPOINT_URL"` |
| No bucket found | `echo "$BUCKET"`, `aws s3 ls` |
| CloudFront returns 403 | Bucket policy, OAC ID, origin domain, object key |
| CloudFront returns 404 | `index.html` exists, default root object |
| Changes not visible | Object version, CDN caching, invalidation support |
| CLI JSON error | `python3 -m json.tool <file>.json` |

## Interview questions

**Why keep the S3 bucket private?** Visitors should access the site through CloudFront; public S3 access is unnecessary when CloudFront is granted appropriate origin access.

**What does OAC do?** It configures CloudFront to sign requests to an S3 origin using SigV4.

**What is versioning?** S3 stores multiple versions of an object, supporting recovery from unintended overwrites or deletions.

**What is a cache TTL?** The period a cache may retain an object before checking for a newer version, subject to caching policies.

**What is CloudFront invalidation?** A request to remove cached content from CloudFront before normal expiry; pricing can apply.

---

**Outcome:** Successfully created and tested a simulated S3 + CloudFront static website workflow using Floci, including two observed object versions and an HTTP 200 response from the local CloudFront endpoint.
