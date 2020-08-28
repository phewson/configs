import json
import os
from pathlib import Path
from splunk import sim_sparkdata


HOST_DATA_FOLDER = Path(os.environ['TEST_DATA_HOME'])
TEMPLATE_FOLDER = HOST_DATA_FOLDER.parent / "templates"


def test_registration():
    # GIVEN a single event registration simulation with customer id 13 (not default!)
    create_sim = [sim_sparkdata.Registration(customer_id=13)._asdict()]
    # WHEN the simulation is rendered
    output = json.loads(
        sim_sparkdata._render([create_sim], TEMPLATE_FOLDER, ["registration_events.jinja"]))
    # THEN we get back a piece of json with the first element
    # containing id 13 in the customer section.
    assert output[0]["customer"]["id"] == "13"


def test_timestamp():
    assert sim_sparkdata.timestamp(1970, 1, 1, 0, 0) == 0
    assert sim_sparkdata.timestamp(1970, 1, 1, 0, 1) == 60


def test_gen_mac_address():
    assert len(next(sim_sparkdata.gen_mac_address())) == 12
    assert isinstance(next(sim_sparkdata.gen_mac_address()), str)
