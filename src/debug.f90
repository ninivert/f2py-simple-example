program debug
	use types, only: dp
	use integrate, only: trapz
	use arrayops, only: diff, ones, zeros, midpoints, arange, linspace, full
	implicit none
	integer, parameter :: n = 1000
	real(dp) :: x(n), y1(n)
	integer :: file_unit, file_iostat

	x = linspace(0.0_dp, 10.0_dp, size(y1))
	y1(:) = sin(x) + 0.1_dp*x**2

	open(newunit=file_unit, iostat=file_iostat, file='debug.out')
	if ( file_iostat > 0 ) stop 'failed to open file'

	print *, '-- tests arrayops'
	! write(file_unit, '(a8,*(f8.3))') 'full', full(size(y1), 3.14_dp)
	write(file_unit, *) 'full', full(size(y1), 3.14_dp)
	write(file_unit, *) 'zeros', zeros(size(y1))
	write(file_unit, *) 'ones', ones(size(y1))
	write(file_unit, *) 'arange', arange(size(y1))

	print *, '-- test integrate'
	write(file_unit, *) 'y', y1
	write(file_unit, *) 'diff', diff(y1)
	write(file_unit, *) 'midpoints', midpoints(y1)

end program debug