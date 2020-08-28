import os
import pytest  # type: ignore
from copy import deepcopy
from testfixtures import TempDirectory  # type: ignore
from splunk import cache_summary


@pytest.fixture
def summary():
    return {"2": {"2020": {"1": {"download": "12.32"}}}}


@pytest.fixture
def summary_with_dup():
    return {"2": {"2020": {
        "1": {"download": "12.32", "download_dup_some_date": "dup_999"}},
        "2": {"download": "14"}
    }}


def test_construct_key(summary):
    assert cache_summary._construct_key(2, 1999, 12, "party") == "2/1999/12/party"


def test_label_mismatch_value(summary):
    key, value = cache_summary._label_mismatch_value(summary, "2/2020/1/download", 999)
    assert "2/2020/1/download_dup_" in key
    assert value == "dup_999"
    assert summary == {'2': {'2020': {'1': {'download': '12.32'}}}}


def test_insert_mutate(summary):
    s = deepcopy(summary)
    cache_summary._insert_mutate(s, "3/2020/1/download", "45")
    assert len(s) == 2


def test_display_duplicates(summary_with_dup):
    dd = cache_summary.create_display_duplicates(cache_summary._filter_dups)
    assert dd(summary_with_dup) == {'2': {'2020': {'1': {'download_dup_some_date': 'dup_999'}}}}


def test_mutate_datastore(summary):
    cache_summary.mutate_datastore(summary, "1", "2020", "1", "download", "143")
    assert summary["1"] == {"2020": {"1": {"download": "143"}}}


def test_queryfile_to_str():
    with TempDirectory() as tempdir:
        tempdir.write("test.json", b'{"a": "b"}')
        cache = cache_summary.load_cache(os.path.join(tempdir.path, 'test.json'))
    assert cache == {"a": "b"}


def test_save_cache():
    with TempDirectory() as tempdir:
        cache_summary.save_cache({"b": "c"}, os.path.join(tempdir.path, "test_write.json"))
        out = tempdir.read('test_write.json')
    assert out == b'{\n    "b": "c"\n}'


def test_create_write_results():
    write_results = cache_summary.create_write_results(1999, 2)
    out = {}
    write_results(out, [{"customer_id": 1, "value": 3}], "value")
    assert out == {'1': {'1999': {'2': {'value': 3}}}}
