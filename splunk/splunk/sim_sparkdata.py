import json
from random import sample
from jinja2 import Environment, FileSystemLoader, Template
from time import mktime
from datetime import datetime
from pathlib import Path
from faker import Faker  # type: ignore
from typing import NamedTuple, Generator, List, Dict, Any, Optional

HEX_DIGITS = set('0123456789ABCDEF')
GIGAWORDS_TO_OCTETS = 4294967296
OCTETS_TO_GB = 1073741824


class Registration(NamedTuple):
    customer_id: int = 1
    customer_name: str = "CustomerName"
    zone_id: int = 10
    zone_name: str = "ZoneName"
    device_mac_address: str = "0ax123fff"
    doing_ajax: bool = False
    form_data_email: str = "vader@empire.com"
    form_data_allow_email_marketing: int = 1
    hotspot_id: int = 100
    hotspot_internet_address: str = "10.0.0.1"
    hotspot_latitude: Optional[float] = None
    hotspot_location: str = ""
    hotspot_longitude: Optional[float] = None
    hotspot_mac: Optional[str] = None
    hotspot_name: str = "HotspotName"
    hotspot_symbol: str = "HotspotSymbol"
    hotspot_timezone: str = "UTC"
    hotspot_type: int = 5
    hotspot_ip: str = "10.10.10.10"
    interface_id: int = 50
    interface_name: str = "eth9.999"
    page: str = "welcome_back"
    sub_acc_create_hotspot: str = "192.168.1.2"
    sub_acc_create_interface: str = "eth1.111"
    sub_account_create_date: str = "2019-04-01 09:00:00"
    sub_agree_terms_and_conditions: int = 1
    sub_allow_email_marketing: int = 1
    sub_allow_mobile_marketing: int = 0
    sub_allow_postal_marketing: int = 0
    sub_bank_account_number: Optional[str] = None
    sub_city: Optional[str] = None
    sub_country: Optional[str] = None
    sub_credit_card_expiry: Optional[str] = None
    sub_credit_card_number: Optional[str] = None
    sub_credit_card_start_date: Optional[str] = None
    sub_credit_card_card_type: Optional[str] = None
    sub_date_of_birth: Optional[str] = None
    sub_device_macs: List[Optional[str]] = []
    sub_email: Optional[str] = None
    sub_first_name: Optional[str] = None
    sub_gdpr_consent_given: int = 1
    sub_gender: Optional[str] = None
    sub_subscriber_id: int = 12345
    sub_issue_number: int = 999
    sub_last_hotspot_address: Optional[str] = None
    sub_last_hotspot_interface: Optional[str] = None
    sub_last_login_datetime: str = "2018-04-01 09:00:00"
    sub_last_name: Optional[str] = None
    sub_last_registration_datetime: str = "2017-04-01 09:00:00"
    sub_login: str = "logon_name"
    sub_mac_address: Optional[str] = None
    sub_mailing_address: Optional[str] = None
    sub_mobile_phone: Optional[str] = None
    sub_mothers_maiden_name: Optional[str] = None
    sub_password: str = "HashedPassword"
    sub_pin_code: Optional[str] = None
    sub_place_of_birth: Optional[str] = None
    sub_realm: str = "Realm"
    sub_secret_answer: Optional[str] = None
    sub_secret_question: Optional[str] = None
    sub_security_number_cvs: Optional[str] = None
    sub_send_receipts: int = 0
    sub_session_expiry_datetime: str = "2025-04-01 12:00:00"
    sub_sort_code: str = Optional[None]
    sub_subscriber_block_status_id: int = 1
    sub_subscriber_block_status_name: str = "open"
    sub_subscriber_type_id: int = 2
    sub_subscriber_type_name: str = "fixed duration"
    sub_user_def01: str = ""
    sub_user_def02: str = ""
    sub_user_def03: str = ""
    sub_user_def04: str = ""
    sub_user_def05: str = ""
    sub_user_def06: str = ""
    sub_user_def07: str = ""
    sub_user_def08: str = ""
    sub_user_def09: str = ""
    sub_user_def10: str = ""
    timestamp: float = 1582508454
    type: str = "Portal"
    ua_Browser: str = "Firefox"
    ua_Browser_Maker: str = "Mozilla"
    ua_Comment: str = "Firefox Generic"
    ua_Crawler: bool = False
    ua_Device_Pointing_Method: str = "mouse"
    ua_Device_Type: str = "Mobile"
    ua_MajorVer: int = 0
    ua_MinorVer: int = 0
    ua_Parent: str = "Firefox"
    ua_Platform: str = "Linux"
    ua_Version: str = "0.0"
    ua_browser_name: str = " Mozilla/5.0 (X11; Ubuntu; Linux x86_64)"
    ua_browser_name_pattern: str = "zilla/5.0 (*linux*) applewebkit/*"
    ua_browser_name_regex: str = "mozilla/5.0 (.*linux.*) applewebkit/.* (khtml.* like"
    ua_IsMobileDevice: bool = True
    ua_isTablet: bool = False
    view: str = "PortalView"
    ua_view_valid: bool = True


class Session(NamedTuple):
    customer_id: int = 1
    device_mac_address: str = "0ax123fff"
    framed_ip_address: str = "10.0.1.2"
    framed_protocol: str = ""
    hotspot_id: int = 100
    input_gigawords: float = 0
    input_octets: float = 0
    interface_id: Optional[str] = None
    ip_address: str = "20.1.2.3"
    nas_mac_address: str = "AB-CD-01-01-01-01"
    output_gigawords: float = 0
    output_octets: float = 0
    packet_src_ip_address: Optional[str] = "20.1.2.3"
    port_id: str = "Wireless-801.11"
    port_type: str = "Wireless"
    realm: str = "ph1"
    session_id: str = "123123123123123123"
    session_time: int = 0
    ssid: str = "MyWifi-Free"
    termination_clause: str = ""
    timestamp: float = 1582508454
    type: str = "Start"
    unique_session_id: str = "abcdef123abcdef123abcdef123"
    username: str = "realm1/MyWifi-0ax123fff"


def gen_mac_address(length: int = 12) -> Generator:
    while True:
        result = ""
        for digit in range(length):
            cur_digit = sample(HEX_DIGITS, 1)[0]
            result += cur_digit
        yield result


def render_write(
        sim: List[Dict[str, Any]], temp_folder: Path, template: List[Template], outfile: Path) -> None:
    with open(outfile, "w") as fn:
        fn.write(_render(sim, temp_folder, template))


def _render(sim: List[Dict[str, Any]], template_folder: Path, template: List[Template]) -> str:
    env = Environment(loader=FileSystemLoader(str(template_folder)))
    env.filters['jsonify'] = json.dumps
    for i, t in enumerate(template):
        working_t = env.get_template(t)
        if i == 0:
            out = "[" + working_t.render(events=sim[0])
        if i > 0:
            out += ", " + working_t.render(events=sim[i])
    return out + "]"


def timestamp(yyyy: int, mm: int, dd: int, HH: int = 0, MM: int = 0) -> float:
    return round(mktime(datetime(yyyy, mm, dd, HH, MM).timetuple()))


def ff(seed: int = 1999, reps: int = 5) -> List[Dict[str, Any]]:
    fake = Faker('en_GB')
    Faker.seed(seed)
    out = []
    for _ in range(reps):
        out.append({"sub_first_name": fake.first_name(), "sub_last_name": fake.last_name(),
                    "sub_email": fake.email()})
    return out
