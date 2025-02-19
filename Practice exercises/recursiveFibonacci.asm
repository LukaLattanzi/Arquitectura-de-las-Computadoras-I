# Recursive Fibonacci program to demonstrate recursion.
# -----------------------------------------------------
# Data Declarations

.data
	
prompt: .ascii "Fibonacci Example Program\n\n"
		.asciiz "Enter N Value: "
results: .asciiz "\nFibonacci of N = "
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

    lw $a0, n
    jal fib # Call the function
    sw $v0, answer

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

fib:

    # ----

    subu $sp, $sp, 8 # Allocate space on stack
    sw $ra, 0($sp) # Save return address
    sw $s0, 4($sp) # Save s0

    move $v0, $a0 # Copy n to v0
    ble $a0, 1, fibDone

    move $s0, $a0 # Copy n to s0
    sub $a0, $a0, 1 # n = n - 1
    jal fib # Call fib(n - 1)

    move $a0, $s0 # Copy s0 to a0
    sub $a0, $a0, 2 # n = n - 2
    move $s0, $v0 # Save fib(n - 1) to s0
    jal fib # Call fib(n - 2)

    add $v0, $s0, $v0 # fib(n) = fib(n - 1) + fib(n - 2)

    # ----

fibDone:

    # ----

    lw $ra, 0($sp) # Restore return address
    lw $s0, 4($sp) # Restore s0
    addu $sp, $sp, 8 # Deallocate space on stack
    jr $ra # Return to caller

    # ----