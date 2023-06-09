.data
.text

# $24/$t8 -> 输出，硬件表现为LED�????7段数码管
# $25/$t9 -> 输入，硬件表现为24位拨码开关，�????1位为case提交，左2-4位为case选择，左5位为数据提交，右8位为数据输入
# $s3 -> a
# $s4 -> b

main:
    addi $24,$zero,0x32767         # 初始灯全亮，表示等待接收case输入
     
    # mars test part
    # addi $t9,$zero,0xf80091
    # addi $s3,$zero,0x5
    # addi $s4,$zero,0x2
    
switch:
    andi $a0,$t9,0x700000

    andi $a1,$t9,0x800000   # 获取左第�????位，$a1用于确认提交case�????
    beq $a1,$zero,main      # 左第�????位为0，未提交
                            # 左第�????位为1，提�????
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

    andi $t0,$t9,0x80000        # 获取左第五位�????$t0用于确认提交
    andi $t1,$t9,0xFF           # $t1为开关的�????8bit
    add $24,$t9,$zero          # 展示输入  

    addi $t3,$t1,-1
    and $t2,$t1,$t3
    beq $t0,$zero,case0         # 左第五位�????0，未提交
                                # 左第五位�????1，提�????
    bne $t2,$zero,case0_not    # n & (n-1) != 0，不�????2的幂
    j case0_is
    case0_not:
        bne $t0,$zero,case0_not     # 若左第五位为1，保持case0
        j switch                   
    case0_is:
        lui $24,0x1
        bne $t0,$zero,case0_is      # 若左第五位为1，保持case0
        
        j switch

case1:  

    andi $t0,$t9,0x80000        # 获取左第五位�????$t0用于确认提交
    andi $t1,$t9,0xFF           # $t1为开关的�????8bit
    add $24,$t9,$zero          # 展示输入

    andi $t1,$t1,0x1
    beq $t0,$zero,case1         # 左第五位�????0，未提交
                                # 左第五位�????1，提�????
    beq $t1,$zero,case1_not     # 末尾�????0，是偶数
    j case1_is

    case1_not:
        bne $t0,$zero,case1_not     # 若左第五位为1，保持case0
        j switch   
    case1_is:
        lui $24,0x1
        bne $t0,$zero,case1_is      # 若左第五位为1，保持case0
        j switch

case2:
	
    # a or b
    andi $t0,$t9,0x80000        # 获取左第五位�????$t0用于确认提交
    or $t1,$s3,$s4
    add $24,$t1,$zero           # 展示结果
    case2_show:
        beq $t0,$zero,case2_show    # 左第五位�????0，未提交
                                    # 左第五位�????1，提�????
        j switch
    

case3:
    # a nor b
    andi $t0,$t9,0x80000        # 获取左第五位�????$t0用于确认提交
    nor $t1,$s3,$s4
    addi $24,$t1,0xFF           # 展示结果
    case3_show:
        beq $t0,$zero,case3_show    # 左第五位�????0，未提交
                                    # 左第五位�????1，提�????
        j switch


case4:
    # a xor b
    andi $t0,$t9,0x80000        # 获取左第五位�????$t0用于确认提交
    xor $t1,$s3,$s4
    addi $24,$t1,0xFF           # 展示结果
    case4_show:
        beq $t0,$zero,case4_show    # 左第五位�????0，未提交
                                    # 左第五位�????1，提�????
        j switch

case5:
    # signed a < b ?
    andi $t0,$t9,0x80000        # 获取左第五位�????$t0用于确认提交
    andi $t3,$s3,0x80
    andi $t4,$s4,0x80
    addi $t2,$zero,0x80

    beq $t3,$t2,case5_an
    j case5_au

    case5_au:   # a+
    beq $t4,$t2,case5_au_bn
    j case5_au_bu

    case5_au_bu:    # a+b+
    andi $t3,$s3,0x7F
    andi $t4,$s4,0x7F
    slt $t1,$t3,$t4
    j case5_over

    case5_au_bn:    # a+b-
    add $t1,$zero,$zero
    j case5_over


    case5_an:   # a-
    beq $t4,$t2,case5_an_bn
    j case5_an_bu

    case5_an_bu:    # a-b+
    addi $t1,$zero,1
    j case5_over

    case5_an_bn:    # a-b-
    andi $t3,$s3,0x7F
    andi $t4,$s4,0x7F
    slt $t1,$t4,$t3
    j case5_over
    
case5_over:

    add $24,$t1,$zero           # 展示结果
    case5_show:
        beq $t0,$zero,case5_show    # 左第五位�????0，未提交
                                    # 左第五位�????1，提�????
        j switch


case6:
    # unsigned a < b ?
    andi $t0,$t9,0x80000        # 获取左第五位�????$t0用于确认提交
    sltu $t1,$s3,$s4
    add $24,$t1,$zero           # 展示结果
    case6_show:
        beq $t0,$zero,case6_show    # 左第五位�????0，未提交
                                    # 左第五位�????1，提�????
        j switch


case7:
        andi $t0,$t9,0x80000        # 获取左第五位�????$t0用于确认提交
        andi $t1,$t9,0xFF           # $t1为开关的�????7bit
        add $24,$t9,$zero          # 展示输入
        
        
        beq $t0,$zero,case7       # 左第五位�????0，未提交
                                    # 左第五位�????1，提�????
        add $s3,$t1,$zero            # $3 = a


case7_b:
    	# addi $t9,$zero,0xf00085
    	
    	andi $t0,$t9,0x80000
        andi $t1,$t9,0xFF
        bne $t0,$zero,case7_b       # 左第五位�????1，未提交
                                    # 左第五位�????0，提�????
        add $s4,$t1,$zero            # $s4 = b
        
        j switch

