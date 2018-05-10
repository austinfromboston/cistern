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

CISTERN_HEIGHT = 96
CISTERN_WIDTH = 192
CISTERN_CENTER = CISTERN_WIDTH / 2
LEDS_PER_UPRIGHT = int(math.floor(CISTERN_HEIGHT / LEDS_PER_IN))

class LedStrip(object):
    def __init__(self, name, start_loc, direction, input_strip, length=148):
        self.name = name
        self.start_location = start_loc
        self.input_strip = input_strip
        self.length = length
        self.direction = direction


    def points(self):
        increment = INCHES_PER_LED
        y_increment = 0
        z_increment = 0
        if self.direction == '+y':
            y_increment = increment
        elif self.direction == '-y':
            y_increment = 0 - increment
        elif self.direction == '+z':
            z_increment = increment
        elif self.direction == '-z':
            z_increment = 0 - increment
        x, y, z = self.start_location
        return [(x, y + (i*y_increment), z + (i*z_increment)) for i in range(self.length)]

# south arch
alpha = LedStrip('alpha', (0,0,0), '+y', None)
bravo = LedStrip('bravo', (0,105,0), '+z', alpha)
charlie = LedStrip('charlie', (0,105,105), '-y', bravo)

# middle arch
delta = LedStrip('delta', (190,0,105), '+y', None)
echo = LedStrip('echo', (190,105,105), '-z', delta)
foxtrot = LedStrip('foxtrot', (190,105,0), '-y', echo)

# north arch
golf = LedStrip('golf', (208,0,105), '+y', None)
hotel = LedStrip('hotel', (208,105,105), '-z', golf)
india = LedStrip('india', (208,105,0), '-y', hotel)

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

strips = [
        alpha, bravo, charlie, delta, echo,
        foxtrot, golf, hotel, india
        ]
points = []

for strip in strips:
    points.extend(strip.points())

#def make_segment(px_py_seg, pz):
    #return [(px, py, pz) for px, py in px_py_seg]

##build layer by layer (what if have to build string by string?)
#for led_z in range(LEDS_PER_UPRIGHT):
    #pz = led_z * LEDS_PER_IN
    #side_wall = make_segment(STUD_LOC_SIDE_HALF, pz)
    #rear_wall = make_segment(STUD_LOC_REAR_HALF, pz)
    #rear_wall_mirror = mirror_x(rear_wall, CISTERN_WIDTH)
    #side_wall_mirror = mirror_x(side_wall, CISTERN_WIDTH)
    #points.extend(side_wall)
    #points.extend(rear_wall)
    #points.extend(rear_wall_mirror)
    #points.extend(side_wall_mirror)

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
