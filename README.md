![image](https://github.com/Kazawaryu/FPGA-Classic-Mips-pipeline-CPU/assets/93501403/2cb2013d-c567-44a9-899e-fdf0f3bf46fb)# FPGA Classic Mips pipeline CPU

[![vivado version](https://img.shields.io/badge/Vivado%20version-2017.4-brightgreen?style=flat-square)](https://img.shields.io/badge/Vivado%20version-2017.4-brightgreen?style=flat-square)    [![mars version](https://img.shields.io/badge/Mars%20version-4.5-orange?style=flat-square)](https://img.shields.io/badge/Mars%20version-4.5-orange?style=flat-square)    [![mars version](https://img.shields.io/badge/Code%20version-1.2-blue?style=flat-square)](https://img.shields.io/badge/Code%20version-1.2-blue?style=flat-square)

## 目录

- [项目介绍](#项目介绍)
- [安装](#安装)
- [使用说明](#使用说明)
- [Insight](#Insight)
- [示例](#示例)
- [相关仓库](#相关仓库)
- [维护者](#维护者)
- [如何贡献](#如何贡献)
- [使用许可](#使用许可)

## 项目介绍

本项目是一个 **Classic Mips pipeline CPU**，由 Verilog 语言编写，Mips 汇编实现场景测试。 


### 项目架构

#### CPU特性

- ISA：支持的指令为Minisys-1 ISA，支持指令集的所有指令；内置32个可供汇编代码使用的寄存器，位宽均为32bits；保护0号寄存器禁止写入，保护pc、hi、le寄存器不可访问。

- 寻址空间设计：基于[哈佛架构](https://en.wikipedia.org/wiki/Harvard_architecture)设计；寻址单位为Byte，数据空间的大小为2048KB。

- 外设与IO支持：硬件将24位拨码开关与25号寄存器绑定，将七段数码管与24号寄存器绑定，低8bit数据输入位显示在VGA显示器，蜂鸣器播放电子音乐。


- CPI：多周期5级流水线CPU，解决冲突方式见后文。

#### CPU接口

| 输入/输出 | 端口类型 | 位宽 | 端口名称    | 用途          |
| --------- | -------- | ---- | ----------- | ------------- |
| input     | wire     | 1    | fpga_rst    | CPU复位信号   |
| input     | wire     | 1    | fpga_clk    | CPU时钟信号   |
| input     | wire     | 24   | switch2N4   | 24位拨码开关  |
| output    | wire     | 24   | led2N4      | 24位LED灯     |
| input     | wire     | 1    | rx          | uart写入      |
| output    | wire     | 1    | tx          | uart传出      |
| output    | wire     | 8    | segment_led | 7段数码管信号 |
| output    | wire     | 8    | segment_en  | 7段数码管信号 |
| output    | wire     | 1    | buzzer      | 蜂鸣器信号    |
| output    | wire     | 4    | red         | VGA信号       |
| output    | wire     | 4    | green       | VGA信号       |
| output    | wire     | 4    | blue        | VGA信号       |
| output    | wire     | 1    | hsync       | VGA信号       |
| output    | wire     | 1    | vsync       | VGA信号       |

### 项目结构

- 详见 [Schematic文件](images/schematic.pdf)

### 模块细节

#### 基本CPU模块

##### Instruction Memory



##### Data Memory



#### 流水线架构与设计

- pre_if模块，用于预测除jal指令以外下一条指令地址。遇到beq和bne时按照跳转预测。

- if_id模块，将instructiton从if传递到id

- gen_regs模块，寄存器模块，读写寄存器，将指定寄存器向外传到io中

- decode模块，decoder模块，从指令中读取出各种控制信号以及立即数等

- id_ex模块，控制信号和数据从decoder传到execute的通路

- execute模块，得到控制信号和输入后计算出alu控制信号，并集成alu进行运算

- ex_mem模块，控制信号和数据从execute传递到mem部分的通路

- mem_wb模块，控制信号和数据从mem传递到wb的通路

- forwarding模块，根据控制信号和数据判断前递什么数据并且前递数据

- hazard模块，根据控制信号和数据判断冒险类型，并且根据冒险类型判断是否进行stall，重新计算pc值或者对流水行进行冲刷

- pc_gen模块，根据hazard，pre_if模块的结果及其他控制信号和数据判断下一条指令的pc，在这个模块中预测错误的pc会被推翻

- cpu模块，集合上述模块，传递信号和数据，比如传递到instruction memory和data memory的信号和数据，比如wb部分中传到寄存器的信号和数据


#### 其他附加模块

##### VGA协议显示器显示模块

###### 模块说明

本项目中实现的VGA显示功能是：通过VGA接口，显示器可以显示当前拨码开关低8位输入的当前状态（0或1的数字显示），并且可以实时更新。

利用VGA进行显示，首先需要了解VGA的显示原理，在使用VGA时，开发板通过hsync，vsync，red，green，blue四个输入实现与显示器的信息传递。在编写实现VGA显示的代码时，要注意由于VGA显示信号传输的原理，需要确定好对应的时钟频率，同时要注意需要使用时序逻辑。

###### 模块结构

###### 引脚说明



##### 蜂鸣器音乐模块

###### 设计思路

要输出某个音符，我们需要知道它的频率，您可以在 [MixButton](https://mixbutton.com/) 获取到更多信息。 假设我们要输出中音C，查表发现它的频率是261.63Hz。 我们从 261.63Hz 计算半周期，即$191110 \times 10^{-8}$ 秒，然后我们只需在 $191110 \times 10^{-8}$ 秒后反转输出蜂鸣器。

我们将半周期编码为 period_code 以避免数据冗余。

基本思想是将音符表示为周期代码。 使用多路复用器选择由“Index”索引的当前周期代码，它表示当前正在播放哪个音符。 索引每 0.15 秒递增 1，这意味着每个音符只会持续 0.15 秒。 当选择当前周期代码时，它被翻译成实际的半周期数并让输出蜂鸣器在半周期后反转。


###### ”音符—bit串“转换脚本

```C++
#include <iostream>
using namespace std;
int main(){
    string s = "131ef0fe101ef0fe1030ef0fe1012101f30" ;
    s = s + "ef0fe101ef0fe301ef0fe1012101310";
    s = s + "1012301e1012301e10e10e010e10e04310f03";
    	
    	......
            
    string out;
    for(int i = 0; i < s.length(); i ++){
        string tmp;
        switch(s[i]){
            case ('0') : tmp = "0000"; break;
                ......
            default : tmp = "0000";
        }
        out = tmp + out;
    }
    cout << s.size() * 4 << "\'b" << out << endl << s.size();
}
```

###### 模块结构

###### 引脚说明

###### 

| 输入/输出 | 端口类型 | 位宽 | 端口名称 |
| --------- | -------- | ---- | -------- |
| input     | wire     | 1    | bgm_clk  |
| input     | wire     | 1    | enable   |
| output    | wire     | 1    | buzzer   |

##### UART串口烧录模块

###### 模块说明

UART（Universal Asynchronous Receiver Transmitter）是一种常用的串行通信协议，通常用于将数据从一个设备传输到另一个设备。在FPGA（Field Programmable Gate Array）和CPU（Central Processing Unit）中，UART通常被实现为一个模块，该模块可以接收和发送串行数据。

UART模块通常由两个主要组件组成：接收器和发射器。接收器负责从串行数据流中接收数据，并将其转换成并行数据。发射器则负责将并行数据转换成串行数据流，并将其发送到目标设备。

###### 模块结构

##### 7段数码管

###### 模块说明

在该设计中，显示模块要求能够显示8位16进制数和1位16进制样例输入，分为以下几个场景。使用时序逻辑，敏感于时钟上升沿。

1. 输入测试样例，在第5位数码管显示
2. 输入测试数据，在第0-4位数码管显示
3. 输出计算结果，在第0-4位数码管显示

在项目的硬件设计中，7段数码管与第24号寄存器绑定，在允许修改的信号位1的情况下，修改24号寄存器内的数值即可实时的更嘎7段数码管的显示结果。

###### 模块结构

###### 引脚说明

| 输入/输出 | 端口类型 | 位宽 | 端口名称    |
| --------- | -------- | ---- | ----------- |
| input     | wire     | 1    | clk, rst    |
| input     | wire     | 32   | in          |
| output    | reg      | 8    | segment_led |
| output    | reg      | 8    | seg_en      |

## 安装

1. 这个项目使用 [Vivado](https://www.xilinx.com/products/design-tools/vivado.html) 和 [Mars](http://courses.missouristate.edu/kenvollmar/mars/)。请确保您本地安装了它们。

2. 将项目克隆到本地。

```sh
git clone https://github.com/Kazawaryu/Simple_CPU_in_FPGA
```

3. 运行 **project.xpr** 文件。
4. 生成 **BitStream** 文件，并烧录到您的FPGA硬件设备。
5. 重启您的FPGA硬件设备。

## 使用说明

### 外设使用

### 按键说明

1. 开启CPU：23号开关置1，开启保险，进入main状态。
2. 输入case：修改18 - 16号开关，7段数码管会同步更新您的输入。
3. 提交case：21号开关置1，跳转到对应的case，对于不同的case，可能由不同的输入需求。
4. 输入num：修改7 - 0号开关，7段数码管会同步更新您的输入。
5. 提交num：20号开关置1，CPU执行对应汇编指令，7段数码管会显示对您输入num的处理结果。
6. 回到main：21号开关置0，推荐您同时将20号开关置0。

| 23   | 22   | 21        | 20       | 19   | 18 - 16         | 15 - 8 | 7 - 0          |
| ---- | ---- | --------- | -------- | ---- | --------------- | ------ | -------------- |
| 保险 | BGM  | Case 提交 | Num 提交 | None | 3bits Case 输入 | None   | 8bits Num 输入 |

> 如果出现了卡死状况，可能是因为您跳转到了某个模块的独立状态中，先复位21号开关后，再重拨复位20号开关可以修复该问题。

### 场景一

1. **Case 0** 输入测试数a，输入完毕后在led灯上显示a，同时用1个led灯显示a是否为二的幂的判断。
2. **Case 1** 输入测试数a，输入完毕后在输出设备上显示a，同时用1个led灯显示a是否为奇数的判断。
3. **Case 2** 先执行Case 7, 再计算 a 和 b的按位或运算，将结果显示在输出设备。
4. **Case 3** 先执行Case 7, 再计算 a 和 b的按位或非运算，将结果显示在输出设备。
5. **Case 4** 先执行Case 7, 再计算 a 和 b的按位异或运算，将结果显示在输出设备。
6. **Case 5** 先执行Case 7, 再计算 a 和 b的按位或运算，再执行 slt 指令，将a和b按照有符号数进行比较，用输出设备展示a<b的关系是否成立。
7. **Case 6** 先执行Case 7, 再计算 a 和 b的按位或运算，再执行 sltu 指令，将a和b按照无符号数进行比较，用输出设备展示a<b的关系是否成立。
8. **Case 7** 输入测试数a, 输入测试数b，在输出设备上展示a和b的值。需要提交两次输入数值。

> 以上用例全部通过上板测试

### 场景二

1. **Case 0** 输入a的数值（a被看作有符号数），计算1到a的累加和，在输出设备上显示累加和（如果a是负数，以闪烁的方式给与提示）。
2. **Case 1** 输入a的数值（a被看作无符号数），以递归的方式计算1到a的累加和，记录本次入栈和出栈次数，在输出设备上显示入栈和出栈的次数之和。
3. **Case 2** 输入a的数值（a被看作无符号数），以递归的方式计算1到a的累加和，记录入栈和出栈的数据，在输出设备上显示入栈的参数，每一个入栈的参数显示停留2-3秒。
4. **Case 3** 输入a的数值（a被看作无符号数），以递归的方式计算1到a的累加和，记录入栈和出栈的数据，在输出设备上显示出栈的参数，每一个出栈的参数显示停留2-3秒。
5. **Case 4** 输入测试数a和测试数b，实现有符号数（a，b以及相加和都是8bit，其中的最高bit被视作符号位，如果符号位为1，表示的是该负数的补码）的加法，并对是否溢出进行判断，输出运算结果以及溢出判断。
6. **Case 5** 输入测试数a和测试数b，实现有符号数（a，b以及差值都是8bit，其中的最高bit被视作符号位，如果符号位为1，表示的是该负数的补码）的减法，并对是否溢出进行判断，输出运算结果以及溢出判断。
7. **Case 6** 输入测试数a和测试数b，实现有符号数（a，b都是8bit，乘积是16bit，其中的最高bit被视作符号位，如果符号位为1，表示的是该负数的补码）的乘法，输出乘积。
8. **Case 7** 输入测试数a和测试数b，实现有符号数（a，b，商和余数都是8bit，其中的最高bit被视作符号位，如果符号位为1，表示的是该负数的补码）的除法，输出商和余数（商和余数交替显示，各持续5秒）。

> 以上用例全部通过上板测试

## Insight

- 在编写汇编代码的时候，注意区分\$3,\$s3的区别，不要忘记在需要的时候加s。
- 在测试的时候请多测试几组，特别是涉及有符号数的运算，最好每一种正负号的组合都测试一下。
- 当uart异常的时候：检查波特率是否是128000（三个零）；选择的文件数据源是否正确，是否随需求的改变重新选择文件数据源；换数据线；如果持续失败可以联系老师更换开发板
- 在开始开发的时候就要确定好reset键按下是高/低电频
- 注意在绑端口的时候，使用的端口名称对应的是开发板的手册电路图中与写在板子表示符号上面（XC7A100T FGG484C-1）的编号


## 示例

想了解我们项目如何运行和使用的的，请参考 [演示视频](www.bilibili.com/video/BV1uN4y1Q7Hj)。

## 相关仓库

- [CS202_CPU_Project](https://github.com/lkpengcs/CS202_CPU_Project/tree/master) — 💌 高质量单周期CPU
- [SUSTech-CS202_214-Computer_Organization-Project](https://github.com/2catycm/SUSTech-CS202_214-Computer_Organization-Project) — 💌 规范模板CPU

## 维护者

[@Kazawaryu](https://github.com/Kazawaryu)	[@XavierYuhanLiu](https://github.com/xavieryuhanliu)	[@houfm](https://github.com/houfm)

## 如何贡献

非常欢迎你的加入！[提一个 Issue](https://github.com/Kazawaryu/Simple_CPU_in_FPGA/issues) 或者[提交一个 Request](https://github.com/Kazawaryu/Simple_CPU_in_FPGA/pulls)。

如果您喜欢我们的项目，给我们一个⭐是对我们最大的支持。

### 贡献者

感谢以下参与项目的人：
<a href="https://github.com/Kazawaryu/FPGA-Classic-Mips-pipeline-CPU/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Kazawaryu/FPGA-Classic-Mips-pipeline-CPU" />
</a>


## 使用许可

[MIT](LICENSE) © Kazawaryu
