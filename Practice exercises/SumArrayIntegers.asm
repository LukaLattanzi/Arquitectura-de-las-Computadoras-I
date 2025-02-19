# Example program to sum an array of integers and compute the float average

# -------------------------------
.data
	iArray: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
	length: .word 12

	iSum: .word 0
	fAve: .float 0.0
# -------------------------------

.text
.globl main
main:
	
	# ----
	# Find the sum of the integer numbers:
	
	la $t0, iArray # array starting addr
	lw $t1, length # array length
	li $t2, 0 # set sum = 0
	# ----
	
sumLoop:

	# ----
	lw $t3, ($t0) # get iArray(n)
	add $t2, $t2, $t3 # sum = sum + iArray(n)
	addu $t0, $t0, 4 # update iArray addr
	sub $t1, $t1, 1
	bnez $t1, sumLoop
	
	sw $t2, iSum # save integer sum
	
	mtc1 $t2, $f6 # move to flt reg
	cvt.s.w $f6, $f6 # cvt to flt format
	
	lw $t1, length
	mtc1 $t1, $f8 # move to float reg
	cvt.s.w $f8, $f8 # cvt to float format
	
	div.s $f10, $f6, $f8 # sum / length
	s.s $f10, fAve
	# ----
	
end:

	# ----
	li $v0, 10
	syscall
	# ----
	
