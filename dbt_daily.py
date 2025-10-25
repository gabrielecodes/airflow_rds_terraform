from __future__ import annotations

import logging
from datetime import datetime

from airflow.hooks.base import BaseHook
from airflow.decorators import dag, task
from airflow.providers.docker.hooks.docker import DockerHook

log = logging.getLogger(__name__)

SSM_PARAMETER_NAME = "/airflow/connections/postgres_url"
CONN_ID = "postgres_conn"
DBT_ECR_IMAGE = (
    "<aws_account_id>.dkr.ecr.<aws_region>.amazonaws.com/<container-name>:latest"
)
DOCKER_CONN_ID = "docker_default"


@dag(
    owner="airflow",
    depends_on_past=False,
    start_date=datetime(2025, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=[
        "dbt",
        "docker",
    ],
)
def dbt_run():
    @task
    def run_dbt_in_docker_securely():
        """
        Extracts rds connection parameters, and executes
        the Docker container running dbt
        """

        conn = BaseHook.get_connection(CONN_ID)

        docker_hook = DockerHook(docker_conn_id=DOCKER_CONN_ID)

        log.info(f"Executing container: {DBT_ECR_IMAGE}")

        docker_hook.run(
            image=DBT_ECR_IMAGE,
            command=["dbt", "run", "--profiles-dir", "."],
            environment=conn,
            auto_remove=True,
            network_mode="bridge",
        )

        log.info("Docker container execution (dbt run) completed successfully.")

    run_dbt_in_docker_securely()


dbt_run()
