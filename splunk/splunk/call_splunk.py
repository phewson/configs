import sys
import logging
from getpass import getpass
import requests
import requests.exceptions
from time import sleep
from typing import Dict, Any, List, Tuple, Callable
from datetime import datetime
import urllib3  # type: ignore
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%m-%d %H:%M',
                    filename='splunk_queries.log',
                    filemode='w')
logger = logging.getLogger("Splunk History")

CHARS_IN_BAR = 60
PARAMS = {"output_mode": "json", "count": "0"}
URLS = {"Dev": "https://splunk-search-dev.wifispark.net:8089",
        "Prod": "https://splunksearch.wifispark.net:8089",
        "Test": "https://splunktest.com"}
EPS = {"auth": "services/auth/login", "search": "services/search/jobs",
       "results": "services/search/jobs/{}/results", "ready": "services/search/jobs/{}"}


def _format_date_range(date_range: Tuple[datetime, datetime]) -> Tuple[str, str]:
    return ("{}T00:00:00".format(date_range[0].strftime("%Y-%m-%d")),
            "{}T23:59:59".format(date_range[1].strftime("%Y-%m-%d")))


def create_call(url: str, verify: bool, authdata: Dict[str, Any], params: Dict[str, Any],
                timeout: Tuple[float, float]) -> Callable[[], requests.Response]:
    def call() -> requests.Response:
        response = requests.post(
            url, verify=verify, data=authdata, params=params, timeout=timeout)
        return response
    return call


def _execute_call(func: Callable[[], requests.Response]) -> requests.Response:
    try:
        response = func()
    except requests.exceptions.Timeout as e:
        print("Timeout, is the server running", e)
        sys.exit(1)
    except requests.exceptions.ConnectionError as e:
        print("Connection Error", e)
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print("Don't now what went wrong", e)
        sys.exit(1)
    return response


def _token(server: str, authdata: Dict[str, Any]) -> Dict[str, str]:
    url = "/".join([URLS[server], EPS['auth']])
    f = create_call(url, False, authdata, PARAMS, (5, 15))
    response = _execute_call(f)
    if response.status_code != 200:
        print("Status code {}: wrong password?".format(response.status_code))
        sys.exit(1)
    token = response.json()['sessionKey']
    return {"Authorization": "Splunk {}".format(token)}


def create_start_search(query: str):
    def start_search(server: str, token: str, sample_ratio: int,
                     date_range: Tuple[datetime, datetime]) -> Dict[str, str]:
        start, stop = _format_date_range(date_range)
        search = {"search": query, "earliest_time": start, "latest_time": stop}
        if sample_ratio > 1:
            search['sample_ratio'] = str(sample_ratio)
        response = requests.post(
            "/".join([URLS[server], EPS['search']]), headers=token, verify=False, data=search, params=PARAMS)
        return response.json().get('sid')
    return start_search


def _search_status(sitrep: Dict[str, List[Dict[str, Any]]]) -> bool:
    status = sitrep.get('entry')
    if status:
        return status[0]['content']['dispatchState'] == "DONE"
    else:
        return False


def _search_finished(
        server: str, sid: str, token: Dict[str, str],
        max_attempts: int, gap: float) -> bool:
    sitrep = {}  # type: Dict[str, List[Dict[str, Any]]]
    i = 0
    while not (_search_status(sitrep)) and i < max_attempts:
        response = requests.get(
            "/".join([URLS[server], EPS['ready'].format(sid)]),
            headers=token, params=PARAMS, verify=False)
        sitrep = response.json()
        sleep(gap)
        i += 1
    return i < max_attempts


def splunk_results(server: str, token: Dict[str, str], sid: str) -> Dict[str, Any]:
    response = requests.get(
        "/".join([URLS[server], EPS['results'].format(sid)]),
        headers=token, verify=False, params=PARAMS)
    return response.json()


def get_password() -> str:
    print("Enter your Splunk password: ")
    password = getpass()
    print("Please re-type your passwork: ")
    if password == getpass():
        print("passwords match, trying Splunk")
    else:
        print("Password does not match. Please try again")
        sys.exit(1)
    return password


def call_splunk(
        server: str, authdata: Dict[str, Any], sample_ratio: str,
        target_range: Tuple[datetime, datetime], query: str,
        max_attempts: int = 24, gap: float = 2.5) -> Dict[str, Any]:
    t = _token(server, authdata)
    _search = create_start_search("search {}".format(query.replace('\n', '')))
    sid = _search(server, t, int(sample_ratio), target_range)
    logger.info("Job Reference Number (sid): {}".format(sid))
    output = {}  # type: Dict[str, Any]
    if _search_finished(server, sid, t, max_attempts, gap):
        output = splunk_results(server, t, sid)
    return output


def create_progress_bar(total: int, status: str) -> Callable[[int], None]:
    def progress_bar(count: int) -> None:
        filled_len = int(round(CHARS_IN_BAR * count / float(total)))
        percent = round(100.0 * count / float(total), 1)
        bar = '=' * filled_len + '-' * (CHARS_IN_BAR - filled_len)
        sys.stdout.write('{} {}% ...{}\r'.format(bar, percent, status))
        sys.stdout.flush()
    return progress_bar
