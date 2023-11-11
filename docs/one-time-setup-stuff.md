# one-time-setup-stuff

There are a few, important pregame steps:

1 - Install some required programs first:

* [homebrew]
* [awscli] 
  * macOS: `brew install awscli`
  * Ubuntu: `sudo apt-get update && sudo apt-get install awscli`
* [keybase] - used to cryptographically validate the Terraform package
  * macOS: `brew install --cask keybase`
  * Install it, open it and configure it. 
  * **Leave `keybase` running during the Terraform install**
* [Terraform]
  * via `tfenv`; `brew install tfenv` [quickstart]
* [IntelliJ] Community Edition
  * macOS: `brew install intellij-idea-ce`
    * install the Terraform plugin
    * Preferences > Plugins > Search: [Terraform and HCL]
    * Install this plugin and restart IntelliJ
* [helm] 3.x
  * macOS: `brew install kubernetes-helm`
  * [Debian/Ubuntu]

2 - Set your project environment variables in `build.env`

_NOTE: It's not necessary to purchase a domain but your experimentation will produce better results if you do._ Register a domain in AWS - _ONLY_, then create a public zone and record these details in `build.env`


3- Always check your build variables; on a new job use a later version of the [AWS Provider].

4 - Source-in build variables:

`source build.env <stage|prod>`; E.G.:

`source build.env stage`

4 - Create the project bucket; it should look like this:

```shell
% scripts/setup/create-backend-resources.sh

Provisioning state Storage and Locking mechnanism...
Region set to: us-west-2
  Creating a DynamoDB table for state locking; ignore the above error...
{
    "TableDescription": {
        "AttributeDefinitions": [
            {
                "AttributeName": "LockID",
                "AttributeType": "S"
            }
        ],
        "TableName": "tf-state-gitops-demo-stage-lock",
        "KeySchema": [
            {
                "AttributeName": "LockID",
                "KeyType": "HASH"
            }
        ],
        "TableStatus": "CREATING",
        "CreationDateTime": "2021-11-14T14:49:36.645000-08:00",
        "ProvisionedThroughput": {
            "NumberOfDecreasesToday": 0,
            "ReadCapacityUnits": 5,
            "WriteCapacityUnits": 5
        },
        "TableSizeBytes": 0,
        "ItemCount": 0,
        "TableArn": "arn:aws:dynamodb:us-west-2:299285526804:table/tf-state-gitops-demo-stage-lock",
        "TableId": "f0c35dea-f26e-463e-8c39-e293bffb87db",
        "SSEDescription": {
            "Status": "ENABLED",
            "SSEType": "KMS",
            "KMSMasterKeyArn": "arn:aws:kms:us-west-2:299285526804:key/35a32fdb-d6c4-4c0f-b600-947280279059"
        }
    }
}


Creating a bucket for remote terraform state...
make_bucket: tf-state-gitops-demo-stage
  The bucket has been created: tf-state-gitops-demo-stage
  Enabling versioning...
  Enabling encryption...
  Blocking public access...
  Creating Terraform backend definition...


We're ready to start Terraforming!
```

5 - Check the contents of the `provider-aws.tf` for the _**backend**_ configuration; names will be auto-populated based on the variables set in `build.env`. It should look similar to:

```terraform
% cat provider-aws.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.2.0"       # Minimum for IPv6 EKS Clusters
    }
  }
  backend "s3" {
    dynamodb_table = "tf-state-gitops-demo-stage-lock"
    bucket         = "tf-state-gitops-demo-stage"
    key            = "terraform/stage"
    region         = "us-west-2"
    encrypt        = true
    //role_arn = "arn:aws:iam:::role/terraform-backend"
  }
}

provider "aws" {
  default_tags {
    tags = {
      env            = var.envBuild
      project        = var.project
      DATADOG_FILTER = "UUID-GOES-HERE"
    }
  }
}

```

You should now be clear to build.

[homebrew]:https://brew.sh/
[aws-iam-authenticator]:https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
[awscli]:https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html
[kubectl]:https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-with-homebrew-on-macos
[native package management]:https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
[ktx]:https://github.com/heptiolabs/ktx
[Linux-install]:https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
[keybase]:https://keybase.io/docs/the_app/install_macos
[Terraform and HCL]:https://plugins.jetbrains.com/plugin/7808-terraform-and-hcl
[IntelliJ]:https://www.jetbrains.com/idea/
[helm]:https://helm.sh/docs/intro/install/#from-homebrew-macos
[Debian/Ubuntu]:https://helm.sh/docs/intro/install/#from-apt-debianubuntu
[Terraform]:https://www.hashicorp.com/blog/announcing-hashicorp-homebrew-tap
[quickstart]:https://gist.github.com/todd-dsm/1dc120506e89ec36d4d9a05ccb93f68c
[one-time setup steps]:https://github.com/todd-dsm/infras-eks/blob/main/docs/one-time-setup-stuff.md
[AWS Provider]:https://github.com/hashicorp/terraform-provider-aws/releases