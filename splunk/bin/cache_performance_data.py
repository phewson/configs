#!/usr/bin/env python
import click
import sys
import os
import calendar
from random import randint
from time import sleep
import urllib3  # type: ignore
from datetime import datetime
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/..")
from splunk import call_splunk  # noqa [E402]
from splunk import cache_summary  # noqa [E402]
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def device_search(customer_id: str) -> str:
    query = """index="cloud_spark_{}" AND sourcetype="spark_data" AND type="Portal"
 | bin timestamp span=1month as _time
 | rename customer.id as customer_id
 | fields _time, customer_id, device_mac_address,
 | stats dc(device_mac_address) as unique_devices
 by _time, customer_id"""
    return query.format(customer_id).replace("\n", "")


def session_search(customer_id: str) -> str:
    query = """index="cloud_spark_{}" AND sourcetype="spark_data"
 AND (type="Stop" AND termination_cause!="Suspect-Logout")
 | bin timestamp span=1month as _time
 | fields unique_session_id, _time, customer_id
 | stats dc(unique_session_id) as unique_sessions
 by _time, customer_id"""
    return query.format(customer_id).replace("\n", "")


def data_usage_search(customer_id: str) -> str:
    query = """
index="cloud_spark_{}" AND sourcetype="spark_data" AND
 (type="Stop" AND termination_cause!="Suspect-Logout")
 | bin _time span=1month
 | fields unique_session_id, input_gigawords, output_gigawords, input_octets,
 output_octets, hotspot_id, customer_id, _time
 | dedup unique_session_id
 | eval
    uploaded_gb =  (((output_gigawords * 4294967296) + output_octets)/1073741824),
    downloaded_gb =  (((input_gigawords * 4294967296) + input_octets)/1073741824)
 | stats sum(uploaded_gb) as total_uploaded_gb, sum(downloaded_gb) as
 total_downloaded_gb by customer_id, _time
 | eval
    corrected_downloaded_gb=max(total_uploaded_gb, total_downloaded_gb),
    corrected_uploaded_gb=min(total_uploaded_gb, total_downloaded_gb)
 | table _time, corrected_uploaded_gb, corrected_downloaded_gb, customer_id
"""
    return query.format(customer_id).replace("\n", "")


SEARCH = {'unique_devices': device_search,
          'unique_sessions': session_search,
          'data_usage': data_usage_search}


def customer_ids() -> str:
    return 'index="cloud_spark_*" AND sourcetype="spark_data"  | stats count by customer_id'


@click.command()
@click.argument('username')
@click.argument('server')
@click.argument('year')
@click.argument('month')
@click.option('--cache_file', envvar='SPLUNK_CACHEFILE', help='Location of Splunk-cachefile')
def update_performance_cache(username, server, year, month, cache_file):
    """Gets performance data for given month and adds it to cache file

       \b
       Required arguments:
       - Splunk username
       - Splunk server (Prod or Dev)
       - year
       - month"""
    if os.path.isfile(cache_file):
        summary = cache_summary.load_cache(cache_file)
    else:
        summary = {}
    y = int(year)
    m = int(month)
    password = call_splunk.get_password()
    authdata = {"username": username, "password": password}
    target_range = (datetime(y, m, 1), datetime(y, m, 1))
    customer_id_list = call_splunk.call_splunk(
        server, authdata, 1, target_range, customer_ids(), 15, 30)
    hitlist = [c_id['customer_id'] for c_id in customer_id_list['results']]
    progress_bar = call_splunk.create_progress_bar(len(hitlist), "Customers Processed")
    whole_month = (
        datetime(y, m, 1), datetime(y, m, calendar.monthrange(y, m)[1]))
    before = datetime.now()
    write_results = cache_summary.create_write_results(year, month)
    for i, c_id in enumerate(hitlist):
        output = call_splunk.call_splunk(
            server, authdata, 1, whole_month, SEARCH['unique_sessions'](c_id))
        if output.get("results"):
            write_results(summary, output['results'], 'unique_sessions')
        output = call_splunk.call_splunk(
            server, authdata, 1, whole_month, SEARCH['unique_devices'](c_id))
        if output.get("results"):
            write_results(summary, output['results'], 'unique_devices')
        output = call_splunk.call_splunk(
            server, authdata, 1, whole_month, SEARCH['data_usage'](c_id))
        if output.get("results"):
            write_results(summary, output['results'], 'corrected_uploaded_gb')
            write_results(summary, output['results'], 'corrected_downloaded_gb')
        progress_bar(i)
        sleep(randint(1, 5))
    after = datetime.now()
    print("Time taken (min)", (after - before).total_seconds() / 60)
    cache_summary.save_cache(summary, cache_file)


if __name__ == '__main__':
    update_performance_cache()
#  [{'_time': '2020-01-01T00:00:00.000+00:00', 'customer_id': '206', 'unique_devices': '250'}]

# {'preview': False, 'init_offset': 0, 'messages': [],
# 'fields':
#     [{'name': '_time', 'groupby_rank': '0'},
#     {'name': 'customer_id', 'groupby_rank': '1'}, {'name': 'unique_devices'}],
# 'results': [
#    {'_time': '2020-01-01T00:00:00.000+00:00', 'customer_id': '220', 'unique_devices': '38021'}],
# 'highlighted': {}}
