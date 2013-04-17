"""
    Wireframe 3D cube simulation.
    Developed by Leonel Machava <leonelmachava@gmail.com>
    http://codeNtronix.com
"""

import sys, math, pygame, csv
from pygame.locals import *

class Point3D:
    def __init__(self, x = 0, y = 0, z = 0):
        self.x, self.y, self.z = float(x), float(y), float(z)

    def rotateX(self, angle):
        """ Rotates the point around the X axis by the given angle in degrees. """
        rad = angle * math.pi / 180
        cosa = math.cos(rad)
        sina = math.sin(rad)
        y = self.y * cosa - self.z * sina
        z = self.y * sina + self.z * cosa
        return Point3D(self.x, y, z)

    def rotateY(self, angle):
        """ Rotates the point around the Y axis by the given angle in degrees. """
        rad = angle * math.pi / 180
        cosa = math.cos(rad)
        sina = math.sin(rad)
        z = self.z * cosa - self.x * sina
        x = self.z * sina + self.x * cosa
        return Point3D(x, self.y, z)

    def rotateZ(self, angle):
        """ Rotates the point around the Z axis by the given angle in degrees. """
        rad = angle * math.pi / 180
        cosa = math.cos(rad)
        sina = math.sin(rad)
        x = self.x * cosa - self.y * sina
        y = self.x * sina + self.y * cosa
        return Point3D(x, y, self.z)

    def project(self, win_width, win_height, fov, viewer_distance):
        """ Transforms this 3D point to 2D using a perspective projection. """
        factor = fov / (viewer_distance + self.z)
        x = self.x * factor + win_width / 2
        y = -self.y * factor + win_height / 2
        return Point3D(x, y, 1)

class Simulation:
    def __init__(self, win_width = 640, win_height = 480):
        pygame.init()
        self.screen = pygame.display.set_mode((win_width, win_height))
        pygame.display.set_caption("3D Wireframe Hand Model Simulation")
        self.clock = pygame.time.Clock()
        self.vertices = [
            Point3D(-1,1,-1),
            Point3D(1,1,-1),
            Point3D(1,-1,-1),
            Point3D(-1,-1,-1),
            Point3D(-1,1,1),
            Point3D(1,1,1),
            Point3D(1,-1,1),
            Point3D(-1,-1,1)
        ]
        self.joints1 = [
            Point3D(.1353, .1122, -1.000),
            Point3D(.1523, .3162, -1.000),
            Point3D(.1570, .4092, -0.980),
            Point3D(.1733, .5292, -0.960),
            Point3D(.4465, .1071, -1.000),
            Point3D(.4488, .2071, -1.000),
            Point3D(.4451, .3375, -0.170),
            Point3D(.4460, .5208, -0.567),
            Point3D(.5697, .0729, -1.000),
            Point3D(.5744, .1588, -0.800),
            Point3D(.5721, .3013, -0.100),
            Point3D(.5488, .5000, 0.000),
            Point3D(.7418, .1458, -1.000),
            Point3D(.7232, .2208, -0.960),
            Point3D(.7000, .3254, -0.678),
            Point3D(.6581, .5083, -0.100),
            Point3D(.9558, .4833, -2.000),
            Point3D(.8767, .5917, -1.888),
            Point3D(.7651, .6833, -1.777),
            Point3D(.4683, .8708, 0.010),
            Point3D(.4444, .9999, -0.100)
        ]

        self.joints = []
        with open(sys.argv[1], 'rU') as f:
            csvf = csv.reader(f)
            #coordinates = f.readline().strip().split(',')
            for line in csvf:
                #coord = line.split(',')
                self.joints.append(Point3D(line[0], line[1], line[2]))

        # Define the vertices that compose each of the 6 faces. These numbers are indices to the vertices list defined above.
        self.faces = [(0,1,2,3),(1,5,6,2),(5,4,7,6),(4,0,3,7),(0,4,5,1),(3,2,6,7)]
        self.fingers = [(0, 1, 2, 3, 19), (4, 5, 6, 7, 19), (8, 9, 10, 11, 19), (12, 13, 14, 15, 19), (16, 17, 18, 19, 20)]
        self.angleX, self.angleY, self.angleZ = 0, 0, 0

    def run(self):
        """ Main Loop """
        while 1:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    sys.exit()
            self.clock.tick(50)
            self.screen.fill((0,0,0))

            # Will hold transformed vertices.
            t = []
            j = []

            for v in self.vertices:
                # Rotate the point around X axis, then around Y axis, and finally around Z axis.
                r = v.rotateX(self.angleX).rotateY(self.angleY).rotateZ(self.angleZ)
                # Transform the point from 3D to 2D
                p = r.project(self.screen.get_width(), self.screen.get_height(), 384, 4)
                # Put the point in the list of transformed vertices
                t.append(p)

            for h in self.joints:
                R = h.rotateX(self.angleX).rotateY(self.angleY).rotateZ(self.angleZ)
                P = R.project(self.screen.get_width(), self.screen.get_height(), 512, 4)
                j.append(P)

#            for f in self.faces:
#                pygame.draw.line(self.screen, (255,255,255), (t[f[0]].x, t[f[0]].y), (t[f[1]].x, t[f[1]].y))
#                pygame.draw.line(self.screen, (255,255,255), (t[f[1]].x, t[f[1]].y), (t[f[2]].x, t[f[2]].y))
#                pygame.draw.line(self.screen, (255,255,255), (t[f[2]].x, t[f[2]].y), (t[f[3]].x, t[f[3]].y))
#                pygame.draw.line(self.screen, (255,255,255), (t[f[3]].x, t[f[3]].y), (t[f[0]].x, t[f[0]].y))

            F0 = self.fingers[0]
            F1 = self.fingers[1]
            F2 = self.fingers[2]
            F3 = self.fingers[3]
            F4 = self.fingers[4]
            pygame.draw.lines(self.screen, (255, 100, 200), False, [(j[F0[0]].x, j[F0[0]].y), (j[F0[1]].x, j[F0[1]].y), (j[F0[2]].x, j[F0[2]].y), (j[F0[3]].x, j[F0[3]].y), (j[F0[4]].x, j[F0[4]].y)], 4)
            pygame.draw.lines(self.screen, (255, 0, 0), False, [(j[F1[0]].x, j[F1[0]].y), (j[F1[1]].x, j[F1[1]].y), (j[F1[2]].x, j[F1[2]].y), (j[F1[3]].x, j[F1[3]].y), (j[F1[4]].x, j[F1[4]].y)], 4)
            pygame.draw.lines(self.screen, (0, 0, 255), False, [(j[F2[0]].x, j[F2[0]].y), (j[F2[1]].x, j[F2[1]].y), (j[F2[2]].x, j[F2[2]].y), (j[F2[3]].x, j[F2[3]].y), (j[F2[4]].x, j[F2[4]].y)], 4)
            pygame.draw.lines(self.screen, (255, 200, 0), False, [(j[F3[0]].x, j[F3[0]].y), (j[F3[1]].x, j[F3[1]].y), (j[F3[2]].x, j[F3[2]].y), (j[F3[3]].x, j[F3[3]].y), (j[F3[4]].x, j[F3[4]].y)], 4)
            pygame.draw.lines(self.screen, (0, 255, 0), False, [(j[F4[0]].x, j[F4[0]].y), (j[F4[1]].x, j[F4[1]].y), (j[F4[2]].x, j[F4[2]].y), (j[F4[3]].x, j[F4[3]].y), (j[F4[4]].x, j[F4[4]].y)], 4)

            pygame.draw.lines(self.screen, (69, 69, 69), False, [(j[F0[3]].x, j[F0[3]].y), (j[F1[3]].x, j[F1[3]].y), (j[F2[3]].x, j[F2[3]].y), (j[F3[3]].x, j[F3[3]].y), (j[F4[2]].x, j[F4[2]].y)], 1)
            pygame.draw.lines(self.screen, (69, 69, 69), False, [(j[F0[2]].x, j[F0[2]].y), (j[F1[2]].x, j[F1[2]].y), (j[F2[2]].x, j[F2[2]].y), (j[F3[2]].x, j[F3[2]].y), (j[F4[1]].x, j[F4[1]].y)], 1)
            pygame.draw.lines(self.screen, (69, 69, 69), False, [(j[F0[1]].x, j[F0[1]].y), (j[F1[1]].x, j[F1[1]].y), (j[F2[1]].x, j[F2[1]].y), (j[F3[1]].x, j[F3[1]].y)], 1)

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

            pygame.display.flip()

if __name__ == "__main__":
    Simulation().run()
