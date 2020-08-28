from splunk import run_docker
import requests  # noqa: F401
import os
from pathlib import Path
import pytest  # type: ignore
from testfixtures import TempDirectory  # type: ignore

HOST_DATA_FOLDER = Path(os.environ['TEST_DATA_HOME'])
TEMPLATE_FOLDER = HOST_DATA_FOLDER.parent / "templates"


def test_queryfile_to_str():
    with TempDirectory() as tempdir:
        tempdir.write("test.spl", b'index = "main" \n| eval count \n| table count')
        query = run_docker.queryfile_to_str(os.path.join(tempdir.path, 'test.spl'))
    assert query == 'index = "main" | eval count | table count'


def test_check_index():
    no_index = {"entry": [{"name": "barry"}]}
    assert run_docker.check_index(no_index, "garry") == []
    index = {"entry": [{"name": "barry"}, {"name": "garry"}]}
    assert run_docker.check_index(index, "garry") == [{"name": "garry"}]


def test_check_file_exists():
    assert run_docker.check_file_exists("not_here.json") == 1


def test_get_index_name():
    assert run_docker.get_index_name("gordon is a moron") == "testing"
    assert run_docker.get_index_name("gordon is a moron", "alt") == "alt"
    assert run_docker.get_index_name('index="barry" | now do something', "alt") == "barry"
    assert run_docker.get_index_name('index="barry" index="garry"', "alt") == "barry"
    assert run_docker.get_index_name('index ="barry" | now do something', "alt") == "barry"
    assert run_docker.get_index_name('index = "barry" | now do something', "alt") == "barry"


def test_search_status():
    assert run_docker.search_status({"entry": [{"content": {"dispatchState": "DONE"}}]})
    assert not run_docker.search_status({"entry": [{"content": {"dispatchState": "NOT"}}]})
    assert not run_docker.search_status({})


def test_requests_post_function(requests_mock):
    requests_mock.post("http://test.com/endpoint", text="Done")
    r = run_docker.requests_post_function(
        "http://test.com", "/endpoint", {"Authorization": "Splunk 999"},
        {"username": "a_user", "password": "a_pword"}, {"param": "value"}, 200)
    assert r.text == "Done"
    assert r.status_code == 200
    assert r.url == "http://test.com/endpoint?param=value"
    assert r.request.headers['Authorization'] == "Splunk 999"


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_requests_post_function_status_check(requests_mock):
    requests_mock.post("https://test.com/endpoint", text="Done")
    with pytest.raises(AssertionError) as error:
        run_docker.requests_post_function(
            "https://test.com", "/endpoint", {"Authorization": "Splunk 999"},
            {"username": "a_user", "password": "a_pword"}, {"param": "value"}, 199)
    assert str(error.value) == "Post at /endpoint received 200 status code"


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_requests_delete_function(requests_mock):
    requests_mock.delete("https://test.com/endpoint/index/index_exists")
    r = run_docker.requests_delete_function(
        "https://test.com", "/endpoint/index/index_exists",
        {"Authorization": "Splunk 999"}, {"param": "value"})
    assert r.status_code == 200
    assert r.url == "https://test.com/endpoint/index/index_exists?param=value"
    assert r.request.headers['Authorization'] == "Splunk 999"
    # {'User-Agent': 'python-requests/2.22.0', 'Accept-Encoding': 'gzip, deflate',
    # 'Accept': '*/*', 'Connection': 'keep-alive', 'a': 'b', 'Content-Length': '0'}


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_requests_authentication_token(requests_mock):
    requests_mock.post("https://test.com/endpoint/auth/login", json={"sessionKey": 999})
    r = run_docker.authentication_token(
        "https://test.com/endpoint", run_docker.requests_post_function,
        {"username": "a_user", "password": "a_password"}, {"param": "value"})
    assert r['Authorization'] == "Splunk 999"


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_requests_search_finished(requests_mock):
    requests_mock.get(
        "https://test.com/endpoint/search/jobs/999",
        json={"entry": [{"content": {"dispatchState": "DONE"}}]})
    r = run_docker.search_finished(
        "https://test.com/endpoint", 999, run_docker.requests_get_function,
        {"username": "a_user"})
    assert r


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_requests_search_not_finished(requests_mock):
    requests_mock.get(
        "https://test.com/endpoint/search/jobs/999",
        json={"entry": [{"content": {"dispatchState": "WAITING"}}]})
    r = run_docker.search_finished(
        "https://test.com/endpoint", 999, run_docker.requests_get_function,
        {"username": "a_user"}, max_attempts=2, gap=0.1)
    assert not r


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_requests_search_not_replied(requests_mock):
    requests_mock.get(
        "https://test.com/endpoint/search/jobs/999", json={})
    r = run_docker.search_finished(
        "https://test.com/endpoint", 999, run_docker.requests_get_function,
        {"username": "a_user"}, max_attempts=2, gap=0.1)
    assert not r


def test_change_sourcetype():
    query1 = 'index = "bananas" AND sourcetype = "spark_data"'
    changed_q1 = run_docker.change_sourcetype(query1, "apples")
    assert changed_q1 == 'index = "bananas" AND sourcetype = "apples"'
    query2 = 'sourcetype="spark_data"'
    assert run_docker.change_sourcetype(query2, "apples") == 'sourcetype="apples"'
    query3 = 'sourcetype="spark_data" AND waffle AND sourcetype = "spark_data"'
    changed_q3 = run_docker.change_sourcetype(query3, "apples")
    assert changed_q3 == 'sourcetype="apples" AND waffle AND sourcetype = "apples"'
