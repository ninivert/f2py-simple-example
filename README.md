# Fortran to Python module basic example

A simple reimplementation of trapezoidal integration (see [wikipedia](https://en.wikipedia.org/wiki/Trapezoidal_rule)) with simple array utilities in Fortran, compilation to a Python module using `numpy.f2py`, and comparison with `numpy.trapz`.

## Demo

```sh
$ make pymodule
$ python demo.py
y = x**2
my trapz    333.3335003338342
numpy trapz 333.333500333834
analytic    333.3333333333333
y = sin(x)
my trapz    1.839056172757498
my trapz 2  1.8390561727575014
numpy trapz 1.8390561727575014
analytic    1.8390715290764525
y = exp(-x)
my trapz    0.9999629497022375
numpy trapz 0.9999629497022364
analytic    0.9999546000702375

```

## Compile

Tested with:

- gcc (gfortran) version 13.1.1
- python version 3.11.0
- numpy version 1.24.2
- CPU: Intel(R) Core(TM) i7-7500U CPU  2.70GHz

### Fortran executable

Run `make fortran` to compile the Fortran executable.

```sh
$ make fortran
$ ./main
 y = x**2
   trapz   0.333334E+03
analytic   0.333333E+03
 y = sin(x)
   trapz   0.183906E+01
analytic   0.183907E+01
 y = exp(-x)
   trapz   0.999963E+00
analytic   0.999955E+00

```

### `f2py`

Run `make pymodule` to compile the Python module using `f2py`.
The file `.f2py_f2cmap` is used to map `real(dp)` to double-precision floats.

Generate intermediary file for `f2py` (we don't use it so it's OK to rm):

```sh
rm mymodule.pyf && python -m numpy.f2py src/types.f90 src/arrayops.f90 src/integrate.f90 -m mymodule -h mymodule.pyf
```

```f90
!    -*- f90 -*-
! Note: the context of this file is case sensitive.

python module mymodule ! in 
    interface  ! in :mymodule
        module types ! in :mymodule:src/types.f90
            integer, parameter,public,optional :: dp=kind(0.d0)
            integer, parameter,public,optional :: hp=selected_real_kind(15)
        end module types
        module arrayops ! in :mymodule:src/arrayops.f90
            use types, only: dp
            function diff(x) result (r) ! in :mymodule:src/arrayops.f90:arrayops
                real(kind=8) dimension(:),intent(in) :: x
                real(kind=8) dimension(-1 + size(x)) :: r
            end function diff
            function midpoints(x) result (r) ! in :mymodule:src/arrayops.f90:arrayops
                real(kind=8) dimension(:),intent(in) :: x
                real(kind=8) dimension(-1 + size(x)) :: r
            end function midpoints
            function arange(n) result (r) ! in :mymodule:src/arrayops.f90:arrayops
                integer intent(in) :: n
                real(kind=8) dimension(n) :: r
            end function arange
            function linspace(x_min,x_max,n) result (r) ! in :mymodule:src/arrayops.f90:arrayops
                real(kind=8) intent(in) :: x_min
                real(kind=8) intent(in) :: x_max
                integer intent(in) :: n
                real(kind=8) dimension(n) :: r
            end function linspace
            function full(n,s) result (r) ! in :mymodule:src/arrayops.f90:arrayops
                integer intent(in) :: n
                real(kind=8) intent(in) :: s
                real(kind=8) dimension(n) :: r
            end function full
            function zeros(n) result (r) ! in :mymodule:src/arrayops.f90:arrayops
                integer intent(in) :: n
                real(kind=8) dimension(n) :: r
            end function zeros
            function ones(n) result (r) ! in :mymodule:src/arrayops.f90:arrayops
                integer intent(in) :: n
                real(kind=8) dimension(n) :: r
            end function ones
        end module arrayops
        module integrate ! in :mymodule:src/integrate.f90
            use types, only: dp
            use arrayops, only: midpoints,diff,ones
            function trapz(y,x) result (r) ! in :mymodule:src/integrate.f90:integrate
                real(kind=8), required,dimension(:),intent(in) :: y
                real(kind=8), optional,dimension(size(y)),intent(in),check(shape(x, 0) == size(y)),depend(y) :: x
                real(kind=8) :: r
            end function trapz
        end module integrate
    end interface 
end python module mymodule

! This file was auto-generated with f2py (version:1.24.2).
! See:
! https://web.archive.org/web/20140822061353/http://cens.ioc.ee/projects/f2py2e

```

## Disassembly

Run `make dump` to generate the dissasembly.

### Fortran module `integrate.trapz`

```

build/integrate.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <__integrate_MOD_trapz>:
   0:	                                           55                   	push   rbp
   1:	                                           48 89 f2             	mov    rdx,rsi
   4:	                                           48 89 e5             	mov    rbp,rsp
   7:	                                           41 57                	push   r15
   9:	                                           41 56                	push   r14
   b:	                                           41 55                	push   r13
   d:	                                           41 54                	push   r12
   f:	                                           53                   	push   rbx
  10:	                                           48 83 e4 e0          	and    rsp,0xffffffffffffffe0
  14:	                                           48 81 ec c0 00 00 00 	sub    rsp,0xc0
  1b:	                                           64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
  22:	                                           00 00 
  24:	                                           48 89 84 24 b8 00 00 	mov    QWORD PTR [rsp+0xb8],rax
  2b:	                                           00 
  2c:	                                           31 c0                	xor    eax,eax
  2e:	                                           48 8b 77 28          	mov    rsi,QWORD PTR [rdi+0x28]
  32:	                                           48 85 f6             	test   rsi,rsi
  35:	/----------------------------------------- 0f 84 15 03 00 00    	je     350 <__integrate_MOD_trapz+0x350>
  3b:	|                                          48 89 f0             	mov    rax,rsi
  3e:	|                                          48 f7 d8             	neg    rax
  41:	|                                          48 89 44 24 28       	mov    QWORD PTR [rsp+0x28],rax
  46:	|  /-------------------------------------> 4c 8b 7f 38          	mov    r15,QWORD PTR [rdi+0x38]
  4a:	|  |                                       41 bd 00 00 00 00    	mov    r13d,0x0
  50:	|  |                                       b9 00 00 00 00       	mov    ecx,0x0
  55:	|  |                                       4c 8b 37             	mov    r14,QWORD PTR [rdi]
  58:	|  |                                       48 89 54 24 20       	mov    QWORD PTR [rsp+0x20],rdx
  5d:	|  |                                       4c 2b 7f 30          	sub    r15,QWORD PTR [rdi+0x30]
  61:	|  |                                       48 89 74 24 18       	mov    QWORD PTR [rsp+0x18],rsi
  66:	|  |                                       49 ff c7             	inc    r15
  69:	|  |                                       4d 0f 49 ef          	cmovns r13,r15
  6d:	|  |                                       48 85 d2             	test   rdx,rdx
  70:	|  |                                       49 63 c5             	movsxd rax,r13d
  73:	|  |                                       48 0f 45 c8          	cmovne rcx,rax
  77:	|  |                                       41 ff cd             	dec    r13d
  7a:	|  |                                       31 ff                	xor    edi,edi
  7c:	|  |                                       b8 01 00 00 00       	mov    eax,0x1
  81:	|  |                                       4d 63 e5             	movsxd r12,r13d
  84:	|  |                                       4d 85 e4             	test   r12,r12
  87:	|  |                                       48 89 4c 24 10       	mov    QWORD PTR [rsp+0x10],rcx
  8c:	|  |                                       49 0f 49 fc          	cmovns rdi,r12
  90:	|  |                                       48 c1 e7 03          	shl    rdi,0x3
  94:	|  |                                       48 0f 44 f8          	cmove  rdi,rax
  98:	|  |                                   /-- e8 00 00 00 00       	call   9d <__integrate_MOD_trapz+0x9d>
  9d:	|  |                                   \-> 48 8b 74 24 18       	mov    rsi,QWORD PTR [rsp+0x18]
  a2:	|  |                                       c5 f9 6f 05 00 00 00 	vmovdqa xmm0,XMMWORD PTR [rip+0x0]        # aa <__integrate_MOD_trapz+0xaa>
  a9:	|  |                                       00 
  aa:	|  |                                       4c 89 bc 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],r15
  b1:	|  |                                       00 
  b2:	|  |                                       48 89 44 24 30       	mov    QWORD PTR [rsp+0x30],rax
  b7:	|  |                                       48 89 c3             	mov    rbx,rax
  ba:	|  |                                       48 b8 00 00 00 00 01 	movabs rax,0x30100000000
  c1:	|  |                                       03 00 00 
  c4:	|  |                                       4c 8d 7c 24 30       	lea    r15,[rsp+0x30]
  c9:	|  |                                       48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
  ce:	|  |                                       4c 89 ff             	mov    rdi,r15
  d1:	|  |                                       48 89 84 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rax
  d8:	|  |                                       00 
  d9:	|  |                                       48 8b 44 24 28       	mov    rax,QWORD PTR [rsp+0x28]
  de:	|  |                                       48 89 b4 24 98 00 00 	mov    QWORD PTR [rsp+0x98],rsi
  e5:	|  |                                       00 
  e6:	|  |                                       4c 89 74 24 70       	mov    QWORD PTR [rsp+0x70],r14
  eb:	|  |                                       4c 8d 74 24 70       	lea    r14,[rsp+0x70]
  f0:	|  |                                       4c 89 64 24 68       	mov    QWORD PTR [rsp+0x68],r12
  f5:	|  |                                       4c 89 f6             	mov    rsi,r14
  f8:	|  |                                       48 c7 44 24 38 ff ff 	mov    QWORD PTR [rsp+0x38],0xffffffffffffffff
  ff:	|  |                                       ff ff 
 101:	|  |                                       48 c7 44 24 40 08 00 	mov    QWORD PTR [rsp+0x40],0x8
 108:	|  |                                       00 00 
 10a:	|  |                                       48 c7 44 24 60 01 00 	mov    QWORD PTR [rsp+0x60],0x1
 111:	|  |                                       00 00 
 113:	|  |                                       48 c7 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],0x8
 11a:	|  |                                       00 08 00 00 00 
 11f:	|  |                                       48 c7 84 24 90 00 00 	mov    QWORD PTR [rsp+0x90],0x8
 126:	|  |                                       00 08 00 00 00 
 12b:	|  |                                       48 c7 84 24 a0 00 00 	mov    QWORD PTR [rsp+0xa0],0x1
 132:	|  |                                       00 01 00 00 00 
 137:	|  |                                       48 89 44 24 78       	mov    QWORD PTR [rsp+0x78],rax
 13c:	|  |                                       c5 f9 7f 44 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm0
 142:	|  |                                   /-- e8 00 00 00 00       	call   147 <__integrate_MOD_trapz+0x147>
 147:	|  |                                   \-> 48 8b 54 24 20       	mov    rdx,QWORD PTR [rsp+0x20]
 14c:	|  |                                       48 85 d2             	test   rdx,rdx
 14f:	|  |  /----------------------------------- 0f 84 13 02 00 00    	je     368 <__integrate_MOD_trapz+0x368>
 155:	|  |  |                                    c5 f9 6f 05 00 00 00 	vmovdqa xmm0,XMMWORD PTR [rip+0x0]        # 15d <__integrate_MOD_trapz+0x15d>
 15c:	|  |  |                                    00 
 15d:	|  |  |                                    48 8b 4c 24 10       	mov    rcx,QWORD PTR [rsp+0x10]
 162:	|  |  |                                    48 89 54 24 30       	mov    QWORD PTR [rsp+0x30],rdx
 167:	|  |  |                                    49 8d 54 24 ff       	lea    rdx,[r12-0x1]
 16c:	|  |  |                                    48 b8 00 00 00 00 01 	movabs rax,0x30100000000
 173:	|  |  |                                    03 00 00 
 176:	|  |  |                                    48 85 d2             	test   rdx,rdx
 179:	|  |  |                                    48 c7 44 24 38 ff ff 	mov    QWORD PTR [rsp+0x38],0xffffffffffffffff
 180:	|  |  |                                    ff ff 
 182:	|  |  |                                    48 89 4c 24 68       	mov    QWORD PTR [rsp+0x68],rcx
 187:	|  |  |                                    48 c7 44 24 40 08 00 	mov    QWORD PTR [rsp+0x40],0x8
 18e:	|  |  |                                    00 00 
 190:	|  |  |                                    48 89 44 24 48       	mov    QWORD PTR [rsp+0x48],rax
 195:	|  |  |                                    48 c7 44 24 60 01 00 	mov    QWORD PTR [rsp+0x60],0x1
 19c:	|  |  |                                    00 00 
 19e:	|  |  |                                    48 89 94 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],rdx
 1a5:	|  |  |                                    00 
 1a6:	|  |  |                                    48 c7 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],0x8
 1ad:	|  |  |                                    00 08 00 00 00 
 1b2:	|  |  |                                    48 89 84 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rax
 1b9:	|  |  |                                    00 
 1ba:	|  |  |                                    48 c7 84 24 a0 00 00 	mov    QWORD PTR [rsp+0xa0],0x0
 1c1:	|  |  |                                    00 00 00 00 00 
 1c6:	|  |  |                                    48 89 54 24 28       	mov    QWORD PTR [rsp+0x28],rdx
 1cb:	|  |  |                                    c5 f9 7f 44 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm0
 1d1:	|  |  |                                    c5 f9 7f 84 24 90 00 	vmovdqa XMMWORD PTR [rsp+0x90],xmm0
 1d8:	|  |  |                                    00 00 
 1da:	|  |  |     /----------------------------- 0f 88 98 01 00 00    	js     378 <__integrate_MOD_trapz+0x378>
 1e0:	|  |  |     |                              4a 8d 3c e5 00 00 00 	lea    rdi,[r12*8+0x0]
 1e7:	|  |  |     |                              00 
 1e8:	|  |  |     |                          /-- e8 00 00 00 00       	call   1ed <__integrate_MOD_trapz+0x1ed>
 1ed:	|  |  |     |                          \-> 48 c7 44 24 78 00 00 	mov    QWORD PTR [rsp+0x78],0x0
 1f4:	|  |  |     |                              00 00 
 1f6:	|  |  |     |                              4c 89 f7             	mov    rdi,r14
 1f9:	|  |  |     |                              4c 89 fe             	mov    rsi,r15
 1fc:	|  |  |     |                              48 89 44 24 70       	mov    QWORD PTR [rsp+0x70],rax
 201:	|  |  |     |                          /-- e8 00 00 00 00       	call   206 <__integrate_MOD_trapz+0x206>
 206:	|  |  |     |                          \-> 48 8b 54 24 28       	mov    rdx,QWORD PTR [rsp+0x28]
 20b:	|  |  |     |                              48 8b 7c 24 70       	mov    rdi,QWORD PTR [rsp+0x70]
 210:	|  |  |     |                              48 83 fa 02          	cmp    rdx,0x2
 214:	|  |  |  /--|----------------------------- 0f 86 b4 01 00 00    	jbe    3ce <__integrate_MOD_trapz+0x3ce>
 21a:	|  |  |  |  |                              4c 89 e2             	mov    rdx,r12
 21d:	|  |  |  |  |                              31 c0                	xor    eax,eax
 21f:	|  |  |  |  |                              48 c1 ea 02          	shr    rdx,0x2
 223:	|  |  |  |  |                              48 c1 e2 05          	shl    rdx,0x5
 227:	|  |  |  |  |                              66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
 22e:	|  |  |  |  |                              00 00 
 230:	|  |  |  |  |                          /-> c5 fd 10 0c 03       	vmovupd ymm1,YMMWORD PTR [rbx+rax*1]
 235:	|  |  |  |  |                          |   c5 f5 59 04 07       	vmulpd ymm0,ymm1,YMMWORD PTR [rdi+rax*1]
 23a:	|  |  |  |  |                          |   c5 fd 11 04 03       	vmovupd YMMWORD PTR [rbx+rax*1],ymm0
 23f:	|  |  |  |  |                          |   48 83 c0 20          	add    rax,0x20
 243:	|  |  |  |  |                          |   48 39 c2             	cmp    rdx,rax
 246:	|  |  |  |  |                          \-- 75 e8                	jne    230 <__integrate_MOD_trapz+0x230>
 248:	|  |  |  |  |                              4d 89 e6             	mov    r14,r12
 24b:	|  |  |  |  |                              49 83 e6 fc          	and    r14,0xfffffffffffffffc
 24f:	|  |  |  |  |                              41 83 e5 03          	and    r13d,0x3
 253:	|  |  |  |  |                              4c 89 f0             	mov    rax,r14
 256:	|  |  |  |  |     /----------------------- 0f 84 54 01 00 00    	je     3b0 <__integrate_MOD_trapz+0x3b0>
 25c:	|  |  |  |  |     |                        c5 f8 77             	vzeroupper
 25f:	|  |  |  |  |  /--|----------------------> 4c 89 e2             	mov    rdx,r12
 262:	|  |  |  |  |  |  |                        4c 29 f2             	sub    rdx,r14
 265:	|  |  |  |  |  |  |                        48 83 fa 01          	cmp    rdx,0x1
 269:	|  |  |  |  |  |  |                 /----- 74 1e                	je     289 <__integrate_MOD_trapz+0x289>
 26b:	|  |  |  |  |  |  |                 |      c4 a1 79 10 14 f7    	vmovupd xmm2,XMMWORD PTR [rdi+r14*8]
 271:	|  |  |  |  |  |  |                 |      4a 8d 0c f3          	lea    rcx,[rbx+r14*8]
 275:	|  |  |  |  |  |  |                 |      c5 e9 59 01          	vmulpd xmm0,xmm2,XMMWORD PTR [rcx]
 279:	|  |  |  |  |  |  |                 |      c5 f9 11 01          	vmovupd XMMWORD PTR [rcx],xmm0
 27d:	|  |  |  |  |  |  |                 |      f6 c2 01             	test   dl,0x1
 280:	|  |  |  |  |  |  |                 |  /-- 74 16                	je     298 <__integrate_MOD_trapz+0x298>
 282:	|  |  |  |  |  |  |                 |  |   48 83 e2 fe          	and    rdx,0xfffffffffffffffe
 286:	|  |  |  |  |  |  |                 |  |   48 01 d0             	add    rax,rdx
 289:	|  |  |  |  |  |  |                 \--|-> c5 fb 10 04 c3       	vmovsd xmm0,QWORD PTR [rbx+rax*8]
 28e:	|  |  |  |  |  |  |                    |   c5 fb 59 04 c7       	vmulsd xmm0,xmm0,QWORD PTR [rdi+rax*8]
 293:	|  |  |  |  |  |  |                    |   c5 fb 11 04 c3       	vmovsd QWORD PTR [rbx+rax*8],xmm0
 298:	|  |  |  |  |  |  |                 /--\-X e8 00 00 00 00       	call   29d <__integrate_MOD_trapz+0x29d>
 29d:	|  |  |  |  |  |  |                 >----> 49 8d 44 24 ff       	lea    rax,[r12-0x1]
 2a2:	|  |  |  |  |  |  |                 |      4d 89 e6             	mov    r14,r12
 2a5:	|  |  |  |  |  |  |                 |      48 83 f8 02          	cmp    rax,0x2
 2a9:	|  |  |  |  |  |  |  /--------------|----- 0f 86 11 01 00 00    	jbe    3c0 <__integrate_MOD_trapz+0x3c0>
 2af:	|  |  |  |  |  |  |  |  /-----------|----> 4c 89 f2             	mov    rdx,r14
 2b2:	|  |  |  |  |  |  |  |  |           |      48 89 d8             	mov    rax,rbx
 2b5:	|  |  |  |  |  |  |  |  |           |      c5 f9 57 c0          	vxorpd xmm0,xmm0,xmm0
 2b9:	|  |  |  |  |  |  |  |  |           |      48 c1 ea 02          	shr    rdx,0x2
 2bd:	|  |  |  |  |  |  |  |  |           |      48 c1 e2 05          	shl    rdx,0x5
 2c1:	|  |  |  |  |  |  |  |  |           |      48 01 da             	add    rdx,rbx
 2c4:	|  |  |  |  |  |  |  |  |           |      0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
 2c8:	|  |  |  |  |  |  |  |  |           |  /-> c5 fb 58 00          	vaddsd xmm0,xmm0,QWORD PTR [rax]
 2cc:	|  |  |  |  |  |  |  |  |           |  |   48 83 c0 20          	add    rax,0x20
 2d0:	|  |  |  |  |  |  |  |  |           |  |   c5 fb 58 40 e8       	vaddsd xmm0,xmm0,QWORD PTR [rax-0x18]
 2d5:	|  |  |  |  |  |  |  |  |           |  |   c5 fb 58 40 f0       	vaddsd xmm0,xmm0,QWORD PTR [rax-0x10]
 2da:	|  |  |  |  |  |  |  |  |           |  |   c5 fb 58 40 f8       	vaddsd xmm0,xmm0,QWORD PTR [rax-0x8]
 2df:	|  |  |  |  |  |  |  |  |           |  |   48 39 c2             	cmp    rdx,rax
 2e2:	|  |  |  |  |  |  |  |  |           |  \-- 75 e4                	jne    2c8 <__integrate_MOD_trapz+0x2c8>
 2e4:	|  |  |  |  |  |  |  |  |           |      4c 89 f0             	mov    rax,r14
 2e7:	|  |  |  |  |  |  |  |  |           |      48 83 e0 fc          	and    rax,0xfffffffffffffffc
 2eb:	|  |  |  |  |  |  |  |  |           |      48 ff c0             	inc    rax
 2ee:	|  |  |  |  |  |  |  |  |           |      41 83 e6 03          	and    r14d,0x3
 2f2:	|  |  |  |  |  |  |  |  |     /-----|----- 74 20                	je     314 <__integrate_MOD_trapz+0x314>
 2f4:	|  |  |  |  |  |  |  |  |  /--|-----|----> 48 8d 14 c3          	lea    rdx,[rbx+rax*8]
 2f8:	|  |  |  |  |  |  |  |  |  |  |     |      c5 fb 58 42 f8       	vaddsd xmm0,xmm0,QWORD PTR [rdx-0x8]
 2fd:	|  |  |  |  |  |  |  |  |  |  |     |      49 39 c4             	cmp    r12,rax
 300:	|  |  |  |  |  |  |  |  |  |  +-----|----- 7e 12                	jle    314 <__integrate_MOD_trapz+0x314>
 302:	|  |  |  |  |  |  |  |  |  |  |     |      48 83 c0 02          	add    rax,0x2
 306:	|  |  |  |  |  |  |  |  |  |  |     |      c5 fb 58 02          	vaddsd xmm0,xmm0,QWORD PTR [rdx]
 30a:	|  |  |  |  |  |  |  |  |  |  |     |      49 39 c4             	cmp    r12,rax
 30d:	|  |  |  |  |  |  |  |  |  |  +-----|----- 7c 05                	jl     314 <__integrate_MOD_trapz+0x314>
 30f:	|  |  |  |  |  |  |  |  |  |  |     |      c5 fb 58 42 08       	vaddsd xmm0,xmm0,QWORD PTR [rdx+0x8]
 314:	|  |  |  |  |  |  |  |  |  |  >-----|----> 48 89 df             	mov    rdi,rbx
 317:	|  |  |  |  |  |  |  |  |  |  |     |      c5 fb 11 44 24 28    	vmovsd QWORD PTR [rsp+0x28],xmm0
 31d:	|  |  |  |  |  |  |  |  |  |  |     |  /-- e8 00 00 00 00       	call   322 <__integrate_MOD_trapz+0x322>
 322:	|  |  |  |  |  |  |  |  |  |  |     |  \-> c5 fb 10 44 24 28    	vmovsd xmm0,QWORD PTR [rsp+0x28]
 328:	|  |  |  |  |  |  |  |  |  |  |     |      48 8b 84 24 b8 00 00 	mov    rax,QWORD PTR [rsp+0xb8]
 32f:	|  |  |  |  |  |  |  |  |  |  |     |      00 
 330:	|  |  |  |  |  |  |  |  |  |  |     |      64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
 337:	|  |  |  |  |  |  |  |  |  |  |     |      00 00 
 339:	|  |  |  |  |  |  |  |  |  |  |  /--|----- 0f 85 99 00 00 00    	jne    3d8 <__integrate_MOD_trapz+0x3d8>
 33f:	|  |  |  |  |  |  |  |  |  |  |  |  |      48 8d 65 d8          	lea    rsp,[rbp-0x28]
 343:	|  |  |  |  |  |  |  |  |  |  |  |  |      5b                   	pop    rbx
 344:	|  |  |  |  |  |  |  |  |  |  |  |  |      41 5c                	pop    r12
 346:	|  |  |  |  |  |  |  |  |  |  |  |  |      41 5d                	pop    r13
 348:	|  |  |  |  |  |  |  |  |  |  |  |  |      41 5e                	pop    r14
 34a:	|  |  |  |  |  |  |  |  |  |  |  |  |      41 5f                	pop    r15
 34c:	|  |  |  |  |  |  |  |  |  |  |  |  |      5d                   	pop    rbp
 34d:	|  |  |  |  |  |  |  |  |  |  |  |  |      c3                   	ret
 34e:	|  |  |  |  |  |  |  |  |  |  |  |  |      66 90                	xchg   ax,ax
 350:	\--|--|--|--|--|--|--|--|--|--|--|--|----> 48 c7 44 24 28 ff ff 	mov    QWORD PTR [rsp+0x28],0xffffffffffffffff
 357:	   |  |  |  |  |  |  |  |  |  |  |  |      ff ff 
 359:	   |  |  |  |  |  |  |  |  |  |  |  |      be 01 00 00 00       	mov    esi,0x1
 35e:	   \--|--|--|--|--|--|--|--|--|--|--|----- e9 e3 fc ff ff       	jmp    46 <__integrate_MOD_trapz+0x46>
 363:	      |  |  |  |  |  |  |  |  |  |  |      0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
 368:	      \--|--|--|--|--|--|--|--|--|--|----> 45 85 ed             	test   r13d,r13d
 36b:	         |  |  |  |  |  |  |  |  |  \----- 0f 8f 2c ff ff ff    	jg     29d <__integrate_MOD_trapz+0x29d>
 371:	         |  |  |  |  |  |  |  |  |  /----- eb 32                	jmp    3a5 <__integrate_MOD_trapz+0x3a5>
 373:	         |  |  |  |  |  |  |  |  |  |      0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
 378:	         |  \--|--|--|--|--|--|--|--|----> bf 01 00 00 00       	mov    edi,0x1
 37d:	         |     |  |  |  |  |  |  |  |  /-- e8 00 00 00 00       	call   382 <__integrate_MOD_trapz+0x382>
 382:	         |     |  |  |  |  |  |  |  |  \-> 48 c7 44 24 78 00 00 	mov    QWORD PTR [rsp+0x78],0x0
 389:	         |     |  |  |  |  |  |  |  |      00 00 
 38b:	         |     |  |  |  |  |  |  |  |      4c 89 f7             	mov    rdi,r14
 38e:	         |     |  |  |  |  |  |  |  |      4c 89 fe             	mov    rsi,r15
 391:	         |     |  |  |  |  |  |  |  |      48 89 44 24 70       	mov    QWORD PTR [rsp+0x70],rax
 396:	         |     |  |  |  |  |  |  |  |  /-- e8 00 00 00 00       	call   39b <__integrate_MOD_trapz+0x39b>
 39b:	         |     |  |  |  |  |  |  |  |  \-> 48 8b 7c 24 70       	mov    rdi,QWORD PTR [rsp+0x70]
 3a0:	         |     |  |  |  |  |  |  |  +----- e8 00 00 00 00       	call   3a5 <__integrate_MOD_trapz+0x3a5>
 3a5:	         |     |  |  |  |  |  |  |  \----> c5 f9 57 c0          	vxorpd xmm0,xmm0,xmm0
 3a9:	         |     |  |  |  |  |  \--|-------- e9 66 ff ff ff       	jmp    314 <__integrate_MOD_trapz+0x314>
 3ae:	         |     |  |  |  |  |     |         66 90                	xchg   ax,ax
 3b0:	         |     |  \--|--|--|-----|-------> c5 f8 77             	vzeroupper
 3b3:	         |     |     |  |  |     |     /-- e8 00 00 00 00       	call   3b8 <__integrate_MOD_trapz+0x3b8>
 3b8:	         |     |     |  \--|-----|-----\-X e9 f2 fe ff ff       	jmp    2af <__integrate_MOD_trapz+0x2af>
 3bd:	         |     |     |     |     |         0f 1f 00             	nop    DWORD PTR [rax]
 3c0:	         |     |     \-----|-----|-------> b8 01 00 00 00       	mov    eax,0x1
 3c5:	         |     |           |     |         c5 f9 57 c0          	vxorpd xmm0,xmm0,xmm0
 3c9:	         |     |           \-----|-------- e9 26 ff ff ff       	jmp    2f4 <__integrate_MOD_trapz+0x2f4>
 3ce:	         \-----|-----------------|-------> 45 31 f6             	xor    r14d,r14d
 3d1:	               |                 |         31 c0                	xor    eax,eax
 3d3:	               \-----------------|-------- e9 87 fe ff ff       	jmp    25f <__integrate_MOD_trapz+0x25f>
 3d8:	                                 \-------> e8 00 00 00 00       	call   3dd <__integrate_MOD_trapz+0x3dd>

```

### Python module `integrate.trapz`


```

mymodule.cpython-311-x86_64-linux-gnu.so:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000009020 <__integrate_MOD_trapz>:
    9020:	                                                          55                   	push   rbp
    9021:	                                                          48 89 f1             	mov    rcx,rsi
    9024:	                                                          48 89 e5             	mov    rbp,rsp
    9027:	                                                          41 57                	push   r15
    9029:	                                                          41 56                	push   r14
    902b:	                                                          41 55                	push   r13
    902d:	                                                          41 54                	push   r12
    902f:	                                                          53                   	push   rbx
    9030:	                                                          48 83 e4 e0          	and    rsp,0xffffffffffffffe0
    9034:	                                                          48 81 ec c0 00 00 00 	sub    rsp,0xc0
    903b:	                                                          64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
    9042:	                                                          00 00 
    9044:	                                                          48 89 84 24 b8 00 00 	mov    QWORD PTR [rsp+0xb8],rax
    904b:	                                                          00 
    904c:	                                                          31 c0                	xor    eax,eax
    904e:	                                                          48 8b 77 28          	mov    rsi,QWORD PTR [rdi+0x28]
    9052:	                                                          48 85 f6             	test   rsi,rsi
    9055:	/-------------------------------------------------------- 0f 84 85 06 00 00    	je     96e0 <__integrate_MOD_trapz+0x6c0>
    905b:	|                                                         48 89 f0             	mov    rax,rsi
    905e:	|                                                         48 f7 d8             	neg    rax
    9061:	|                                                         48 89 44 24 28       	mov    QWORD PTR [rsp+0x28],rax
    9066:	|  /----------------------------------------------------> 4c 8b 7f 38          	mov    r15,QWORD PTR [rdi+0x38]
    906a:	|  |                                                      41 bc 00 00 00 00    	mov    r12d,0x0
    9070:	|  |                                                      ba 00 00 00 00       	mov    edx,0x0
    9075:	|  |                                                      4c 8b 37             	mov    r14,QWORD PTR [rdi]
    9078:	|  |                                                      41 b8 01 00 00 00    	mov    r8d,0x1
    907e:	|  |                                                      48 89 74 24 18       	mov    QWORD PTR [rsp+0x18],rsi
    9083:	|  |                                                      4c 2b 7f 30          	sub    r15,QWORD PTR [rdi+0x30]
    9087:	|  |                                                      48 89 4c 24 20       	mov    QWORD PTR [rsp+0x20],rcx
    908c:	|  |                                                      49 ff c7             	inc    r15
    908f:	|  |                                                      4d 0f 49 e7          	cmovns r12,r15
    9093:	|  |                                                      48 85 c9             	test   rcx,rcx
    9096:	|  |                                                      41 8d 5c 24 ff       	lea    ebx,[r12-0x1]
    909b:	|  |                                                      4d 63 ec             	movsxd r13,r12d
    909e:	|  |                                                      4c 63 e3             	movsxd r12,ebx
    90a1:	|  |                                                      4c 0f 44 ea          	cmove  r13,rdx
    90a5:	|  |                                                      31 ff                	xor    edi,edi
    90a7:	|  |                                                      89 5c 24 14          	mov    DWORD PTR [rsp+0x14],ebx
    90ab:	|  |                                                      4d 85 e4             	test   r12,r12
    90ae:	|  |                                                      49 0f 49 fc          	cmovns rdi,r12
    90b2:	|  |                                                      48 c1 e7 03          	shl    rdi,0x3
    90b6:	|  |                                                      49 0f 44 f8          	cmove  rdi,r8
    90ba:	|  |                                                      e8 f1 9f ff ff       	call   30b0 <mallocplt>
    90bf:	|  |                                                      4c 8b 4c 24 18       	mov    r9,QWORD PTR [rsp+0x18]
    90c4:	|  |                                                      4c 8b 54 24 28       	mov    r10,QWORD PTR [rsp+0x28]
    90c9:	|  |                                                      48 bf 00 00 00 00 01 	movabs rdi,0x30100000000
    90d0:	|  |                                                      03 00 00 
    90d3:	|  |                                                      48 89 7c 24 48       	mov    QWORD PTR [rsp+0x48],rdi
    90d8:	|  |                                                      c5 f9 6f 05 80 34 00 	vmovdqa xmm0,XMMWORD PTR [rip+0x3480]        # c560 <__func__.2+0x250>
    90df:	|  |                                                      00 
    90e0:	|  |                                                      48 89 c3             	mov    rbx,rax
    90e3:	|  |                                                      48 89 bc 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rdi
    90ea:	|  |                                                      00 
    90eb:	|  |                                                      4c 89 bc 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],r15
    90f2:	|  |                                                      00 
    90f3:	|  |                                                      4c 8d 7c 24 30       	lea    r15,[rsp+0x30]
    90f8:	|  |                                                      4c 89 74 24 70       	mov    QWORD PTR [rsp+0x70],r14
    90fd:	|  |                                                      4c 8d 74 24 70       	lea    r14,[rsp+0x70]
    9102:	|  |                                                      4c 89 ff             	mov    rdi,r15
    9105:	|  |                                                      4c 89 64 24 68       	mov    QWORD PTR [rsp+0x68],r12
    910a:	|  |                                                      4c 89 f6             	mov    rsi,r14
    910d:	|  |                                                      48 89 44 24 30       	mov    QWORD PTR [rsp+0x30],rax
    9112:	|  |                                                      48 c7 44 24 38 ff ff 	mov    QWORD PTR [rsp+0x38],0xffffffffffffffff
    9119:	|  |                                                      ff ff 
    911b:	|  |                                                      48 c7 44 24 40 08 00 	mov    QWORD PTR [rsp+0x40],0x8
    9122:	|  |                                                      00 00 
    9124:	|  |                                                      48 c7 44 24 60 01 00 	mov    QWORD PTR [rsp+0x60],0x1
    912b:	|  |                                                      00 00 
    912d:	|  |                                                      48 c7 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],0x8
    9134:	|  |                                                      00 08 00 00 00 
    9139:	|  |                                                      48 c7 84 24 90 00 00 	mov    QWORD PTR [rsp+0x90],0x8
    9140:	|  |                                                      00 08 00 00 00 
    9145:	|  |                                                      48 c7 84 24 a0 00 00 	mov    QWORD PTR [rsp+0xa0],0x1
    914c:	|  |                                                      00 01 00 00 00 
    9151:	|  |                                                      4c 89 8c 24 98 00 00 	mov    QWORD PTR [rsp+0x98],r9
    9158:	|  |                                                      00 
    9159:	|  |                                                      4c 89 54 24 78       	mov    QWORD PTR [rsp+0x78],r10
    915e:	|  |                                                      c5 f9 7f 44 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm0
    9164:	|  |                                                      e8 d7 a2 ff ff       	call   3440 <__arrayops_MOD_midpointsplt>
    9169:	|  |                                                      4c 8b 5c 24 20       	mov    r11,QWORD PTR [rsp+0x20]
    916e:	|  |                                                      4d 85 db             	test   r11,r11
    9171:	|  |  /-------------------------------------------------- 0f 84 81 05 00 00    	je     96f8 <__integrate_MOD_trapz+0x6d8>
    9177:	|  |  |                                                   c5 f9 6f 0d e1 33 00 	vmovdqa xmm1,XMMWORD PTR [rip+0x33e1]        # c560 <__func__.2+0x250>
    917e:	|  |  |                                                   00 
    917f:	|  |  |                                                   48 be 00 00 00 00 01 	movabs rsi,0x30100000000
    9186:	|  |  |                                                   03 00 00 
    9189:	|  |  |                                                   4c 89 6c 24 68       	mov    QWORD PTR [rsp+0x68],r13
    918e:	|  |  |                                                   4d 8d 6c 24 ff       	lea    r13,[r12-0x1]
    9193:	|  |  |                                                   4c 89 5c 24 30       	mov    QWORD PTR [rsp+0x30],r11
    9198:	|  |  |                                                   48 c7 44 24 38 ff ff 	mov    QWORD PTR [rsp+0x38],0xffffffffffffffff
    919f:	|  |  |                                                   ff ff 
    91a1:	|  |  |                                                   48 c7 44 24 40 08 00 	mov    QWORD PTR [rsp+0x40],0x8
    91a8:	|  |  |                                                   00 00 
    91aa:	|  |  |                                                   48 89 74 24 48       	mov    QWORD PTR [rsp+0x48],rsi
    91af:	|  |  |                                                   48 c7 44 24 60 01 00 	mov    QWORD PTR [rsp+0x60],0x1
    91b6:	|  |  |                                                   00 00 
    91b8:	|  |  |                                                   4c 89 ac 24 a8 00 00 	mov    QWORD PTR [rsp+0xa8],r13
    91bf:	|  |  |                                                   00 
    91c0:	|  |  |                                                   48 c7 84 24 80 00 00 	mov    QWORD PTR [rsp+0x80],0x8
    91c7:	|  |  |                                                   00 08 00 00 00 
    91cc:	|  |  |                                                   48 89 b4 24 88 00 00 	mov    QWORD PTR [rsp+0x88],rsi
    91d3:	|  |  |                                                   00 
    91d4:	|  |  |                                                   48 c7 84 24 a0 00 00 	mov    QWORD PTR [rsp+0xa0],0x0
    91db:	|  |  |                                                   00 00 00 00 00 
    91e0:	|  |  |                                                   c5 f9 7f 4c 24 50    	vmovdqa XMMWORD PTR [rsp+0x50],xmm1
    91e6:	|  |  |                                                   c5 f9 7f 8c 24 90 00 	vmovdqa XMMWORD PTR [rsp+0x90],xmm1
    91ed:	|  |  |                                                   00 00 
    91ef:	|  |  |                                                   4d 85 ed             	test   r13,r13
    91f2:	|  |  |                                               /-- 79 3c                	jns    9230 <__integrate_MOD_trapz+0x210>
    91f4:	|  |  |                                               |   bf 01 00 00 00       	mov    edi,0x1
    91f9:	|  |  |                                               |   e8 b2 9e ff ff       	call   30b0 <mallocplt>
    91fe:	|  |  |                                               |   48 c7 44 24 78 00 00 	mov    QWORD PTR [rsp+0x78],0x0
    9205:	|  |  |                                               |   00 00 
    9207:	|  |  |                                               |   4c 89 f7             	mov    rdi,r14
    920a:	|  |  |                                               |   4c 89 fe             	mov    rsi,r15
    920d:	|  |  |                                               |   48 89 44 24 70       	mov    QWORD PTR [rsp+0x70],rax
    9212:	|  |  |                                               |   e8 49 a1 ff ff       	call   3360 <__arrayops_MOD_diffplt>
    9217:	|  |  |                                               |   48 8b 7c 24 70       	mov    rdi,QWORD PTR [rsp+0x70]
    921c:	|  |  |                                               |   e8 2f 9f ff ff       	call   3150 <freeplt>
    9221:	|  |  |     /-----------------------------------------|-> c4 41 31 57 c9       	vxorpd xmm9,xmm9,xmm9
    9226:	|  |  |     |  /--------------------------------------|-- e9 77 04 00 00       	jmp    96a2 <__integrate_MOD_trapz+0x682>
    922b:	|  |  |     |  |                                      |   0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    9230:	|  |  |     |  |                                      \-> 4a 8d 3c e5 00 00 00 	lea    rdi,[r12*8+0x0]
    9237:	|  |  |     |  |                                          00 
    9238:	|  |  |     |  |                                          e8 73 9e ff ff       	call   30b0 <mallocplt>
    923d:	|  |  |     |  |                                          48 c7 44 24 78 00 00 	mov    QWORD PTR [rsp+0x78],0x0
    9244:	|  |  |     |  |                                          00 00 
    9246:	|  |  |     |  |                                          4c 89 f7             	mov    rdi,r14
    9249:	|  |  |     |  |                                          4c 89 fe             	mov    rsi,r15
    924c:	|  |  |     |  |                                          48 89 44 24 70       	mov    QWORD PTR [rsp+0x70],rax
    9251:	|  |  |     |  |                                          e8 0a a1 ff ff       	call   3360 <__arrayops_MOD_diffplt>
    9256:	|  |  |     |  |                                          48 8b 7c 24 70       	mov    rdi,QWORD PTR [rsp+0x70]
    925b:	|  |  |     |  |                                          49 83 fd 02          	cmp    r13,0x2
    925f:	|  |  |  /--|--|----------------------------------------- 0f 86 eb 04 00 00    	jbe    9750 <__integrate_MOD_trapz+0x730>
    9265:	|  |  |  |  |  |                                          4c 89 e2             	mov    rdx,r12
    9268:	|  |  |  |  |  |                                          31 c0                	xor    eax,eax
    926a:	|  |  |  |  |  |                                          48 c1 ea 02          	shr    rdx,0x2
    926e:	|  |  |  |  |  |                                          48 c1 e2 05          	shl    rdx,0x5
    9272:	|  |  |  |  |  |                                          4c 8d 42 e0          	lea    r8,[rdx-0x20]
    9276:	|  |  |  |  |  |                                          49 c1 e8 05          	shr    r8,0x5
    927a:	|  |  |  |  |  |                                          49 ff c0             	inc    r8
    927d:	|  |  |  |  |  |                                          41 83 e0 07          	and    r8d,0x7
    9281:	|  |  |  |  |  |                    /-------------------- 0f 84 b4 00 00 00    	je     933b <__integrate_MOD_trapz+0x31b>
    9287:	|  |  |  |  |  |                    |                     49 83 f8 01          	cmp    r8,0x1
    928b:	|  |  |  |  |  |                    |  /----------------- 0f 84 8e 00 00 00    	je     931f <__integrate_MOD_trapz+0x2ff>
    9291:	|  |  |  |  |  |                    |  |                  49 83 f8 02          	cmp    r8,0x2
    9295:	|  |  |  |  |  |                    |  |  /-------------- 74 75                	je     930c <__integrate_MOD_trapz+0x2ec>
    9297:	|  |  |  |  |  |                    |  |  |               49 83 f8 03          	cmp    r8,0x3
    929b:	|  |  |  |  |  |                    |  |  |  /----------- 74 5c                	je     92f9 <__integrate_MOD_trapz+0x2d9>
    929d:	|  |  |  |  |  |                    |  |  |  |            49 83 f8 04          	cmp    r8,0x4
    92a1:	|  |  |  |  |  |                    |  |  |  |  /-------- 74 43                	je     92e6 <__integrate_MOD_trapz+0x2c6>
    92a3:	|  |  |  |  |  |                    |  |  |  |  |         49 83 f8 05          	cmp    r8,0x5
    92a7:	|  |  |  |  |  |                    |  |  |  |  |  /----- 74 2a                	je     92d3 <__integrate_MOD_trapz+0x2b3>
    92a9:	|  |  |  |  |  |                    |  |  |  |  |  |      49 83 f8 06          	cmp    r8,0x6
    92ad:	|  |  |  |  |  |                    |  |  |  |  |  |  /-- 74 11                	je     92c0 <__integrate_MOD_trapz+0x2a0>
    92af:	|  |  |  |  |  |                    |  |  |  |  |  |  |   c5 fd 10 33          	vmovupd ymm6,YMMWORD PTR [rbx]
    92b3:	|  |  |  |  |  |                    |  |  |  |  |  |  |   b8 20 00 00 00       	mov    eax,0x20
    92b8:	|  |  |  |  |  |                    |  |  |  |  |  |  |   c5 cd 59 17          	vmulpd ymm2,ymm6,YMMWORD PTR [rdi]
    92bc:	|  |  |  |  |  |                    |  |  |  |  |  |  |   c5 fd 11 13          	vmovupd YMMWORD PTR [rbx],ymm2
    92c0:	|  |  |  |  |  |                    |  |  |  |  |  |  \-> c5 fd 10 2c 03       	vmovupd ymm5,YMMWORD PTR [rbx+rax*1]
    92c5:	|  |  |  |  |  |                    |  |  |  |  |  |      c5 d5 59 1c 07       	vmulpd ymm3,ymm5,YMMWORD PTR [rdi+rax*1]
    92ca:	|  |  |  |  |  |                    |  |  |  |  |  |      c5 fd 11 1c 03       	vmovupd YMMWORD PTR [rbx+rax*1],ymm3
    92cf:	|  |  |  |  |  |                    |  |  |  |  |  |      48 83 c0 20          	add    rax,0x20
    92d3:	|  |  |  |  |  |                    |  |  |  |  |  \----> c5 fd 10 24 03       	vmovupd ymm4,YMMWORD PTR [rbx+rax*1]
    92d8:	|  |  |  |  |  |                    |  |  |  |  |         c5 dd 59 3c 07       	vmulpd ymm7,ymm4,YMMWORD PTR [rdi+rax*1]
    92dd:	|  |  |  |  |  |                    |  |  |  |  |         c5 fd 11 3c 03       	vmovupd YMMWORD PTR [rbx+rax*1],ymm7
    92e2:	|  |  |  |  |  |                    |  |  |  |  |         48 83 c0 20          	add    rax,0x20
    92e6:	|  |  |  |  |  |                    |  |  |  |  \-------> c5 7d 10 04 03       	vmovupd ymm8,YMMWORD PTR [rbx+rax*1]
    92eb:	|  |  |  |  |  |                    |  |  |  |            c5 3d 59 0c 07       	vmulpd ymm9,ymm8,YMMWORD PTR [rdi+rax*1]
    92f0:	|  |  |  |  |  |                    |  |  |  |            c5 7d 11 0c 03       	vmovupd YMMWORD PTR [rbx+rax*1],ymm9
    92f5:	|  |  |  |  |  |                    |  |  |  |            48 83 c0 20          	add    rax,0x20
    92f9:	|  |  |  |  |  |                    |  |  |  \----------> c5 7d 10 14 03       	vmovupd ymm10,YMMWORD PTR [rbx+rax*1]
    92fe:	|  |  |  |  |  |                    |  |  |               c5 2d 59 1c 07       	vmulpd ymm11,ymm10,YMMWORD PTR [rdi+rax*1]
    9303:	|  |  |  |  |  |                    |  |  |               c5 7d 11 1c 03       	vmovupd YMMWORD PTR [rbx+rax*1],ymm11
    9308:	|  |  |  |  |  |                    |  |  |               48 83 c0 20          	add    rax,0x20
    930c:	|  |  |  |  |  |                    |  |  \-------------> c5 7d 10 24 03       	vmovupd ymm12,YMMWORD PTR [rbx+rax*1]
    9311:	|  |  |  |  |  |                    |  |                  c5 1d 59 2c 07       	vmulpd ymm13,ymm12,YMMWORD PTR [rdi+rax*1]
    9316:	|  |  |  |  |  |                    |  |                  c5 7d 11 2c 03       	vmovupd YMMWORD PTR [rbx+rax*1],ymm13
    931b:	|  |  |  |  |  |                    |  |                  48 83 c0 20          	add    rax,0x20
    931f:	|  |  |  |  |  |                    |  \----------------> c5 7d 10 34 03       	vmovupd ymm14,YMMWORD PTR [rbx+rax*1]
    9324:	|  |  |  |  |  |                    |                     c5 0d 59 3c 07       	vmulpd ymm15,ymm14,YMMWORD PTR [rdi+rax*1]
    9329:	|  |  |  |  |  |                    |                     c5 7d 11 3c 03       	vmovupd YMMWORD PTR [rbx+rax*1],ymm15
    932e:	|  |  |  |  |  |                    |                     48 83 c0 20          	add    rax,0x20
    9332:	|  |  |  |  |  |                    |                     48 39 c2             	cmp    rdx,rax
    9335:	|  |  |  |  |  |                    |                 /-- 0f 84 c0 00 00 00    	je     93fb <__integrate_MOD_trapz+0x3db>
    933b:	|  |  |  |  |  |                    >-----------------|-> c5 fd 10 04 03       	vmovupd ymm0,YMMWORD PTR [rbx+rax*1]
    9340:	|  |  |  |  |  |                    |                 |   c5 fd 10 74 03 20    	vmovupd ymm6,YMMWORD PTR [rbx+rax*1+0x20]
    9346:	|  |  |  |  |  |                    |                 |   c5 fd 10 6c 03 40    	vmovupd ymm5,YMMWORD PTR [rbx+rax*1+0x40]
    934c:	|  |  |  |  |  |                    |                 |   c5 fd 10 64 03 60    	vmovupd ymm4,YMMWORD PTR [rbx+rax*1+0x60]
    9352:	|  |  |  |  |  |                    |                 |   c5 7d 10 84 03 80 00 	vmovupd ymm8,YMMWORD PTR [rbx+rax*1+0x80]
    9359:	|  |  |  |  |  |                    |                 |   00 00 
    935b:	|  |  |  |  |  |                    |                 |   c5 7d 10 94 03 a0 00 	vmovupd ymm10,YMMWORD PTR [rbx+rax*1+0xa0]
    9362:	|  |  |  |  |  |                    |                 |   00 00 
    9364:	|  |  |  |  |  |                    |                 |   c5 7d 10 a4 03 c0 00 	vmovupd ymm12,YMMWORD PTR [rbx+rax*1+0xc0]
    936b:	|  |  |  |  |  |                    |                 |   00 00 
    936d:	|  |  |  |  |  |                    |                 |   c5 7d 10 b4 03 e0 00 	vmovupd ymm14,YMMWORD PTR [rbx+rax*1+0xe0]
    9374:	|  |  |  |  |  |                    |                 |   00 00 
    9376:	|  |  |  |  |  |                    |                 |   c5 fd 59 0c 07       	vmulpd ymm1,ymm0,YMMWORD PTR [rdi+rax*1]
    937b:	|  |  |  |  |  |                    |                 |   c5 cd 59 54 07 20    	vmulpd ymm2,ymm6,YMMWORD PTR [rdi+rax*1+0x20]
    9381:	|  |  |  |  |  |                    |                 |   c5 d5 59 5c 07 40    	vmulpd ymm3,ymm5,YMMWORD PTR [rdi+rax*1+0x40]
    9387:	|  |  |  |  |  |                    |                 |   c5 dd 59 7c 07 60    	vmulpd ymm7,ymm4,YMMWORD PTR [rdi+rax*1+0x60]
    938d:	|  |  |  |  |  |                    |                 |   c5 3d 59 8c 07 80 00 	vmulpd ymm9,ymm8,YMMWORD PTR [rdi+rax*1+0x80]
    9394:	|  |  |  |  |  |                    |                 |   00 00 
    9396:	|  |  |  |  |  |                    |                 |   c5 2d 59 9c 07 a0 00 	vmulpd ymm11,ymm10,YMMWORD PTR [rdi+rax*1+0xa0]
    939d:	|  |  |  |  |  |                    |                 |   00 00 
    939f:	|  |  |  |  |  |                    |                 |   c5 fd 11 0c 03       	vmovupd YMMWORD PTR [rbx+rax*1],ymm1
    93a4:	|  |  |  |  |  |                    |                 |   c5 1d 59 ac 07 c0 00 	vmulpd ymm13,ymm12,YMMWORD PTR [rdi+rax*1+0xc0]
    93ab:	|  |  |  |  |  |                    |                 |   00 00 
    93ad:	|  |  |  |  |  |                    |                 |   c5 fd 11 54 03 20    	vmovupd YMMWORD PTR [rbx+rax*1+0x20],ymm2
    93b3:	|  |  |  |  |  |                    |                 |   c5 0d 59 bc 07 e0 00 	vmulpd ymm15,ymm14,YMMWORD PTR [rdi+rax*1+0xe0]
    93ba:	|  |  |  |  |  |                    |                 |   00 00 
    93bc:	|  |  |  |  |  |                    |                 |   c5 fd 11 5c 03 40    	vmovupd YMMWORD PTR [rbx+rax*1+0x40],ymm3
    93c2:	|  |  |  |  |  |                    |                 |   c5 fd 11 7c 03 60    	vmovupd YMMWORD PTR [rbx+rax*1+0x60],ymm7
    93c8:	|  |  |  |  |  |                    |                 |   c5 7d 11 8c 03 80 00 	vmovupd YMMWORD PTR [rbx+rax*1+0x80],ymm9
    93cf:	|  |  |  |  |  |                    |                 |   00 00 
    93d1:	|  |  |  |  |  |                    |                 |   c5 7d 11 9c 03 a0 00 	vmovupd YMMWORD PTR [rbx+rax*1+0xa0],ymm11
    93d8:	|  |  |  |  |  |                    |                 |   00 00 
    93da:	|  |  |  |  |  |                    |                 |   c5 7d 11 ac 03 c0 00 	vmovupd YMMWORD PTR [rbx+rax*1+0xc0],ymm13
    93e1:	|  |  |  |  |  |                    |                 |   00 00 
    93e3:	|  |  |  |  |  |                    |                 |   c5 7d 11 bc 03 e0 00 	vmovupd YMMWORD PTR [rbx+rax*1+0xe0],ymm15
    93ea:	|  |  |  |  |  |                    |                 |   00 00 
    93ec:	|  |  |  |  |  |                    |                 |   48 05 00 01 00 00    	add    rax,0x100
    93f2:	|  |  |  |  |  |                    |                 |   48 39 c2             	cmp    rdx,rax
    93f5:	|  |  |  |  |  |                    \-----------------|-- 0f 85 40 ff ff ff    	jne    933b <__integrate_MOD_trapz+0x31b>
    93fb:	|  |  |  |  |  |                                      \-> 4d 89 e7             	mov    r15,r12
    93fe:	|  |  |  |  |  |                                          49 83 e7 fc          	and    r15,0xfffffffffffffffc
    9402:	|  |  |  |  |  |                                          4d 89 f9             	mov    r9,r15
    9405:	|  |  |  |  |  |                                          f6 44 24 14 03       	test   BYTE PTR [rsp+0x14],0x3
    940a:	|  |  |  |  |  |     /----------------------------------- 0f 84 20 03 00 00    	je     9730 <__integrate_MOD_trapz+0x710>
    9410:	|  |  |  |  |  |     |                                    c5 f8 77             	vzeroupper
    9413:	|  |  |  |  |  |  /--|----------------------------------> 4d 89 e2             	mov    r10,r12
    9416:	|  |  |  |  |  |  |  |                                    4d 29 fa             	sub    r10,r15
    9419:	|  |  |  |  |  |  |  |                                    49 83 fa 01          	cmp    r10,0x1
    941d:	|  |  |  |  |  |  |  |                             /----- 74 21                	je     9440 <__integrate_MOD_trapz+0x420>
    941f:	|  |  |  |  |  |  |  |                             |      c4 a1 79 10 04 ff    	vmovupd xmm0,XMMWORD PTR [rdi+r15*8]
    9425:	|  |  |  |  |  |  |  |                             |      4e 8d 34 fb          	lea    r14,[rbx+r15*8]
    9429:	|  |  |  |  |  |  |  |                             |      c4 c1 79 59 0e       	vmulpd xmm1,xmm0,XMMWORD PTR [r14]
    942e:	|  |  |  |  |  |  |  |                             |      c4 c1 79 11 0e       	vmovupd XMMWORD PTR [r14],xmm1
    9433:	|  |  |  |  |  |  |  |                             |      41 f6 c2 01          	test   r10b,0x1
    9437:	|  |  |  |  |  |  |  |                             |  /-- 74 19                	je     9452 <__integrate_MOD_trapz+0x432>
    9439:	|  |  |  |  |  |  |  |                             |  |   49 83 e2 fe          	and    r10,0xfffffffffffffffe
    943d:	|  |  |  |  |  |  |  |                             |  |   4d 01 d1             	add    r9,r10
    9440:	|  |  |  |  |  |  |  |                             \--|-> c4 a1 7b 10 34 cb    	vmovsd xmm6,QWORD PTR [rbx+r9*8]
    9446:	|  |  |  |  |  |  |  |                                |   c4 a1 4b 59 14 cf    	vmulsd xmm2,xmm6,QWORD PTR [rdi+r9*8]
    944c:	|  |  |  |  |  |  |  |                                |   c4 a1 7b 11 14 cb    	vmovsd QWORD PTR [rbx+r9*8],xmm2
    9452:	|  |  |  |  |  |  |  |                                \-> e8 f9 9c ff ff       	call   3150 <freeplt>
    9457:	|  |  |  |  |  |  |  |        /-------------------------> 49 8d 7c 24 ff       	lea    rdi,[r12-0x1]
    945c:	|  |  |  |  |  |  |  |        |                           4d 89 e7             	mov    r15,r12
    945f:	|  |  |  |  |  |  |  |        |                           48 83 ff 02          	cmp    rdi,0x2
    9463:	|  |  |  |  |  |  |  |  /-----|-------------------------- 0f 86 d7 02 00 00    	jbe    9740 <__integrate_MOD_trapz+0x720>
    9469:	|  |  |  |  |  |  |  |  |  /--|-------------------------> 4c 89 fe             	mov    rsi,r15
    946c:	|  |  |  |  |  |  |  |  |  |  |                           49 89 dd             	mov    r13,rbx
    946f:	|  |  |  |  |  |  |  |  |  |  |                           c4 41 31 57 c9       	vxorpd xmm9,xmm9,xmm9
    9474:	|  |  |  |  |  |  |  |  |  |  |                           48 c1 ee 02          	shr    rsi,0x2
    9478:	|  |  |  |  |  |  |  |  |  |  |                           48 c1 e6 05          	shl    rsi,0x5
    947c:	|  |  |  |  |  |  |  |  |  |  |                           48 8d 0c 1e          	lea    rcx,[rsi+rbx*1]
    9480:	|  |  |  |  |  |  |  |  |  |  |                           48 83 ee 20          	sub    rsi,0x20
    9484:	|  |  |  |  |  |  |  |  |  |  |                           48 c1 ee 05          	shr    rsi,0x5
    9488:	|  |  |  |  |  |  |  |  |  |  |                           48 ff c6             	inc    rsi
    948b:	|  |  |  |  |  |  |  |  |  |  |                           83 e6 07             	and    esi,0x7
    948e:	|  |  |  |  |  |  |  |  |  |  |        /----------------- 0f 84 e1 00 00 00    	je     9575 <__integrate_MOD_trapz+0x555>
    9494:	|  |  |  |  |  |  |  |  |  |  |        |                  48 83 fe 01          	cmp    rsi,0x1
    9498:	|  |  |  |  |  |  |  |  |  |  |        |  /-------------- 0f 84 b2 00 00 00    	je     9550 <__integrate_MOD_trapz+0x530>
    949e:	|  |  |  |  |  |  |  |  |  |  |        |  |               48 83 fe 02          	cmp    rsi,0x2
    94a2:	|  |  |  |  |  |  |  |  |  |  |        |  |  /----------- 0f 84 8c 00 00 00    	je     9534 <__integrate_MOD_trapz+0x514>
    94a8:	|  |  |  |  |  |  |  |  |  |  |        |  |  |            48 83 fe 03          	cmp    rsi,0x3
    94ac:	|  |  |  |  |  |  |  |  |  |  |        |  |  |  /-------- 74 6a                	je     9518 <__integrate_MOD_trapz+0x4f8>
    94ae:	|  |  |  |  |  |  |  |  |  |  |        |  |  |  |         48 83 fe 04          	cmp    rsi,0x4
    94b2:	|  |  |  |  |  |  |  |  |  |  |        |  |  |  |  /----- 74 48                	je     94fc <__integrate_MOD_trapz+0x4dc>
    94b4:	|  |  |  |  |  |  |  |  |  |  |        |  |  |  |  |      48 83 fe 05          	cmp    rsi,0x5
    94b8:	|  |  |  |  |  |  |  |  |  |  |        |  |  |  |  |  /-- 74 26                	je     94e0 <__integrate_MOD_trapz+0x4c0>
    94ba:	|  |  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |   48 83 fe 06          	cmp    rsi,0x6
    94be:	|  |  |  |  |  |  |  |  |  |  |     /--|--|--|--|--|--|-- 0f 85 4c 02 00 00    	jne    9710 <__integrate_MOD_trapz+0x6f0>
    94c4:	|  |  |  |  |  |  |  |  |  |  |  /--|--|--|--|--|--|--|-> c4 c1 33 58 7d 00    	vaddsd xmm7,xmm9,QWORD PTR [r13+0x0]
    94ca:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |   49 83 c5 20          	add    r13,0x20
    94ce:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |   c4 41 43 58 45 e8    	vaddsd xmm8,xmm7,QWORD PTR [r13-0x18]
    94d4:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |   c4 41 3b 58 4d f0    	vaddsd xmm9,xmm8,QWORD PTR [r13-0x10]
    94da:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |   c4 41 33 58 4d f8    	vaddsd xmm9,xmm9,QWORD PTR [r13-0x8]
    94e0:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  \-> c4 41 33 58 55 00    	vaddsd xmm10,xmm9,QWORD PTR [r13+0x0]
    94e6:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      49 83 c5 20          	add    r13,0x20
    94ea:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      c4 41 2b 58 5d e8    	vaddsd xmm11,xmm10,QWORD PTR [r13-0x18]
    94f0:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      c4 41 23 58 65 f0    	vaddsd xmm12,xmm11,QWORD PTR [r13-0x10]
    94f6:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      c4 41 1b 58 4d f8    	vaddsd xmm9,xmm12,QWORD PTR [r13-0x8]
    94fc:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  \----> c4 41 33 58 6d 00    	vaddsd xmm13,xmm9,QWORD PTR [r13+0x0]
    9502:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |         49 83 c5 20          	add    r13,0x20
    9506:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |         c4 41 13 58 75 e8    	vaddsd xmm14,xmm13,QWORD PTR [r13-0x18]
    950c:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |         c4 41 0b 58 7d f0    	vaddsd xmm15,xmm14,QWORD PTR [r13-0x10]
    9512:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |         c4 41 03 58 4d f8    	vaddsd xmm9,xmm15,QWORD PTR [r13-0x8]
    9518:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  \-------> c4 c1 33 58 45 00    	vaddsd xmm0,xmm9,QWORD PTR [r13+0x0]
    951e:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |            49 83 c5 20          	add    r13,0x20
    9522:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |            c4 c1 7b 58 4d e8    	vaddsd xmm1,xmm0,QWORD PTR [r13-0x18]
    9528:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |            c4 c1 73 58 75 f0    	vaddsd xmm6,xmm1,QWORD PTR [r13-0x10]
    952e:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |            c4 41 4b 58 4d f8    	vaddsd xmm9,xmm6,QWORD PTR [r13-0x8]
    9534:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  \----------> c4 c1 33 58 55 00    	vaddsd xmm2,xmm9,QWORD PTR [r13+0x0]
    953a:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |               49 83 c5 20          	add    r13,0x20
    953e:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |               c4 c1 6b 58 6d e8    	vaddsd xmm5,xmm2,QWORD PTR [r13-0x18]
    9544:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |               c4 c1 53 58 5d f0    	vaddsd xmm3,xmm5,QWORD PTR [r13-0x10]
    954a:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |               c4 41 63 58 4d f8    	vaddsd xmm9,xmm3,QWORD PTR [r13-0x8]
    9550:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  \-------------> c4 c1 33 58 65 00    	vaddsd xmm4,xmm9,QWORD PTR [r13+0x0]
    9556:	|  |  |  |  |  |  |  |  |  |  |  |  |  |                  49 83 c5 20          	add    r13,0x20
    955a:	|  |  |  |  |  |  |  |  |  |  |  |  |  |                  c4 c1 5b 58 7d e8    	vaddsd xmm7,xmm4,QWORD PTR [r13-0x18]
    9560:	|  |  |  |  |  |  |  |  |  |  |  |  |  |                  c4 41 43 58 45 f0    	vaddsd xmm8,xmm7,QWORD PTR [r13-0x10]
    9566:	|  |  |  |  |  |  |  |  |  |  |  |  |  |                  c4 41 3b 58 4d f8    	vaddsd xmm9,xmm8,QWORD PTR [r13-0x8]
    956c:	|  |  |  |  |  |  |  |  |  |  |  |  |  |                  4c 39 e9             	cmp    rcx,r13
    956f:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              /-- 0f 84 fd 00 00 00    	je     9672 <__integrate_MOD_trapz+0x652>
    9575:	|  |  |  |  |  |  |  |  |  |  |  |  |  >--------------|-> c4 41 33 58 55 00    	vaddsd xmm10,xmm9,QWORD PTR [r13+0x0]
    957b:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   49 81 c5 00 01 00 00 	add    r13,0x100
    9582:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 2b 58 9d 08 ff 	vaddsd xmm11,xmm10,QWORD PTR [r13-0xf8]
    9589:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    958b:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 23 58 a5 10 ff 	vaddsd xmm12,xmm11,QWORD PTR [r13-0xf0]
    9592:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    9594:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 1b 58 ad 18 ff 	vaddsd xmm13,xmm12,QWORD PTR [r13-0xe8]
    959b:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    959d:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 13 58 b5 20 ff 	vaddsd xmm14,xmm13,QWORD PTR [r13-0xe0]
    95a4:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95a6:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 0b 58 bd 28 ff 	vaddsd xmm15,xmm14,QWORD PTR [r13-0xd8]
    95ad:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95af:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 03 58 85 30 ff 	vaddsd xmm0,xmm15,QWORD PTR [r13-0xd0]
    95b6:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95b8:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 7b 58 8d 38 ff 	vaddsd xmm1,xmm0,QWORD PTR [r13-0xc8]
    95bf:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95c1:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 73 58 b5 40 ff 	vaddsd xmm6,xmm1,QWORD PTR [r13-0xc0]
    95c8:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95ca:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 4b 58 95 48 ff 	vaddsd xmm2,xmm6,QWORD PTR [r13-0xb8]
    95d1:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95d3:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 6b 58 ad 50 ff 	vaddsd xmm5,xmm2,QWORD PTR [r13-0xb0]
    95da:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95dc:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 53 58 9d 58 ff 	vaddsd xmm3,xmm5,QWORD PTR [r13-0xa8]
    95e3:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95e5:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 63 58 a5 60 ff 	vaddsd xmm4,xmm3,QWORD PTR [r13-0xa0]
    95ec:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95ee:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 5b 58 bd 68 ff 	vaddsd xmm7,xmm4,QWORD PTR [r13-0x98]
    95f5:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    95f7:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 43 58 85 70 ff 	vaddsd xmm8,xmm7,QWORD PTR [r13-0x90]
    95fe:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    9600:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 3b 58 8d 78 ff 	vaddsd xmm9,xmm8,QWORD PTR [r13-0x88]
    9607:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   ff ff 
    9609:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 33 58 55 80    	vaddsd xmm10,xmm9,QWORD PTR [r13-0x80]
    960f:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 2b 58 5d 88    	vaddsd xmm11,xmm10,QWORD PTR [r13-0x78]
    9615:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 23 58 65 90    	vaddsd xmm12,xmm11,QWORD PTR [r13-0x70]
    961b:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 1b 58 6d 98    	vaddsd xmm13,xmm12,QWORD PTR [r13-0x68]
    9621:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 13 58 75 a0    	vaddsd xmm14,xmm13,QWORD PTR [r13-0x60]
    9627:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 0b 58 7d a8    	vaddsd xmm15,xmm14,QWORD PTR [r13-0x58]
    962d:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 03 58 45 b0    	vaddsd xmm0,xmm15,QWORD PTR [r13-0x50]
    9633:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 7b 58 4d b8    	vaddsd xmm1,xmm0,QWORD PTR [r13-0x48]
    9639:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 73 58 75 c0    	vaddsd xmm6,xmm1,QWORD PTR [r13-0x40]
    963f:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 4b 58 55 c8    	vaddsd xmm2,xmm6,QWORD PTR [r13-0x38]
    9645:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 6b 58 6d d0    	vaddsd xmm5,xmm2,QWORD PTR [r13-0x30]
    964b:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 53 58 5d d8    	vaddsd xmm3,xmm5,QWORD PTR [r13-0x28]
    9651:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 63 58 65 e0    	vaddsd xmm4,xmm3,QWORD PTR [r13-0x20]
    9657:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 c1 5b 58 7d e8    	vaddsd xmm7,xmm4,QWORD PTR [r13-0x18]
    965d:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 43 58 45 f0    	vaddsd xmm8,xmm7,QWORD PTR [r13-0x10]
    9663:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   c4 41 3b 58 4d f8    	vaddsd xmm9,xmm8,QWORD PTR [r13-0x8]
    9669:	|  |  |  |  |  |  |  |  |  |  |  |  |  |              |   4c 39 e9             	cmp    rcx,r13
    966c:	|  |  |  |  |  |  |  |  |  |  |  |  |  \--------------|-- 0f 85 03 ff ff ff    	jne    9575 <__integrate_MOD_trapz+0x555>
    9672:	|  |  |  |  |  |  |  |  |  |  |  |  |                 \-> 4d 89 fb             	mov    r11,r15
    9675:	|  |  |  |  |  |  |  |  |  |  |  |  |                     49 83 e3 fc          	and    r11,0xfffffffffffffffc
    9679:	|  |  |  |  |  |  |  |  |  |  |  |  |                     49 ff c3             	inc    r11
    967c:	|  |  |  |  |  |  |  |  |  |  |  |  |                     41 83 e7 03          	and    r15d,0x3
    9680:	|  |  |  |  |  +--|--|--|--|--|--|--|-------------------- 74 20                	je     96a2 <__integrate_MOD_trapz+0x682>
    9682:	|  |  |  |  |  |  |  |  |  |  |  |  |              /----> 4a 8d 14 db          	lea    rdx,[rbx+r11*8]
    9686:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      c5 33 58 4a f8       	vaddsd xmm9,xmm9,QWORD PTR [rdx-0x8]
    968b:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      4d 39 dc             	cmp    r12,r11
    968e:	|  |  |  |  |  +--|--|--|--|--|--|--|--------------|----- 7e 12                	jle    96a2 <__integrate_MOD_trapz+0x682>
    9690:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      49 83 c3 02          	add    r11,0x2
    9694:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      c5 33 58 0a          	vaddsd xmm9,xmm9,QWORD PTR [rdx]
    9698:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      4d 39 dc             	cmp    r12,r11
    969b:	|  |  |  |  |  +--|--|--|--|--|--|--|--------------|----- 7c 05                	jl     96a2 <__integrate_MOD_trapz+0x682>
    969d:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      c5 33 58 4a 08       	vaddsd xmm9,xmm9,QWORD PTR [rdx+0x8]
    96a2:	|  |  |  |  |  \--|--|--|--|--|--|--|--------------|----> 48 89 df             	mov    rdi,rbx
    96a5:	|  |  |  |  |     |  |  |  |  |  |  |              |      c5 7b 11 4c 24 28    	vmovsd QWORD PTR [rsp+0x28],xmm9
    96ab:	|  |  |  |  |     |  |  |  |  |  |  |              |      e8 a0 9a ff ff       	call   3150 <freeplt>
    96b0:	|  |  |  |  |     |  |  |  |  |  |  |              |      c5 fb 10 44 24 28    	vmovsd xmm0,QWORD PTR [rsp+0x28]
    96b6:	|  |  |  |  |     |  |  |  |  |  |  |              |      48 8b 84 24 b8 00 00 	mov    rax,QWORD PTR [rsp+0xb8]
    96bd:	|  |  |  |  |     |  |  |  |  |  |  |              |      00 
    96be:	|  |  |  |  |     |  |  |  |  |  |  |              |      64 48 2b 04 25 28 00 	sub    rax,QWORD PTR fs:0x28
    96c5:	|  |  |  |  |     |  |  |  |  |  |  |              |      00 00 
    96c7:	|  |  |  |  |     |  |  |  |  |  |  |              |  /-- 0f 85 8e 00 00 00    	jne    975b <__integrate_MOD_trapz+0x73b>
    96cd:	|  |  |  |  |     |  |  |  |  |  |  |              |  |   48 8d 65 d8          	lea    rsp,[rbp-0x28]
    96d1:	|  |  |  |  |     |  |  |  |  |  |  |              |  |   5b                   	pop    rbx
    96d2:	|  |  |  |  |     |  |  |  |  |  |  |              |  |   41 5c                	pop    r12
    96d4:	|  |  |  |  |     |  |  |  |  |  |  |              |  |   41 5d                	pop    r13
    96d6:	|  |  |  |  |     |  |  |  |  |  |  |              |  |   41 5e                	pop    r14
    96d8:	|  |  |  |  |     |  |  |  |  |  |  |              |  |   41 5f                	pop    r15
    96da:	|  |  |  |  |     |  |  |  |  |  |  |              |  |   5d                   	pop    rbp
    96db:	|  |  |  |  |     |  |  |  |  |  |  |              |  |   c3                   	ret
    96dc:	|  |  |  |  |     |  |  |  |  |  |  |              |  |   0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    96e0:	\--|--|--|--|-----|--|--|--|--|--|--|--------------|--|-> 48 c7 44 24 28 ff ff 	mov    QWORD PTR [rsp+0x28],0xffffffffffffffff
    96e7:	   |  |  |  |     |  |  |  |  |  |  |              |  |   ff ff 
    96e9:	   |  |  |  |     |  |  |  |  |  |  |              |  |   be 01 00 00 00       	mov    esi,0x1
    96ee:	   \--|--|--|-----|--|--|--|--|--|--|--------------|--|-- e9 73 f9 ff ff       	jmp    9066 <__integrate_MOD_trapz+0x46>
    96f3:	      |  |  |     |  |  |  |  |  |  |              |  |   0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]
    96f8:	      \--|--|-----|--|--|--|--|--|--|--------------|--|-> 8b 4c 24 14          	mov    ecx,DWORD PTR [rsp+0x14]
    96fc:	         |  |     |  |  |  |  |  |  |              |  |   85 c9                	test   ecx,ecx
    96fe:	         |  |     |  |  |  |  \--|--|--------------|--|-- 0f 8f 53 fd ff ff    	jg     9457 <__integrate_MOD_trapz+0x437>
    9704:	         |  \-----|--|--|--|-----|--|--------------|--|-- e9 18 fb ff ff       	jmp    9221 <__integrate_MOD_trapz+0x201>
    9709:	         |        |  |  |  |     |  |              |  |   0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]
    9710:	         |        |  |  |  |     |  \--------------|--|-> c5 b3 58 2b          	vaddsd xmm5,xmm9,QWORD PTR [rbx]
    9714:	         |        |  |  |  |     |                 |  |   4c 8d 6b 20          	lea    r13,[rbx+0x20]
    9718:	         |        |  |  |  |     |                 |  |   c5 d3 58 5b 08       	vaddsd xmm3,xmm5,QWORD PTR [rbx+0x8]
    971d:	         |        |  |  |  |     |                 |  |   c5 e3 58 63 10       	vaddsd xmm4,xmm3,QWORD PTR [rbx+0x10]
    9722:	         |        |  |  |  |     |                 |  |   c5 5b 58 4b 18       	vaddsd xmm9,xmm4,QWORD PTR [rbx+0x18]
    9727:	         |        |  |  |  |     \-----------------|--|-- e9 98 fd ff ff       	jmp    94c4 <__integrate_MOD_trapz+0x4a4>
    972c:	         |        |  |  |  |                       |  |   0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
    9730:	         |        |  \--|--|-----------------------|--|-> c5 f8 77             	vzeroupper
    9733:	         |        |     |  |                       |  |   e8 18 9a ff ff       	call   3150 <freeplt>
    9738:	         |        |     |  \-----------------------|--|-- e9 2c fd ff ff       	jmp    9469 <__integrate_MOD_trapz+0x449>
    973d:	         |        |     |                          |  |   0f 1f 00             	nop    DWORD PTR [rax]
    9740:	         |        |     \--------------------------|--|-> 41 bb 01 00 00 00    	mov    r11d,0x1
    9746:	         |        |                                |  |   c4 41 31 57 c9       	vxorpd xmm9,xmm9,xmm9
    974b:	         |        |                                \--|-- e9 32 ff ff ff       	jmp    9682 <__integrate_MOD_trapz+0x662>
    9750:	         \--------|-----------------------------------|-> 45 31 ff             	xor    r15d,r15d
    9753:	                  |                                   |   45 31 c9             	xor    r9d,r9d
    9756:	                  \-----------------------------------|-- e9 b8 fc ff ff       	jmp    9413 <__integrate_MOD_trapz+0x3f3>
    975b:	                                                      \-> e8 80 9b ff ff       	call   32e0 <__stack_chk_failplt>

Disassembly of section .fini:

```