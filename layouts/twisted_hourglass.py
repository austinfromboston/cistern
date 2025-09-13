from math import pi, cos, sin
from typing import Dict
import json
import sys
import getopt

Address = tuple[int, int]
Coord = tuple[float, float, float]


def hourglass_coords(
    num_wands,
    mount_radius,
    declination_deg,
    wand_length,
    pts_per_wand,
    *,
    half_circle: bool = False,
    start_angle_deg: float = 0.0,
    rotation_x_deg: float = 45.0,
    rotation_z_deg: float = 0.0,
    x_offset: float = 0.0,
    y_offset: float = 0.0,
    channel_offset: int = 0,
) -> Dict[Address, Coord]:
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
    :param half_circle: when True, distribute wands evenly over a half circle (π radians);
                        when False, distribute over a full circle (2π radians)
    :param start_angle_deg: starting angle for the first channel (degrees), applied to either half or full circle
    :param rotation_x_deg: rotation angle applied about the X-axis (degrees), about the origin (center of mount)
    :param rotation_z_deg: rotation angle applied about the Z-axis (degrees), positive is towards +Y
    :param x_offset: translation (meters) applied on X after rotation; useful for mount separation
    :param y_offset: translation (meters) applied on Y after rotation; useful for mount separation
    :param channel_offset: value added to each channel index in the returned keys, for composing multiple mounts
    :return: a set of coordinates for each point of each channel
    """
    start_angle = start_angle_deg * pi / 180.0
    if half_circle:
        # Spread channels evenly from 0 to π inclusive so channel 0 sits on +X axis
        # Use (num_wands - 1) to include both endpoints (0 and π)
        arc_per_wand = pi / (num_wands - 1)
        arc_start = start_angle
    else:
        arc_per_wand = pi * 2 / num_wands
        arc_start = start_angle
    neg_declination = declination_deg < 0
    wand_pitch_rad_from_horiz = pi * (90 - declination_deg) / 180
    pt_dist = wand_length / pts_per_wand

    def find_coord(point, channel) -> (float, float, float):
        """Given a point and a channel, calculates one coordinate"""

        arc_for_chan = arc_start + arc_per_wand * channel

        mount_x = mount_radius * cos(arc_for_chan)
        mount_y = mount_radius * sin(arc_for_chan)

        dist_from_mid_wand = (point - (pts_per_wand / 2)) * pt_dist

        if neg_declination:
            wand_x_offset = dist_from_mid_wand * -cos(wand_pitch_rad_from_horiz) * sin(arc_for_chan)
            wand_y_offset = dist_from_mid_wand * -cos(wand_pitch_rad_from_horiz) * -cos(arc_for_chan)
        else:
            wand_x_offset = dist_from_mid_wand * cos(wand_pitch_rad_from_horiz) * -sin(arc_for_chan)
            wand_y_offset = dist_from_mid_wand * cos(wand_pitch_rad_from_horiz) * cos(arc_for_chan)

        z = dist_from_mid_wand * sin(wand_pitch_rad_from_horiz)
        x = mount_x + wand_x_offset
        y = mount_y + wand_y_offset

        return x, y, z

    def rotate_x_about_origin(x: float, y: float, z: float, angle_rad: float) -> Coord:
        ca = cos(angle_rad)
        sa = sin(angle_rad)
        # x remains unchanged; rotate YZ plane
        yr = y * ca - z * sa
        zr = y * sa + z * ca
        return x, yr, zr

    rotation_angle = rotation_x_deg * pi / 180.0
    rotation_z_angle = rotation_z_deg * pi / 180.0

    def rotate_z_about_origin(x: float, y: float, z: float, angle_rad: float) -> Coord:
        ca = cos(angle_rad)
        sa = sin(angle_rad)
        xr = x * ca - y * sa
        yr = x * sa + y * ca
        return xr, yr, z

    # Build mount for requested angular distribution
    coords = {(point, channel + channel_offset): find_coord(point, channel)
              for channel in range(num_wands)
              for point in range(pts_per_wand)}

    # Rotate around X, then Z, then translate to keep mounts centered pre-translation
    transformed = {}
    for addr, (x, y, z) in coords.items():
        xr, yr, zr = rotate_x_about_origin(x, y, z, rotation_angle)
        xz, yz, zz = rotate_z_about_origin(xr, yr, zr, rotation_z_angle)
        transformed[addr] = (xz + x_offset, yz + y_offset, zz)

    return transformed


if __name__ == '__main__':

    # Build two opposed half-circle mounts by calling hourglass_coords twice
    mount_a = hourglass_coords(
        num_wands=9,
        mount_radius=0.15,
        declination_deg=-45,
        wand_length=2,
        pts_per_wand=120,
        half_circle=True,
        start_angle_deg=45.0,   # right semicircle; flat side on Y axis
        rotation_x_deg=0.0,
        rotation_z_deg=0.0,
        x_offset=-0.0,   # half of 0.5 m separation left of origin
        y_offset=0.0,
        channel_offset=0,
    )
    mount_b = hourglass_coords(
        num_wands=9,
        mount_radius=0.15,
        declination_deg=45,
        wand_length=2,
        pts_per_wand=120,
        half_circle=True,
        start_angle_deg=-45.0,    # left semicircle; flat side on Y axis
        rotation_x_deg=90.0,
        rotation_z_deg=-135.0,
        x_offset=0.0,   # half of 0.5 m separation right of origin
        y_offset=0.0,
        channel_offset=9,
    )
    soak_proto = {**mount_a, **mount_b}

    # hourglass_coords already returns points rotated 45° around the origin

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
        
