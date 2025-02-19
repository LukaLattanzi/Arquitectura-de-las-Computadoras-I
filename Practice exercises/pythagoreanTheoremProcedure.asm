# Example program to calculate the cSide for each
# right triangle in a series of right triangles
# given the aSides and bSides using the
# Pythagorean theorem.
# Pythagorean theorem:
# cSide = sqrt ( aSide^2 + bSide^2 )
# Provides examples of MIPS procedure calling.

# -----------------------------------------------------
# Data Declarations

.data

aSides: .word 19, 17, 15, 13, 11, 19, 17, 15, 13, 11, 12, 14, 16, 18, 10
bSides: .word 34, 32, 31, 35, 34, 33, 32, 37, 38, 39, 32, 30, 36, 38, 30
cSides: .space 60 # 15 * 4 bytes

length: .word 15

min: .word 0
max: .word 0
sum: .word 0
ave: .word 0

# -----------------------------------------------------
# text/code section

.text
.globl main

main:

# ----

    la $a0, aSides # $a0 = aSides array address
    la $a1, bSides # $a1 = bSides array address
    la $a2, cSides # $a2 = cSides array address
    lw $a3, length # $a3 = length of arrays

    la $t0, min # $t0 = min address
    la $t1, max # $t1 = max address
    la $t2, sum # $t2 = sum address
    la $t3, ave # $t3 = ave address

    subu $sp, $sp, 16 # make space on stack for 4 words
    sw $t0, 0($sp) # save min address on stack
    sw $t1, 4($sp) # save max address on stack
    sw $t2, 8($sp) # save sum address on stack  
    sw $t3, 12($sp) # save ave address on stack

    jal calcCSides # call calcCSides procedure
    addu $sp, $sp, 16 # clear stack

# ----

end:

# ----

    li $v0, 10 # exit
    syscall

# ----

# -----------------------------------------------------

calcCSides:

# ---- 

    # Save register $ra
    addiu $sp, $sp, -4
    sw $ra, 0($sp)

    move $s0, $a0 # $s0 = aSides array address
    move $s1, $a1 # $s1 = bSides array address
    move $s2, $a2 # $s2 = cSides array address
    li $s3, 0 # $s3 = index
    move $s4, $a3 # $s4 = length of arrays
    move $s5, $a2 # $s5 = copy of cSides array address

# ----

calcLoop:

# ----

    lw $t0, 0($s0) # aSides[i]
    mul $t0, $t0, $t0 # aSides[i]^2
    lw $t1, 0($s1) # bSides[i]
    mul $t1, $t1, $t1 # bSides[i]^2
    add $a0, $t0, $t1 # aSides[i]^2 + bSides[i]^2

    jal sqrt # call sqrt procedure
    sw $v0, 0($s2) # cSides[i] = sqrt(aSides[i]^2 + bSides[i]^2)

    addu $s0, $s0, 4 # advance aSides pointer
    addu $s1, $s1, 4 # advance bSides pointer
    addu $s2, $s2, 4 # advance cSides pointer
    addi $s3, $s3, 1 # increment index

    blt $s3, $s4, calcLoop # loop if index < length

# ----

# ----

    move $s2, $s5 # $s2 = cSides array address (original)
    li $t0, 0 # index = 0
    lw $t1, 0($s2) # min = cSides[0]
    lw $t2, 0($s2) # max = cSides[0]
    li $t3, 0 # sum = 0

# ----

statsLoop:

# ---- 

    lw $t4, 0($s2) # cSides[i]

    bge $t4, $t1, notNewMin # if cSides[i] >= min, not new min
    move $t1, $t4 # min = cSides[i]

# ----

notNewMin:

# ----

    ble $t4, $t2, notNewMax # if cSides[i] <= max, not new max
    move $t2, $t4 # max = cSides[i]

# ----

notNewMax:

# ----

    add $t3, $t3, $t4 # sum += cSides[i]

    addu $s2, $s2, 4 # advance cSides pointer
    addi $t0, $t0, 1 # increment index

    blt $t0, $s4, statsLoop # loop if index < length

# ----

# ----

    lw $t0, 4($sp) # min address
    sw $t1, 0($t0) # min = min

    lw $t0, 8($sp) # max address
    sw $t2, 0($t0) # max = max

    lw $t0, 12($sp) # sum address
    sw $t3, 0($t0) # sum = sum

    div $t3, $s4 # sum / length
    mflo $t4 # average
    lw $t0, 16($sp) # ave address
    sw $t4, 0($t0) # ave = average

# ----

# ----

    # Restore register $ra
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# ----

sqrt:

# ----

    mtc1 $a0, $f0 # $f0 = a0
    cvt.s.w $f0, $f0 # $f0 = float($f0)
    sqrt.s $f0, $f0 # $f0 = sqrt($f0)
    cvt.w.s $f0, $f0 # $f0 = int($f0)
    mfc1 $v0, $f0 # $v0 = $f0
    jr $ra # return

# ----