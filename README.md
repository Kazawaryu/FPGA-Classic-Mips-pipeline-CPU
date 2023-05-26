# Verilog Classic Mips pipeline CPU

[![vivado version](https://img.shields.io/badge/Vivado%20version-2017.4-brightgreen?style=flat-square)](https://img.shields.io/badge/Vivado%20version-2017.4-brightgreen?style=flat-square) [![mars version](https://img.shields.io/badge/Mars%20version-4.5-orange?style=flat-square)](https://img.shields.io/badge/Mars%20version-4.5-orange?style=flat-square) [![mars version](https://img.shields.io/badge/Code%20version-1.1-blue?style=flat-square)](https://img.shields.io/badge/Code%20version-1.1-blue?style=flat-square)

## 目录

- [项目介绍](#项目介绍)
- [安装](#安装)
- [使用说明](#使用说明)
- [示例](#示例)
- [相关仓库](#相关仓库)
- [维护者](#维护者)
- [如何贡献](#如何贡献)
- [使用许可](#使用许可)

## 项目介绍

本项目是一个 **Classic Mips pipeline CPU**，由 Verilog 语言编写，Mips 汇编实现场景测试。

- 架构：基于冯·诺依曼体系设计的单周期cpu（CPI = 1），采用经典5级流水线，内置32个寄存器，位宽为32bits。

- 外设：通过LED灯、七段数码显示管、VGA协议显示进行数据可视化，寻址单位为1byte。使用蜂鸣器，可以播放内置的电子音乐。

- 指令：支持的指令集为Minisys-1 ISA，采用UART串口烧录实现辅助用户测试。

### 项目架构





### 模块细节

#### 流水线架构与设计







#### 其他附加模块

##### VGA协议显示器显示模块



##### 蜂鸣器音乐模块

###### 设计思路

要输出某个音符，我们需要知道它的频率，您可以在 [MixButton](https://mixbutton.com/) 获取到更多信息。 假设我们要输出中音C，查表发现它的频率是261.63Hz。 我们从 261.63Hz 计算半周期，即 $191110 * 10^{-8}$ 秒，然后我们只需在 $191110 * 10^{-8}$ 秒后反转输出蜂鸣器。

我们将半周期编码为 period_code 以避免数据冗余。

基本思想是将音符表示为周期代码。 使用多路复用器选择由“Index”索引的当前周期代码，它表示当前正在播放哪个音符。 索引每 0.15 秒递增 1，这意味着每个音符只会持续 0.15 秒。 当选择当前周期代码时，它被翻译成实际的半周期数并让输出蜂鸣器在半周期后反转。

![buzzer.png](images/buzzer.png)

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



##### UART串口烧录模块



##### 7段数码管





## 安装

1. 这个项目使用 [Vivado](https://www.xilinx.com/products/design-tools/vivado.html) 和 [Mars](http://courses.missouristate.edu/kenvollmar/mars/)。请确保你本地安装了它们。

2. 将项目克隆到本地。

```sh
git clone https://github.com/Kazawaryu/Simple_CPU_in_FPGA
```

3. 运行 **project.xpr** 文件。
4. 生成 **BitStream** 文件，并烧录到您的FPGA硬件设备。
5. 重启您的FPGA硬件设备。

## 使用说明

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

### 场景一

1. **Case 0** 输入测试数a，输入完毕后在led灯上显示a，同时用1个led灯显示a是否为二的幂的判断。
2. **Case 1** 输入测试数a，输入完毕后在输出设备上显示a，同时用1个led灯显示a是否为奇数的判断。
3. **Case 2** 先执行Case 7, 再计算 a 和 b的按位或运算，将结果显示在输出设备。
4. **Case 3** 先执行Case 7, 再计算 a 和 b的按位或非运算，将结果显示在输出设备。
5. **Case 4** 先执行Case 7, 再计算 a 和 b的按位异或运算，将结果显示在输出设备。
6. **Case 5** 先执行Case 7, 再计算 a 和 b的按位或运算，再执行 slt 指令，将a和b按照有符号数进行比较，用输出设备展示a<b的关系是否成立。
7. **Case 6** 先执行Case 7, 再计算 a 和 b的按位或运算，再执行 sltu 指令，将a和b按照无符号数进行比较，用输出设备展示a<b的关系是否成立。
8. **Case 7** 输入测试数a, 输入测试数b，在输出设备上展示a和b的值。需要提交两次输入数值。

### 场景二

1. **Case 0** 输入a的数值（a被看作有符号数），计算1到a的累加和，在输出设备上显示累加和（如果a是负数，以闪烁的方式给与提示）。
2. **Case 1** 输入a的数值（a被看作无符号数），以递归的方式计算1到a的累加和，记录本次入栈和出栈次数，在输出设备上显示入栈和出栈的次数之和。
3. **Case 2** 输入a的数值（a被看作无符号数），以递归的方式计算1到a的累加和，记录入栈和出栈的数据，在输出设备上显示入栈的参数，每一个入栈的参数显示停留2-3秒。
4. **Case 3** 输入a的数值（a被看作无符号数），以递归的方式计算1到a的累加和，记录入栈和出栈的数据，在输出设备上显示出栈的参数，每一个出栈的参数显示停留2-3秒。
5. **Case 4** 输入测试数a和测试数b，实现有符号数（a，b以及相加和都是8bit，其中的最高bit被视作符号位，如果符号位为1，表示的是该负数的补码）的加法，并对是否溢出进行判断，输出运算结果以及溢出判断。
6. **Case 5** 输入测试数a和测试数b，实现有符号数（a，b以及差值都是8bit，其中的最高bit被视作符号位，如果符号位为1，表示的是该负数的补码）的减法，并对是否溢出进行判断，输出运算结果以及溢出判断。
7. **Case 6** 输入测试数a和测试数b，实现有符号数（a，b都是8bit，乘积是16bit，其中的最高bit被视作符号位，如果符号位为1，表示的是该负数的补码）的乘法，输出乘积。
8. **Case 7** 输入测试数a和测试数b，实现有符号数（a，b，商和余数都是8bit，其中的最高bit被视作符号位，如果符号位为1，表示的是该负数的补码）的除法，输出商和余数（商和余数交替显示，各持续5秒）。

## 示例

想了解我们项目如何运行和使用的的，请参考 [演示视频](www.google.com)。

## 相关仓库

- [CS202_CPU_Project](https://github.com/lkpengcs/CS202_CPU_Project/tree/master) — 💌 高质量单周期CPU
- [SUSTech-CS202_214-Computer_Organization-Project](https://github.com/2catycm/SUSTech-CS202_214-Computer_Organization-Project) — 💌 规范模板CPU

## 维护者

[@Kazawaryu](https://github.com/Kazawaryu)	[@酷酷的阿涵](https://github.com/xzzxy0413)	[@houfm](https://github.com/houfm)

## 如何贡献

非常欢迎你的加入！[提一个 Issue](https://github.com/Kazawaryu/Simple_CPU_in_FPGA/issues) 或者[提交一个 Request](https://github.com/Kazawaryu/Simple_CPU_in_FPGA/pulls)。

如果您喜欢我们的项目，给我们一个⭐是对我们最大的支持。

### 贡献者

感谢以下参与项目的人：
<a href="https://github.com/Kazawaryu/Simple_CPU_in_FPGA/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Kazawaryu/Simple_CPU_in_FPGA" />
</a>

## 使用许可

[MIT](LICENSE) © Kazawaryu

