from typing import List
from matplotlib import pyplot
import numpy
import random


class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y


def generate(line_count=2, point_count=20, randmin=-20, randmax=20) -> List[Point]:
    curves = []

    for l in range(0, line_count):
        points = []
        for e in range(0, point_count):
            points.append(Point(random.randrange(randmin, randmax), random.randrange(randmin, randmax)))

        x = sorted([p.x for p in points])
        y = sorted([p.y for p in points])
        func = numpy.poly1d(numpy.polyfit(x, y, 3))
        new_x = numpy.linspace(x[0], x[-1], point_count)
        new_y = func(new_x)

        fit_points = []
        for xy in zip(new_x, new_y):
            fit_points.append(Point(xy[0], xy[1]))

        curves.append(fit_points)

    return curves


def curves_plot(curves: List[List[Point]]):
    for curve in curves:
        __create_plot(curve)

    total = sum([len(c) for c in curves])
    xmax = max([p.x for p in curves[0]])
    xmin = min([p.x for p in curves[0]])
    interval = (xmax - xmin) / total
    __display(xmax, xmin, interval)


def __create_plot(curve: List[Point], color: str = 'b'):
    xpoints = [p.x for p in curve]
    ypoints = [p.y for p in curve]

    pyplot.plot(xpoints, ypoints, 'o-', color=color)


def __display(xmax, xmin, interval):
    pyplot.xticks(numpy.arange(xmin - interval, xmax + interval, interval * 10))
    pyplot.show()


if __name__ == '__main__':
    cp = generate()
    curves_plot(cp)
