from flask import Flask, render_template, jsonify, request
import arduino
app = Flask(__name__)

HOST ="10.42.0.1"  #  "0.0.0.0"
PORT = 5000
API_URL = f"http://{HOST}:{PORT}"

@app.before_request
def before_request_func():
    print("receive a request")

@app.teardown_request
def teardown_request_func(error=None):
    if error is None:
        print("an error occured", error)
    return jsonify({"msg":"an error occured; " + str(error)})


def response(dict={}):
    return jsonify(dict)

def trotinette_data_res(battery_lvl=100, speed_kmh=0, gear=0):
    """
    :param gear: speed level (0, 1, 2 or 3).
    if set None, try autocomplete using speed_kmh value
    :param speed_kmh: speed in km/h.
    if set None, try autocomplete using gear value:
    """
    if(speed_kmh is None and gear is not None):
        speed_kmh = GEAR_TO_KMH[gear]
    elif(gear is None and speed_kmh is not None):
        gear = list(GEAR_TO_KMH.values()).index(speed_kmh)
    return response({"batteryLevel":battery_lvl, "speed_kmh":speed_kmh, "gear":gear})

GEAR_TO_KMH = {0:0, 1:6, 2:15, 3:25}

@app.route('/battery', methods=["GET"])
def battery_route():
    lvl = arduino.get_battery()
    return trotinette_data_res(battery_lvl=lvl)

@app.route("/allData", methods=["GET"])
def all_trotinette_data():
    lvl = arduino.get_battery()
    gear = 0
    return trotinette_data_res(battery_lvl=lvl, speed_kmh=None, gear=gear)

@app.route('/test', methods=["GET"])
def test_route():
    return jsonify({"msg":"Hello There"})


app.run(host=HOST, port=PORT)
print("you can connect on : ", API_URL)
