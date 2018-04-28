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

STRIP_LEN = 5
LEDS_PER_METER = 32
LEDS_PER_FOOT = int(LEDS_PER_METER * FT_TO_M) # rounded
LEDS_PER_IN = LEDS_PER_METER * IN_TO_M
LEDS_PER_STRIP = 160
METERS_PER_LED = 1 / LEDS_PER_METER

CISTERN_HEIGHT = 96
CISTERN_WIDTH = 180
LEDS_PER_UPRIGHT = int(math.floor(CISTERN_HEIGHT / LEDS_PER_IN))

#in inches
STUD_LOC_REAR_HALF = [
                    (12,0),
                    (28,0),
                    (44,0),
                    (60,0),
                    (76,0),
                    ]

STUD_LOC_SIDE_HALF = [
                    (0,12),
                    (0,40),
                    (0,68),
                    (0,96),
                    ]

points = []

def make_segment(px_py_seg, pz):
    return [(px, py, pz) for px, py in px_py_seg]

#build layer by layer (what if have to build string by string?)
for led_z in range(LEDS_PER_UPRIGHT):
    pz = led_z * LEDS_PER_IN
    side_wall = make_segment(STUD_LOC_SIDE_HALF, pz)
    rear_wall = make_segment(STUD_LOC_REAR_HALF, pz)
    rear_wall_mirror = mirror_x(rear_wall, CISTERN_WIDTH)
    side_wall_mirror = mirror_x(side_wall, CISTERN_WIDTH)
    points.extend(side_wall)
    points.extend(rear_wall)
    points.extend(rear_wall_mirror)
    points.extend(side_wall_mirror)

#do a maneuvering
points = transform(points, (0,0,0))
points = scale(points, IN_TO_M)
# convert to JSON and print
result = ['[']
for point in points:
    result.append('  {"point": [%.4f, %.4f, %.4f]},' % point)
result[-1] = result[-1][:-1]  # trim off last comma
result.append(']')
print '\n'.join(result)
