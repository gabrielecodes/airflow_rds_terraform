# Airflow + Postgres RDS instance (master + 2 replicas) on AWS

This config setups an airflow instance available to your IP only (SSH and Web access are granted via Security Group Ingress rules)
plus a Postgres RDS instance with a master and 2 replicas in different zones and in private subnets.

You can acces the Airflow instance with its url and use the `username` and `password` to login.

# Setup

## Prerequisites

You need:

1. a valid aws region where to provision the resources (e.g. "us-west-1").
2. A project name (e.g. "my-airflow-rds-project").
3. An AWS account with access to Secrets Manager.

### Step 1

Clone this repo and use the command

```
terraform init
```

to initialize terraform. Then use

```
terraform plan
```

to check the resources provisioned by this repo. Finally apply this config to provision the resouces with

```
terraform apply
```

The config creates an RDS instance with a password stored in the Secret Manager.

## SSH Access to the Airflow frontend

To access the Airflow frontend via SSH, ensure you have the appropriate SSH key. The system is preconfigured to accept SSH connections, so no additional setup is required beyond providing the correct key.
Generate the key with the following command:

```
ssh-keygen -t rsa -b 2048 -m PEM -f terraform_ec2_key
```

which generates in the current directory a public (terraform_ec2_key.pub) and private key.
Use the private key to connect via SSH to the instance with:

```
ssh -i terraform_ec2_key ubuntu@<public_ip_address>
```

The public IP address of the instance is visible via the AWS console.
