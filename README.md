# Teffaform Config: Airflow + Postgres RDS instance on AWS

This config setups an airflow instance available to your IP only (SSH and Web access are granted via Security Group Ingress rules)
plus a Postgres RDS instance with a master and 2 replicas in different zones and in private subnets.

You can acces the Airflow instance with its url and use the `username` and `password` to login.

# What you get

1. An EC2 instance running the Airflow frontend (_no https in this version_).
2. An RDS instance with a master and 2 replicas that servers as main database.
3. A bucket where to load the DAGs that will be available in Airflow.
4. Airflow is configured to run[ dbt](https://www.getdbt.com/) on the RDS instance to generate tables.

# Setup

## Prerequisites

You need:

1. a valid aws region where to provision the resources (e.g. "us-west-1").
2. A project name (e.g. "my-airflow-rds-project").
3. You will be prompted by terraform for a `username` and `password` for the Airflow frontend as well as for a `username` and `password` for the RDS instance.
   Note that the RDS `username` and `password` are never stored as environment variables. They are used to launch the instance and stored in SSM as `SecretString`.
   They be retrieved in dags as shown below in the section [Running DAGs on the RDS Postgres Database](#running-dags-on-the-rds-postgres-database)
4. You will also be prompted for a `bucket name for the Airflow dags. Airflow ill pick them up from that bucket.

### Step 1

The Airflow instance is configured to accept SSH connections allowing your IP to connect.
If less restrictive rules are desired, modify the security group of the airflow ec2 instance adding ingress rules.

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

It will take up to 5 minutes for Airflow to be up and running.

### Step 3

Use the private key generated in [step 1](#step-1) to SSH into the instance and clone your
dbt repository at a chosen path. (see`/path/to/dbt/` referenced later). You'll need git
credentials to perform this step or perform this step as part of a deployment strategy (e.g. with
GitHub Actions or similar).

### Step 4

Add a dag to the bucket and it will be picked up by Airflow within 30 seconds.

## Running DAGs on the RDS Postgres Database

In order not to store usernames and passwords

The dbt `profiles.yaml` must be configured to reach the RDS instance. Here is an example:

```yaml
my_project:
  target: dev
  outputs:
    dev:
      type: postgres
      host: "{{ env_var('DBT_HOST') }}"
      port: 5432
      user: "{{ env_var('DBT_USER') }}"
      password: "{{ env_var('DBT_PASSWORD') }}"
      dbname: my_database
      schema: public
```

To run commands like `dbt run` in a DAG, you can use a DockerOperator passing the environment
variables necessaty to run `dbt`. Here below `/path/to/dbt` is the path where the `dbt` repo
has been cloned.

```py
DockerOperator(
    task_id="dbt_run",
    image="ghcr.io/dbt-labs/dbt-postgres:1.9.latest",
    command="dbt run",
    environment={
        "DBT_HOST": "{{ var.value.rds_host }}",
        "DBT_USER": "{{ var.value.rds_username }}",
        "DBT_PASSWORD": "{{ var.value.rds_password }}"
    },
    volumes=["/path/to/dbt:/usr/dbt"],
    working_dir="/usr/dbt",
    auto_remove=True,
)
```

## TODO

1. Generate a certificate and add a proxy and enable HTTPS
2. Add a cronjob to renew the certificate
