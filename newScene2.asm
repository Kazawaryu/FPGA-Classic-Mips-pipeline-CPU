.data   
    stack: .space 100
.text

# $24/$t8 -> 输出，硬件表现为LED和7段数码管
# $25/$t9 -> 输入，硬件表现为24位拨码开关，左1位为case提交，左2-4位为case选择，左5位为数据提交，右8位为数据输入

main:
    lui $24,0x32767         # 初始灯全亮，表示等待接收case输入
switch:
    andi $a0,$t9,0x700000

    andi $a1,$t9,0x800000   # 获取左第一位，$a1用于确认提交case数
    beq $a1,$zero,main      # 左第一位为0，未提交
                            # 左第一位为1，提交
    lui $24,0x0
    lui $t0,0x000000    # 0x000
    beq $a0,$t0,case0
    lui $t0,0x100000    # 0x001
    beq $a0,$t0,case1
    lui $t0,0x200000    # 0x010
    beq $a0,$t0,case2
    lui $t0,0x300000    # 0x011
    beq $a0,$t0,case3
    lui $t0,0x400000    # 0x100
    beq $a0,$t0,case4
    lui $t0,0x500000    # 0x101
    beq $a0,$t0,case5
    lui $t0,0x600000    # 0x110
    beq $a0,$t0,case6
    lui $t0,0x700000    # 0x111
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

# 函数区

input:
    andi $s0,$t9,0x80000        # 获取左第五位，$s0用于确认提交
    add $24,$t9,$zero           # 展示输入

    beq $s0,$zero,input         # 左第五位为0，未提交
                                # 左第五位为1，提交

    andi $a0,$t9,0xFF           # $a0为开关的右8bit，即n
    li $v0, 0                   # 累加和
    li $s4, 0                   # 当前数字

    li $sp, 0x7fffeffc          # 设置栈顶指针
    jal sum
    j show


# 递归函数
sum:
    # 保存当前状态
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $v0, 8($sp)

    # 判断是否结束递归
    beq $a0, $zero, end

    # 递归调用
    addi $a0, $a0, -1 # 参数 a0 减 1
    addi $sp, $sp, -4 # 为当前函数调用创建新的栈帧
    sw $a0, 0($sp) # 将参数 a0 存入栈中
    jal sum # 递归调用函数 sum
    lw $a0, 0($sp) # 从栈中恢复参数 a0
    addi $sp, $sp, 4 # 将当前栈帧弹出

    # 计算当前数字和累加和
    add $s4, $s4, 1 # 当前数字加 1
    add $v0, $v0, $s4 # 累加和加上当前数字

    # 递归返回
    end:
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $v0, 8($sp)
    addi $sp, $sp, 12
    jr $ra

# 展示递归结果
show_res:
