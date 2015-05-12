from __future__ import print_function
import os
from cmd3.console import Console
from cmd3.shell import command

from cloudmesh_shelve.command_shelve import command_shelve


class cm_shell_shelve:

    def activate_cm_shell_shelve(self):
        self.register_command_topic('mycommands', 'shelve')

    @command
    def do_shelve(self, args, arguments):
        """
        ::

          Usage:
              shelve start [--file=FILENAME]
              shelve clear [--file=FILENAME]
              shelve set <index> <data> [--file=FILENAME]
              shelve delete <index> [--file=FILENAME]
              shelve list [--file=FILENAME]

          Arguments:

            <index>          The key
            <data>           The value

          Options:

             --file=FILENAME  Path to the shelve file [default: shelve.db]

        """
        # pprint(arguments)

        # import pdb;pdb.set_trace()

        if arguments['start']:
            command_shelve.start(path=arguments['--file'])
        elif arguments['clear']:
            command_shelve.clear(path=arguments['--file'])
        elif arguments['set']:
            command_shelve.set(index=arguments['<index>'], data=arguments['<data>'], path=arguments['--file'])
        elif arguments['delete']:
            command_shelve.delete(index=arguments['<index>'])
        elif arguments['list']:
            command_shelve.list(path=arguments['--file'])
        else:
            Console.error("Unsupported argument {}".format(args))


if __name__ == '__main__':
    command = cm_shell_shelve()
    command.do_shelve("iu.edu")
    command.do_shelve("iu.edu-wrong")
