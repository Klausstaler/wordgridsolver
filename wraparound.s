
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
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

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
.align 2                                        # ( maximum size of each word + \n) + NULL
dictionary_idx: 	.space 4000
helperString:		.space 65
.align 2
size:			.space 8

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
li $s2,0 #diagonal
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
flag:
	beq $s1,1 return
	li $a0, -1
	li $v0, 1
	syscall
	jr $ra
add_1_arr:
	bnez $t2,return
	addi $t2,$t2,1 #rows++
row_counter:
	bne $t4,'\n',return # if t4 != '\n', go back
	addi $t2,$t2,1 #rows++
	bnez $t3, return # if flag != 0, go back
	li $t3,1   #flag = 1
	sw $t1,size +4  #size[1] = grid_idx
array_init:
	lb $t4,grid($t1)   # t4 = grid[grid_idx]
	blez $t4,return    #  if t4 == \0, stop
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal row_counter
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	addi $t1,$t1,1  #grid_idx++
	j array_init
strReset:
	li $t3,0
	j strResetLoop
strResetLoop:
	beq $t3,64,return
	sb $0,helperString($t3)
	addi $t3,$t3,1
	j strResetLoop
	
init_idxs:
	li $t2,0 #idx=0; in array_init rows
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
horizontal:

	lw $v1,size
	bge $s1,$v1,return
	lw $v1, size + 4
	bge $t1,$v1,return
	move $a0,$s3
	li $v0,1       #print row
	syscall
	
	li $a0, 44
	li $v0,11 # print comma
	syscall
	

	move $a0,$t1
	li $v0,1       #print string_idx
	syscall
	
	li $a0,32
	li $v0,11  #print whitespace
	syscall
	li $a0, 72
	li $v0,11   #print direction H
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
vertical:

	lw $v1,size
	bge $t1,$v1,return
	lw $v1, size + 4
	bge $s3,$v1, return

	move $a0,$t1
	li $v0,1       #print string_idx
	syscall
	
	li $a0, 44
	li $v0,11 # print comma
	syscall
	

	move $a0,$s3
	li $v0,1       #print row
	syscall
	
	li $a0,32
	li $v0,11  #print whitespace
	syscall
	li $a0, 86
	li $v0,11   #print direction V
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
direction_finder:
	beq $s4, 72, horizontal
	beq $s4, 86, vertical
	
	lw $v1, size + 4
	move $a0,$s2        ##stay if diagonal+string_idx < size[1]
	add $a0,$a0,$t1
	bge $a0,$v1,return
	lw $v1, size
	move $a0,$t1
	add $a0,$a0,$s3  #stay if row +string_idx < sisze[0]
	bge $a0,$v1,return 
	
	move $a0,$s3
	add $a0,$t1,$a0
	li $v0,1       #print row +string_idx
	syscall
	
	li $a0, 44
	li $v0,11 # print comma
	syscall
	
	move $a0,$s2
	add $a0,$a0,$t1
	li $v0,1       #print diagonal +string_idx
	syscall
	
	li $a0,32
	li $v0,11  #print whitespace
	syscall
	li $a0, 68
	li $v0,11   #print direction D
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
	
print_strfind: #t6,t7
	beqz $v1, return
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal direction_finder
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	
	jr $ra
	
strfind:
	li $t1,0 #string_idx
	li $t2,0 # idx
	j strfind_loop
strfind_loop:
	lb $t3,grid($t1)
	blez $t3,return
	addi $sp,$sp,-4 
	sw $ra, 0($sp)  
	jal increment
	
	lw $t0,dictionary_idx($t2) # t0 = dictionary_idx[idx]
	la $a1,dictionary($t0) #word = t0 = dictionary[dictionary_idx[idx]]
	la $a2,helperString($t1) #load grid with offset string_idx, is then called string

	jal contain   #check if string contains char
	jal print_strfind #print if string matches
	lw $ra,0($sp)
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	addi $t2,$t2, 4  #increment idx
	j strfind_loop
parseHorizontal:
	li $t7, 0  #grid_idx
	li $t6, 0 #helper_idx
	li $s3, 0 #row
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal strReset
	lw $ra,0($sp)
	addi $sp,$sp,4
	j horizontalloop
horizontalloop:
	lw $t5,size # load size[0]
	beq $t5,$s3,return # while row < size[0]
	lb $t4,grid($t7)  #grid[grid_idx]
	
	addi $sp,$sp,-4
	sw $t7,0($sp) #storing t7
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal horizontal_else

	lw $ra,0($sp)  #loading $ra
	addi $sp,$sp,4
	lw $t7,0($sp)  #loading $t7
	addi $sp,$sp,4
	addi $t7,$t7,1 #grid_idx++
	j horizontalloop
horizontal_if:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal wraparound  #implemented for wraparound
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	li $s4, 72 #direction ='H'
	jal strfind
	lw $ra, 0($sp)
	addi $sp,$sp,4
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal strReset
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	addi $s3,$s3,1 #row++
	li $t6,0 #helper_idx = 0
	jr $ra
horizontal_else:
	beq $t4,10,horizontal_if # go to if if grid[grid_idx] =='\n'
	blez $t4,horizontal_if
	sb $t4,helperString($t6)
	addi $t6,$t6,1
	jr $ra
	
parseVertical:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal strReset
	lw $ra,0($sp)
	addi $sp,$sp,4
	li $t7, 0  #grid_idx
	li $t6, 0 #helper_idx
	li $s3, 0 #row
	j parseVerticalloop
parseVerticalloop:
	lw $t5, size + 4 #load size[1]
	beq $t7, $t5, return
	lb $t4,grid($t7)  #grid[grid_idx]
	sw $t4,helperString # helperString[0] = grid[grid_idx]
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	li $t8,1 #offsetmul = 1
	li $t6,0 #helper_idx = 0
	jal innerVertical
	lw $ra,0($sp) #loading $ra
	addi $sp,$sp,4
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal wraparound  #implemented for wraparound
	lw $ra,0($sp)
	addi $sp,$sp,4

	addi $sp,$sp,-4
	sw $t7,0($sp) #storing t7
	li $s4, 86 #direction 'V'
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal strfind  #search for string
	lw $ra, 0($sp)
	addi $sp,$sp,4
	lw $t7,0($sp)  #loading $t7
	addi $sp,$sp,4
	
	addi $t7,$t7,1 #grid_idx ++
	addi $s3,$s3,1 #row++
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal strReset  #added for wraparound
	lw $ra,0($sp)
	addi $sp,$sp,4
	j parseVerticalloop
innerVertical:
	lw $t5, size + 4 #load size[1]
	lw $t9, size # load size[0]
	beq $t8,$t9,return  # branch if offsetmult = size[0]
	addi $t6,$t6, 1 #helper_idx++
	mul $t5,$t5, $t8  # t5= size[1] *offsetmult
	add $t5,$t5,$t8   # t5 = t5 + offsetmult
	add $t5,$t5,$t7   # t5 = t5 +grid_idx
	lb $t5,grid($t5)  # t5 = grid[t5]
	sb $t5,helperString($t6) # helperString[helper_idx]= t5
	addi $t8,$t8,1
	j innerVertical
parseDiagonal:
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal strReset
	lw $ra,0($sp)
	addi $sp,$sp,4
	lw $t7,size + 4
	addi $t7,$t7,-1 #j
	li $t6, 0 #k
	li $s7, 0 #i
	li $s5, 0 #helper_idx
	li $s6, 0 #grid_idx
	li $s3  0 #row
	li $t4, 0 #col
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal parseDiagonalloop
	lw $ra,0($sp)
	addi $sp,$sp,4
	li $t6, 0 #k
	li $s5, 0 #helper_idx
	li $s6, 0 #grid_idx
	li $s3  0 #row
	li $t4, 0 #col
	li $s7, 1 #i
	j diagloop2
parseDiagonalloop:
	beq $t7,-1,return
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal strReset
	lw $ra,0($sp)
	addi $sp,$sp,4
	li $s5, 0 #helper_idx reset
	li $s3,0 #row
	li $t4,0 #col
	li $t6,0 #k
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal innerDiagonalloop
	lw $ra,0($sp)
	addi $sp,$sp,4
	

	move $s2,$t4 #diagonal = col
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal wraparound  #implemented for wraparound
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	addi $sp,$sp,-4
	sw $t4,0($sp) #store col
	addi $sp,$sp,-4
	sw $t7,0($sp) #store row
	addi $sp,$sp,-4
	sw $ra,0($sp)
	li $s4,68
	jal strfind
	lw $ra,0($sp)
	addi $sp,$sp,4
	lw $t7,0($sp)
	addi $sp,$sp,4
	lw $t4,0($sp)
	addi $sp,$sp,4
	
	addi $t7,$t7,-1
	j parseDiagonalloop
innerDiagonalloop:
	lw $t5, size
	beq $t5,$t6,return #return if size[0] = k
	add $t5,$t7,$t6  # j+k
	lw $t8,size + 4 #size[1]
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal stringadder
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	addi $t6,$t6,1
	j innerDiagonalloop
return_stringadder:
			  #overwrite return address( which would lead back to innerDiagonalloop
	lw $ra,0($sp)  # to jump back to parse Diagonalloop
	addi $sp,$sp,4
	jr $ra 
stringadder:
	bge $t5,$t8,return_stringadder
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal idxsetter
	lw $ra,0($sp)
	addi $sp,$sp,4
	

	lw $s6,size + 4 # size[1]
	addi $s6,$s6,1  #size[1] +1 
	mul $s6,$s6,$t6 # s& = k*s6
	add $s6,$s6,$t6 #add k
	add $s6,$s6,$t7 # add j
	lb $s6,grid($s6)
	sb $s6,helperString($s5) #vString[helper_idx] = grid[grid_idx]
	addi $s5,$s5,1  #helper_idx++
	jr $ra
idxsetter:
	bnez $s5,return #if helper_idx != 0, do nothhing
	move $s3,$t6 #row = k
	add $t4,$t7,$t6 #col = j + k
	jr $ra
diagloop2:
	lw $t5,size
	beq $t5,$s7,return
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal strReset
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	li $t6,0 #k
	li $s5,0 #helper_idx
	li $s3,0 #row
	li $t4,0 #col
	move $t7,$s7 # j=i
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal innerdiagloop2
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	move $s2, $t4
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal wraparound  #implemented for wraparound
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	addi $sp,$sp,-4
	sw $t4,0($sp) #store col
	addi $sp,$sp,-4
	sw $s3,0($sp) #store row
	addi $sp,$sp,-4
	sw $ra,0($sp)
	li $s4,68
	jal strfind
	lw $ra,0($sp)
	addi $sp,$sp,4
	lw $s3,0($sp)
	addi $sp,$sp,4
	lw $t4,0($sp)
	addi $sp,$sp,4
	
	addi $s7,$s7,1 #i++
	j diagloop2
innerdiagloop2:

	lw $t5,size  
	beq $t7,$t5,return #return if j= size[0]

	#move $a0,$t7
	#li $v0,1
	#syscall
	#li $a0,10,
	#li $v0,11
	#syscall
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal diag2_if
	lw $ra,0($sp)
	addi $sp,$sp,4
	addi $t6,$t6,1 #k++
	addi $t7,$t7,1 #j++
	j innerdiagloop2
diag2_if:
	lw $t5,size + 4
	bge $t6,$t5,return
	
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal second_setter
	lw $ra,0($sp)
	addi $sp,$sp,4
	
	lw $s6,size + 4
	addi $s6,$s6,1 #size[1] +1
	mul $s6,$s6,$t7 # j*s6
	add $s6,$s6,$t6 # s6 + k
	lb $s6,grid($s6)
	sb $s6,helperString($s5)
	addi $s5,$s5,1 #helper_idx++
	jr $ra
second_setter:
	bnez $s5,return
	move $s3,$t7
	move $t4,$t6
	jr $ra
wraparound:
	li $t8,0 #i
	li $t9,0 #len
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal wraparoundloop
	lw $ra,0($sp)
	addi $sp,$sp,4
	move $t8,$t9
	addi $sp,$sp,-4
	sw $ra,0($sp)
	jal wraparoundloop2
	lw $ra,0($sp)
	addi $sp,$sp,4
wraparoundloop2:
	mul $t3,$t9,2
	beq $t8,$t3,return
	sub $t3,$t8,$t9
	lb $t3, helperString($t3)
	sb $t3, helperString($t8)
	addi $t8,$t8,1
	j wraparoundloop2
wraparoundloop:
	beq $t9, 64, return
	lb $t3,helperString($t9)
	beq $t3,0,return
	addi $t9,$t9,1
	j wraparoundloop
	
	

	
	
	
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:
	jal init_idxs
	li $t3, 0 #flag in array_init
	jal array_init
	jal add_1_arr
	sw $t2,size     # size[0] = rows
	jal parseHorizontal
	jal parseVertical
	jal parseDiagonal
	jal flag
	
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
# $s1 reserved for flag
# $s0 reserved for dict_num_words
# size is for row, cols
# $s2 is for diagonal
# $s3 is for row
# $s4 is for direction
