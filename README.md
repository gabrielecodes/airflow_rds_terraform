# Teffaform Config: Airflow + Postgres RDS instance on AWS

This config setups an airflow instance available to your IP only (SSH and Web access are granted via Security Group Ingress rules)
plus a Postgres RDS instance with a master and 2 replicas in different zones and in private subnets.

You can acces the Airflow instance with its url and use the `username` and `password` to login.

# What you get

1. An EC2 instance running the Airflow frontend (_no https in this version_).
2. An RDS instance with a master and 2 replicas that servers as main database.
3. Airflow is configures to run[ dbt](https://www.getdbt.com/) on the RDS instance to generate tables.

# Setup

## Prerequisites

You need:

1. a valid aws region where to provision the resources (e.g. "us-west-1").
2. A project name (e.g. "my-airflow-rds-project").
3. An AWS account with access to Secrets Manager.
4. You will be prompted by terraform for a `username` and `password` for the Airflow frontend as well as for a `username` for the RDS instance.
   The password is automatically created and saved in the Secrets Manager.

### Step 1

The Airflow instance is configured to accept SSH connections allowing your IP to connect.
If less restrictive rules are desired, modify the airflow security group adding ingress rules.

The first step is to generate the SSH key:

```
ssh-keygen -t rsa -b 4096 -m PEM -f <key_name>
```

which generates in the current directory a public key (file `<key_name>.pub`) and private key (file `<key_name>`).
Use the private key to connect via SSH to the instance with:

```
ssh -i <key_name> ubuntu@<public_ip_address>
```

The public IP address of the instance is visible via the AWS console and it's also written as an output by terraform (see the variable `airflow_public_ip` in `airflow/outputs.tf`). Consider removing this output for production builds.

### Step 2

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

You will be prompted for the `username` and `password` for the Airflow frontend and for a `username` for the RDS instance. The RDS password is saved in the Secrets Manager.
It will take up to 5 minutes for Airflow to be up and running.

## TODO

1. Generate a certificate and add a proxy and enable HTTPS
2. Add a cronjob to renew the certificate
3. Add a table of "dbt runs" that collect all the dbt runs and their state
