.data 0x0000				      		
	buf: .word 0x0000
.text 0x0000
#寄存器初始化				
start:
	lui   $1,0xFFFF	                    
    ori   $28,$1,0xF000         #设置$28=0xFFFFF000
    lui   $12,0x0000               #$12=0

    ori $27,$12,0x8000         #设置$27=0x00008000

	ori $26,$12,0x0010         #$26=16
	ori $19,$12,0x0001         #$19=1
	ori $18,$12,0x0000         #$18=0

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
	beq $2,$13,L8_1
	j main

L1:
	lw $2,0xC72($28)
	lw   $20,0xC70($28)
    sw   $20,0xC60($28)            
	beq $2,$12,L1                #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）
	
    # 判断2次幂
    sub $23,$20,$19
    and $23,$20,$23              #n & (n-1) ? 0 
    bne $23,$12,nothing

show:
	sw $19,0xC62($28)               #显示灯亮
	lw $2,0xC72($28)           #判断拨码开关状态        
	beq $2,$26,show             #左数第四个键为确认键，拨起跳出场景0回到main
	j main                                   

nothing: 	
	lw $2,0xC72($28)
	beq $2,$26,nothing               
	j main

L2:
	lw $2,0xC72($28)
	lw   $20,0xC70($28)
    sw   $20,0xC60($28)            
	beq $2,$12,L2                #不停地读数字，直到确认键拨起（即前八个拨码开关不全是0）
	
    # 判断奇数
    and $27,$20,$19
    beq $27,$19,show
    j nothing

L3: #a or b
	or $5,$3,$4
L3_reback:
    lui   $1,0x0000	
    ori   $11,$1,0x0060
	sw $5,0xC60($28)
	lw $2,0xC72($28)
	beq $2,$11,L3_reback
	j main

L4: #a nor b
    nor $5,$3,$4
L4_reback:
    lui   $1,0x0000	
    ori   $11,$1,0x0060
	sw $5,0xC60($28)
	lw $2,0xC72($28)
	beq $2,$11,L4_reback
	j main

L5: #a xor b
	xor $5,$3,$4
L5_reback:
    lui   $1,0x0000	
    ori   $11,$1,0x0080
	sw $5,0xC60($28)        #显示结果
	lw $2,0xC72($28)
	beq $2,$11,L5_reback    #拨起左数第五个键回main
	j main

L6: #signed: a < b 
	slt $5,$3,$4
L6_reback:
	lui	$1,0x0000
	ori $11,$1,0x0080
	sw $5,0xC60($28)
	lw $2,0Xc72($28)
	beq $2,$11,L6_reback

L7: #unsigned: a < b
	sltu $5,$3,$4
L7_reback:
    lui	$1,0x0000
	ori $11,$1,0x0080
	sw $5,0xC60($28)
	lw $2,0Xc72($28)
	beq $2,$11,L7_reback

L8_1:
	lui   $1,0x0000	                  
    ori   $11,$1,0x0030    #$11=0x00000030
	lw $3,0xC70($28)       #输入A到$3
	sw $3,0xC60($28)       #显示A
	lw $2,0xC72($28)      
	bne $2,$11,L8_1         #左数第四个键为确认键，往下执行

L8_2:
    lui   $1,0x0000	
    ori   $11,$1,0x0030
	lw $4,0xC70($28)
	sw $4,0xC60($28)      #输入B，显示B  $4
	lw $2,0xC72($28)
	beq $2,$11,L8_2         
	j main                #拨起左数第五个键回main
