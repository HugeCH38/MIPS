.data # data segment
	# no data

.text # code segment
main: # program entry
	ori $t1, $0, 1 # temp variable for comparison, $t1 = 1
	ori $t2, $0, 2 # temp variable for comparison, $t2 = 2

	ori $t8, $0, 1 # $t8 stores f(n - 2), $t8 = f(1) = 1
	ori $t9, $0, 1 # $t9 stores f(n - 1), $t9 = f(2) = 1

	# ori $v0, $0, 5 # syscall code, $v0 = 5
	# syscall # input an integer n, stores in $v0
	lw $v0, 32($0)
	
	beq $v0, $t1, nequ1 # n == 1?
	beq $v0, $t2, nequ2 # n == 2?
	j nlt2 # n > 2

nequ1: # n = 1
nequ2: # n = 2
	ori $a0, $0, 1 # result = fib(1) or fib(2) = 1, stores in $a0
	j end

nlt2: # n > 2
	ori $t3, $0, 2 # $t3 = count = 2
cal:
	add $a0, $t8, $t9 # result fib(n) = f(n - 1) + f(n - 2), stores in $a0
	ori $t8, $t9, 0 # $t8 stores f(n - 2), $t8 = $t9
	ori $t9, $a0, 0 # $t9 stores f(n - 1), $t9 = $a0
	addi $t4, $t3, 1 # $t4 = count + 1
	ori $t3, $t4, 0 # count = count + 1
	bne $t3, $v0, cal # count == n? loop until (count == n)

end:
	# ori $v0, $0, 1 # syscall code, $v0 = 1
	# syscall # output result fib(n)
	sw $a0, 32($0)
