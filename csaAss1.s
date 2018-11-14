        .data
	    .align 2
k:      .word   4                   # include a null character to terminate string
s:      .asciiz "bac"
n:      .word   6
L:      .asciiz "cba"
        .asciiz "bca"
        .asciiz "cba"
        .asciiz "cde"
        .asciiz "dde"
        .asciiz "dec"
	
    .text
### ### ### ### ### ###
### MainCode Module ###
### ### ### ### ### ###
main:
    li    $t9,4                     # t9: constant 4
    
    lw    $s0,k                     # s0: length of the key word
    la    $s1,s                     # s1: key word
    lw    $s2,n                     # s2: size of string list
    
# allocate heap space for string array:    
    li    $v0,9                     # syscall code 9: allocate heap space
    mul   $a0,$s2,$t9               # calculate the amount of heap space
    syscall
    move  $s3,$v0                   # s3: base address of a string array
# record addresses of declared strings into a string array:  
    move  $t0,$s2                   # t0: counter i = n
    move  $t1,$s3                   # t1: base address of a string array (j) 
    la    $t2,L                     # t2: address of declared list L
READ_DATA:
    # add strings to array
    blez  $t0, FIND                 # if i > 0, read string from L
    sw    $t2,($t1)                 # put the address of a string into string array.
    
    addi  $t0, $t0, -1              # decrement counter
    addi  $t1, $t1, 4               # increment the array to the next element
    add   $t2, $t2, $s0             # increment to the next string in the list L
    j     READ_DATA

FIND:
    move  $t0, $s2                  # t0: counter = n
    move  $t1, $s3                  # t1: base address of a string array
    lw    $t2, L
    #store machine state
    addi  $sp, $sp, -4
    sw    $t1, 0($sp)               # store the base address of the list so that we can collect the list of sorted items after
    # Go on to loop through the array, sorting each element
    
    move  $t5, $t1
    
Loop:
    blez  $t0, count_equal          # if (counter <= 0) the list items are all sorted, so count the number of equal strings
    
    # Print the un-sorted string
    #lw    $a0, ($t1)
    #li    $v0, 4
    #syscall
    ############################
    
    # TO CALL MERGE SORT YOU MUST GIVE THE PARAMS
    # Load the string in the array at the position count
    lw    $a0, ($t1)                # a0: ith string from the list
    lw    $s0, k
    add   $a1, $a0, $s0             # a1: a0 + k (length of word) # S0 USED IN THE MERGESORT, SO WE MUST REASSIGN THIS
    addi  $a1, $a1, -1              # a1: a1 - 1 (because of the null character)
    
    # store machine state
	addi  $sp, $sp, -8		        # adjust the stack pointer so we can store the values on the stack
	sw	  $t0, 0($sp)		        # store the counter on the stack
	sw    $t1, 4($sp)               # store the current base address of the string array on the stack
    #####################
    
    jal   merge_sort                # sort string
    
    # preserve machine state
	lw	  $t0, 0($sp)		        # load the counter from the stack
	lw    $t1, 4($sp)               # load the base address of the string array from the stack
	addi  $sp, $sp, 8		        # adjust the stack pointer back
    ########################
    
    # PRINT SORTED
    #move  $a0, $v0
    #li    $v0, 4
    #syscall
    ##############

    addi  $t0, $t0, -1              # t0: t0 - 1 (decrement the counter)
    addi  $t1, $t1, 4               # t1: t1 + 4 (increment the array to the next element)
    j     Loop
    

count_equal:
    lw    $s0, k
    la    $a0, s                    # a0: word to check against
    add   $a1, $a0, $s0             # a1: a0 + k (size of string)
    addi  $a1, $a1, -1              # a1: a1 - 1 (because of the null character
    
    jal merge_sort
    
    move  $t5, $v0                  # a1: sorted word to check against

    lw    $t0, n                    # t0: counter to check how many strings there are left to compare
    li    $t1, 0                    # t1: counter to track how many strings are equal
    lw    $a2, k                    # a2: length of word we are comparing
    addi  $a2, $a2, -1              # a2: a2 - 1 (remove null character)
    #preserve machine state
    lw    $t2, 0($sp)               # t2: base address of the list of sorted strings
    addi  $sp, $sp, 4               # adjust the stack pointer

count_equal_loop:
    move  $a1, $t5                  # reset the key word (gets changed during the compare_strings method)
    blez  $t0, count_equal_end      # while (t0 > 0)
    lw    $a0, 0($t2)
    
    jal   compare_strings           # compare the strings in a0 and a1
    
    add   $t1, $t1, $v0             # update the counter with the result of the string comparison
    addi  $t2, $t2, 4               # move to the next word
    addi  $t0, $t0, -1              # decrease the word count by 1
    j     count_equal_loop

count_equal_end:
    move  $a0, $t1
    li    $v0, 1
    syscall
    
    li    $v0, 10
    syscall

# Compare two strings, returning 1 if equal, 0 if not
#
# @p a0: first string
# @p a1: second string
# @p a2: length of string (minus the newline space)
# @p a3: c - our counter to track how many characters we have compared
compare_strings:
    
    lbu   $t6, 0($a0)
    lb    $t7, 0($a1)
    
    bne   $t6, $t7, compare_strings_end

    addi  $a0, $a0, 1               # increment to next character
    addi  $a1, $a1, 1               # increment to next character
    addi  $a3, $a3, 1
    sub   $t9, $a2, $a3             # t9: k - c (counter)
    bgtz  $t9, compare_strings      # loop while our counter is less to the length of the string
    
    li    $v0, 1
    jr    $ra

compare_strings_end:
    li    $v0, 0
    jr    $ra

# Recrusive mergesort
#
# @p a0: first address of the array
# @p a1: last address of the array
merge_sort:
    # store machine state
	addi $sp, $sp, -16		        # adjust the stack pointer so we can store the values on the stack
	sw	 $ra, 0($sp)		        # store the return address on the stack
	sw	 $a0, 4($sp)		        # store the array start address on the stack
	sw	 $a1, 8($sp)		        # store the array end address on the stack
	
	sub  $t0, $a1, $a0		        # t0: start address - end address (i.e. number of elements * 4)
    
    li   $t1, 1                     # t1: 1 (int)
    sub  $t1, $t0, $t1              # t1: num elements - 1
    blez $t1, mergesort_end         # if num elements - 1 <= 0 (num elements <= 1)
	
	li   $t9, 2                     # t9: 2 (int)
	div	 $t0, $t0, $t9		        # t0: array size / 2
	add	 $a1, $a0, $t0		        # a1: leftP + (size / 2) = midP
	sw	 $a1, 12($sp)		        # store midP address on the stack
	
	jal	 merge_sort		            # call recursively on the first part of the array
	
	lw	 $a0, 12($sp)		        # a0: load midP address
	lw	 $a1, 8($sp)		        # a1: load rightP address
	
	jal	 merge_sort		            # call recursively on the second part of the array
	
	lw	 $a0, 4($sp)		        # a0: left pointer
	lw	 $a1, 12($sp)		        # a1: mid pointer
	lw	 $a2, 8($sp)		        # a2: right pointer (end address)
	
	# store the machine state
	addi $sp, $sp, -4               
	sw   $a0, 0($sp)                # store a0 on the stack so that we can collect it afterwards to return the output
	
	jal	 merge			            # merge the two array halves
	
	# preserve the machine state
	lw   $v0, 0($sp)                # move the sorted value to be returned
	addi $sp, $sp, 4
	
mergesort_end:				

	lw	 $ra, 0($sp)		        # load the return address from the stack
	addi $sp, $sp, 16		        # adjust the stack pointer
	jr	 $ra			            # return 
	
# merge two sorted arrays
#
# @p a0: first address of first array
# @p a1: first address of second array
# @p a2: last address of second array
merge:
    # preserve machine state
	addi $sp, $sp, -16		        # Adjust the stack pointer
	sw	 $ra, 0($sp)		        # store return address
	sw	 $a0, 4($sp)		        # store start address
	sw	 $a1, 8($sp)		        # store midpoint address
	sw	 $a2, 12($sp)		        # store end address
	
	move $s0, $a0		            # copy of the first half address
	move $s1, $a1		            # copy of the second half address
	
merge_loop:

	lbu	 $t0, 0($s0)		        # load first half pointer
	lbu	 $t1, 0($s1)		        # load second half pointer
	
	sub  $t9, $t0, $t1              # t9: a[0] - b[0]
	blez $t9, dont_move             # if (a[0] - b[0] <= 0) (a[0] <= b[0])
	
	move $a0, $s1		            # Load the argument for the element to move
	move $a1, $s0		            # Load the argument for the address to move it to
	jal	 change_index			    # move the element to the new position 
	
	addi $s1, $s1, 1		        # s1: second half pointer++
dont_move:
	addi $s0, $s0, 1		        # s0: first half pointer++
	
	lw	 $a2, 12($sp)		        # a2: load the end address
	
	sub  $t9, $s0, $a2
	bgez $t9, mergeloop_end         # end when both halves are empty (s0 >= a2)
	
	sub  $t9, $s1, $a2
	bgez $t9, mergeloop_end         # end when both halves are empty (s1 >= a2)
	
	b    merge_loop
	
mergeloop_end:
	
	lw   $ra, 0($sp)		        # Load return address
	addi $sp, $sp, 16		        # Adjust the stack pointer
	jr   $ra			            # Return

# move an element in the array to an index lower than current
#
# @p a0: value to shift (address of)
# @p a1: address to move to
change_index:
	li   $t0, 10
	ble	 $a0, $a1, changeindex_end	# If we are at the location, stop shifting
	addi $t6, $a0, -1		        # Find the previous address in the array
	lbu	 $t7, 0($a0)		        # Get the current pointer
	lbu	 $t8, 0($t6)		        # Get the previous pointer
	sb   $t7, 0($t6)		        # Save the current pointer to the previous address
	sb   $t8, 0($a0)		        # Save the previous pointer to the current address
	move $a0, $t6	                # Shift the current position back
	b    change_index		        # Loop again
	
changeindex_end:
	jr	 $ra			            # Return
