from math import pi, cos, sin
from typing import Dict
import json
import sys
import getopt

Address = tuple[int, int]
Coord = tuple[float, float, float]


def hourglass_coords(num_wands, mount_radius, declination_deg, wand_length, pts_per_wand) -> Dict[Address, Coord]:
    """
    Calculates the a three dimensional coordinate distance from the origin in meters, with X and Y on the horizontal
    plane and Z on the vertical plane, for each point of each wand, with one wand per channel.

    This assumes:
    - The center of the mount assumes the location of coordinates (0,0,0)
    - The X and Y coordinates are viewed from above, and channel 0 is on the X axis (between Quadrants I and IV)
    - The wands point counter-clockwise above the plane of the mount
    - The channels increase in order counter-clockwise around the mount (viewed from above)

    :param num_wands: the number of evenly spaced wands on a mount
    :param mount_radius: the radius of the mount in meters
    :param declination_deg: the declination of the wands in degrees fom vertical
    :param wand_length: the length of the wand im meters
    :param pts_per_wand: the number of LEDs on a wand
    :return: a set of coordinates for each point of each channel
    """
    arc_per_wand = pi * 2 / num_wands
    wand_pitch_rad_from_horiz = pi * (90 - declination_deg) / 180
    pt_dist = wand_length / pts_per_wand

    def find_coord(point, channel) -> (float, float, float):
        """Given a point and a channel, calculates one coordinate"""

        arc_for_chan = arc_per_wand * channel

        mount_x = mount_radius * cos(arc_for_chan)
        mount_y = mount_radius * sin(arc_for_chan)

        dist_from_mid_wand = (point - (pts_per_wand / 2)) * pt_dist

        wand_x_offset = dist_from_mid_wand * cos(wand_pitch_rad_from_horiz) * -sin(arc_for_chan)
        wand_y_offset = dist_from_mid_wand * cos(wand_pitch_rad_from_horiz) * cos(arc_for_chan)

        z = dist_from_mid_wand * sin(wand_pitch_rad_from_horiz)
        x = mount_x + wand_x_offset
        y = mount_y + wand_y_offset

        return x, y, z

    coords = {(point, channel): find_coord(point, channel)
              for channel in range(num_wands)
              for point in range(pts_per_wand)}

    return coords


if __name__ == '__main__':

    #soak_proto = hourglass_coords(num_wands=18, mount_radius=0.15, declination_deg=35, wand_length=2, pts_per_wand=120)
    soak_proto = hourglass_coords(num_wands=18, mount_radius=0.15, declination_deg=35, wand_length=2, pts_per_wand=120)

    #print(soak_proto)
    
    # this version used the channel and the point as a key
    # transposed = {address: (x, z, y) for address, (x, y, z) in soak_proto.items()}
    # print(transposed)
    #transposed = [{"point": (x, z, y)} for address, (x,y,z) in soak_proto.items()]
    #print(json.dumps(transposed, indent=2))
    format = "opc"
    opts, args = getopt.getopt(sys.argv[1:], "hf", ["format="])
    for opt, arg in opts:
        if opt == "-h":
            print("hourglass.py -f [opc|csv]")
            sys.exit()
        elif opt in ("-f", "--format"):
            # print("opt found '%s' = '%s'" % (opt, arg))
            format = arg
        else:
            pass
            # print("opt found '%s'" % opt)

    if format == "opc":
        print("[")
        protolen = len(soak_proto.values())
        for idx, (x, y, z) in enumerate(soak_proto.values()):
            endchar = "," if idx + 1 < protolen else ""
            print('  {"point": [%f, %f, %f]}%s' % (x, y, z, endchar))
        print("]")
    elif format == "csv":
        print('x,y,z')
        for idx, (x, y, z) in enumerate(soak_proto.values()):
            print('%f,%f,%f' % (x, y, z))
    else:
        print("format must be opc or csv, not '%s'" % (format))
        



