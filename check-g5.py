patterns = [
  [0, 3, 4],
  [0, 1, 6],
  [2, 3, 5],
  [1, 3, 6],
  [3, 4, 6],
  [0, 3, 5],
  [1, 4, 6]
]

reached = [ 0 for x in range(128) ]

for i in range(128):
  res = 0
  for j, p in enumerate(patterns):
    if (i >> j) & 1:
      res ^= 1 << p[0]
      res ^= 1 << p[1]
      res ^= 1 << p[2]
  reached[res] = 1
  print(i, res)

print(reached)
