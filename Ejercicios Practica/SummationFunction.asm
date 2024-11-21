# Example function to demonstrate calling conventions
# Function to sum six arguments.

# -------------------------------
.data
	num1: .word 3
	num2: .word 5
	num3: .word 3
	num4: .word 5
	num5: .word 3
	num6: .word 5
	sum: .word 0
# -------------------------------

.text
.globl main
main:
	
	# ----
	# First 4 arguments are passed in $a0-$a3.
	# Next 2 arguments are passed on the stack.
	
	lw $a0, num1 # pass arg's
	lw $a1, num2
	lw $a2, num3
	lw $a3, num4
	
	lw $t0, num5
	lw $t1, num6
	subu $sp, $sp, 8
	sw $t0,($sp)
	sw $t1, 4($sp)
	
	jal addem
	sw $v0, sum
	
	addu $sp, $sp 8 # clear stack
	# ----

end:

	# ----
	li $v0, 10
	syscall
	# ----