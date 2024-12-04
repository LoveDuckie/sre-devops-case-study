"""
Helpers: Kubernetes
"""

import os


def is_running_in_kubernetes() -> bool:
    """
    Determine if this is running in a kubernetes cluster
    :return:
    """
    env_check = "KUBERNETES_SERVICE_HOST" in os.environ
    service_account_path = "/var/run/secrets/kubernetes.io/serviceaccount/"
    file_check = os.path.exists(service_account_path)
    return env_check and file_check
