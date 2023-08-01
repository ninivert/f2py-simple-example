# Fortran to Python module basic example

A simple reimplementation of trapezoidal integration (see [wikipedia](https://en.wikipedia.org/wiki/Trapezoidal_rule)) with simple array utilities in Fortran, compilation to a Python module using `numpy.f2py`, and comparison with `numpy.trapz`.

## Demo

```sh
$ make pymodule
$ python demo.py
\include{demo.out}
```

## Compile

Tested with:

- gcc (gfortran) version 13.1.1
- python version 3.11.0
- numpy version 1.24.2
- CPU: Intel(R) Core(TM) i7-7500U CPU @ 2.70GHz

### Fortran executable

Run `make fortran` to compile the Fortran executable.

```sh
$ make fortran
$ ./main
\include{main.out}
```

### `f2py`

Run `make pymodule` to compile the Python module using `f2py`.
The file `.f2py_f2cmap` is used to map `real(dp)` to double-precision floats.

Generate intermediary file for `f2py` (we don't use it so it's OK to rm):

```sh
rm mymodule.pyf && python -m numpy.f2py src/types.f90 src/arrayops.f90 src/integrate.f90 -m mymodule -h mymodule.pyf
```

```f90
\include{mymodule.pyf}
```

## Disassembly

Run `make dump` to generate the dissasembly.

### Fortran module `integrate.trapz`

```
\include{objdump_fortran_trapz.dump}
```

### Python module `integrate.trapz`


```
\include{objdump_pymodule_trapz.dump}
```