# asoloa.com.tf

![asoloa.com.tf Architecture](assets/asoloa.com.tf_Architecture.png)
**NOTE:** Not every resources and processes are shown in the diagram above.

For a broader view of the architecture, see [asoloa.com Architecture](assets/asoloa.com_Architecture.png).
\
For the full mapping of the resources, see [resource dependency graph](assets/graph.png).

\
List of Modules (creation and configuration):
- **acm** → handles the ACM certificate for our domain
- **api_gateway** → API endpoint that invokes our Lambda function
- **cloudfront** → distribution that serves our site assets securely
- **dynamodb** → database that stores our view count data
- **github** → uses outputs from other modules to store as secrets
- **hostinger** → adds the necessary DNS records (CAA, ALIAS, validation)
- **lambda** → function that processes the view count data
- **s3** → bucket and CloudFront origin that hosts our site assets

&nbsp;
### terraform.tfvars
```hcl
hostinger_api_token = "HOSTINGER_API_TOKEN"
github_token        = "GITHUB_TOKEN"
github_repo         = "GITHUB_REPO"

aws_region = "us-east-1"
access_key = "AWS_ACCESS_KEY"
secret_key = "AWS_SECRET_KEY"

domain_name         = "EXAMPLE.COM"
dynamodb_table      = "MY_TABLE"
site_files_path     = "../SITE_REPO"
site_files_git_repo = "https://github.com/USER/SITE_REPO.git"
view_count_html_id  = "HTML_ID_FOR_VIEW_COUNT"
```

&nbsp;
### backend.tf & state.config
I am using S3 to store the state file and using [Partial configuration](https://developer.hashicorp.com/terraform/language/backend#partial-configuration).

Apply the necessary permissions on the backend bucket as shown [here](https://developer.hashicorp.com/terraform/language/backend/s3#permissions-required).
```hcl
### ./backend.tf 
terraform {
  backend "s3" {
    bucket       = ""
    key          = ""
    region       = ""
    use_lockfile = true
  }
}

### ./state.config
bucket       = "xxx-bucket"
key          = "terraform.tfstate"
region       = "us-east-1"
use_lockfile = true
```


