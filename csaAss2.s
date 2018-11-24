# Fibonacci Function of O(n) complexity
        .data
        .align 2
msg:    .asciiz "\nEnter a number>"
comma:  .asciiz ","
errmsg: .asciiz "\nError - must enter a positive integer\n"
newln:  .asciiz "\n"
colon:  .asciiz " : "
zero:   .word   0

.text
main:
# read user input
INPUT:                          #
    la   $a0, msg               # load address for message
    li   $v0, 4                 #
    syscall                     # print message
                                #
    li   $v0, 5                 #
    syscall                     # read input
                                # validate data
    addi $t0, $v0, 1            # t0 : N + 1 (so that we also print the nth fibonacci number
    bgtz $t0, SETUP             # if (N > 0) go to next step, else input again
                                #
                                # invalid input
    la   $a0, errormsg          # load error message
    li   $v0, 4                 #
    syscall                     # print error message
                                #
    j    INPUT                  # get user input again
    
SETUP:                          #
    li   $a1, 0                 # a1 : i
                                #
    addi $t5, $t0, 1            # t5 : N + 1
    # allocate an array the size of N + 1 because this is how many numbers we print
    sll  $a0, $t5, 2            # a0 : number of bytes needed 
    li   $v0, 9                 #
    syscall                     # v0 : address of array space
    move $a2, $v0               # a2 : address of array space

LOOP:                           #
                                # a1 : i
    addi $a3, $a1, 0            # a3 : copy of a1
                                # t0 : counter for the loop
    beq  $a1, $t0, end          # end when the counter has reached n
                                #
    # store machine state       #
    addi $sp, $sp, -4           # decrement the stack
    sw   $a1, ($sp)             # store a1 on the stack
    
    
    move $a0, $a1
    li   $v0, 1
    syscall
    
    la   $a0, colon
    li   $v0, 4
    syscall
    
    
                                #
    # call fibonacci            #
    jal  FIB                    # call fib(n)
    # print fibonacci return    #
    move $a0, $v0               # a0 : fib(n)
    li   $v0, 1                 #
    syscall                     # print the output of fib(n)
                                #
    la   $a0, newln             # load address for new line
    li   $v0, 4                 # 
    syscall                     # print new line
                                #
    # preserve machine state    #
    lw   $a1, ($sp)             # store a1 on the stack
    addi $sp, $sp, 4            # increment the stack
                                #
                                #
    addi $a1, $a1, 1            # a1: i++
    j    LOOP                   # loop
    
    
# Fibonacci method of complexity O(n)
#
# @p : a1 : n
# @p : a2 : integer array memo
# @p : a3 : copy of n
FIB:                            #
    # store machine state       #
    addi $sp, $sp, -4           # decrement the stack
    sw   $ra, ($sp)             # store the return address on the stack
                                #
    blez $a1, FIB0              # if (n <=0) return 0
                                #
    li   $t1, 1                 # t1 : 1
                                #
    beq  $a1, $t1, FIB1         # if (n == 1) return 1
                                #
    sll  $t8, $a1, 2            # calculate number of bytes we need to increment array pointer by
    add  $a2, $a2, $t8          # a2 : a2 + t8 (increment array pointer to get the position of a[n])
    lw   $a0, ($a2)             # a0 : a[n]
    sub  $a2, $a2, $t8          # a2 : a2 - t8 (decrement array pointer to get the starting position)
                                #
    bgtz $a0, FIB_MEMO          # if (a[n] > 0) return a[n]
                                #
    addi $a1, $a1, -1           # a1 : a1 - 1
    jal  FIB                    # v0 : fib(n-1, memo)
    move $t2, $v0               # t2 : fib(n-1, memo)
                                #
    addi $a1, $a1, -1           # a1 : a1 - 1
    jal  FIB                    # v0 : fib(n-2, memo)
    move $t3, $v0               # t3 : fib(n-2, memo)
                                #
    add  $t2, $t2, $t3          # t2 : fib(n-1, memo) + fib(n-2, memo)
                                #
    sll  $t8, $a3, 2            # calculate number of bytes we need to increment array pointer by
    add  $a2, $a2, $t8          # increment array pointer to get to position of a[n]
    sw   $t2, ($a2)             # store fib(n-1, memo) + fib(n-2, memo) at a[n]
    sub  $a2, $a2, $t8          # decrement array pointer to get the starting position
                                #
    move $a0, $t2               # a0 : memo[n] = fib(n-1, memo) + fib(n-2, memo)
    j    FIB_MEMO               # jump to return memo[n]

# return 0 when fib(0) is called
FIB0:                           #
    # preserve machine state    #
    lw   $ra, ($sp)             # load the return address from the stack
    addi $sp, $sp, 4            # increment the stack
                                #
    li   $v0, 0                 # v0 : 0
    jr   $ra                    # return

# return 1 when fib(1) is called
FIB1:                           #
    # preserve machine state    #
    lw   $ra, ($sp)             # load the return address from the stack
    addi $sp, $sp, 4            # increment the stack
                                #
    li   $v0, 1                 # v0 : 1
    jr   $ra                    # return

# return memo[n]
# @p : a0 : memo[n]
FIB_MEMO:                       #
    # preserve machine state    #
    lw   $ra, ($sp)             # load the return address from the stack
    addi $sp, $sp, 4            # increment the satck
                                #
    move $v0, $a0               # v0 : memo[n]
    jr   $ra                    # return
                                
# end the program properly      #
end:                            #
    li   $v0, 10                #
    syscall                     #