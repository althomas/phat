# CIS 192 - Python Final Project
# Wireframe Hand Model
# Nick Howarth <nhowarth>
# References:
### http://codentronix.com/2011/04/21/rotating-3d-wireframe-cube-with-python/


import sys
import math
import pygame
import csv
from pygame.locals import *


def slicer(all_points, ppf):
    """Breaks all_points (list of points) into frames
    of size ppf (points per frame). Returns list of frames.
    """
    return (all_points[i:i + ppf] for i in xrange(0, len(all_points), ppf))


def cos_and_sin(angle):
    """ Converts angle given in degrees to angle in radians,
    and returns tuple containing cos(angle) and sin(angle). """
    rad = angle * math.pi / 180
    return (math.cos(rad), math.sin(rad))


class Point3D:
    def __init__(self, x=0, y=0, z=0):
        self.x, self.y, self.z = float(x), float(y), float(z)

    def rotateX(self, angle):
        """ Rotates point around x-axis by angle given in degrees. """
        rad = angle * math.pi / 180
        y = self.y * math.cos(rad) - self.z * math.sin(rad)
        z = self.y * math.sin(rad) + self.z * math.cos(rad)
        return Point3D(self.x, y, z)

    def rotateY(self, angle):
        """ Rotates point around y-axis by angle given in degrees. """
        rad = angle * math.pi / 180
        z = self.z * math.cos(rad) - self.x * math.sin(rad)
        x = self.z * math.sin(rad) + self.x * math.cos(rad)
        return Point3D(x, self.y, z)

    def rotateZ(self, angle):
        """ Rotates point around z-axis by angle given in degrees. """
        rad = angle * math.pi / 180
        x = self.x * math.cos(rad) - self.y * math.sin(rad)
        y = self.x * math.sin(rad) + self.y * math.cos(rad)
        return Point3D(x, y, self.z)

    def project(self, win_width, win_height, field_view=512, viewer_dist=5):
        """ Uses perspective projection to transforms 3D point to 2D. """
        factor = field_view / (viewer_dist + self.z)
        x = self.x * factor + win_width / 2
        y = -self.y * factor + win_height / 2
        return Point3D(x, y, 1)


class Simulation:
    def __init__(self, win_width=640, win_height=480):
        """ Initialization of pygame environment and hand joint coordinates """
        pygame.init()
        self.clock = pygame.time.Clock()
        self.screen = pygame.display.set_mode((win_width, win_height))
        pygame.display.set_caption("3D Wireframe Hand Model Simulation")

        # Read in joint positions from csv file
        self.joints = []
        with open(sys.argv[1], 'rU') as f:
            csvf = csv.reader(f)
            for line in csvf:
                self.joints.append(Point3D(line[0], line[1], line[2]))

        # Define the points that compose each of the fingers.
        self.index = (0, 1, 2, 3, 19)
        self.middle = (4, 5, 6, 7, 19)
        self.ring = (8, 9, 10, 11, 19)
        self.pinky = (12, 13, 14, 15, 19)
        self.thumb = (16, 17, 18, 19, 20)

        self.angleX = 0
        self.angleY = 0
        self.angleZ = 0
        self.play = 0

    def run(self):
        """ Loop that animates hand movement """
        while 1:
            for frame in slicer(self.joints, 21):
                if self.play == 0:
                    frame = self.joints[0:21]
                for event in pygame.event.get():
                    if event.type == pygame.QUIT:
                        sys.exit()
                self.clock.tick(5)  # frames per second
                self.screen.fill((0, 0, 0))  # clear screen

                j = []  # holds transformed joint positions

                for joint in frame:
                    # Rotate point around x-axis, then y-axis, then z-axis.
                    Rotated = joint.rotateX(self.angleX).rotateY(self.angleY).rotateZ(self.angleZ)
                    # Transform the point from 3D to 2D
                    Projected = Rotated.project(self.screen.get_width(),
                                                self.screen.get_height())
                    # Put the point in the list of transformed vertices
                    j.append(Projected)

                # Define fingers
                index = self.index
                middle = self.middle
                ring = self.ring
                pinky = self.pinky
                thumb = self.thumb

                # Draw fingers
                pygame.draw.lines(self.screen, (255, 100, 200), False,
                                  [(j[index[0]].x, j[index[0]].y),
                                   (j[index[1]].x, j[index[1]].y),
                                   (j[index[2]].x, j[index[2]].y),
                                   (j[index[3]].x, j[index[3]].y),
                                   (j[index[4]].x, j[index[4]].y)], 4)
                pygame.draw.lines(self.screen, (255, 0, 0), False,
                                  [(j[middle[0]].x, j[middle[0]].y),
                                   (j[middle[1]].x, j[middle[1]].y),
                                   (j[middle[2]].x, j[middle[2]].y),
                                   (j[middle[3]].x, j[middle[3]].y),
                                   (j[middle[4]].x, j[middle[4]].y)], 4)
                pygame.draw.lines(self.screen, (0, 0, 255), False,
                                  [(j[ring[0]].x, j[ring[0]].y),
                                   (j[ring[1]].x, j[ring[1]].y),
                                   (j[ring[2]].x, j[ring[2]].y),
                                   (j[ring[3]].x, j[ring[3]].y),
                                   (j[ring[4]].x, j[ring[4]].y)], 4)
                pygame.draw.lines(self.screen, (255, 200, 0), False,
                                  [(j[pinky[0]].x, j[pinky[0]].y),
                                   (j[pinky[1]].x, j[pinky[1]].y),
                                   (j[pinky[2]].x, j[pinky[2]].y),
                                   (j[pinky[3]].x, j[pinky[3]].y),
                                   (j[pinky[4]].x, j[pinky[4]].y)], 4)
                pygame.draw.lines(self.screen, (0, 255, 0), False,
                                  [(j[thumb[0]].x, j[thumb[0]].y),
                                   (j[thumb[1]].x, j[thumb[1]].y),
                                   (j[thumb[2]].x, j[thumb[2]].y),
                                   (j[thumb[3]].x, j[thumb[3]].y),
                                   (j[thumb[4]].x, j[thumb[4]].y)], 4)

                for r in range(0, 10):
                # Rotate around axis if specific key pressed
                # for loop used to increase rate of rotation
                    if pygame.key.get_pressed()[K_u]:
                        self.angleX += 1
                    if pygame.key.get_pressed()[K_n]:
                        self.angleX -= 1
                    if pygame.key.get_pressed()[K_h]:
                        self.angleY += 1
                    if pygame.key.get_pressed()[K_l]:
                        self.angleY -= 1
                    if pygame.key.get_pressed()[K_j]:
                        self.angleZ += 1
                    if pygame.key.get_pressed()[K_k]:
                        self.angleZ -= 1
                    if pygame.key.get_pressed()[K_SPACE]:
                        self.play = 1

                # Update the full display surface to the screen
                pygame.display.flip()

            # Reset play mode to 0 after one animation cycle
            # Only plays after space bar is pressed
            self.play = 0


if __name__ == "__main__":
    Simulation().run()
