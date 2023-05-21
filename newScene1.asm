.data
.text

# $24/$t8 -> 输出，硬件表现为LED和7段数码管
# $25/$t9 -> 输入，硬件表现为24位拨码开关，左1位为case提交，左2-4位为case选择，左5位为数据提交，右8位为数据输入
# $s3 -> a
# $s4 -> b

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
    andi $t0,$t9,0x80000        # 获取左第五位，$t0用于确认提交
    andi $t1,$t9,0xFF           # $t1为开关的右8bit
    add $24,$t9,$zero          # 展示输入  

    lui $t2,0x1
    sub $t3,$t1,$t2
    and $t2,$t1,$t3
    beq $t0,$zero,case0         # 左第五位为0，未提交
                                # 左第五位为1，提交
    bne $t2,$zero,case0_not    # n & (n-1) != 0，不为2的幂
    j case0_is

    case0_not:
        bne $t0,$zero,case0_not     # 若左第五位为1，保持case0
        j switch                   
    case0_is:
        lui $24,0x1
        bne $t0,$zero,case0_is      # 若左第五位为1，保持case0
        j switch

case1:  
    andi $t0,$t9,0x80000        # 获取左第五位，$t0用于确认提交
    andi $t1,$t9,0xFF           # $t1为开关的右8bit
    add $24,$t9,$zero          # 展示输入

    andi $t1,$t1,0x1
    beq $t0,$zero,case1         # 左第五位为0，未提交
                                # 左第五位为1，提交
    beq $t1,$zero,case1_not     # 末尾为0，是偶数
    j case1_is

    case1_not:
        bne $t0,$zero,case0_not2     # 若左第五位为1，保持case0
        j switch   
    case1_is:
        lui $24,0x1
        bne $t0,$zero,case0_is2      # 若左第五位为1，保持case0
        j switch

case2:
    # a or b
    andi $t0,$t9,0x80000        # 获取左第五位，$t0用于确认提交
    or $t0,$s3,$s4
    add $24,$t0,$zero           # 展示结果
    case2_show:
        beq $t0,$zero,case2_show    # 左第五位为0，未提交
                                    # 左第五位为1，提交
        j switch
    

case3:
    # a nor b
    andi $t0,$t9,0x80000        # 获取左第五位，$t0用于确认提交
    nor $t0,$s3,$s4
    add $24,$t0,$zero           # 展示结果
    case3_show:
        beq $t0,$zero,case3_show    # 左第五位为0，未提交
                                    # 左第五位为1，提交
        j switch


case4:
    # a xor b
    andi $t0,$t9,0x80000        # 获取左第五位，$t0用于确认提交
    xor $t0,$s3,$s4
    add $24,$t0,$zero           # 展示结果
    case4_show:
        beq $t0,$zero,case4_show    # 左第五位为0，未提交
                                    # 左第五位为1，提交
        j switch



case5:
    # signed a < b ?
    andi $t0,$t9,0x80000        # 获取左第五位，$t0用于确认提交
    slt $t0,$s3,$s4
    add $24,$t0,$zero           # 展示结果
    case5_show:
        beq $t0,$zero,case5_show    # 左第五位为0，未提交
                                    # 左第五位为1，提交
        j switch


case6:
    # unsigned a < b ?
    andi $t0,$t9,0x80000        # 获取左第五位，$t0用于确认提交
    sltu $t0,$s3,$s4
    add $24,$t0,$zero           # 展示结果
    case6_show:
        beq $t0,$zero,case6_show    # 左第五位为0，未提交
                                    # 左第五位为1，提交
        j switch

case 7:

    case7_a:
        andi $t0,$t9,0x80000        # 获取左第五位，$t0用于确认提交
        andi $t1,$t9,0xFF           # $t1为开关的右8bit
        add $24,$t9,$zero          # 展示输入
        
        
        beq $t0,$zero,case7_a       # 左第五位为0，未提交
                                    # 左第五位为1，提交
        andi $s3,$t9,0xF            # $3 = a

    case7_b:

        bne $t0,$zero,case7_b       # 左第五位为1，未提交
                                    # 左第五位为0，提交
        andi $s4,$t9,0xF            # $s4 = b


