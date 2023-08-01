import numpy as np
import math
import mymodule as mm

n = 1000
x = mm.arrayops.linspace(0.0, 10.0, n)
y1 = x**2
y2 = np.sin(x)
y3 = np.exp(-x)

print('y = x**2')
print('my trapz   ', mm.integrate.trapz(y1, x))
print('numpy trapz', np.trapz(y1, x))
print('analytic   ', 1/3*(x.max() - x.min())**3)

print('y = sin(x)')
print('my trapz   ', mm.integrate.trapz(y2, x))
print('my trapz 2 ', (np.diff(x) * (y2[1:] + y2[:-1]) / 2.0).sum())
print('numpy trapz', np.trapz(y2, x))
print('analytic   ', math.cos(x.min()) - math.cos(x.max()))

print('y = exp(-x)')
print('my trapz   ', mm.integrate.trapz(y3, x))
print('numpy trapz', np.trapz(y3, x))
print('analytic   ', math.exp(-x.min()) - math.exp(-x.max()))