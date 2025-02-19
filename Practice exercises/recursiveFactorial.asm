# Example program to demostrate recursion.
# -----------------------------------------------------
# Data Declarations

.data
	
prompt: .ascii "Factorial Example Program\n\n"
		.asciiz "Enter N Value: "
results: .asciiz "\nFactorial of N = "
n: .word 0
answer: .word 0

# -----------------------------------------------------
# Text/code section

.text
.globl main

main:
	
	# ----
	
	li $v0, 4 # Print string 
	la $a0, prompt
    syscall

    li $v0, 5 # Read integer
    syscall
    sw $v0, n

    # ----

    # ----

    lw $a0, n
    jal fact # Call the function
    sw $v0, answer

    # ----

    # ----

    li $v0, 4 # Print string
    la $a0, results
    syscall

    li $v0, 1 # Print integer
    lw $a0, answer
    syscall

    # ----

end:

    # ----

    li $v0, 10 # Exit
    syscall

    # ----

fact:

    # ----

    subu $sp, $sp, 8
    sw $ra, 0($sp) # Save return address
    sw $s0, 4($sp) # Save s0

    li $v0, 1 # check if n = 0
    beq $a0, 0, fact_end

    move $s0, $a0 # Save n
    sub $a0, $a0, 1 # Decrement n
    jal fact # Call the function

    mul $v0, $v0, $s0 # Multiply the result with n

    # ----

fact_end:

    # ----

    lw $ra, 0($sp) # Restore return address
    lw $s0, 4($sp) # Restore s0
    addu $sp, $sp, 8
    jr $ra

    # ----
