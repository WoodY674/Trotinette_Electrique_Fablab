#!/usr/bin/env python
# -*- coding: utf-8 -*-
# lsusb to check device name
#dmesg | grep "tty" to find port name

import serial,time


def get_battery():
    # used to make an average, because sometimes arduino return strange values, ex 58% then 8%
    values = []
    print('Running. Press CTRL-C to exit.')
    try:
        with serial.Serial("/dev/ttyACM0", 9600, timeout=1) as arduino:
            time.sleep(0.1)
            if arduino.isOpen():
                print("{} connected!".format(arduino.port))
                try:
                    print("HERE arduino ---- ", arduino)
                    while values.length < 20 :
                        result = arduino.readline().strip().decode("utf-8")
                        if isinstance(result, str):
                            if result == "":
                                continue
                            result = int(result)

                        if(isinstance(result, int) and result > 0 and result <= 100):
                            values.append(result)
                except KeyboardInterrupt as err:
                    print("KeyboardInterrupt has been caught.", err)
    except Exception as err:
        print("ARDUINO ERROR ", err)
    return(round(sum(values) / len(values)))

if __name__ == "__main__":
    print("get battery fro testArduino", get_battery())


