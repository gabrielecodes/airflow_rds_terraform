# Terraform Config: Airflow + Postgres RDS instance on AWS

This Terraform configuration provides an isolated environment for data orchestration by deploying Apache Airflow on an EC2 instance, backed by a PostgreSQL RDS database within a private AWS subnet. This setup is provides a platform for managing data pipelines and workflows and run DBT.

# What you get

This configuration provisions the following key components to establish your data orchestration environment:

1.  **Airflow EC2 Instance:** A dedicated EC2 instance running the Apache Airflow frontend, providing a web-based interface to monitor and manage your DAGs. (Note: HTTPS is not configured in this version).
2.  **PostgreSQL RDS Database:** A fully managed AWS RDS instance with a PostgreSQL database, serving as a data warehouse.
3.  **S3 Bucket for DAGs:** An S3 bucket designated for storing your Airflow DAGs.

# Setup

## Prerequisites

You need:

1. a valid aws region where to provision the resources (e.g. "us-west-1").
2. A project name (e.g. "my-airflow-rds-project").
3. You will be prompted by terraform for a `username` and `password` for the Airflow frontend as well as for a `username` and `password` for the RDS instance.
   The RDS `username` and `password` are never stored as environment variables.
4. You will also be prompted for a bucket name. Airflow DAGs are stored in this bucket.

### Step 1

The Airflow security group allows your IP to connect via SSH using a key.
If less restrictive rules are desired, modify the security group of the Airflow EC2 instance by adding ingress rules.

The first step is to generate the SSH key:

```
ssh-keygen -t rsa -b 4096 -m PEM -f <key_name>
```

which generates a public key (file `<key_name>.pub`) and private key (file `<key_name>`) in the current directory.
Use the private key to connect via SSH to the instance with:

```
ssh -i <key_name> ubuntu@<public_ip_address>
```

The public IP address of the instance is visible via the AWS console.

### Step 2

Clone this repo and use the command

```
terraform init
```

to initialize terraform. Then use

```
terraform plan
```

to check the resources provisioned by this repo. Finally apply this config to provision the resources with

```
terraform apply
```

It will take up to 5 minutes for Airflow to be up and running.

### Step 4

Add an Airflow Connection to the postgres RDS instance via the UI.
You'll need the following parameters:

```
connection type: 'postgres'
connection host: rds address visible via the AWS console, RDS page
connection login: the username you've chosen (see [prerequisites](#prerequisites))
connection password: the password you've chosen (see [prerequisites](#prerequisites))
connection schema: the name of the schema in the postgres database
connection port: port for the postgres database (see AWS console), typically 5432
```

You can add a DAG to the bucket and it will be added to Airflow within 30 seconds.

## Running DBT in a DAGs

An example of Airflow DAG executing `dbt run` is available in the script `dbt_daily.py`.
Replace the variable `DBT_ECR_IMAGE` with the name of the image containing your dbt project.
The container should have:

- an installation of `dbt-core` and `dbt-postgres`.
- a clone of your dbt repository.
- Configure the `profile.yaml` of your dbt project to use environment variables (see example below)

Here is an example of `profiles.yml`:

```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: postgres
      host: "{{ env_var('DBT_HOST') }}"
      user: "{{ env_var('DBT_USER') }}"
      password: "{{ env_var('DBT_PASSWORD') }}"
      port: 5432
      dbname: "{{ env_var('DBT_DBNAME') }}"
      schema: public
```

## TODO

1. Generate a certificate and add a proxy and enable HTTPS
2. Add a cronjob to renew the certificate
