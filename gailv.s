.data
Prompt:     .asciiz     "input An integer which is array's size value >=0 : "
PromptLast:   .asciiz       "input an integer :"
PromptNum:    .asciiz      "input an integer>=0 which you need:"
PrintfFormat:   .asciiz     "Probability: %g "
PromptError:    .asciiz     "Error!Need int>=0!Input:(Go:0,End:other number)"
.align   2
PrintfPar:  .word    PrintfFormat
Printf:      .space       8
PrintfValue:    .space   1024

.text
.global main

main:
                ;*** 输入数组大小和相关初始化
                addi                 r1,r0,Prompt     ;将Prompt字符串首地址放入r1寄存器中
                jal                  InputUnsigned    ;跳转子函数，输入数组大小n
                bnez                 r10,Error
                beqz                 r1,InputNum
                add                  r2,r0,r1         ;将数组大小n存于r2
                add                  r6,r0,r1         ;将数组大小n存于r6
                addi                 r3,r0,0          ;初始化r3
                addi                 r7,r0,1          ;r7等于1
                movi2fp              f1,r7            ;f1等于1
                addf                 f2,f2,f0         ;初始化f2,f3,f4
                addf                 f3,f3,f0
                addf                 f4,f4,f0
                movi2fp              f5,r1            ;将数组大小n存于f5
                            

InputArray:
                ;*** 输入数组
                beqz                 r2, ProcessPart      ;如果r2等于0则跳转ProcessPart 
                addi                 r1,r0,PromptLast     ;输入数字
                jal                  InputUnsigned
                bnez                 r10,Error
                sw                   PrintfValue(r3),r1   ;将r1寄存器中的数放入r3寄存区中所存数地址的存储器中
                addi                 r3,r3,4              ;r3后移
                subi                 r2,r2,1              ;r2减1
                j                    InputArray           ;循环输入
                          
                          
ProcessPart:
                addi                 r3,r0,0              ;初始化r3

InputNum:
                ;*** 输入求概率的数字 
                addi                 r1,r0,PromptNum
                jal                  InputUnsigned
                bnez                 r10,Error
                add                  r2,r0,r1             ;保存i到r2
                movi2fp              f2,r2                ;保存i到f2

Loop:
                ;*** 循环与计数       
                beqz                 r6,Output            ;如果r6等于0则结束Loop跳转Output
                subi                 r6,r6,1              ;r6减1
                lf                   f3,PrintfValue(r3)   ;取出r3地址中的数到f3
                addi                 r3,r3,4              ;r3后移

                movfp2i              r7,f2                
                movfp2i              r8,f3
                seq                  r12,r7,r8            ;如果r7等于r8,r12为1，否则为0 
                bnez                 r12,Sum              ;r12为不等于0,则跳转到Sum计数，否则继续循环
                j                    Loop                 ;循环

Sum:
                addf                 f4,f4,f1             ;计数
                j                    Loop
Output:
                cvti2d               f0,f4                ;单精度转换为双精度
                cvti2d               f6,f5
                movfp2i              r5,f5
                beqz                 r5,OutputInner       ;分母为0
                divd                 f6,f0,f6             ;f6=f0/f6
OutputInner:
                sd                   Printf,f6
                addi                 r14,r0,PrintfPar     
                trap                 5                    ;标准输出
                trap                 0                    ;程序结束

Error:
                addi                 r1,r0,PromptError
                jal                  InputUnsigned
                beqz                 r1,main
                trap                 0