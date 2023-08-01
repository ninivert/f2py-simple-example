# Fortran to Python module basic example

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