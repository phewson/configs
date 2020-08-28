import requests
import time
import ast
import re
import subprocess
from pprint import pprint
from pathlib import Path
from typing import Dict, Any, Callable, List, NamedTuple
from . import sim_sparkdata
# http.server.BaseHTTPRequestHandler.responses


HTTP_CODES = {"OK": 200, "Created": 201, "Not Found": 404}

RestFuncs = NamedTuple('RestFuncs', [
    ('delete', Callable),
    ('get', Callable),
    ('post', Callable)
    ])
RestInfo = NamedTuple('RestInfo', [
    ('data', Dict[str, Any]),
    ('params', Dict[str, Any])
    ])
DockerInfo = NamedTuple('DockerInfo', [
    ('host_data_folder', Path),
    ('template_folder', Path),
    ('guest_data_folder', Path)
    ])
SplunkInfo = NamedTuple('SplunkInfo', [
    ('filename', str),  # simulated data docker guest filename
    ('host', str),  # fake hostname (for splunk index)
    ('index', str),  # name of splunk index
    ('search', str),  # search string
    ('earliest', str),  # earliest search date
    ('latest', str)  # latest search date
    ])
Dates = NamedTuple('Dates', [
    ('e', str),
    ('l', str)
    ])


def queryfile_to_str(filename: Path) -> str:
    with open(filename, "r") as fn:
        query = fn.read().replace('\n', '')
    return query


def get_index_name(splunk_query: str, alternative_name: str = "testing") -> str:
    poss_name = re.search(r"(?<=index\=\")\w+(?=\")", splunk_query.replace(" ", ""))
    return alternative_name if not poss_name else poss_name.group()


def requests_delete_function(
        http_service: str, endpoint: str, header: Dict[str, Any],
        param: Dict[str, Any]) -> requests.Response:
    response = requests.delete(
        http_service + endpoint, verify=False, headers=header, params=param)
    err_msg = "Was expecting either 200 (deleted) or 404 (no index), instead got {}"
    h_code = response.status_code
    assert h_code in [HTTP_CODES['OK'], HTTP_CODES['Not Found']], err_msg.format(h_code)
    return response


def requests_get_function(
        http_service: str, endpoint: str, header: Dict[str, Any],
        param: Dict[str, Any]) -> requests.Response:
    response = requests.get(
        http_service + endpoint, headers=header, verify=False, params=param)
    return(response)


def requests_post_function(
        http_service: str, endpoint: str, token: Dict[str, Any], data: Dict[str, Any],
        param: Dict[str, Any], status_code: int) -> requests.Response:
    response = requests.post(
        http_service + endpoint, verify=False, headers=token,
        data=data, params=param)
    h_code = response.status_code
    assert h_code == status_code, "Post at {} received {} status code".format(endpoint, h_code)
    return response


def search_status(sitrep: Dict[str, List[Dict[str, Any]]]) -> bool:
    status = sitrep.get('entry')
    if status:
        return status[0]['content']['dispatchState'] == "DONE"
    else:
        return False


def search_finished(
        http_service: str, sid: str, get_function: Callable,
        header: Dict[str, str], max_attempts: int = 30, gap: float = 0.5) -> bool:
    sitrep = {}  # type: Dict[str, List[Dict[str, Any]]]
    i = 0
    while not (search_status(sitrep)) and i < max_attempts:
        response = get_function(
            http_service, "/search/jobs/{}".format(sid), header, {"output_mode": "json"})
        sitrep = response.json()
        time.sleep(gap)
        i += 1
    return i < max_attempts


def authentication_token(
        http_service: str, post_function: Callable,
        data: Dict[str, Any], params: Dict[str, Any]) -> Dict[str, Any]:
    response = post_function(
        http_service, "/auth/login", {}, data, params, HTTP_CODES['OK'])
    key = ast.literal_eval(response.content.decode('utf8')).get("sessionKey")
    return {"Authorization": "Splunk {}".format(key)}


def change_sourcetype(query: str, sourcetype_name: str) -> str:
    return re.sub(r"spark_data", sourcetype_name, query)


def check_index(response_json: Dict[str, Any], index: str) -> List[Any]:
    return [i for i in response_json['entry'] if i['name'] == index]


def load_and_test(http_service, rest_funcs: RestFuncs, rest_info: RestInfo,
                  splunk_info: SplunkInfo) -> Dict[str, Any]:
    token = authentication_token(http_service, rest_funcs.post, rest_info.data, rest_info.params)
    endpoint = "/data/indexes/{}".format(splunk_info.index)
    response = rest_funcs.delete(http_service, endpoint, token, rest_info.params)
    d_status = response.status_code
    response = rest_funcs.get(http_service, "/data/indexes", token, rest_info.params)
    msg = "Index should have been removed, status reported {}"
    assert len(check_index(response.json(), splunk_info.index)) == 0, msg.format(d_status)
    endpoint = "NS/nobody/search/data/indexes"
    payload = {"name": splunk_info.index}
    response = rest_funcs.post(
        http_service, endpoint, token, payload, rest_info.params, HTTP_CODES['Created'])
    response = rest_funcs.get(http_service, "/data/indexes", token, rest_info.params)
    p_status = response.status_code
    msg = "Index not created, delete requests status: {}, post request status: {}"
    index_created = check_index(response.json(), splunk_info.index)
    assert len(index_created) == 1, msg.format(d_status, p_status)
    assert index_created[0]['content']['totalEventCount'] == 0, "Index is not empty"
    payload_data = {"name": splunk_info.filename, "host": splunk_info.host,
                    "index": splunk_info.index, "sourcetype": "_json"}
    endpoint = "/data/inputs/oneshot"
    response = rest_funcs.post(
        http_service, endpoint, token, payload_data, rest_info.params, HTTP_CODES['Created'])
    search_payload = {
        'search': splunk_info.search, 'earliest_time': splunk_info.earliest, 'latest_time': splunk_info.latest}
    response = rest_funcs.post(
        http_service, "/search/jobs", token, search_payload,  rest_info.params, HTTP_CODES['Created'])
    sid = response.json().get('sid')
    endpoint = "/search/jobs/{}/results".format(sid)
    results = {}  # type: Dict[str, Any]
    if search_finished(http_service, sid, rest_funcs.get, token):
        post_oneshot_index = rest_funcs.get(http_service, "/data/indexes", token, rest_info.params)
        index_state = check_index(post_oneshot_index.json(), splunk_info.index)
        assert index_state[0]['content']['totalEventCount'] > 0, "Index is still empty"
        pprint(index_state[0])
        response = rest_funcs.get(http_service, endpoint, token, rest_info.params)
        results = response.json().get('results')
    return results


def check_file_exists(guest_fn: str) -> int:
    out = subprocess.Popen(['docker', 'ps'], stdout=subprocess.PIPE)
    stdout, _ = out.communicate()
    container = stdout.decode('utf-8').split()[-1]
    return subprocess.call(['docker', 'exec', container, 'test', '-f', guest_fn])


def create_test(
        dock_info: DockerInfo, rest_funcs: RestFuncs, rest_info: RestInfo, dates: Dates) -> Callable:
    def run_test(http_service: str, sim_info: Dict[str, Any], search_string: str,
                 sim_host: str) -> Dict[str, Any]:
        host_simfile_path = dock_info.host_data_folder / sim_info['sim_filename']
        sim_sparkdata.render_write(
            sim_info['simulation'], dock_info.template_folder,
            sim_info['template_file'], host_simfile_path)
        index_name = get_index_name(search_string)
        guest_fn = str(dock_info.guest_data_folder / sim_info['sim_filename'])
        assert check_file_exists(guest_fn) == 0, "File not found on guest container"
        splunk_spec = SplunkInfo(guest_fn, sim_host, index_name, search_string, dates.e, dates.l)
        results = load_and_test(http_service, rest_funcs, rest_info, splunk_spec)
        return results
    return run_test
