# Fibonacci Function O(n)
        .data
        .align 2
msg:    .asciiz "\nEnter a number>"
comma:  .asciiz ","
errmsg: .asciiz "\nError - must enter a positive integer\n"
zero:   .word   0

.text
main:
# read user input
INPUT:
    la   $a0, msg               # load address for message
    li   $v0, 4
    syscall                     # print message
    
    li   $v0, 5
    syscall                     # read input
                                # validate data
    addi $t0, $v0, 0            # t0 : N
    bgtz $t0, SETUP             # if (N > 0) go to next step, else input again
    
                                # invalid input
    la   $a0, errormsg          # load error message
    li   $v0, 4
    syscall                     # print error message
    
    j    INPUT                  # get user input again
    
SETUP:
    li   $a0, 0                 # a0 : i
    sll  $a0, $v0, 2
    li   $v0, 9
    syscall                     # v0 : address of array space
    move $a1, $v0               # a1 : address of array space

LOOP:
                                # a0 : i
                                # t0 : counter for the loop
    beq  $a0, $t0, end
    
    # call fibonacci
    jal FIB
    # print fibonacci return
    
    
    
    
    
    addi $a0, $a0, 1
    j    LOOP                   # loop
    
    
# Fibonacci method of complexity O(n)
#
# @p : a0 : n
# @p : a1 : integer array memo
FIB:





end:
    li   $a0, 10
    syscall