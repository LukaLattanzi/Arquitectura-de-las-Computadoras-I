# Example program to compute the sum of squares from 1 to n

# -------------------------------
.data
	n: .word 10
	sumOfSquares: .word 0
# -------------------------------

.text
.globl main
main:
	
	# ----
	# Compute sum of squares from 1 to n

	lw $t0, n
	li $t1, 1 # loop index (1 to n)
	li $t2, 0 # sum
	# ----

sumLoop:

	# ----
	mul $t3, $t1, $t1 # square
	add $t2, $t2, $t3
	
	add $t1, $t1, 1
	ble $t1, $t0, sumLoop
	
	sw $t2, sumOfSquares
	# ----

end:

	# ----
	li $v0, 10
	syscall
	# ----
	
