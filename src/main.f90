program main
	use types, only: dp
	use integrate, only: trapz
	use arrayops, only: diff, ones, zeros, midpoints, arange, linspace, full
	implicit none
	integer, parameter :: n = 1000
	real(dp) :: x(n), y1(n), y2(n), y3(n)

	x = linspace(0.0_dp, 10.0_dp, size(y1))
	y1(:) = x**2
	y2(:) = sin(x)
	y3(:) = exp(-x)
	
	print *, 'y = x**2'
	print '(a8,e15.6)', 'trapz', trapz(y1, x)
	print '(a8,e15.6)', 'analytic', 1.0_dp/3.0_dp*(maxval(x)-minval(x))**3

	print *, 'y = sin(x)'
	print '(a8,e15.6)', 'trapz', trapz(y2, x)
	print '(a8,e15.6)', 'analytic', cos(minval(x))-cos(maxval(x))
	
	print *, 'y = exp(-x)'
	print '(a8,e15.6)', 'trapz', trapz(y3, x)
	print '(a8,e15.6)', 'analytic', exp(-minval(x))-exp(-maxval(x))
end program main