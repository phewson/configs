#!/usr/bin/env python
import click
import sys
import os
import calendar
import urllib3  # type: ignore
from datetime import datetime
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/..")
from splunk import call_splunk  # noqa [E402]
from splunk import cache_summary  # noqa [E402]
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def device_search(customer_id: int) -> str:
    query = """index="cloud_spark_{}" AND sourcetype="spark_data" AND type="Portal"
 | bin timestamp span=1month as _time
 | rename customer.id as customer_id
 | fields _time, customer_id, device_mac_address,
 | stats dc(device_mac_address) as unique_devices
 by _time, customer_id"""
    return query.format(customer_id).replace("\n", "")


def customer_ids() -> str:
    return 'index="cloud_spark_*" AND sourcetype="spark_data"  | stats count by customer_id'


@click.command()
@click.argument('username')
@click.argument('server')
@click.argument('year')
@click.argument('month')
@click.option('--cache_file', envvar='SPLUNK_CACHEFILE', help='Location of Splunk-cachefile')
def update_performance_cache(username, server, year, month, cache_file):
    """Gets previous weeks User Agent data and writes to GSheet

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
    year = int(year)
    month = int(month)
    password = call_splunk.get_password()
    authdata = {"username": username, "password": password}
    target_range = (datetime(year, month, 1), datetime(year, month, 1))
    customer_id_list = call_splunk.call_splunk(
        server, authdata, 1, target_range, customer_ids(), 15, 30)
    hitlist = [c_id['customer_id'] for c_id in customer_id_list['results']]
    whole_month = (
        datetime(year, month, 1), datetime(year, month, calendar.monthrange(year, month)[1]))
    print("hitlist", len(hitlist))
    for i in range(40, 60):
        output = call_splunk.call_splunk(
            server, authdata, 1, whole_month, device_search(hitlist[i]))
        results = output['results']
        if len(results) == 1:
            cache_summary.mutate_datastore(
                summary, results[0]['customer_id'], year, month, "unique_devices",
                results[0]['unique_devices'])
    print(output)
    cache_summary.save_cache(summary, cache_file)


if __name__ == '__main__':
    update_performance_cache()
#  [{'_time': '2020-01-01T00:00:00.000+00:00', 'customer_id': '206', 'unique_devices': '250'}]
