from splunk import call_splunk
import pytest  # type: ignore
import requests
from datetime import datetime


def test_format_date_range():
    dr = (datetime(2019, 1, 1), datetime(2019, 1, 5))
    f, t = call_splunk._format_date_range(dr)
    assert f == ("2019-01-01T00:00:00")
    assert t == ("2019-01-05T23:59:59")


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_requests_search_finished(requests_mock):
    requests_mock.get(
        "https://splunktest.com/services/search/jobs/999",
        json={"entry": [{"content": {"dispatchState": "DONE"}}]})
    r = call_splunk._search_finished("Test", 999, {"username": "a_user"}, 5, 2)
    assert r


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_execute_call(requests_mock):
    url = "https://splunktest.com/whacky/endpoint"
    requests_mock.post(url, json={"greetings": "earthling"})
    f = call_splunk.create_call(url, False, {}, {}, (2, 5))
    out = call_splunk._execute_call(f)
    assert out.json() == {"greetings": "earthling"}


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_execute_call_exceptions(requests_mock):
    url = "https://splunktest.com/whacky/endpoint"
    requests_mock.post(url, exc=requests.exceptions.Timeout)
    with pytest.raises(SystemExit) as e:
        f = call_splunk.create_call(url, False, {}, {}, (2, 5))
        call_splunk._execute_call(f)
        assert e.type == SystemExit
        assert e.value == 1
    requests_mock.post(url, exc=requests.exceptions.ConnectionError)
    with pytest.raises(SystemExit):
        f = call_splunk.create_call(url, False, {}, {}, (2, 5))
        call_splunk._execute_call(f)
        assert e.type == SystemExit
        assert e.value == 1
    requests_mock.post(url, exc=requests.exceptions.RequestException)
    with pytest.raises(SystemExit):
        f = call_splunk.create_call(url, False, {}, {}, (2, 5))
        call_splunk._execute_call(f)
        assert e.type == SystemExit
        assert e.value == 1


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_token(requests_mock):
    url = "https://splunktest.com/services/auth/login"
    requests_mock.post(url, json={"sessionKey": "ThisIsAKey"})
    out = call_splunk._token("Test", {})
    assert out == {"Authorization": "Splunk ThisIsAKey"}


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_token_exceptions(requests_mock):
    url = "https://splunktest.com/services/auth/login"
    requests_mock.post(url, status_code=616)
    with pytest.raises(SystemExit) as e:
        out = call_splunk._token("Test", {})
        assert out.status_code == 616
    assert e.type == SystemExit


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_start_search(requests_mock):
    url = "https://splunktest.com/services/search/jobs"
    requests_mock.post(url, json={"sid": "999"})
    start_search = call_splunk.create_start_search("This is a splunk query")
    out = start_search("Test", {}, 1, (datetime(2020, 1, 1), datetime(2020, 1, 2)))
    assert out == "999"
    url = "https://splunktest.com/services/search/jobs?sample_ratio=2"
    requests_mock.post(url, json={"sid": "999"})
    out = start_search("Test", {}, 2, (datetime(2020, 1, 1), datetime(2020, 1, 2)))
    assert out == "999"


@pytest.mark.filterwarnings('ignore::urllib3.exceptions.InsecureRequestWarning')
def test_splunk_results(requests_mock):
    url = "https://splunktest.com/services/search/jobs/314/results?output_mode=json&count=0"
    requests_mock.get(url, json={"splunk": "results"})
    results = call_splunk.splunk_results("Test", {}, 314)
    assert results == {"splunk": "results"}
