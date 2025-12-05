# Terraform AWS Large Language Model (LLM) Infrastructure

The main purpose of this repository is to create an [AWS EC2](https://aws.amazon.com/ec2/) instance that will run a large language model (LLM) using
an the [Ollama](https://ollama.com/) server. Along side other resources such as [AWS App Runner](https://aws.amazon.com/apprunner/).

## Development

### Dependencies

- [aws-vault](https://github.com/99designs/aws-vault)
- [terraform](https://www.terraform.io/)
- [terragrunt](https://terragrunt.gruntwork.io/)
- [terraform-docs](https://terraform-docs.io/) this is required for `terraform_docs` hooks
- [pre-commit](https://pre-commit.com/)

## Prerequisites

1. Have a [AWS account](https://aws.amazon.com/free) account and [associated credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html).
2. You may need to [request a service quote increase](https://docs.aws.amazon.com/servicequotas/latest/userguide/request-quota-increase.html) for example for [AWS EC2](http://aws.amazon.com/contact-us/ec2-request) you will not be able to deploy resources until the request has been completed by AWS:
   - Running On-Demand G and VT instances
   - All G and VT Spot Instance Requests

## Usage

1. Navigate to the environment you would like to deploy,
2. Create the S3 bucket for your Terraform state file:
   
   ```bash
   aws-vault exec <profile> --no-session terragrunt backend bootstrap
   ```

3. Initialize the configuration with:
   
   ```bash
   aws-vault exec <profile> --no-session terragrunt init
   ```

4. Plan your changes with:
   
   ```bash
   aws-vault exec <profile> --no-session terragrunt plan
   ``` 

5. If you're happy with the changes:
   
   ```bash
   aws-vault exec <profile> --no-session terragrunt apply
   ```

> [!NOTE]
>
> Please note that terragrunt will create an S3 Bucket and DynamoDB table for storing the remote state. 
> Ensure the account deploying the resources has the appropriate permissions to create or connect to these resources.

## Pre-Commit hooks

Git hook scripts are very helpful for identifying simple issues before pushing any changes. Hooks will run on every commit automatically pointing out issues in the code e.g. trailing whitespace.

To help with the maintenance of these hooks, [pre-commit](https://pre-commit.com/) is used, along with [pre-commit-hooks](https://pre-commit.com/#install).

Please following [these instructions](https://pre-commit.com/#install) to install `pre-commit` locally and ensure that you have run `pre-commit install` to install the hooks for this project.

Additionally, once installed, the hooks can be updated to the latest available version with `pre-commit autoupdate`.

## Documentation Generation

Code formatting and documentation for `variables` and `outputs` is generated using [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform/releases) hooks that in turn uses [terraform-docs](https://github.com/terraform-docs/terraform-docs) that will insert/update documentation. The following markers have been added to the `README.md`:
```
<!-- {BEGINNING|END} OF PRE-COMMIT-TERRAFORM DOCS HOOK --->
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK --->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7, <= 1.13.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.19.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.19.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.ollama_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.main_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.ollama_developer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_resourcegroups_group.project_resource_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group) | resource |
| [aws_route_table.main_public_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.main_route_table_public_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.sg_ollama_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.main_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_security_group_egress_rule.allow_outbound_http_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allow_outbound_https_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_ollama_server_communication_for_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_ssh_tcp_for_users](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [tls_private_key.ollama_developer_ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_availability_zones.available_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [http_http.aws_check_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_developer_access_ip_addresses"></a> [additional\_developer\_access\_ip\_addresses](#input\_additional\_developer\_access\_ip\_addresses) | Map of developer name and their IP address to access<br>various resources. | `map(string)` | `{}` | no |
| <a name="input_allowed_account_ids"></a> [allowed\_account\_ids](#input\_allowed\_account\_ids) | List of allowed AWS account IDs to prevent you<br>from mistakenly using an incorrect one. | `list(string)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region. | `string` | n/a | yes |
| <a name="input_env_prefix"></a> [env\_prefix](#input\_env\_prefix) | The prefix added to resources in the environment. | `string` | n/a | yes |
| <a name="input_ollama_default_model_installed"></a> [ollama\_default\_model\_installed](#input\_ollama\_default\_model\_installed) | The Ollama model to be pulled from registry,<br>ready to be invoked. | `string` | `"gemma3n:e4b"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | List of the Availability Zone names available to the account. |
| <a name="output_current_caller_identity"></a> [current\_caller\_identity](#output\_current\_caller\_identity) | AWS Account ID number of the account that owns or contains the <br>calling entity. |
| <a name="output_ec2_ollama_server_instance_public_dns"></a> [ec2\_ollama\_server\_instance\_public\_dns](#output\_ec2\_ollama\_server\_instance\_public\_dns) | Public DNS name assigned to the instance. |
| <a name="output_ec2_ollama_server_instance_public_ip_address"></a> [ec2\_ollama\_server\_instance\_public\_ip\_address](#output\_ec2\_ollama\_server\_instance\_public\_ip\_address) | Public IP address assigned to the instance. |
| <a name="output_ollama_developer_key_pair_name"></a> [ollama\_developer\_key\_pair\_name](#output\_ollama\_developer\_key\_pair\_name) | The key pair name. |
| <a name="output_tls_ollama_developer_private_key"></a> [tls\_ollama\_developer\_private\_key](#output\_tls\_ollama\_developer\_private\_key) | Private key data in PEM (RFC 1421) format for connecting to the EC2<br>instance hosting the Ollama server. |
| <a name="output_tls_ollama_developer_public_key"></a> [tls\_ollama\_developer\_public\_key](#output\_tls\_ollama\_developer\_public\_key) | Public key data in PEM (RFC 1421) format for connecting to the EC2<br>instance hosting the Ollama server. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK --->
