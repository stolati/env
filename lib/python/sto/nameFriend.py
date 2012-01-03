#!/usr/bin/env python
True = (1 == 1)
False = (not True)

# permit friendly name chose
# if the name is near, or other keyboard stuffs

class Names:
  def __init__(self, content=[]):
    self.setContent(content)

  def setContent(self, content):
    self._content=[]
    for n in sorted(content):
      assert n not in self._content, "Duplicate [%s]" %n
      self._content.append(n)

  def getContent(self): return self._content

  # finds functions
  # return a list of valid names

  def find_exact(self, token): #find the exact name
    if token in self._content: return [token]
    return []

  def find_begin(self, token): #find names that begin with token
    return filter(lambda x: x.find(token) == 0, self._content)

  def find_contain(self, token): #find names that contain token
    return filter(lambda x: x.find(token) != -1, self._content)

  def find_anagram(self, token): #find names that contains the sames words
    tl=sorted(list(token))
    return filter(lambda x: sorted(list(x)) == tl, self._content)

  #try to find a single response using all the methods
  #from the nearest to the farest
  #if a method return multiple responses, consider failed
  #and return empty list
  def find_all(self, token):
    res = self.find_exact(token)
    if res : return res

    res = self.find_begin(token)
    if len(res) == 1 : return res
    if res : return []

    res = self.find_contain(token)
    if len(res) == 1 : return res
    if res : return []

    res = self.find_anagram(token)
    if len(res) == 1 : return res
    if res : return []


if __name__ == "__main__":
  n = Names()
  n.setContent(['toto', 'tito', 'totu', 'tralal', 'ttio'])

  assert n.find_exact('tito') == ['tito']
  assert n.find_exact('titi') == []

  assert n.find_begin('to') == ['toto', 'totu']
  assert n.find_begin('tr') == ['tralal']
  assert n.find_begin('o') == []

  assert n.find_contain('to') == ['tito', 'toto', 'totu']
  assert n.find_contain('la') == ['tralal']
  assert n.find_contain('lo') == []

  assert n.find_anagram('toot') == ['toto']
  assert n.find_anagram('iott') == ['tito', 'ttio']
  assert n.find_anagram('tra') == []

