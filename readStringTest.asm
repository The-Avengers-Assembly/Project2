#main problem: I need to figure out a way to add every value from the string to an int
#I thought of two solutions, one is where I use a counter to find length and then use that length to multiply by 10 to create the tenths place
#Second solution is to do the same thing but instead of resetting the base address, subtract from the base address to work backwards because we now know the length
#Ok I ended up doing the first solution but it still needs cleaning up, might need some adapting to put into the task 1 program. Could probably be more efficient and shorter


.data
buffer: .space 10
inputMessage: .asciiz "\ninput number: "
invalid: .asciiz "\ninvalid input, please try again"
correct: .asciiz "\nnice job! thanks for correct input, you entered: "

.text
main: 
	#print enter number prompt
	li $v0, 4
	la $a0, inputMessage
	syscall
	#read string and create buffer to store string
	la $a0, buffer
	li $a1, 10
	li $v0, 8
	syscall
	#user input s0
	#load base address into s0
	la $s0, ($a0)
	#load the unsigned byte into s1
	lbu $s1, ($s0)
	#loop counter 
	li $t0, 0
	#second loop counter for adding stuff
	li $t1, 0
	#the number in int form 
	li $s2, 0
	
	j loop
		
	
loop:
	#exit clasue so basically if the ascii value is below 11 it means it is no longer an input from the user (fyi clicking enter counts as an ascii value of 10)
	blt $s1, 11, reset
	
	#ascii values of 0-9 is between 48-57 so basically branch to retry label if it is not between these values
	blt  $s1, 48, retry
	bgt  $s1, 57, retry	
	
	#add 1 to s0 to increase by 1 byte for next character
	addi $s0, $s0, 1
	#load the byte of s0 into s1
	lbu $s1, ($s0)
	#add 1 to the counter
	addi $t0, $t0, 1
	
	j loop
	
	#my solution for converting it into an int again, basically subtracting the number by 48 and then multiplying it by 10 based on its 10s place
otherLoop: 
	#this is the base for the tens place, has to be 1 every time this loop runs
	li $t3, 1
	#subtract one from the counter to begin with because the other loop has the counter at 1 higher than it should be
	sub $t0, $t0, 1
	#subtracting it by 48 to get decimal value
	sub $s1, $s1, 48
	#copying the counter number to second counter for the exponent loop
	move $t1, $t0
	#jal to exponent loop because you need to get back to this exact spot
	jal exponentLoop
	#multiply t3 from exponent loop which is the place value of number and store in temp value t4
	mul $t4, $t3, $s1
	#add int number to t4 to get the final int number
	add $s2, $s2, $t4
	
	#add 1 to s0 to increase by 1 byte for next character
	addi $s0, $s0, 1
	#load the byte of s0 into s1
	lbu $s1, ($s0)
	#exit statement if the counter becomes 0
	beq $t0, 0, continue
	
	j otherLoop
	
exponentLoop: 
	#if second counter = 0 then go back to the label
	beq $t1, 0, jumpReturn
	#multiply t3 by 10 until you get the number
	mul $t3, $t3, 10
	#subtract 1 from second counter
	sub $t1, $t1, 1
	j exponentLoop

#used to reset s0 and s1 back to the first byte for int conversion
reset:
	#load base address into s0
	la $s0, ($a0)
	#load the unsigned byte into s1
	lbu $s1, ($s0)
	j otherLoop

#kind of inefficient but just straight up a jump return statement because I didn't know how to put a jr into a branch statement
jumpReturn:
	jr $ra
#print out correct statement and then print out number as int
continue: 
	li $v0, 4
	la $a0, correct
	syscall
	li $v0, 1
	move $a0, $s2
	syscall
	j exit
#print out retry statement and loop back to main to reset buffer/counter numbers/reprint message
retry: 
	li $v0, 4
	la $a0, invalid
	syscall
	j main

exit: 
	li $v0, 10
	syscall
