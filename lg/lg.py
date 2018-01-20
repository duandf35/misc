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

    stage = __init(kwargs['size'], kwargs['init_percentage'])

    gen = 0
    while gen <= kwargs['generation']:
        __display(stage, gen)
        __update(stage, kwargs['threshold'])
        gen += 1
        time.sleep(0.75)


def __init(stage_size, percentage):
    import random

    stage = [[0] * stage_size for _ in range(stage_size)]
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
    for r in range(0, len(stage)):
        for c in range(0, len(stage[0])):
            neighbours = [(r - 1, c), (r - 1, c - 1), (r - 1, c + 1),
                          (r, c - 1), (r, c + 1),
                          (r + 1, c), (r + 1, c - 1), (r + 1, c + 1)]
            live_count = len([valid_neighbour for valid_neighbour in neighbours if
                              valid_neighbour[0] in range(0, len(stage)) and
                              valid_neighbour[1] in range(0, len(stage[0])) and
                              stage[valid_neighbour[0]][valid_neighbour[1]] in [1, 2]])

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


if __name__ == '__main__':
    from sys import argv

    size = 100
    threshold_lower = 2
    threshold_upper = 3
    generation = 20
    init_percentage = 15

    argv.pop(0)
    while argv:
        opt = argv.pop(0)
        if opt == '-s':
            size = int(argv.pop(0))
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

    life_game(size=size,
              threshold=(threshold_lower, threshold_upper),
              generation=generation,
              init_percentage=init_percentage)
