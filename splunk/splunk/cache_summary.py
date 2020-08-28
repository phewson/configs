import json
import dpath.util  # type: ignore
from datetime import datetime
from typing import Dict, Any, Callable, Tuple, List
from pathlib import Path


def load_cache(filename: Path) -> Dict[str, Any]:
    with open(filename) as f:
        cache = json.load(f)
    return cache


def save_cache(data_store: Dict[str, Any], filename: Path) -> None:
    with open(filename, 'w') as fn:
        json.dump(data_store, fn, indent=4, sort_keys=True)


def _construct_key(customer_id, year, month, data_type):
    return "{}/{}/{}/{}".format(customer_id, year, month, data_type)


def _label_mismatch_value(data_store: Dict[str, Any], key: str, datum: str) -> Tuple[str, str]:
    if dpath.util.search(data_store, key) != {}:
        if dpath.util.get(data_store, key) != datum:
            key = key + "_dup_{}".format(datetime.today())
            datum = "dup_{}".format(datum)
    return key, datum


def _insert_mutate(data_store: Dict[str, Any], key: str, datum: str) -> None:
    dpath.util.new(data_store, key, datum)


def mutate_datastore(
        data_store: Dict[str, Any], customer_id: int, year: int, month: int,
        data_type: str,  datum: str) -> None:
    key = _construct_key(customer_id, year, month, data_type)
    key, datum = _label_mismatch_value(data_store, key, datum)
    _insert_mutate(data_store, key, datum)


def _filter_dups(text: str) -> bool:
    strtext = str(text)
    if "dup_" in strtext:
        return True
    return False


def create_display_duplicates(dup_filter: Callable[[str], bool]):
    def display_duplicates(data_store: Dict[str, Any]) -> Dict[str, Any]:
        return dpath.util.search(data_store, '**', afilter=dup_filter)
    return display_duplicates


def create_write_results(
        year: int, month: int) -> Callable[[Dict[str, Any], List[Dict[str, Any]], str], None]:
    def write_results(
            data_cache: Dict[str, Any], results: List[Dict[str, Any]], variable: str) -> None:
        if len(results) == 1:
            mutate_datastore(
                data_cache, results[0]['customer_id'], year, month, variable, results[0][variable])
    return write_results
