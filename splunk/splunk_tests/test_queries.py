import pytest  # type: ignore
import requests
import os
from pathlib import Path
from requests.exceptions import ConnectionError
from splunk import run_docker


TEST_AUTH = ('admin', 'ChangeMe123')
PARAMS = {"output_mode": "json"}
DATA = dict(zip(("username", "password"), TEST_AUTH))
GUEST_DATA_FOLDER = Path("/home/data/")
HOST_DATA_FOLDER = Path(os.environ['TEST_DATA_HOME'])
TEMPLATE_FOLDER = HOST_DATA_FOLDER.parent / "templates"
REST_DEFAULT = run_docker.RestFuncs(
    run_docker.requests_delete_function, run_docker.requests_get_function,
    run_docker.requests_post_function)
REST_INFO = run_docker.RestInfo(DATA, PARAMS)
DOCKER_INFO = run_docker.DockerInfo(HOST_DATA_FOLDER, TEMPLATE_FOLDER, GUEST_DATA_FOLDER)
DATES = run_docker.Dates("-5year@year", "now")
RUN_TEST = run_docker.create_test(DOCKER_INFO, REST_DEFAULT, REST_INFO, DATES)


@pytest.fixture
def two_events():
    mac = run_docker.gen_mac_address()
    return {'template_file': 'session_events.jinja',
            'sim_filename': 'simple_two.json',
            'simulation': [
                {'device_mac_address': next(mac), 'customer_id': '1', 'type': 'Start',
                 'timestamp': str(run_docker.timestamp(2020, 1, 1, 1, 1))},
                {'device_mac_address': next(mac), 'type': 'Start',
                 'timestamp': str(run_docker.timestamp(2020, 1, 1, 1, 2))}
            ]}


@pytest.fixture
def three_events_two_macs():
    mac = run_docker.gen_mac_address()
    mac1 = next(mac)
    mac2 = next(mac)
    return {'template_file': 'session_events.jinja',
            'sim_filename': 'three_events_two_macs.json',
            'simulation': [
                {'device_mac_address': mac1, 'customer_id': '1', 'type': 'Start',
                 'timestamp': run_docker.timestamp(2020, 1, 1, 1, 1)},
                {'device_mac_address': mac1, 'customer_id': '1', 'type': 'Start',
                 'timestamp': run_docker.timestamp(2020, 1, 1, 1, 2)},
                {'device_mac_address': mac2, 'customer_id': '1', 'type': 'Start',
                 'timestamp': run_docker.timestamp(2020, 1, 1, 1, 2)}
            ]}


def is_responsive(url):
    try:
        response = requests.get(url, auth=TEST_AUTH, verify=False)
        if response.status_code == 200:
            return True
    except ConnectionError:
        return False


@pytest.fixture(scope="session")
def http_service(docker_ip, docker_services):
    port = docker_services.port_for("splunkenterprise", 8089)
    url = "https://{}:{}/services".format(docker_ip, port)
    docker_services.wait_until_responsive(
        timeout=150.0, pause=0.1, check=lambda: is_responsive(url)
        )
    return url
