import os
import sqlite3
from datetime import date


class Db:

    def __init__(self):
        self.conn = sqlite3.connect(f'{os.path.dirname(os.path.realpath(__file__))}/vb.db')

        if not self.check('vocabulary'):
            self.init()

    def check(self, table_name):
        c = self.conn.cursor()
        c.execute(f"SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = '{table_name}'")
        result = c.fetchall()

        return len(result) > 0

    def init(self):
        c = self.conn.cursor()
        c.execute('''
                  CREATE TABLE vocabulary 
                  (id INTEGER PRIMARY KEY, word TEXT NOT NULL, example TEXT, define TEXT, created TEXT NOT NULL)
                  ''')

    def add(self, word, define='n', example='n'):
        c = self.conn.cursor()
        c.execute(f"INSERT INTO vocabulary (word, define, example, created) "
                  f"VALUES ('{word}', '{define}', '{example}', '{str(date.today())}')")
        self.conn.commit()

    def delete(self, word):
        c = self.conn.cursor()
        c.execute(f"DELETE FROM vocabulary WHERE word = '{word}'")
        self.conn.commit()

    def find(self, word):
        c = self.conn.cursor()
        c.execute(f"SELECT * FROM vocabulary WHERE word LIKE '%{word}%'")
        return c.fetchall()

    def list(self, before=str(date.today())):
        c = self.conn.cursor()
        c.execute(f"SELECT * FROM vocabulary WHERE created <= '{before}'")
        return c.fetchall()

    def update(self, word, field, value):
        c = self.conn.cursor()
        c.execute(f"UPDATE vocabulary SET {field} = '{value}' WHERE word = '{word}'")
        self.conn.commit()

    def close(self):
        self.conn.close()


if __name__ == '__main__':
    from sys import argv

    help_info = '\n'.join(['-a <word> [define] [example] | add',
                           '-f <word>                    | find',
                           '-d <word>                    | delete',
                           '-u <word> <field> <value>    | update'])

    argv.pop(0)
    if not argv:
        print(help_info)
        exit(0)

    db = Db()

    def pop(args, warn=None):
        if args:
            return args.pop(0)
        if warn:
            print(warn)
            exit(0)
        return None

    while argv:
        opt = argv.pop(0)
        if opt == '-a':
            db.add(pop(argv, 'add word is missing'), pop(argv), pop(argv))
            break
        elif opt == '-f':
            found = db.find(pop(argv, 'find word is missing'))
            print(found)
            break
        elif opt == '-d':
            db.delete(pop(argv, 'delete word is missing'))
            break
        elif opt == '-u':
            db.update(pop(argv, 'update word is missing'),
                      pop(argv, 'update field is missing'),
                      pop(argv, 'update value is missing'))
            break
        elif opt == '-l':
            found_list = db.list(pop(argv))
            for found in found_list:
                print(found)
            break
        else:
            print(help_info)
            break

    db.close()
