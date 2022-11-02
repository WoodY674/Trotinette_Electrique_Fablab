#!/usr/bin/env python
# -*- coding: utf-8 -*-
# lsusb to check device name
#dmesg | grep "tty" to find port name

import serial,time


def get_battery():
    answer = 101
    print('Running. Press CTRL-C to exit.')
    try:
        with serial.Serial("/dev/ttyACM0", 9600, timeout=1) as arduino:
            time.sleep(0.1)
            if arduino.isOpen():
                print("{} connected!".format(arduino.port))
                try:
                    print("HERE arduino ---- ", arduino)
                    while answer == 101:
                        result = arduino.readline().stip().decode("utf-8")
                        #result = result.strip()
                        #result = result.decode("utf-8")
                        if isinstance(result, str):
                            if result == "":
                                continue
                            result = int(result)

                        if(isinstance(result, int) and result > 0 and result <= 100):
                            answer = result
                        #print(answer)
                except KeyboardInterrupt as err:
                    print("KeyboardInterrupt has been caught.", err)
    except Exception as err:
        print("ARDUINO ERROR ", err)
    return(answer)

if __name__ == "__main__":
    print("get battery fro testArduino", get_battery())


