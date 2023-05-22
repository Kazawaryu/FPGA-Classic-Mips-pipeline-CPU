.data
    # 分配栈空间，但可能不�?�?
    # stack: .space 100
.text

# $24/$t8 -> 输出，硬件表现为LED�?7段数码管
# $25/$t9 -> 输入，硬件表现为24位拨码开关，�?1位为case提交，左2-4位为case选择，左5位为数据提交，右8位为数据输入

main:
    addi $24,$zero,0x32767         # 初始灯全亮，表示等待接收case输入
switch:
    andi $a0,$t9,0x700000

    andi $a1,$t9,0x800000   # 获取左第�?位，$a1用于确认提交case�?
    beq $a1,$zero,main      # 左第�?位为0，未提交
                            # 左第�?位为1，提�?
    lui $24,0x0
    lui $t0,0x000000    # 0x000
    beq $a0,$t0,case0
    addi $t0,$zero,0x100000    # 0x001
    beq $a0,$t0,case1
    addi $t0,$zero,0x200000    # 0x010
    beq $a0,$t0,case2
    addi $t0,$zero,0x300000    # 0x011
    beq $a0,$t0,case3
    addi $t0,$zero,0x400000    # 0x100
    beq $a0,$t0,case4
    addi $t0,$zero,0x500000    # 0x101
    beq $a0,$t0,case5
    addi $t0,$zero,0x600000    # 0x110
    beq $a0,$t0,case6
    addi $t0,$zero,0x700000    # 0x111
    beq $a0,$t0,case7

    j switch

case0:
    lui $s1,0x0
    j input
        
case1:
    lui $s1,0x1
    j input

case2:
    lui $s1,0x2
    j input

case3:
    lui $s1,0x3
    j input




case4:


case5:


case6:


case7:



    j main

# 函数�?

input:
    andi $s0,$t9,0x80000        # 获取左第五位�?$s0用于确认提交
    add $24,$t9,$zero           # 展示输入

    beq $s0,$zero,input         # 左第五位�?0，未提交
                                # 左第五位�?1，提�?

    # �?测是否为case0
    bne $s1,$zero,input_keepon
    andi $a0,$t9,0xFF           # $a0为开关的�?8bit，即n
    andi $t0,$t9,0x40           # 判断�?高位是否�?1
    beq $t0,$t0,signed          # �?1，则为负�?

input_keepon:

    li $v0, 0                   # 累加�?
    li $s3, 0                   # case显示寄存�?

    lui $s4,0x1                 # 初始化case寄存�?
    lui $s5,0x2
    lui $s6,0x3

    jal sum
    j show

sum:
    # 保存返回地址和调用�?�保存寄存器
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    # �?测是否为case1
    bne $s1,$s4,case1_keepon_1
    addi $s3,$s3,1
case1_keepon_1:

    # �?测是否为case2
    bne $s1,$s5,case2_keepon
    add $24,$a0,$zero
    addi $t0,$t0,0x009f
case2_show:
    addi $t0,$t0,-1
    bne $t0,$zero,case2_show
    add $24,$zero,$zero
case2_keepon:

    # �?�? n 是否为零
    beq $a0, $zero, base_case

    # 计算 sum(n-1) 的�?�归调用
    addi $a0, $a0, -1
    jal sum

    # 获得 n 的�?�并将其�? sum(n-1) 相加
    lw $t0, 0($sp)
    add $v0, $v0, $t0

    # �?测是否为case3
    bne $s1,$s5,case3_keepon
    add $24,$t0,$zero
    addi $t0,$t0,0x009f
case3_show:
    addi $t0,$t0,-1
    bne $t0,$zero,case3_show
    add $24,$zero,$zero
case3_keepon:


    # 恢复返回地址和调用�?�保存寄存器
    lw $ra, 4($sp)
    addi $sp, $sp, 8

    # �?测是否为case1
    bne $s1,$s4,case1_keepon_2
    addi $s3,$s3,1

case1_keepon_2:
    # 返回 sum(n-1) + n 的�??
    jr $ra

base_case:
    # 将结果设置为 0
    add $v0, $zero,$zero

    # 恢复返回地址和调用�?�保存寄存器
    lw $ra, 4($sp)
    addi $sp, $sp, 8

    # 返回 0
    jr $ra

signed:
    add $24,$a0,$zero
    addi $t0,$t0,0x009f
show_signed_light:
    andi $t1,$t9,0x80000        # 获取左第五位�?$t0用于确认提交
    beq $t1,$zero,input

    addi $t0,$t0,-1
    bne $t0,$zero,show_signed_light

    add $24,$zero,$zero
    addi $t0,$t0,0x009f
show_signed_unlight:
    andi $t1,$t9,0x80000        # 获取左第五位�?$t0用于确认提交
    beq $t1,$zero,input

    addi $t0,$t0,-1
    bne $t0,$zero,show_signed_unlight

show:
    add $24,$v0,$zero
    andi $t1,$t9,0x80000        # 获取左第五位�?$t0用于确认提交
    beq $t1,$zero,switch
    j show

