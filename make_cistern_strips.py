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
CISTERN_DEPTH = 76
CISTERN_DEPTH_C = CISTERN_DEPTH / 2
LEDS_PER_UPRIGHT = int(math.floor(CISTERN_HEIGHT / LEDS_PER_IN))

class LedStrip(object):
    def __init__(self, name, start_loc, input_strip, length=148):
        self.name = name
        self.start_location = start_loc
        self.input_strip = input_strip
        self.length = length


    def points(self):
        z_increment = INCHES_PER_LED
        if self.input_strip:
            z_increment = 0 - INCHES_PER_LED
        x, y, z = self.start_location
        return [(x, y, z + (i*z_increment)) for i in range(self.length)]

class FloodStrip(object):
    def __init__(self, name, length, radius):
        self.name = name
        self.length = length
        self.r = radius
        self.z = -1 #keeping all the floods in -z for convenience

    def points(self):
        #ellipse version
        theta = 0 # angle that will be increased each loop in radiand
        step = (2*math.pi)/self.length

        points = []
        for ii in range(1, self.length+1):
            #print('ii :',ii)
            #print('theta :', ii*step)
            x = self.r * math.cos(theta)
            y = self.r * math.sin(theta)
            z = self.z
            points.append((x,y,z))
            theta += step

        return points


# stage left wall
alpha = LedStrip('alpha', (0,76,0), None)
bravo = LedStrip('bravo', (0,60,CISTERN_HEIGHT), alpha)
charlie = LedStrip('charlie', (0,44,0), None)
delta = LedStrip('delta', (0,28,CISTERN_HEIGHT), charlie)
echo = LedStrip('echo', (0,12,0), None)

# rear wall, stage left
foxtrot = LedStrip('foxtrot', (CISTERN_CENTER - 76,0,CISTERN_HEIGHT), echo)
golf = LedStrip('golf', (CISTERN_CENTER - 60,0,0), None)
hotel = LedStrip('hotel', (CISTERN_CENTER - 44,0,CISTERN_HEIGHT), golf)
india = LedStrip('india', (CISTERN_CENTER - 28,0,0), None)
juliett = LedStrip('juliett', (CISTERN_CENTER - 12,0,CISTERN_HEIGHT), india)

# stairs

# rear wall, stage right
kilo = LedStrip('kilo', (CISTERN_CENTER + 12,0,0), None)
lima = LedStrip('lima', (CISTERN_CENTER + 28,0,CISTERN_HEIGHT), kilo)
mike = LedStrip('mike', (CISTERN_CENTER + 44,0,0), None)
november = LedStrip('november', (CISTERN_CENTER + 60,0,CISTERN_HEIGHT), mike)
oscar = LedStrip('oscar', (CISTERN_CENTER + 76,0,0), None)

# rear wall, stage right
papa = LedStrip('papa', (CISTERN_WIDTH,12,CISTERN_HEIGHT), oscar)
quebec = LedStrip('quebec', (CISTERN_WIDTH,28,0), None)
romeo = LedStrip('romeo', (CISTERN_WIDTH,44,CISTERN_HEIGHT), quebec)
sierra = LedStrip('sierra', (CISTERN_WIDTH,60,0), None)
tango = LedStrip('tango', (CISTERN_WIDTH,76,CISTERN_HEIGHT), sierra)

# bowl

umbrella = FloodStrip('umbrella', 12, 96)


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
        foxtrot, golf, hotel, india, juliett,
        kilo, lima, mike, november, oscar,
        papa, quebec, romeo, sierra, tango,
        ]

floods = [umbrella]


points = []

for strip in strips:
    points.extend(strip.points())


#do a maneuvering
points = transform(points, (-1*CISTERN_CENTER, -1*CISTERN_DEPTH_C ,0))

for flood in floods:
    points.extend(flood.points())

points = scale(points, IN_TO_M)



# convert to JSON and print
result = ['[']
for point in points:
    result.append('  {"point": [%.4f, %.4f, %.4f]},' % point)
result[-1] = result[-1][:-1]  # trim off last comma
result.append(']')
print('\n'.join(result))
