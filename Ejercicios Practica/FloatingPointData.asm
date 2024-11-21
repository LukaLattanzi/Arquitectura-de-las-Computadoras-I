# Example program of Floating-Point Data

# -------------------------------
.data
	fnum1: .float 3.14
	fnum2: .float 0.0
	dnum1: .double 6.28
	dnum2: .double 0.0
# -------------------------------

.text
.globl main
main:
	
	# ----
	l.s $f6, fnum1
	s.s $f6, fnum2 # fnum2 = fnum1
	# ----

	# ----
	l.d $f6, dnum1
	mov.d $f8, $f6
	s.d $f8, dnum2 # dnum2 = dnum1
	# ----

end:

	# ----
	li $v0, 10
	syscall
	# ----
	