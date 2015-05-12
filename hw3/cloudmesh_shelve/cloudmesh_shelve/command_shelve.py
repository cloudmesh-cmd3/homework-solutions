from cloudmesh_base.Shell import Shell

import shelve


class command_shelve(object):

    @classmethod
    def start(cls, path=None):
        s = shelve.open(path)
        s.sync()

    @classmethod
    def clear(cls, path=None):
        s = shelve.open(path)
        s.clear()
        s.sync()

    @classmethod
    def set(cls, index=None, data=None, path=None):
        s = shelve.open(path)
        s[index] = data
        s.sync()

    @classmethod
    def delete(cls, index=None, path=None):
        s = shelve.open(path)
        del s[index]
        s.sync()

    @classmethod
    def list(cls, path=None):
        s = shelve.open(path)
        for k,v in s.iteritems():
            print k, v
