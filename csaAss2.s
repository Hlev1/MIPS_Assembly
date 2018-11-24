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
    li   $a1, 0                 # a1 : i
    sll  $a0, $t0, 2            # a0 : number of bytes needed 
    li   $v0, 9
    syscall                     # v0 : address of array space
    move $a2, $v0               # a2 : address of array space

LOOP:
                                # a1 : i
    addi $a3, $a1, 0            # a3 : copy of a1
                                # t0 : counter for the loop
    beq  $a1, $t0, end
    
    # store machine state
    addi $sp, $sp, -8           # decrement the stack
    sw   $t0, ($sp)             # store t0 on the stack
    sw   $a1, ($sp)             # store a1 on the stack
    
    # call fibonacci
    jal FIB
    # print fibonacci return
    move $a0, $v0
    li   $v0, 1
    syscall
    
    # preserve machine state
    lw   $t0, ($sp)             # load t0 from the stack
    lw   $a1, ($sp)
    addi $sp, $sp, 8            # increment the stack
    
    
    addi $a1, $a1, 1            # a1: i++
    j    LOOP                   # loop
    
    
# Fibonacci method of complexity O(n)
#
# @p : a1 : n
# @p : a2 : integer array memo
# @p : a3 : copy of n
FIB:
    # store machine state
    addi $sp, $sp, -4
    sw   $ra, ($sp)             # store the return address on the stack
    
    blez $a1, FIB0              # if (n <=0) return 0
    
    li   $t1, 1                 # t1 : 1
    
    beq  $a1, $t1, FIB1         # if (n == 1) return 1
    
    sll  $t8, $a1, 2            # calculate number of bytes we need to increment array pointer by
    add  $a2, $a2, $t8          # a2 : a2 + t8 (increment array pointer to get the position of a[n])
    lw   $a0, ($a2)             # a0 : a[n]
    sub  $a2, $a2, $t8          # a2 : a2 - t8 (decrement array pointer to get the starting position)
    
    bgtz $a0, FIB_MEMO          # if (a[n] > 0) return a[n]
    
    addi $a1, $a1, -1           # a1 : a1 - 1
    jal  FIB                    # v0 : fib(n-1, memo)
    move $t2, $v0               # t2 : fib(n-1, memo)
    
    addi $a1, $a1, -1           # a1 : a1 - 1
    jal  FIB                    # v0 : fib(n-2, memo)
    move $t3, $v0               # t3 : fib(n-2, memo)
    
    add  $t2, $t2, $t3          # t2 : fib(n-1, memo) + fib(n-2, memo)
    
    sll  $t8, $a3, 2            # calculate number of bytes we need to increment array pointer by
    add  $a2, $a2, $t8          # increment array pointer to get to position of a[n]
    sw   $t2, ($a2)             # store fib(n-1, memo) + fib(n-2, memo) at a[n]
    sub  $a2, $a2, $t8          # decrement array pointer to get the starting position
    
    move $a0, $t2               # a0 : fib(n-1, memo) + fib(n-2, memo)
    j  FIB_MEMO
    
    
    
    
FIB0:
    # preserve machine state
    lw   $ra, ($sp)             # load the return address from the stack
    addi $sp, $sp, 4            # increment the stack
    
    li   $v0, 0
    jr   $ra

FIB1:
    # preserve machine state
    lw   $ra, ($sp)             # load the return address from the stack
    addi $sp, $sp, 4            # increment the stack
    
    li   $v0, 1
    jr   $ra

# @p : a0 : memo[n]
FIB_MEMO:
    # preserve machine state
    lw   $ra, ($sp)
    addi $sp, $sp, 4
    
    move $v0, $a0
    jr   $ra
    

FIB2:




end:
    li   $a0, 10
    syscall