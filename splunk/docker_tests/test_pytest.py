import pytest  # type: ignore
import requests
import ast
import os
from pathlib import Path
from requests.exceptions import ConnectionError
from splunk import run_docker
from splunk import sim_sparkdata


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
    mac = sim_sparkdata.gen_mac_address()
    return {'template_file': ['session_events.jinja'],
            'sim_filename': 'simple_two.json',
            'simulation': [[
                {'device_mac_address': next(mac), 'customer_id': '1', 'type': 'Start',
                 'timestamp': str(sim_sparkdata.timestamp(2020, 1, 1, 1, 1))},
                {'device_mac_address': next(mac), 'type': 'Start',
                 'timestamp': str(sim_sparkdata.timestamp(2020, 1, 1, 1, 2))}
            ]]}


@pytest.fixture
def three_events_two_macs():
    mac = sim_sparkdata.gen_mac_address()
    mac1 = next(mac)
    mac2 = next(mac)
    return {'template_file': ['session_events.jinja'],
            'sim_filename': 'three_events_two_macs.json',
            'simulation': [[
                {'device_mac_address': mac1, 'customer_id': '1', 'type': 'Start',
                 'timestamp': sim_sparkdata.timestamp(2020, 1, 1, 1, 1)},
                {'device_mac_address': mac1, 'customer_id': '1', 'type': 'Start',
                 'timestamp': sim_sparkdata.timestamp(2020, 1, 1, 1, 2)},
                {'device_mac_address': mac2, 'customer_id': '1', 'type': 'Start',
                 'timestamp': sim_sparkdata.timestamp(2020, 1, 1, 1, 2)}
            ]]}


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


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_job_list(http_service):
    # GIVEN a docker containing providing a splunk instance
    # WHEN the services/search/jobs API is directly queried with requests
    response = requests.get(
        http_service + "/search/jobs", auth=TEST_AUTH, verify=False, params=PARAMS)
    # THEN one element of the json response (origin) will exist
    assert ast.literal_eval(response.content.decode('utf8')).get("origin")
    # THEN the response status code will be 200
    assert response.status_code == 200


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_post_fail(http_service):
    # GIVEN a running docker api
    # and username/password in DATA matching the docker-compose.yml
    # and params requesting json return
    # WHEN the authentication_token function is called
    token = run_docker.authentication_token(
        http_service, run_docker.requests_post_function, DATA, PARAMS)
    # THEN token is received containing an entry
    assert token['Authorization']
    # WHEN this token is used to call a non-existent API
    # THEN a 404 is returned.
    response = run_docker.requests_post_function(
        http_service, "/non_existent/endpoint", token, {'search': '| eval count'}, PARAMS, 404)
    assert response.status_code == 404


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_two_events(http_service, two_events):
    # GIVEN a query string counting by host and fake data containing two events
    search_string = 'search index = "testing" | stats count by host'
    # WHEN the RUN_TEST function is called
    results = RUN_TEST(http_service, two_events, search_string, 'sim_host')
    # THEN the host is correctly identified and the count of results equals 2
    assert results[0]['host'] == 'sim_host'
    assert results[0]['count'] == '2'


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_three_events_two_macs(http_service, three_events_two_macs):
    # GIVEN a search string taken from file which counts by mac address
    # GIVEN data containing three events but two mac addresses
    search_string = 'search ' + run_docker.queryfile_to_str(HOST_DATA_FOLDER.parent / "single.spl")
    # WHEN the run test function is called
    results = RUN_TEST(http_service, three_events_two_macs, search_string, 'sim_host')
    # THEN the response contains a count of two (for the number of mac addresses)
    assert results[0]['count'] == '2'


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_three_events_two_macs_counts(http_service, three_events_two_macs):
    # GIVEN a search string with a different index name, and a count by host
    search_string = 'search index="bananas" | stats count by host'
    # WHEN the run test function is called on the fake data
    results = RUN_TEST(http_service, three_events_two_macs, search_string, 'sim_host')
    # THEN the results indicate a count of three events
    assert results[0]['count'] == '3'
