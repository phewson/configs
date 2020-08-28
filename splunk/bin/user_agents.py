#!/usr/bin/env python
import click
import sys
import os
import urllib3  # type: ignore
import gspread  # type: ignore
from oauth2client.service_account import ServiceAccountCredentials  # type: ignore
from typing import Dict, Any, List, Tuple, Callable, Optional
from datetime import datetime
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + "/..")
from splunk import call_splunk  # noqa [E402]
from splunk import user_agents  # noqa [E402]
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


UA_LOOKUPS = {
    "browser": ('user_agent', 'family'),
    "browser_version": ('user_agent', 'family', 'major'),
    "os": ('os', 'family'),
    "os_version": ('os', 'family', 'major', 'minor'),
    "device": ('device', 'brand'),
    "device_model": ('device', 'brand', 'model')}

HEADERS = ["Browser", "New Users", "",
           "Browser+Version", "New Users", "",
           "OS", "New Users", "",
           "OS-Version",  "New Users", "",
           "Device", "New Users", "",
           "Model", "New Users", "",
           "Unmatched String (Browser)", "New Users", "",
           "Unmatched String (Device)", "New Users", "",
           "Splunk Browser", "New Users"]

COLNAMES = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

UA_SEARCH = """index = "cloud_spark_*" AND type="Portal"
 AND user_agent.browser_name != "" AND view="NewUser"
 |  fields user_agent.browser_name | stats count by user_agent.browser_name
 | sort -count""".replace("\n", "")

UA_CHECK = """index = "cloud_spark_*" AND type="Portal"
 AND user_agent.browser_name != "" AND view="NewUser"
 | fields user_agent.Browser
 | stats count by user_agent.Browser""".replace("\n", "")

SCOPE = ['https://spreadsheets.google.com/feeds',
         'https://www.googleapis.com/auth/drive']

TARGET_GSHEET = "User Agent Analysis"


def _worksheet(spreadsheet: gspread.models.Spreadsheet,
               server: str, date_range: Tuple[datetime, datetime]) -> gspread.models.Worksheet:
    worksheet_title = "{}:{}".format(server, date_range[0].strftime("%Y-%m-%d"))
    ws = [sheet.title for sheet in spreadsheet.worksheets()]
    if worksheet_title not in ws:
        worksheet = spreadsheet.add_worksheet(title=worksheet_title, rows="100", cols="26")
    else:
        worksheet = spreadsheet.worksheet(worksheet_title)
    return worksheet


def publish_results(
        server: str, r: Dict[str, Any], google_delay: int, date_range: Tuple[datetime, datetime],
        credentials: ServiceAccountCredentials) -> None:
    gc = gspread.authorize(credentials)
    spreadsheet = gc.open(TARGET_GSHEET)
    worksheet = _worksheet(spreadsheet, server, date_range)
    get_cells = create_get_cells(worksheet)
    write_cells = create_write_cells(worksheet)
    for i, run in enumerate(r.keys()):
        names, numbers = user_agents._sort_results(r[run])
        if len(names) > 0:
            cell_list = get_cells(len(names), i * 3, False, None)
            write_cells(cell_list, names)
            cell_list = get_cells(len(numbers), i * 3, True, None)
            write_cells(cell_list, numbers)
    cell_list = get_cells(len(HEADERS), None, False, "A1:Z1")
    write_cells(cell_list, HEADERS)


def create_get_cells(
    worksheet: gspread.models.Worksheet) -> Callable[
        [int, Optional[int], bool, Optional[str]], List[gspread.models.Cell]]:
    def get_cells(
            nrows: int, offset: Optional[int], is_title: bool,
            cell_range: Optional[str]) -> List[gspread.models.Cell]:
        if cell_range is None:
            letter = offset + is_title if offset is not None else 0
            col = COLNAMES[letter]
            cell_range = '{}2:{}{}'.format(col, col, nrows + 1)
        cell_list = worksheet.range(cell_range)
        return cell_list
    return get_cells


def create_write_cells(
        worksheet: gspread.models.Worksheet) -> Callable[[List[gspread.models.Cell], List[str]], None]:
    def write_cells(cell_list: List[gspread.models.Cell], data: List[str]) -> None:
        for j, cell in enumerate(cell_list):
            cell.value = data[j]
        worksheet.update_cells(cell_list)
    return write_cells


@click.command()
@click.argument('username')
@click.argument('server')
@click.argument('sample_ratio')
@click.option('--google_delay', '-g', default=10, help='Google API delay (seconds - default 10)')
@click.option('--target_date', '-d', default=None, help='Target date, default today')
@click.option('--gsheet_api_key', envvar='GSHEET_API_KEY', help='Location of GSHEET API FILE')
def update_ua_report(username, server, sample_ratio, google_delay, target_date, gsheet_api_key):
    """Gets previous weeks User Agent data and writes to GSheet

       \b
       Required arguments:
       - Splunk username
       - Splunk server (Prod or Dev)
       - Sample Ratio"""
    target_range = user_agents._date_range(target_date)
    click.echo("Targeted date range will be {}-{}".format(target_range[0], target_range[1]))
    password = call_splunk.get_password()
    authdata = {"username": username, "password": password}
    output = call_splunk.call_splunk(server, authdata, sample_ratio, target_range, UA_SEARCH)
    print("output length", len(output['results']))
    parsed = user_agents._parse(output['results'])
    r = user_agents.summary(parsed, UA_LOOKUPS)
    check = call_splunk.call_splunk(server, authdata, sample_ratio, target_range, UA_CHECK)
    r['check'] = user_agents._check_results(check['results'])
    credentials = ServiceAccountCredentials.from_json_keyfile_name(gsheet_api_key, SCOPE)
    publish_results(server, r, google_delay, target_range, credentials)


if __name__ == '__main__':
    update_ua_report()
