# Machine Learning Specialist Test - PicPay

## Introduction
This repository provides the code for deploying a data pipeline using AWS. This data pipeline consists on triggering a Lambda function that calls an API which provides random generated data. These data are forwarded then for a Kinesis Stream which serves two Firehose Delivery Streams. One of these, delivery raw data on a S3 bucket. The other one extracts certain fields then delivery those also on S3 but in a separated bucket.

Now you have two options:
- Continue reading this awesome README (just keep scrolling);
- [Screw that sh*t, I just want to run this](##Instructions)



### Architecture
The original architecture was re-drawed in order to group the used services in layers for a better code organization, cost analysis and comprehension of the solution in general. The result is the following:

![Alt text](img/architecture.png?raw=true  "Data Pipeline Architecture")

Those layers were designed to reliabillitly attend the Single-responsibility principle, that we can list as follows:
 - **ingestion:** Responsible only for providing data;
 - **serving:** Responsible for guarantee that raw data will be **available** for any consumer in low latency;
 - **etl-raw:** Responsible for storaging raw data;
 - **etl-cleaned:** Responsible for clean and storage cleaned data;
 - **consume:** Responsible for comporting consuming services.

## General Definitions
### Project Structure
The project was physical structured following [Terraform recommendation](https://www.terraform.io/docs/language/modules/develop/structure.html) looking something like this:
```
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── ...
├── modules/
│   ├── nestedA/
│   │   ├── README.md
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   ├── nestedB/
│   ├── .../
├── examples/
│   ├── exampleA/
│   │   ├── main.tf
│   ├── exampleB/
│   ├── .../
```
Where:

> **`main.tf`,  `variables.tf`,  `outputs.tf`**. These are the recommended filenames for a minimal module, even if they're empty.
> `main.tf` should be the primary entrypoint. For a simple module, this
> may be where all the resources are created. For a complex module,
> resource creation may be split into multiple files but any nested
> module calls should be in the main file. `variables.tf` and
> `outputs.tf` should contain the declarations for variables and
> outputs, respectively.

source: [https://www.terraform.io/docs/language/modules/develop/structure.html](https://www.terraform.io/docs/language/modules/develop/structure.html)

As suggested above, the entry point to this project is located at `main.tf` file at the root path. This is the entry point for the root module and this module will call its children.

### Naming Convention
For service naming, a derivation of AWS recommendation was applied. Basically the services names is composed by 3 groups separated by *undescore* (_):
 1. **account-name prefix**: for example, production, development, shared-services, audit, etc. 
 2. **resource-name**: free-form field for the logical name of the resource
 3. **type suffix**: for example, subnet, sg, role, policy, kms-key, etc

### Tagging
The tagging strategy were designed to provide visibility for the services allocated in this project by three aspects: `enviroment`, `project` and `layer`. This structure allows this project to coexist with other projects in the same account, being easily identified and billed. The following table shows an example of tagging for a ingestion layer located service:

|tag    |value           |
|:-------:|:----------------:|
|env    |dev             |
|project|picpay-audition |
|layer  |ingestion       |

## Instructions
This project is mainly developed using Terraform which is a language for developing Infra As Code (IaC). So you need to initialize the the repository:

    $ terraform init

After doing this, the second command would be run the code by running the `apply` command. But, you'll have to provide valid credentials as `access_key` and `secret_key` are required variables for running this code. Given that, is recommended that you create a `.tfvar` file providing your keys and apply the code using the following command:

    $ terraform apply -var-file="path/to/aws-keys.tfvars" -auto-approve

The `-auto-approve` option will save you some time avoiding the need of typing 'yes' every time.
A valid `.tfvars` file should look something like:

    access_key="<your_access_key_here>"
    secret_key="<your_access_key_here>"

### Known bugs and needed improvements
- Account alias querying not working, so `account_alias` and `account_id` were hardcoded;
- IAM role definition could be better, however, the time wasn't enough to get this section better. So other aspects were priorized like code organization and better framework usage;
- Python lambda layer dependency manual generation/versioning. For automating this section both 'zip' and 'python' function would be required on a well known environment;
- Stage layer is partitioned by firehose. Firehose defines UTC timestamp for partitioning, this may create non-truth partitioning.

## References
- Python documentation - https://www.python.org/dev/peps/pep-0257/
- AWS Naming Convention: https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/other-aws-resource-types.html
- Cost allocation tagging: https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/best-practices-for-cost-allocation-tags.html
- Terraform structure best practices - https://www.terraform.io/docs/language/modules/develop/structure.html
