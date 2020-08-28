import pytest  # type: ignore
import requests
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
SPLUNK_QUERY_REPO = Path(os.environ['SPLUNK_QUERY_REPO'])


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
                [{'device_mac_address': mac1, 'customer_id': '1', 'type': 'Start',
                 'timestamp': run_docker.timestamp(2020, 1, 1, 1, 1)}],
                [{'device_mac_address': mac1, 'customer_id': '1', 'type': 'Start',
                 'timestamp': run_docker.timestamp(2020, 1, 1, 1, 2)},
                 {'device_mac_address': mac2, 'customer_id': '1', 'type': 'Start',
                 'timestamp': run_docker.timestamp(2020, 1, 1, 1, 2)}]
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


@pytest.fixture
def single_user_single_session():
    mac_address = next(sim_sparkdata.gen_mac_address())
    reg_date = sim_sparkdata.timestamp(2020, 3, 4, 12, 0)
    session_start_date = sim_sparkdata.timestamp(2020, 3, 5, 12, 5)
    session_end_date = sim_sparkdata.timestamp(2020, 3, 5, 12, 35)
    subscriber_email = sim_sparkdata.ff(1234, 1)[0]["sub_email"]
    registration = sim_sparkdata.Registration(
        device_mac_address=mac_address, timestamp=reg_date, form_data_email=subscriber_email,
        view="NewUser")
    session_start = sim_sparkdata.Session(
        timestamp=session_start_date, device_mac_address=mac_address, unique_session_id=12)
    session_end = sim_sparkdata.Session(
        timestamp=session_end_date, device_mac_address=mac_address, unique_session_id=12,
        type="Stop")
    sim = {
        'template_file': ['registration_events.jinja'] + ['session_events.jinja'],
        'sim_filename': 'one_session.json',
        'simulation': [[registration._asdict()], [session_start._asdict(), session_end._asdict()]]}
    return sim


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_single_user_single_session_events_loaded(http_service, single_user_single_session):
    search_string = 'search ' + 'sourcetype="_json" AND index="wibble" | stats count'
    results = RUN_TEST(http_service, single_user_single_session, search_string, 'sim_host')
    print(results)
    assert results[0]['count'] == '3'


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_single_user_single_session_email_count(http_service, single_user_single_session):
    search_string = 'search ' + 'sourcetype="_json" AND index="dibble" and type="Portal" '
    search_string += '| rename form_data.* as form_data_* | stats dc(form_data_email) as emails'
    results = RUN_TEST(http_service, single_user_single_session, search_string, 'sim_host')
    assert results[0]['emails'] == '1'


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_single_user_single_session_one_session(http_service, single_user_single_session):
    search_string = 'search ' + 'sourcetype="_json" AND index="topcat" '
    search_string += '| transaction unique_session_id '
    search_string += 'endswith=(type="Stop") startswith=(type="Start") '
    search_string += '| fields duration, _time'
    results = RUN_TEST(http_service, single_user_single_session, search_string, 'sim_host')
    assert results[0]['duration'] == '1800'


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_single_user_single_session_report(http_service, single_user_single_session):
    search_string = 'search index="kippers" AND ' + run_docker.queryfile_to_str(
        SPLUNK_QUERY_REPO / "splunk_code_snippets/usage_by_email.spl")
    search_string = run_docker.change_sourcetype(search_string, "_json")
    print(search_string)
    results = RUN_TEST(http_service, single_user_single_session, search_string, 'sim_host')
    print("RESULTS>............RESULTS")
    print(results)
    assert 1 == 2
