# aws-lambda-kms-encryption

**Maintained by [@goci-io/prp-terraform](https://github.com/orgs/goci-io/teams/prp-terraform)**

![terraform](https://github.com/goci-io/aws-lambda-kms-encryption/workflows/terraform/badge.svg?branch=master)

This module provisions an en- and decryption Lambda using the Node.js AWS SDK with an AWS KMS key. 
Additionally a log group is created for each lambda with a retention of 5 days. Key rotation is enabled.
A role which allows the Lambda to en- and decrypt valus and write to the log group is assigned as lambda execution role.

Checkout the [encryption](src/encrypt.js) or [decryption](src/decrypt.js) source code.

## Usage

```hcl
module "encryption" {
  source     = "git::https://github.com/goci-io/aws-lambda-kms-encryption.git?ref=tags/<latest-version>"
  namespace  = "goci"
  stage      = "staging"
  region     = "eu1"
}
```

For more examples look into the [terraform.tfvars](terraform.tfvars.example) example.

Keep in mind that your encrypted values will be stored in your Terraform state file. Make sure to have an encrypted backend configured to store the state. For example you can use the s3 [tfstate-backend](https://github.com/goci-io/tfstate-backend-aws) module to provision an encrypted S3 Bucket as backend.

## Encrypt values
To store encrypted values in your repository you need to encrypt the value manually by using the encryption lambda.

You can also use the provided [Makefile](Makefile) to en- or decrypt values using `make encrypt` and `make decrypt`. 
You may also provide `STAGE` argument to `make` to build the correct lambda function name.

_-- or --_

### Use AWS Console

1. Go to [Lambda](https://eu-central-1.console.aws.amazon.com/lambda/home?region=eu-central-1#/functions)  
2. Choose encrypt or decrypt function  
3. Create a new test payload (see below)  
4. Execute the test and grab the result  
5. __Delete your test!!!__

Example payload:

```json
{
  "secret-1": "my-secret",
  "secret-2": "..."
}
```

## Usage in Terraform

This module is mainly designed to be used in Terraform. You can either build the lambda function name by relying on the convention applied to the name or import it from remote state.
The convention applied to the lambda function name follows this: `<namespace>-<stage>-<name>-<attributes>-[encrypt|decrypt]`. 
The name defaults to `encryption`. An example could be `goci-staging-encryption-encrypt`.
When using the remote state to import the function name you can use something like:

```hcl-terraform
data "terraform_remote_state" "encryption" {
  backend = "s3"

  config {
    bucket = var.tf_bucket
    key    = "encryption/eu1.tfstate"
  }
}
```

### How-To
Accept a variable of an encrypted value in your `variables.tf`. 
Send the encrypted variable to the decrypt lambda. Store the result safely or just use it for the moment.

#### Single values
```hcl-terraform

# Example for decrypting a single value
data "aws_lambda_invocation" "decrypt_pwd" {
  input         = "{\"value\": \"${var.encrypted_value}\"}"
  function_name = "${data.terraform_remote_state.encryption.outputs.decrypt_function}"
}

# Result
data.aws_lambda_invocation.decrypt_pwd.result_map["result"]
```

#### Multi values (maps & lists) 
```hcl-terraform
locals {
  lambda_payload = {
    list = [
       { key-1 = "my secret" },
       { key-2 = "another secret" },
     ],
     map = {
        key-3 = "secret in a map",
        key-4 = "another secret in a map"
     }
  }
}

# Invoce the desired lambda function to retrieve values
data "aws_lambda_invocation" "encrypt_values" {
  input         = jsonencode(local.lambda_payload)
  function_name = data.terraform_remote_state.encryption.outputs.encrypt_function
}

# Result:
data.aws_lambda_invocation.encrypt_values.result_map["key-1"]
data.aws_lambda_invocation.encrypt_values.result_map["key-2"]
data.aws_lambda_invocation.encrypt_values.result_map["key-3"]
data.aws_lambda_invocation.encrypt_values.result_map["key-4"]
```
