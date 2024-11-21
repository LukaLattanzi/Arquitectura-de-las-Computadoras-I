# Example program to compute the surface area and volume of a sphere
# surfaceArea = 4.0 * pi * radius^2 || volume = [(4.0 * pi) / 3.0] * radius^3

# -------------------------------
.data
	pi: .float 3.14159
	fourPtZero: .float 4.0
	threePtZero: .float 3.0
	radius: .float 17.25
	surfaceArea: .float 0.0
	volume: .float 0.0
# -------------------------------

.text
.globl main
main:
	
	# ----
	# Compute (4.0 * pi) which is used for both equations.

	l.s $f2, fourPtZero
	l.s $f4, pi
	
	mul.s $f4, $f2, $f4 # 4.0 * pi
	l.s $f6, radius # radius
	# ----
	
	# ----
	# Calculate surface area of a sphere.
	
	mul.s $f8, $f6, $f6 # radius^2
	mul.s $f8, $f4, $f8 # 4.0 * pi * radius^2
	s.s $f8, surfaceArea # Store final answer
	
	# ----
	
	# ----
	# Calculate volume of a sphere.

	l.s $f8, threePtZero
	
	div.s $f2, $f4, $f8 # (4.0 * pi / 3.0)
	
	mul.s $f10, $f6, $f6
	mul.s $f10, $f10, $f6 # radius^3
	
	mul.s $f12, $f2, $f10 # [(4.0 * pi) / 3.0] * radius^3
	
	s.s $f12, volume # store final answer
	# ----
	
end:

	# ----
	li $v0, 10
	syscall
	# ----
	
