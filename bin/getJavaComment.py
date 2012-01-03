#!/usr/bin/env python
import sys, re
True, False = (1 == 1, 1 == 0)

class JavaComment:
  def __init__(self):
    self.status = 'NIC'
    self.result = ''

  def readFile(self, f):
    i = open(f, 'r')
    content = i.read()
    i.close()
    for c in content: self.addChar(c)
    return self.result

  def addChar(self, c):
    if self.status == 'NIC':
      if c == '/': self.status = 'MIC'

    elif self.status == 'MIC':
      if c == '/':
        self.status = 'SC'
        self.result += '//'
      elif c == '*' :
        self.status ='BC'
        self.result += '/*'
      else: self.status = 'NIC'
    elif self.status == 'SC':
      self.result += c
      if c == '\n': self.status = 'NIC'
    elif self.status == 'BC':
      self.result += c
      if c == '*': self.status = 'MEBC'
    elif self.status == 'MEBC':
      self.result += c
      if c == '/': self.status = 'NIC'
      elif c != '*' : self.status = 'BC'
    else:
      print "!!!Not known status %s !!!" % self.status

  def getResult(self): return result

if __name__ == '__main__':
  for f in sys.argv[1:]:
    jc = JavaComment()
    print '\n'.join([ "%s  : %s" % (f, s) for s in jc.readFile(f).split("\n") if s != ''])

#__EOF__
