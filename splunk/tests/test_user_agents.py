from splunk import user_agents
import pytest  # type: ignore
from collections import Counter
from datetime import datetime
from faker import Faker  # type: ignore

UA_LOOKUPS = {
    "browser": ('user_agent', 'family'),
    "browser_version": ('user_agent', 'family', 'major'),
    "os": ('os', 'family'),
    "os_version": ('os', 'family', 'major', 'minor'),
    "device": ('device', 'brand'),
    "device_model": ('device', 'brand', 'model')}


@pytest.fixture
def nested_data():
    two = [{"ua": {"a": {"b": "beta"}}, "count": 1}]
    three = [{"ua": {"a": {"b": "beta", "c": "gamma"}}, "count": 2}]
    four = [{"ua": {"a": {"b": "beta", "c": "gamma", "d": "delta"}}, "count": 3}]
    return (two, three, four)


@pytest.fixture
def nested_data_one():
    string = """'Mozilla/5.0 (iPod; U; CPU iPhone OS 3_0 like Mac OS X; mt-MT)
 AppleWebKit/532.39.3 (KHTML, like Gecko)
 Version/3.0.5 Mobile/8B118 Safari/6532.39.3""".replace("\n", "")
    return [{'ua': {
        'user_agent': {
            'family': 'Mobile Safari', 'major': '3', 'minor': '0', 'patch': '5'},
        'os': {
            'family': 'iOS', 'major': '3', 'minor': '0', 'patch': None, 'patch_minor': None},
        'device': {
            'family': 'iPod', 'brand': 'Apple', 'model': 'iPod'},
        'string': string},
             'count': 666}]


@pytest.fixture
def nested_data_three():
    string = """'Mozilla/5.0 (iPod; U; CPU iPhone OS 3_0 like Mac OS X; mt-MT)
 AppleWebKit/532.39.3 (KHTML, like Gecko)
 Version/3.0.5 Mobile/8B118 Safari/6532.39.3""".replace("\n", "")
    return [
        {'ua': {
            'user_agent': {
                'family': 'Mobile Safari', 'major': '3', 'minor': '0', 'patch': '5'},
            'os': {
                'family': 'iOS', 'major': '3', 'minor': '0', 'patch': None, 'patch_minor': None},
            'device': {
                'family': 'iPod', 'brand': 'Apple', 'model': 'iPod'},
            'string': string},
         'count': 6},
        {'ua': {
            'user_agent': {
                'family': 'Other', 'major': '3', 'minor': '0', 'patch': '5'},
            'os': {
                'family': 'iOS', 'major': '3', 'minor': '0', 'patch': None, 'patch_minor': None},
            'device': {
                'family': 'iPod', 'brand': 'Apple', 'model': 'iPod'},
            'string': 'No Browser'},
         'count': 5},
        {'ua': {
            'user_agent': {
                'family': 'Mobile Safari', 'major': '3', 'minor': '0', 'patch': '5'},
            'os': {
                'family': 'iOS', 'major': '3', 'minor': '0', 'patch': None, 'patch_minor': None},
            'device': {
                'family': 'iPod', 'brand': None, 'model': 'iPod'},
            'string': 'No Brand'},
         'count': 4}]


def test_sum_counters():
    r = [Counter({"a": 2, "b": 3}), Counter({"a": 2, "c": 5})]
    output = user_agents._sum_counters(r)
    assert output == Counter({"a": 4, "b": 3, "c": 5})


def test_int():
    assert user_agents._int(None) == 0
    assert user_agents._int(1) == 1
    assert user_agents._int("1") == 1


def test_sort_results():
    data = {"a": 1, "b": 5, "c": 3}
    k, v = user_agents._sort_results(data)
    assert k == ["b", "c", "a"]
    assert v == [5, 3, 1]


def test_parse():
    f = Faker()
    Faker.seed(0)
    user_agent = f.user_agent()
    r = [{"user_agent.browser_name": user_agent, "count": 10}]
    out = user_agents._parse(r)
    print(out)
    assert out[0]['ua']['string'] == user_agent
    assert out[0]['ua']['user_agent']['family'] == 'Mobile Safari'
    assert out[0]['count'] == 10


def test_date_range():
    output = user_agents._date_range("2020-02-01")
    assert output == (datetime(2020, 1, 19, 0, 0), datetime(2020, 1, 26, 0, 0))
    output = user_agents._date_range(None)
    assert len(output) == 2


def test_nested_data(nested_data):
    assert user_agents.nested_count(nested_data[0], ["a", "b"])[0]["beta"] == 1
    assert user_agents.nested_count(nested_data[1], ["a", "b", "c"])[0]["beta-gamma"] == 2
    assert user_agents.nested_count(nested_data[2], ["a", "b", "c", "d"])[0]["beta-gamma-delta"] == 3


def test_main_summary(nested_data_one):
    r = user_agents._main_summary(nested_data_one, UA_LOOKUPS)
    assert len(r.keys()) == 6
    assert type(r['device']) == Counter
    assert list(r['browser'].values()) == [666]


def test_summary(nested_data_three):
    r = user_agents.summary(nested_data_three, UA_LOOKUPS)
    assert len(r.keys()) == 8
    assert r['browser']['Mobile Safari'] == 10
    assert r['browser']['Other'] == 5
    assert r['unmatched_browser']['No Browser'] == 5
    assert r['unmatched_device']['No Brand'] == 4


def test_check_results():
    r = [{"user_agent.Browser": "Opera", "count": 6}, {"user_agent.Browser": "IE2", "count": 666}]
    out = user_agents._check_results(r)
    assert out == {"Opera": 6, "IE2": 666}
