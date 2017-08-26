#!/usr/bin/env python3

from random import randint


class Roller:

    def roll(self, expr):
        """
        Evaluate a D&D dice expression.

        TODO: support +/- expression, e.g. (3d2-1)d(5d6+7)

        :param expr:
        :return:
        """
        left, right = self.__split(expr)

        # Note: if the whole expression is wrapped into the parentheses
        # e.g. (3d2), the left is trimmed 3d2 and the right is empty
        if not right:
            left, right = self.__split(left)

        print(f'orig: {expr}, left: {left}, right: {right}')

        if left.find('d') != -1:
            left = self.roll(left)
        if right.find('d') != -1:
            right = self.roll(right)

        return self.__roll(int(left), int(right))

    def __split(self, expr):
        """
        (3d4)d5 -- 3d4 and 5

        :param expr:
        :return:
        """
        first_open = expr.find('(')
        first_d = expr.find('d')

        if first_d == -1:
            raise Exception(f'Invalid expression: {expr}')

        # case 1: no sub expression
        if first_open == -1:
            return expr[:first_d], expr[first_d + 1:]

        # case 2: left has sub expression
        # (3d(1d2))d5
        if first_open < first_d:
            open_close = 0
            for i in range(0, len(expr)):
                if expr[i] == '(':
                    open_close += 1
                elif expr[i] == ')':
                    open_close -= 1
                if open_close == 0:
                    return expr[1:i], expr[i + 2:]

        # case 3: right has sub expression (first_open > first_d)
        # 3d(2d(6d7))
        return expr[:first_d], expr[first_d + 2:len(expr) - 1]

    def __roll(self, times, faces):
        """
        3d5 -- roll a dice with 5 faces 3 times.

        :param times:
        :param faces:
        :return:
        """
        if times < 1:
            return 0

        if faces < 2:
            return times * faces

        result = 0
        for t in range(0, times):
            result += randint(1, faces + 1)

        print(f'rolling dice {times}d{faces}, result: {result}')
        return result

if __name__ == '__main__':
    from sys import argv, exit

    # test case: '(6d5)d(3d(2d1))'

    argv.pop(0)
    if argv:
        e = argv.pop(0)
        try:
            r = Roller().roll(e)
            print(f'{e} => {r}')
        except Exception as err:
            print(f'Unable to roll! expression: {e}, error: {err}')
        exit(0)
    else:
        print('No expression is passed')
        exit(0)
