import operator
from typing import Dict, Any, List, Tuple, Optional
from datetime import datetime, timedelta
from ua_parser import user_agent_parser  # type: ignore
from collections import Counter
# os.environ["UA_PARSER_YAML"] = "~/Downloads/regexes.yaml"


def _date_range(input_date: Optional[str]) -> Tuple[datetime, datetime]:
    target_date = datetime.today() if not input_date else datetime.strptime(input_date, "%Y-%m-%d")
    return _previous_week(target_date)


def _previous_week(date: datetime) -> Tuple[datetime, datetime]:
    start = date - timedelta(days=date.weekday()+8)
    end = date - timedelta(days=date.weekday()+1)
    return (start, end)


def nested_count(d, lookup: List[str]) -> List[Counter]:
    if len(lookup) == 2:
        foo = [
            Counter({u['ua'][lookup[0]][lookup[1]]: int(u.get('count', 0))}) for u in d]
    elif len(lookup) == 3:
        foo = [
            Counter({"{}-{}".format(
                u['ua'][lookup[0]][lookup[1]], u['ua'][lookup[0]][lookup[2]]):
                     int(u.get('count', 0))}) for u in d]
    elif len(lookup) == 4:
        foo = [Counter({
            "{}-{}-{}".format(
                u['ua'][lookup[0]][lookup[1]], u['ua'][lookup[0]][lookup[2]],
                u['ua'][lookup[0]][lookup[3]]): int(u.get('count', 0))}) for u in d]
    return foo


def _sum_counters(counters: List[Counter]) -> Counter:
    sum_counter = Counter()  # type: Counter
    for counter in counters:
        sum_counter = sum_counter + counter
    return sum_counter


def _parse(search_results: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    return [{
        "ua": user_agent_parser.Parse(ua['user_agent.browser_name']), "count": ua['count']}
            for ua in search_results]


def _int(i: Optional[str]) -> int:
    return 0 if not i else int(i)


def _check_results(results: Dict[Any, Any]) -> Dict[str, Any]:
    return {r['user_agent.Browser']: _int(r['count']) for r in results}


def _main_summary(d, what):
    r = {}
    for k, v in what.items():
        r[k] = _sum_counters(nested_count(d, v))
    return r


def summary(d, what):
    r = _main_summary(d, what)
    r["unmatched_browser"] = {p['ua']['string']: _int(p['count']) for p in
                              d if "Other" in p['ua']['user_agent']['family']}
    r["unmatched_device"] = {p['ua']['string']: _int(p['count']) for p in
                             d if p['ua']['device'].get('brand', None) is None}
    return r


def _sort_results(data: Dict[str, Any]) -> Tuple[List, List]:
    sorted_by_value = sorted(data.items(), key=operator.itemgetter(1), reverse=True)
    return[k[0] for k in sorted_by_value], [v[1] for v in sorted_by_value]
