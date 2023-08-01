import matplotlib.pyplot as plt
import re
import sys

data: dict[str, list[float]] = dict()

SPLIT_RE = re.compile(r' +')

with open(sys.argv[1]) as file:
	for line in file.readlines():
		dat = re.split(SPLIT_RE, line.strip())
		data[dat[0]] = [ float(x) for x in dat[1:] ]


fig, axs = plt.subplots(nrows=len(data), layout='constrained')
for ax, (name, dats) in zip(axs, data.items()):
	ax.plot(dats, '.-')  #, label=name)
	ax.set_title(name)
plt.show()