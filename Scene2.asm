.data 0x0000				      		
	stack: .space 40
.text 0x0000
#寄存器初始化				
start:
	lui   $1,0xFFFF	                    
        ori   $28,$1,0xF000         #设置$28=0xFFFFF000
        lui   $12,0x0000               #$12=0

        ori $27,$12,0x8000         #设置$27=0x00008000

	ori $26,$12,0x0010         	#$26=16
	ori $19,$12,0x0001         	#$19=1
	ori $18,$12,0x0000         	#$18=0
	ori $17,$12,0x0002			#$17=2
	ori $16,$12,0x0003			#$16=3

#检测高16位,定位到label
main:
	#lui $8,0xffff                        
        #ori $8,$8,0xffff
        #sw $8,0xC62($28)       #确认处于main状态 用于debug

	lw $2,0xC72($28)            #获取左边八个拨码开关的值，即$2=样例编号
	ori $13,$12,0x0000          #$13=24'b0,00000000
	beq $2,$13,L1                  #进入场景0
	ori $13,$12,0x0020          #$13=24'b0,00100000       
	beq $2,$13,L2              
	ori $13,$12,0x0040          #$13=24'b0,01000000
	beq $2,$13,L3                
	ori $13,$12,0x0060          #$13=24'b0,01100000
	beq $2,$13,L4
	ori $13,$12,0x0080          #$13=24'b0,10000000
	beq $2,$13,L5
	ori $13,$12,0x00a0          #$13=24'b0,10100000
	beq $2,$13,L6
	ori $13,$12,0x00c0          #$13=24'b0,11000000
	beq $2,$13,L7
	ori $13,$12,0x00e0          #$13=24'b0,11100000
	beq $2,$13,L8
	j main

L1:
    addi $21,$18,0             	#$21=0,不展示细节
    j Input

L2:
    addi $21,$19,0           	#$21=1,展示出栈入栈次数之和
    j Input

L3:
    addi $21,$17,0             	#$21=2,展示每次入栈参数
    j Input

L4:
    addi $21,$16,0				#$21=3,展示每次入栈参数
    j Input



L5:
	input1:
	lw $2,0xC72($28)			#提交开关
	lw $20,0xC70($28)			#$20=原始数据
	sw $20,0xC60($28)           #数据显示
	beq $2,$12,input1        #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）

	input2:
	lw $2,0xC72($28)			#提交开关
	lw $21,0xC70($28)			#$20=原始数据
	sw $21,0xC60($28)           #数据显示
	beq $2,$12,input2         #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）

	addu $3,$20,$21

	slt $4,$20,$zero
	slt $5,$21,$zero
	slt $6,$3,$zero
	beq $4, $5, check_overflow
	j no_overflow 
	
L6:
input1:
	lw $2,0xC72($28)			#提交开关
	lw $20,0xC70($28)			#$20=原始数据
	sw $20,0xC60($28)           #数据显示
	beq $2,$12,input1        #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）

	input2:
	lw $2,0xC72($28)			#提交开关
	lw $21,0xC70($28)			#$20=原始数据
	sw $21,0xC60($28)           #数据显示
	beq $2,$12,input2         #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）

	subu $3,$20,$21

	slt $4,$20,$zero
	slt $5,$21,$zero
	slt $6,$3,$zero
	bne $4, $5, check_overflow
	j no_overflow 

L7:
	input1:
	lw $2,0xC72($28)			#提交开关
	lw $20,0xC70($28)			#$20=原始数据
	sw $20,0xC60($28)           #数据显示
	beq $2,$12,input1        #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）

	input2:
	lw $2,0xC72($28)			#提交开关
	lw $21,0xC70($28)			#$20=原始数据
	sw $21,0xC60($28)           #数据显示
	beq $2,$12,input2         #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）    

	slt $3,$12,$20	# 0: number>0
	slt $4,$12,$21
	beq $3,$4,same_sign

	different_sign:
	beq $3,$12,a_is_positive
	b_is_positive:
	ori $2,$21,0x0000
	nor $1,$20,$12
	addi $1,$1,1
	a_is_positive:
	ori $1,$20,0x0000
	nor $2,$21,$12
	addi $2,$2,1
	j mul_pre


	same_sign:
	beq $3,$12,mul_pre
	nor $1,$20,$12
	addi $1,$1,1
	nor $2,$21,$12
	addi $2,$2,1
	j mul_pre

	mul_pre:
	lui   $3,0x0000        
	lui   $4,0x0000    
	mul:
	beq $4,$2 mul_end
	add $3,$3,$1
	addi $4,$4,1
	j mul

	mul_end:
	sw $3,0x60($28)
	j main

L8:
	input1:
	lw $2,0xC72($28)			#提交开关
	lw $20,0xC70($28)			#$20=原始数据
	sw $20,0xC60($28)           #数据显示
	beq $2,$12,input1        #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）

	input2:
	lw $2,0xC72($28)			#提交开关
	lw $21,0xC70($28)			#$20=原始数据
	sw $21,0xC60($28)           #数据显示
	beq $2,$12,input2         #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）    

	nor $1,$20,$12
	addi $1,$1,1
	nor $2,$21,$12
	addi $2,$2,1

	div_pre:
	lui   $3,0x0000        
	addi $4,$2,0
	div:
	blt $4,$2,div_end
	sub $4,$4,$2
	addi $3,$3,1
	j div

	div_end:
	slt $5,$12,$20	# 0: number>0
	slt $6,$12,$21
	beq $5,$6,alternate_display

	comp:
	nor $3,$3,$12
	addi $3,$3,1
	beq $5,$12,alternate_display
	nor $4,$4,$12
	addi $4,$4,1

	alternate_display:
	sw $3,0xC60($28)
	addi $6, $0, 10000000 
	delay_loop:
	subu $6, $6, 1
	bnez $6, delay_loop
	sw $4, 0xC60($28)
	addi $6, $0, 10000000 
	delay_loop:
	subu $6, $6, 1
	bnez $6, delay_loop
	j main




	# 防止溢出 
	j main



	# 函数区

Input:
	lw $2,0xC72($28)			#提交开关
	lw $20,0xC70($28)			#$20=原始数据
	sw $20,0xC60($28)           #数据显示
	beq $2,$12,Input            #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）

	ori   $10,$27,0x0000		#$10=$sp,$s11=$ra
	addi $3,$20,0				#$3=n
    addi $4,$12,0				#$4=res(0)
    addi $5,$12,0				#$5=cnt(0)



Sum:
	addi $10,$10,-8			# 在栈上分配空间
	sw $11,4($10)			# 保存返回地址
	sw $3,0($10)			# 保存参数 n

	bne $21,$19,n1_1		# case1
	addi $7,$7,1
n1_1:
	bne $21,$17,n2			# case2
	addi $7,$3,0
	j Show

n2:
	beq $3,$12,End			# 如果 n 为 0，直接返回 0
	addi $3,$3,-1			# n = n - 1
	j Sum					# 递归调用子函数 sum(n-1) //jal

	lw $3,0($10)			# 恢复参数 n
	lw $11,4($10)			# 恢复返回地址

	beq $21,$16,n3			# case3
	addi $7,$3,0
	j Show
n3:
	add $4,$4,$3			# 计算 sum(n) = n + sum(n-1)

	bne $21,$19,n1_2		# case1
	addi $7,$7,1
	beq $3,$20,Show			# case1:递归结束，显示出入栈次数和
n1_2:	

	beq $3,$20,main			# case2|3:递归结束，回到main状态
End:
	addi $10,$10,8		 	# 释放栈空间
	j $11					# 返回到调用者 //jr




Show:
    lui $15,0x0200
	ori $15,$15,0x009f          #显示大约2-3s

    #counter:
    lui  $27,0x0000 
	addi $10,$27,0

	addi $10,$10,1
	sw $7, 0x60($28)
	bne $10,$15,Show

	beq $21,$19,main	
	beq $21,$17,n2		
	beq $21,$16,n3



check_overflow:
	beq $4, $6,no_overflow
	j overflow

	overflow:
	li $4, 1                  
	j end_check_overflow

	no_overflow:
	li $4, 0                  

	end_check_overflow:
	sw $3, 0xC60($28)  
	sw $4, 0xC62($28)  
	j main




    

