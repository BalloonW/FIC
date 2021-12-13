                JMS calcualte_f
                LDR R0, START_ADRESS 
                JMS read
                LDR R0, CNT
                LDR R1, START_ADRESS 
                JMS append_one
                MOV R0, #82 //end_addres
                LDR R1, CNT
                JMS append_length
                JMS put_zero
                LDR R0, START_ADRESS 
                JMS step_four
                LDR R0, START_ADRESS 
                JMS step_six 
                JMS step_seven
                HLT

CNT             DAT 0
START_ADRESS    DAT 54
AUX1            DAT 0
AUX2            DAT 0

// step one registers [H1 = Hx0 + Hx1]
H00             DAT 26590
H01             DAT 10753 
H10             DAT 47875
H11             DAT 54996
H20             DAT 286
H21             DAT 61916
H30             DAT 52719
H31             DAT 9129
H40             DAT 37523
H41             DAT 59874

// step five copy registers H to ABCD
A00             DAT 26590
A01             DAT 10753 
B00             DAT 47875
B01             DAT 54996   
C00             DAT 286
C01             DAT 61916
D00             DAT 52719
D01             DAT 9129
E00             DAT 37523
E01             DAT 59874

// K values 
K10             DAT 23170
K11             DAT 31129
K20             DAT 28377
K21             DAT 60321
K30             DAT 36635
K31             DAT 48348
K40             DAT 51810
K41             DAT 49622

F00             DAT 0
F01             DAT 0
F10             DAT 0
F11             DAT 0
F20             DAT 0
F21             DAT 0

BLANK00             DAT 0
BLANK01             DAT 0
BLANK02             DAT 0
BLANK03             DAT 0
BLANK04             DAT 0
BLANK05             DAT 0
BLANK06             DAT 0
BLANK07             DAT 0
BLANK08             DAT 0
BLANK09             DAT 0
BLANK10             DAT 0
BLANK11             DAT 0
BLANK12             DAT 0
BLANK13             DAT 0
BLANK14             DAT 0
BLANK15             DAT 0
BLANK16             DAT 0
BLANK17             DAT 0
BLANK18             DAT 0
BLANK19             DAT 0
BLANK20             DAT 0
BLANK21             DAT 0
BLANK22             DAT 0
BLANK23             DAT 0
BLANK24             DAT 0
BLANK25             DAT 0
BLANK26             DAT 0
BLANK27             DAT 0
BLANK28             DAT 0
BLANK29             DAT 0
BLANK30             DAT 0
BLANK31             DAT 0
BLANK32             DAT 0
BLANK33             DAT 0
BLANK34             DAT 0
BLANK35             DAT 0
BLANK36             DAT 0
BLANK37             DAT 0
BLANK38             DAT 0



calcualte_f     PSH {LR}

                // B xor C xor D
                // result in R4, R5 
F_FIRST         LDR R4, B00
                LDR R5, C00
                XOR R4, R4, R5 // B xor C (first step, save in R4)
                LDR R2, B01
                LDR R5, C01
                XOR R5, R5, R2 // B xor C (second step, save in R5)
                LDR R2, D00
                XOR R4, R4, R2 // xor D (first step)
                LDR R2, D01
                XOR R5, R5, R2 // xor D (second step)
                STR R4, F00
                STR R5, F01
                

                // (B and C) or (B and D) or (C and D)
                // result in R4, R5
F_SECOND        LDR R4, B00
                LDR R2, C00
                AND R4, R4, R2 // save in R4
                LDR R5, B01
                LDR R2, C01
                AND R5, R5, R2 // save in R5
                STR R4, AUX1
                STR R5, AUX2
                LDR R4, B00
                LDR R2, D00
                AND R4, R4, R2
                LDR R5, B01
                LDR R2, D01
                AND R5, R5, R2
                LDR R2, AUX1
                ORR R4, R4, R2
                LDR R2, AUX2
                ORR R5, R5, R2
                STR R4, AUX1
                STR R5, AUX2
                LDR R4, C00
                LDR R2, D00
                AND R4, R4, R2 // save in R4
                LDR R5, C01
                LDR R2, D01
                AND R5, R5, R2
                LDR R2, AUX1
                ORR R4, R4, R2
                LDR R2, AUX2
                ORR R5, R5, R2
                STR R4, F10
                STR R5, F11
                

                // (B ∧ C)∨((¬B)∧D)
                // result in R4, R5
F_THIRD         LDR R4, B00
                LDR R2, C00
                ORR R4, R4, R2 // save in R4
                LDR R5, B01
                LDR R2, C01
                ORR R5, R5, R2 // save in R5
                STR R4, AUX1
                STR R5, AUX2
                LDR R4, B00
                LDR R2, D00
                // implement not B 
                MOV R0, #0 
                SUB R4, R0, R4
                // continue
                ORR R4, R4, R2
                LDR R5, B01
                LDR R2, D01
                SUB R5, R0, R5
                ORR R5, R5, R2
                LDR R2, AUX1
                AND R4, R4, R2
                LDR R2, AUX2
                AND R5, R5, R2
                STR R4, F20
                STR R5, F21

end_calc_f      POP {PC}


// read characters and stop when encountre -1
// put two 8 bits chars on a single register:
// 1 char on first 8 bits
// 2 char on last 8 bits
read            PSH {LR}
                MOV R2, #0 // Stores -1
                SUB R2, #1
                MOV R6, #0 // Used as counter
read_l1         MOV R1, #0 // used to retain first charachter in memory on addres R0
                JMS read_char
                CMP R1, R2 // if char = -1 end function
                BEQ end_read 
                LSL R1, R1, #8
                STR R1, [R0]
                ADD R6, #1 
                MOV R1, #0 // used to retain second charachter
                LDR R3, [R0] // used as first char
                JMS read_char
                CMP R1, R2 // if char = -1, set second char on 0
                BEQ end_read
                ORR R3, R3, R1
                STR R3, [R0]
                ADD R0, #1 
                ADD R6, #1 
                BRA read_l1
end_read        STR R6, CNT
                POP {PC}
        
read_char       PSH {LR}
                MOV R5, #0 // stores -1
                SUB R5, #1
                MOV R4, #255 // stores 255
l1_input        INP R1, 2 // input charachter 
                CMP R1, R5 // if number < -1 continue
                BLT l1_input
                CMP R1, R4 // if number > 255 continue
                BGT l1_input
                POP {PC}

append_one      PSH {LR}
                MOV R2, R0
                UDV R2, #2
                MOV R3, R0
                MOD R3, #2 
                MOV R4, #1 // stores one
                CMP R3, #0
                BEQ msb_append_one
                BRA lsb_append_one
msb_append_one  LSL R4, R4, #15 
                BRA cont_append
lsb_append_one  LSL R4, R4, #7
cont_append     ADD R5, R1, R2 // R5 - register where to append 1
                LDR R6, [R5]
                ORR R4, R4, R6
                STR R4, [R5]
end_append_one  POP {PC}

append_length   PSH {LR} 
                MUL R1, #8
                STR R1, [R0]
                POP {PC}

step_four       PSH {LR}
                MOV R3, #32 

step_four_l1    MOV R2, #160
                CMP R3, R2 // loop until 160
                BGT end_step_four

                // calculate w(i-3) xor w(i-8)  xor w(i-14) xor w(i-16) 
                // for W1
                JMS stp4_heplper
                MOV R7, R4

                // calculate w(i-3) xor w(i-8)  xor w(i-14) xor w(i-16) 
                // for W2
                ADD R3, #1 
                JMS stp4_heplper
                
                MOV R5, R4
                MOV R4, R7

                // implement rotation
                LSL R1, R4, #1
                LSL R2, R5, #1
                LSR R6, R4, #15
                LSR R7, R5, #15
                // do not swap R1 with R2
                ORR R4, R2, R6
                ORR R5, R1, R7

                // store result on position start_adress + i
                ADD R2, R0, R3
                SUB R2, #1
                STR R4, [R2]                
                ADD R2, R0, R3
                STR R5, [R2]
                ADD R3, #1 
                BRA step_four_l1

end_step_four   POP {PC} 

                
stp4_heplper    PSH {LR}
                MOV R4, #0 // used as half W
                // find w(i-3) 
                MOV R1, #6
                SUB R6, R3, R1
                ADD R6, R0
                LDR R6, [R6]
                // mov w(i-3) in R4
                MOV R4, R6
                // find w(i-8) 
                MOV R1, #16
                SUB R6, R3, R1 
                ADD R6, R0
                LDR R6, [R6]
                // w(i-3) or w(i - 8)
                XOR R4, R4, R6
                // find w(i-14) 
                MOV R1, #28
                SUB R6, R3, R1
                ADD R6, R0
                LDR R6, [R6]
                // w(i-3) or w(i - 8) or w(i - 14)
                XOR R4, R4, R6
                // find w(i-16) 
                MOV R1, #32
                SUB R6, R3, R1
                ADD R6, R0
                LDR R6, [R6]
                // w(i-3) or w(i - 8) or w(i - 14) or w(i-15)
                XOR R4, R4, R6
                POP {PC}



step_six        PSH {LR}
                MOV R3, #0 // used as i
step_six_l      MOV R2, #160 // loop until 160
                CMP R3, R2
                BGT end_step_six
                
                // gasim f de care avem nevoie
                MOV R6, #19 
                CMP R3, R6 
                BGT s_f1
                MOV R6, #39
                CMP R3, R6
                BGT s_f2 // se calculeaza dupa a doua implementare
                MOV R6, #59
                CMP R3, R6
                BGT s_f1
                LDR R4, F20
                LDR R5, F21
                BRA switch_cont

s_f1            LDR R4, F00
                LDR R5, F01
                BRA switch_cont
s_f2            LDR R4, F10
                LDR R5, F11
                BRA switch_cont

                // adaguam E
switch_cont     LDR R1, E00
                LDR R2, E01
                ADD R5, R5, R2 
                ADC R4, R1 // adaugam cu carry 
                // adaugam W(i)
                LDR R1, [R3] // incarcam prima parte de w(i)
                ADD R3, #1 // incrementam 
                LDR R2, [R3] // incarcam a doua parte 
                ADD R3, #1 // incrementare finala 
                ADD R5, R5, R2
                ADC R4, R1 
                // adaugam K(i)
                MOV R6, #19 
                CMP R3, R6 
                BGT ADD_K2 // se calculeaza dupa prima implementare 
                MOV R6, #39
                CMP R3, R6
                BGT ADD_K3 // se calculeaza dupa a doua implementare
                MOV R6, #59
                CMP R3, R6
                BGT ADD_K4
                BRA ADD_K1 // se calculeaza dupa a treia implementare
SUMA_CONT       ADD R5, R5, R2
                ADC R4, R1
                // adaugam S^5(A)
                // trebuie sa ma mai gandesc la acest pas, pentru ca nu pare a fi corect 
                LSL R1, R4, #5 
                LSL R2, R5, #5
                LSR R6, R4, #11
                LSR R7, R5, #11
                // do not swap R1 with R2
                ORR R2, R2, R6
                ORR R1, R1, R7
                ADD R5, R5, R2 
                ADC R4, R1
                // reassign the values 
                LDR R1, D00
                LDR R2, D01
                STR R1, E00
                STR R2, E01
                LDR R1, C00
                LDR R2, C01
                STR R1, D00
                STR R2, D01
                LDR R1, A00
                LDR R2, A01
                STR R1, B00
                STR R2, B01
                STR R4, A00
                STR R5, A01 
                BRA step_six_l 
ADD_K1          LDR R1, K10
                LDR R2, K11
                BRA SUMA_CONT
ADD_K2          LDR R1, K20
                LDR R2, K21
                BRA SUMA_CONT
ADD_K3          LDR R1, K30
                LDR R2, K31
                BRA SUMA_CONT
ADD_K4          LDR R1, K40
                LDR R2, K41
                BRA SUMA_CONT
end_step_six    POP {PC}


step_seven      PSH {LR}
                LDR R1, H00
                LDR R2, H01
                LDR R3, A00
                LDR R4, A01
                ADD R4, R4, R2
                ADC R3, R1

                OUT R4, 6
                OUT R3, 6

                LDR R1, H10
                LDR R2, H11
                LDR R3, B00
                LDR R4, B01
                ADD R4, R4, R2
                ADC R3, R1

                
                OUT R4, 6
                OUT R3, 6

                LDR R1, H20
                LDR R2, H21
                LDR R3, C00
                LDR R4, C01
                ADD R4, R4, R2
                ADC R3, R1

                OUT R4, 6
                OUT R3, 6

                LDR R1, H30
                LDR R2, H31
                LDR R3, D00
                LDR R4, D01
                ADD R4, R4, R2
                ADC R3, R1

                OUT R4, 6
                OUT R3, 6

                LDR R1, H40
                LDR R2, H41
                LDR R3, E00
                LDR R4, E01
                ADD R4, R4, R2
                ADC R3, R1

                OUT R4, 6
                OUT R3, 6
end_step_seven  POP {PC}

put_zero        PSH {LR}   
                LDR R0, START_ADRESS
                ADD R0, CNT                
                MOV R1, #214
                MOV R2, #0
put_zero_l      CMP R0, R1
                BGT end_put_zero            
                STR R2, [R0]
                ADD R0, #1
                BRA put_zero_l
end_put_zero    POP {PC}




