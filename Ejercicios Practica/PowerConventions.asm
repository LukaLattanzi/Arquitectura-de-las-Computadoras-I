# Example function to demonstrate calling conventions
# Function computes power ( i,e, x to y power ).

# -------------------------------
.data
	x: .word 3
	y: .word 5
	answer: .word 0
# -------------------------------

.text
.globl main
main:
	
	# ----
	lw $a0, x # pass arg's to function
	lw $a1, y
	jal power
	sw $v0, answer
	# ----

end:

	# ----
	li $v0, 10
	syscall
	# ----

power: 
	
	# ----
	li $v0, 1
	li $t0, 0
	# ----

powLoop:

	# ----
	mul $v0, $v0, $a0
	add $t0, $t0, 1
	blt $t0, $a1, powLoop
	
	jr $ra
	# ----
