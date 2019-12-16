
#=========================================================================
# 1D String Finder 
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
.align 2                                        # ( maximum size of each word + \n) + NULL
dictionary_idx: 	.space 4000     #start idx of each word, in 32 bit size cuz idx can be > 2^8
# You can add your data here!

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!
li $s0,0 # $s0 =dict_num_words
li $s1,0 #flag

li $t4,0 #dict_idx
li $t5,0 #start_idx
li $t0,0 #idx
li $t3,0
dict_idx:
	lb $t1, dictionary($t0)
	li $t2, '\n'
	blez $t1, end_loop #end_loop if t1 == '\0'
	jal counter
	addi $t0,$t0,1 # increment address of dictionary
	j dict_idx
counter:
	bne $t1, $t2, return
	sw $t5,dictionary_idx($t4) #dictionary_idx[dict_idx] = start_idx
	addi $t4,$t4,4  # dict_idx++
	move $s0,$t4
	
	addi $t5,$t5,0 #start_idx = 0
	addi $t5,$t0,1   # start_idx = idx +1
	#addi $s0,$s0,1  #increment dict_num_words
	jr $ra
return:
	jr $ra
end_loop:
	j main_end
flag: #uses s1
	beq $s1,1 return
	li $a0, -1
	li $v0, 1
	syscall
	jr $ra
init_idxs:
	li $t2,0 #idx=0;
	li $t1,0 #grid_idx = 0
	jr $ra
print_word: #uses t6, $a0,$v0
	move $t4,$a1 #local reference to word (needed to print word)
	j print_word_loop
print_word_loop:
	lb $t6, 0($t4) #word char
	beq $t6,10, return
	blez $t6,return
	move $a0,$t6
	li $v0,11
	syscall
	addi $t4,$t4,1
	j print_word_loop
increment:
	blt $t2,$s0,return
	li $t2, 0 # set idx to 0 for next loop
	addi $t1,$t1,1 #increment grid_idx
	jr $ra
contain:
	move $t4,$a1 #local reference to word
	move $t5,$a2 #local reference to string
	j contain_loop
contain_loop:
	lb $t6, 0($t4) #word char
	lb $t7, 0($t5) #string char
	seq $v1,$t6, '\n'
	bne $t6,$t7, return
	addi $t4,$t4,1
	addi $t5,$t5,1
	j contain_loop
print_strfind: #t6,t7
	beqz $v1, return
	move $a0,$t1
	li $v0,1 #print grid_idx
	syscall
	li $a0, 32  #print ' '
	li $v0, 11
	syscall
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal print_word  #print_word(word) word stored in $t4
	lw $ra,0($sp)
	addi $sp,$sp,4
	li $a0,10     #print newline
	li $v0,11
	syscall
	li $s1,1 # $s1 = 1 for flag
	jr $ra
	
strfind:
	lb $t3,grid($t1)
	blez $t3,return
	addi $sp,$sp,-4 
	sw $ra, 0($sp)   
	jal increment    
	
	lw $t0,dictionary_idx($t2) # t0 = dictionary_idx[idx]
	la $a1,dictionary($t0) #word = t0 = dictionary[dictionary_idx[idx]]
	la $a2,grid($t1) #load grid with offset grid_idx, is then called string
	
	jal contain   #check if string contains char
	jal print_strfind #print if string matches
	lw $ra,0($sp)
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	addi $t2,$t2, 4  #increment idx
	j strfind

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:
	jal init_idxs      
	jal strfind
	jal flag
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
