#!/usr/bin/env python3


def countdown(dur, m):
    import time

    if m == 'm':
        remain = dur * 60
    elif m == 'h':
        remain = dur * 60 * 60
    else:
        remain = dur

    while remain:
        mins, secs = divmod(remain, 60)
        time_format = '{:02d}:{:02d}'.format(mins, secs)
        print(time_format, end='\r')
        time.sleep(1)
        remain -= 1
    print('Times up!')


def notify():
    import os

    m = '"Times up!"'
    t = '"Python Timer"'
    os.system(f"osascript -e 'display notification {m} with title {t}'")


if __name__ == '__main__':
    help_info = '\n'.join(['<duration> | countdown duration'
                           '-s         | seconds',
                           '-h         | hours',
                           '-m         | minutes (default)'])

    import re
    from sys import argv

    mode = 'm'
    duration = 5

    argv.pop(0)
    while argv:
        opt = argv.pop(0)
        if opt == '-s':
            mode = 's'
        elif opt == '-h':
            mode = 'h'
        else:
            match = re.search('^[0-9]+$', opt)
            if match:
                duration = int(match.group(0))

    countdown(duration, mode)
    notify()
