.data
	.align 2
k:      .word    4          # include a null character to terminate string
s:      .asciiz "bac"
n:      .word   1
L:      .asciiz "abc"
        #.asciiz "bbc"
        #.asciiz "cba"
        #.asciiz "cde"
        #.asciiz "dde"
        #.asciiz "dec"
	
    .text
### ### ### ### ### ###
### MainCode Module ###
### ### ### ### ### ###
main:
    li $t9,4                # $t9 = constant 4
    
    lw $s0,k                # $s0: length of the key word
    la $s1,s                # $s1: key word
    lw $s2,n                # $s2: size of string list
    
# allocate heap space for string array:    
    li $v0,9                # syscall code 9: allocate heap space
    mul $a0,$s2,$t9         # calculate the amount of heap space
    syscall
    move $s3,$v0            # $s3: base address of a string array
# record addresses of declared strings into a string array:  
    move $t0,$s2            # $t0: counter i = n
    move $t1,$s3            # $t1: base address of a string array (j) 
    la $t2,L                # $t2: address of declared list L
READ_DATA:
    # add strings to array
    blez $t0, FIND          # if i > 0, read string from L
    sw $t2,($t1)            # put the address of a string into string array.
    
    addi $t0, $t0, -1       # decrement counter
    addi $t1, $t1, 4        # increment the array to the next element
    add $t2, $t2, $s0       # increment to the next string in the list L
    j READ_DATA
 
FIND: 
### write your code ###

    #BEFORE
    # la $a0, L
    # la $a1, 4($a0) #a1 = a0 + 3, but a0 is not changed
    
    #AFTER
	la	$a0, L		        # Load the start address of the array
	add $a1, $a0, $s0       # a1 = a0 + n
	addi $a1, $a1, -1       # a1 = a1 - 1 (because of the null character)
	la $a1, ($a1)           # obtain the last address of the array
	
	jal	mergesort		    # Call the merge sort function
  	b	sortend			    # We are finished sorting
	
##
# Recrusive mergesort function
#
# @param $a0 first address of the array
# @param $a1 last address of the array
##

#mergesort needs to be in a loop
mergesort:
    # preserve the program state
	addi $sp, $sp, -16		    # Adjust stack pointer
	sw	$ra, 0($sp)		        # Store the return address on the stack
	sw	$a0, 4($sp)		        # Store the array start address on the stack
	sw	$a1, 8($sp)		        # Store the array end address on the stack
	
	sub $t0, $a1, $a0		    # t0 : difference between the start and end address (i.e. number of elements * 4)
    
    li $t1, 1                   # t1 : 1 (int)
	ble	$t0, $t1, mergesortend	# If (num elements in list <= 1) end
	
	srl	$t0, $t0, 1		        # Divide the array size by 2 to half the number of elements (shift right 3 bits)
	add	$a1, $a0, $t0		    # Calculate the midpoint address of the array
	sw	$a1, 12($sp)		    # Store the array midpoint address on the stack
	
	jal	mergesort		        # Call recursively on the first half of the array
	
	lw	$a0, 12($sp)		    # Load the midpoint address of the array from the stack
	lw	$a1, 8($sp)		        # Load the end address of the array from the stack
	
	jal	mergesort		        # Call recursively on the second half of the array
	
	lw	$a0, 4($sp)		        # Load the array start address from the stack
	lw	$a1, 12($sp)		    # Load the array midpoint address from the stack
	lw	$a2, 8($sp)		        # Load the array end address from the stack
	
	jal	merge			        # Merge the two array halves
	
mergesortend:				

	lw	$ra, 0($sp)		        # Load the return address from the stack
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr	$ra			            # Return 
	
##
# Merge two sorted, adjacent arrays into one, in-place
#
# @param $a0 First address of first array
# @param $a1 First address of second array
# @param $a2 Last address of second array
##
merge:
	addi    $sp, $sp, -16		# Adjust the stack pointer
	sw	$ra, 0($sp)		        # Store the return address on the stack
	sw	$a0, 4($sp)		        # Store the start address on the stack
	sw	$a1, 8($sp)		        # Store the midpoint address on the stack
	sw	$a2, 12($sp)		    # Store the end address on the stack
	
	move	$s0, $a0		    # Create a working copy of the first half address
	move	$s1, $a1		    # Create a working copy of the second half address
	
mergeloop:

	lbu	$t0, 0($s0)		        # Load the first half position pointer
	lbu	$t1, 0($s1)		        # Load the second half position pointer
	
	bgt	$t1, $t0, noshift	    # If the lower value is already first, don't shift
	
	move	$a0, $s1		    # Load the argument for the element to move
	move	$a1, $s0		    # Load the argument for the address to move it to
	jal	shift			        # Shift the element to the new position 
	
	addi	$s1, $s1, 1		    # Increment the second half index
noshift:
	addi	$s0, $s0, 1		    # Increment the first half index
	
	lw	$a2, 12($sp)		    # Reload the end address
	bge	$s0, $a2, mergeloopend	# End the loop when both halves are empty
	bge	$s1, $a2, mergeloopend	# End the loop when both halves are empty
	b	mergeloop
	
mergeloopend:
	
	lw	$ra, 0($sp)		        # Load the return address
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr 	$ra			            # Return

##
# Shift an array element to another position, at a lower address
#
# @param $a0 address of element to shift
# @param $a1 destination address of element
##
shift:
	li	$t0, 10
	ble	$a0, $a1, shiftend	    # If we are at the location, stop shifting
	addi	$t6, $a0, -1		# Find the previous address in the array
	lbu	$t7, 0($a0)		        # Get the current pointer
	lbu	$t8, 0($t6)		        # Get the previous pointer
	sb	$t7, 0($t6)		        # Save the current pointer to the previous address
	sb	$t8, 0($a0)		        # Save the previous pointer to the current address
	move	$a0, $t6	        # Shift the current position back
	b 	shift			        # Loop again
shiftend:
	jr	$ra			            # Return
	
sortend:				        # Point to jump to when sorting is complete
# Print out the indirect array
	li	$t0, 0				    # Initialize the current index
	                            # We are finished
	la $a0 L
	li $v0 4
	syscall
	li	$v0,10
	syscall
