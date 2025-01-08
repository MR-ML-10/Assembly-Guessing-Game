# ------------------------------------------------------------------------
# Author: Doom Al Rajhi
# Date: Dec 4, 2023
# Description: 	This assembly program implements a simple number guessing game. 
#              	The user is prompted to enter a 9-digit number to generate a random number.
#              	They then attempt to guess the generated number with feedback on each guess.
#              	After a successful guess, the program displays the number of tries and plays a sound effect.
#
# Additional Information:
# - This program uses an LCG (Linear Congruential Generator) to generate random numbers.
# - It includes functions to play MIDI notes for sound effects.
#
# Usage:
# - Run the program, and follow the on-screen prompts to play the guessing game.
#
# ------------------------------------------------------------------------

.text

main:
	jal guessing_game  			# Call the guessing_game function to start the game.

	# Exit program
	li $v0, 10         					# Load system call code for program exit into $v0
	syscall            					# Invoke the system call to exit the program

# guessing_game:
# This function implements a simple number guessing game where the user tries to guess a random number.
# It provides feedback to the user after each guess.
#
# The game logic:
# - Generates a random number using the generate_random_number function.
# - Repeatedly prompts the user to enter a guess until they guess the correct number.
# - Provides feedback (high or low) on each guess.
# - Keeps track of the number of tries.
# - Plays sad or happy sound effects using play_am_chord and play_c_chord functions.
#
# Usage:
#   Call this function to start the number guessing game.
#   Upon completion, it displays the number of tries made and plays a sound effect.
#
# Registers used:
#   $s0: User input (current guess)
#   $s1: Randomly generated number to guess
#   $t0: Temporary register for comparisons (current guess)
#   $t1: Tries counter
#   $t2: Temporary register for comparisons
#
# Exit:
#   Exits the program after displaying the results.
guessing_game:

	addiu $sp, $sp, -24
	sw $fp, 0($sp)
	sw $ra, 4($sp)
	addiu $fp, $sp, 20

# printing difficulty msg
	li $v0, 4
	la $a0, difficulty_msg
	syscall

# Get user input for difficulty level
	li $v0, 5
	syscall
	move $s2, $v0   				# Store difficulty level in $t3

# printing line msg
	li $v0, 4
	la $a0, lines
	syscall

# printing welcome msg
	li $v0, 4
	la $a0, welcomeMsg
	syscall

# getting user input
	li $v0, 5
	syscall
	move $s0, $v0	   				#storing the input into $s0

# printing line msg
	li $v0, 4
	la $a0, lines
	syscall

# starting the game

	move $a0, $s0	   				#making sure to pass the correct arg
	move $a1, $s2    # Difficulty level (0, 1, or 2)
	jal generate_random_number	   	# generating a random number
	move $s1, $v0	   				#storing the random number into $s1 to compare it later
	
	li $t0, 0		   				# initializing a guess variable
	li $t1, 0		   				# initializing tries variable
	
# while (guess != randomNumber) {
while_loop:
	
	# Check if the input is a 9-digit number
	beqz $s0, invalid_input 			# Check if input is zero
	bgt $s0, 999999999, invalid_input 	# Check if input is greater than 999999999
	blt $s0, 100000000, invalid_input 	# Check if input is less than 100000000
	
	beq $t0, $s1, exit				# if(guess==randomNumber)	
		
	# Select the correct prompt based on the chosen difficulty level (stored in $s2)
	bne $s2, 0, check_is_medium     	# If difficulty level is not 0 (easy), check medium
	j print_easy_prompt             		# Otherwise, print the prompt for easy level
	
check_is_medium:
	bne $s2, 1, check_is_hard       	# If difficulty level is not 1 (medium), check hard
	j print_medium_prompt           	# Otherwise, print the prompt for medium level
	
check_is_hard:
	j print_hard_prompt              		# If not easy or medium (i.e., hard level), print the prompt for hard level
	
print_easy_prompt:
	li $v0, 4                         			# Load system call code for printing a string into $v0
	la $a0, easy_enter_number          	# Load the address of the prompt message for easy level into $a0
	syscall
	j continue                        			# Jump to the "continue" label to proceed with user input
	
print_medium_prompt:
	li $v0, 4                         			# Load system call code for printing a string into $v0
	la $a0, medium_enter_number       # Load the address of the prompt message for medium level into $a0
	syscall
	j continue                        			# Jump to the "continue" label to proceed with user input
	
print_hard_prompt:
	li $v0, 4                         			# Load system call code for printing a string into $v0
	la $a0, hard_enter_number          	# Load the address of the prompt message for hard level into $a0
	syscall
	
	
continue:
	    # Get user input for guess
	    li $v0, 5
	    syscall
	    move $t0, $v0    				# Storing the input into $t0
	
	#tries++
	addi $t1, $t1, 1
	
	slt $t2, $s1, $t0    				# if (randomNumber < guess) 
	beq $t2, $zero, elif
	
	# printing enter_number msg
	li $v0, 4
	la $a0, high
	syscall
	
	jal play_em_chord   			# calling Sad sound effect
	
elif:
	slt $t2, $t0, $s1    				# if (randomNumber > guess) 
	beq $t2, $zero, else
	
	# printing enter_number msg
	li $v0, 4
	la $a0, low
	syscall
	
	jal play_am_chord 				# calling Sad sound effect
	
else:
	j while_loop
	
exit:
	# printing "You guessed the number" msg
	li $v0, 4
	la $a0, guessed_number
	syscall
	
	li  $v0, 1
	add $a0, $s1, $zero
	syscall

	# printing the random number
	li $v0, 4
	la $a0, in_msg
	syscall
	
	# printing the tries number
	li  $v0, 1
	add $a0, $t1, $zero
	syscall
    
	# printing "tries" msg
	li $v0, 4
	la $a0, tries_msg
	syscall
	
	jal play_c_chord    				# calling Happy sound effect
	
	lw $ra, 4($sp)
	lw $fp, 0($sp)
	addiu $sp, $sp, 24
	jr $ra

# Function: invalid_input
# This function handles invalid user input by printing an error message, asking for input again, and restarting the game loop.
#
# Parameters: None
# Returns: None
#
# It performs the following steps:
# 1. Print an error message using system call 4.
# 2. Ask for input again by displaying the "nine_digits" prompt.
# 3. Get user input as an integer using system call 5 and store it in $s0.
# 4. Restart the game loop by jumping to the "while_loop" label.
invalid_input:
	# Print an error message
	li $v0, 4
	la $a0, invalid_input_msg
	syscall
	    
	#Ask for input again
	li $v0, 4
	la $a0, nine_digits
	syscall
	    
	#Get user input again
	li $v0, 5
	syscall
	move $s0, $v0
	
	#Restart the game
	j while_loop
	    
	    
# Function: generate_random_number
# Generates a pseudo-random number in the range of 0 to 100 using a Linear Congruential Generator (LCG).
# Parameters:
# $a0: seed value (input)
# Returns:
# $v0: pseudo-random number in the range of 0 to 100
#
# This function implements an LCG with the following parameters:
# - Multiplier (a): 1103515245
# - Increment (c): 12345
# - Modulus (m): 2^32 (0xFFFFFFFF)
# It takes the input seed value, performs LCG calculations, and scales the result to the 0-100 range.
#
# Usage example:
#   - Set $a0 to the seed value.
#   - Call this function.
#   - Retrieve the pseudo-random number from $v0.
generate_random_number:
	addiu $sp, $sp, -24
	sw $fp, 0($sp)
	sw $ra, 4($sp)
	addiu $fp, $sp, 20

	# LCG parameters
	li $t1, 1103515245     			# Multiplier a
	li $t2, 12345          				# Increment c
	li $t3, 0xFFFFFFFF   			# Modulus m (2^32)

	add $t0, $zero, $a0   			# Load current arg into $t0

	#Xn+1 = (a * Xn + c) % m
	mul $t0, $t0, $t1   				# a * Xn
	add $t0, $t0, $t2   				# a * Xn + c
	and $t0, $t0, $t3   				# (a * Xn + c) % m

	# Take absolute value if negative
	bltz $t0, make_positive
	j continue_modulus
    
make_positive:
	neg $t0, $t0        				# negate if negative

continue_modulus:
    	# Adjust the number range based on difficulty level
	bne $a1, 0, check_medium
	li $t4, 51            				# Easy: Range 0-50
	j adjust_range
check_medium:
	bne $a1, 1, check_hard
	li $t4, 101           				# Medium: Range 0-100
	j adjust_range
check_hard:
	li $t4, 201          				# Hard: Range 0-200

adjust_range:
    	# Scale the number to the specified range
	div $t0, $t4
	mfhi $v0             				# Move the remainder (modulo result) to $v0

	lw $ra, 4($sp)
	lw $fp, 0($sp)
	addiu $sp, $sp, 24
	jr $ra


# Function: play_am_chord:
# Plays a sad sound using the MIDI out system call
# Parameters for MIDI out:
# $a0: pitch (0-127)
# $a1: duration in milliseconds
# $a2: instrument (0-127)
# $a3: volume (0-127)
# Function: play_am_chord
# Simulates playing an A minor chord by rapidly playing A, C, and E notes
play_am_chord:
	# Note 1: A
	li $a0, 69        					# Set pitch for note 1 (A)
	li $a1, 2000     			 		# Set short duration (200 milliseconds)
	li $a2, 0          					# Set instrument (0 for Acoustic Grand Piano)
	li $a3, 70        					# Set volume (70 for moderate volume)
	li $v0, 31         					# Syscall number for MIDI out
	syscall

   	# Note 2: C
	li $a0, 72         					# Set pitch for note 2 (C)
	li $a1, 2000        				# Set short duration
  	# Other parameters (instrument and volume) are the same
	syscall

    	# Note 3: E
	li $a0, 76    				 	# Set pitch for note 3 (E)
	li $a1, 2000        				# Set short duration
	# Other parameters remain the same
	syscall

	jr $ra             					# Return to the calling function


# Function: play_c_chord
# Simulates playing a C major chord by rapidly playing C, E, and G notes
# Plays a happy sound using the MIDI out system call
# Parameters for MIDI out:
# $a0: pitch (0-127)
# $a1: duration in milliseconds
# $a2: instrument (0-127)
# $a3: volume (0-127)
# Function: play_am_chord
play_c_chord:
    	# Note 1: C
	li $a0, 60         					# Set pitch for C (Middle C)
	li $a1, 2000        				# Set short duration (200 milliseconds)
	li $a2, 0          					# Set instrument (0 for Acoustic Grand Piano)
	li $a3, 70         					# Set volume (70 for moderate volume)
	li $v0, 31         					# Syscall number for MIDI out
	syscall

    	# Note 2: E
	li $a0, 64        					# Set pitch for E
	li $a1, 2000        				# Set short duration (200 milliseconds)
    	# Duration, instrument, and volume remain the same
	syscall

    	# Note 3: G
	li $a0, 67         					# Set pitch for G
    	li $a1, 2000        				# Set short duration (200 milliseconds)
    	# Duration, instrument, and volume remain the same
    	syscall
    
    	jr $ra             					# Return to the calling function

# Function: play_em_chord:
# Plays a sad sound using the MIDI out system call
# Parameters for MIDI out:
# $a0: pitch (0-127)
# $a1: duration in milliseconds
# $a2: instrument (0-127)
# $a3: volume (0-127)
# Function: play_em_chord
# Simulates playing an E major chord by rapidly playing E, G#, and B notes
play_em_chord:
    	# Note 1: E
    	li $a0, 76        					# Set pitch for note 1 (E)
    	li $a1, 2000     			 		# Set short duration (200 milliseconds)
    	li $a2, 0          					# Set instrument (0 for Acoustic Grand Piano)
    	li $a3, 70        					# Set volume (70 for moderate volume)
    	li $v0, 31         					# Syscall number for MIDI out
    	syscall

    	# Note 2: G#
    	li $a0, 80         					# Set pitch for note 2 (G#)
    	li $a1, 2000        				# Set short duration
    	# Other parameters (instrument and volume) are the same
    	syscall

    	# Note 3: B
    	li $a0, 83    				 	# Set pitch for note 3 (B)
    	li $a1, 2000        				# Set short duration
    	# Other parameters remain the same
    	syscall

    	jr $ra             					# Return to the calling function
    
.data
lines:				.asciiz 	"\n------------------------------------------------------------------------\n"
difficulty_msg: 		.asciiz 	"Choose difficulty level (0: Easy, 1: Medium, 2: Hard): "
invalid_input_msg: 		.asciiz 	"Invalid input! Please enter a 9-digit number.\n"
welcomeMsg: 			.asciiz	"Welcome To The Guessing Game!\n\nBefore we start, please enter a 9-digit number to generate a random number: "
nine_digits:			.asciiz	"please enter a 9-digit number to generate a random number: "
high: 				.asciiz 	"\nToo High! try again\n"
low: 					.asciiz 	"\nToo Low! try again\n"
easy_enter_number:   	.asciiz "Enter a number from 0 - 50: "
medium_enter_number: .asciiz "Enter a number from 0 - 100: "
hard_enter_number:   	.asciiz "Enter a number from 0 - 200: "
guessed_number:		.asciiz 	"\nYou got it!\nYou guessed the number "
in_msg:				.asciiz 	" in "
tries_msg:			.asciiz 	" tries!"