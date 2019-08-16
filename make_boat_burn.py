#!/usr/bin/env python

from __future__ import division
import math, sys

# z is up
# x is sideways
# y is depth

#================================================================================
def transform(points, amount):
    ax, ay, az = amount
    return [(px+ax, py+ay, pz+az) for px, py, pz in points]

def scale(points, amount):
    if isinstance(amount, float):
        amount = amount, amount, amount
    ax, ay, az = amount
    return [(px*ax, py*ay, pz*az) for px, py, pz in points]

def mirror_x(points, xlen):
    mirror_point = xlen
    return [(mirror_point-px, py, pz) for px, py, pz in points]

def row(start, direction, count):
    # assume direction is normalized
    sx, sy, sz = start
    dx, dy, dz = direction
    result = []
    for ii in range(count):
        result.append(( sx + dx * ii * METERS_PER_LED,
                        sy + dy * ii * METERS_PER_LED,
                        sz + dz * ii * METERS_PER_LED ))
    return result

#================================================================================

FT_TO_M = 0.3048
IN_TO_M = 0.0254

LEDS_PER_METER = 60
LEDS_PER_IN = LEDS_PER_METER * IN_TO_M
METERS_PER_LED = 1 / LEDS_PER_METER
INCHES_PER_LED = METERS_PER_LED / IN_TO_M

RIB_LENGTH = 2 # welcome to meters, frenz
#FAN_HEIGHT =120 
#CISTERN_WIDTH = 192
#CISTERN_CENTER = CISTERN_WIDTH / 2
#CISTERN_DEPTH = 76
#CISTERN_DEPTH_C = CISTERN_DEPTH / 2
LEDS_PER_UPRIGHT = int(math.floor(RIB_LENGTH / LEDS_PER_METER))

class LedStrip(object):
    def __init__(self, x_loc=0, y_loc=0, x_multiplier=0, y_multiplier=0, length=130):
        self.start_location =  (0,0,0)
        self.x_loc= x_loc
        self.y_multiplier = y_multiplier
        self.x_multiplier = x_multiplier
        self.length = length
        self.y_loc = y_loc


    def points(self):
        y_increment = self.y_multiplier * METERS_PER_LED
        x_increment = self.x_multiplier * METERS_PER_LED
        led_range = range(self.length)
        return [(self.x_loc + (i*x_increment), self.y_loc + (i*y_increment), 0) for i in led_range]


strips = [
        LedStrip(0, 0, 0, -1),
        LedStrip(0, -2, 1, 0, 40),
        LedStrip(40 * METERS_PER_LED, -2, 0, 1)
        ];

points = []

for strip in strips:
    points.extend(strip.points())


#points = scale(points, IN_TO_M)



# convert to JSON and print
result = ['[']
for point in points:
    result.append('  {"point": [%.4f, %.4f, %.4f]},' % point)
result[-1] = result[-1][:-1]  # trim off last comma
result.append(']')
print('\n'.join(result))
