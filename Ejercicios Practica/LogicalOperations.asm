# Example of the Logical Operations

# -------------------------------
.data
	wnum1: .word 0x000000ff
	wnum2: .word 0x0000ff00
	wans1: .word 0
	wans2: .word 0
	wans3: .word 0
# -------------------------------

.text
.globl main
main:
	
	# ----
	lw $t0, wnum1
	lw $t1, wnum2
	and $t2, $t0, $t1
	sw $t2, wans1 # wans1 = wnum1 & wnum2
	# ----
	
	# ----
	or $t2, $t0, $t1
	sw $t2, wans2 # wans2 = wnum1 | wnum2
	# ----
	
	# ----
	not $t2, $t1
	sw $t2, wans3 # wans = ¬ wnum2
	# ----

end:

	# ----
	li $v0, 10
	syscall
	# ----
	