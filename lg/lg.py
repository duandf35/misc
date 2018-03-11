#!/usr/bin/env python3


def life_game(**kwargs):
    """
    Any live cell with fewer than two live neighbours dies, as if caused by underpopulation.
    Any live cell with two or three live neighbours lives on to the next generation.
    Any live cell with more than three live neighbours dies, as if by overpopulation.
    Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
    """
    import time

    print(f"\nconfig: {kwargs}\n")
    time.sleep(1)

    file = kwargs['input_file']

    if not file:
        stage = __init(kwargs['size'], kwargs['init_percentage'])
    else:
        stage = __from_file(file)

    gen = 0
    while gen < kwargs['generation']:
        __display(stage, gen)
        __update(stage, kwargs['threshold'])
        gen += 1
        time.sleep(0.75)
    __display(stage, gen)
    __to_file(stage)


def __init(stage_size, percentage):
    import random

    stage = [[0] * stage_size[0] for _ in range(stage_size[1])]
    for r in range(0, len(stage)):
        for c in range(0, len(stage[0])):
            if random.randint(0, 100) <= percentage:
                stage[r][c] = 1

    return stage


def __update(stage, live_threshold):
    """
    0 -- dead
    1 -- live
    2 -- dying
    3 -- respawn
    :param stage:
    :return:
    """
    height = len(stage)
    width = len(stage[0])
    for r in range(0, height):
        for c in range(0, width):
            neighbours = []
            for roff in range(-1, 2):
                for coff in range(-1, 2):
                    if roff == 0 and coff == 0:
                        continue
                    neighbours.append(((r + roff) % height, (c + coff) % width))

            live_count = len([neighbour for neighbour in neighbours if
                              stage[neighbour[0]][neighbour[1]] in [1, 2]])

            if stage[r][c] == 1 and live_count not in range(live_threshold[0], live_threshold[1] + 1):
                # dying
                stage[r][c] = 2

            if stage[r][c] == 0 and live_count == live_threshold[1]:
                # respawn
                stage[r][c] = 3


def __display(stage, gen):
    print(f"\ngeneration: {gen}")
    for r in range(0, len(stage)):
        for c in range(0, len(stage[0])):
            if stage[r][c] == 2:
                stage[r][c] = 0
            elif stage[r][c] == 3:
                stage[r][c] = 1
            print(stage[r][c], end='')
        print()


def __from_file(file):
    stage = []
    with open(file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            stage.append([int(c) for c in list(line) if c != '\n'])
    return stage


def __to_file(stage):
    from datetime import datetime

    with open(f"output-{str(datetime.now().timestamp()).split('.')[0]}.txt", 'w') as f:
        for row in stage:
            for col in row:
                f.write(str(col))
            f.write('\n')


if __name__ == '__main__':
    from sys import argv

    size_w = 100
    size_h = 25
    threshold_lower = 2
    threshold_upper = 3
    generation = 20
    init_percentage = 15
    input_file = None

    argv.pop(0)
    while argv:
        opt = argv.pop(0)
        if opt == '-w':
            size_w = int(argv.pop(0))
        elif opt == 'h':
            size_h = int(argv.pop(0))
        elif opt == '-l':
            if threshold_lower > 0:
                threshold_lower = int(argv.pop(0))
        elif opt == 'u':
            if threshold_upper > 0 and threshold_upper > threshold_lower:
                threshold_upper = int(argv.pop(0))
        elif opt == '-g':
            generation = int(argv.pop(0))
        elif opt == '-p':
            init_percentage = int(argv.pop(0))
        elif opt == '-f':
            input_file = argv.pop(0)

    life_game(size=(size_w, size_h),
              threshold=(threshold_lower, threshold_upper),
              generation=generation,
              init_percentage=init_percentage,
              input_file=input_file)
