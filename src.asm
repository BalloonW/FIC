                LDR R0, START_ADRESS
                JMS read

                LDR R0, CNT
                OUT R0, 4
                LDR R1, START_ADRESS
                JMS append_one

                LDR R0, END_ADRESS
                LDR R1, CNT
                JMS append_length

                LDR R0, START_ADRESS
                JMS step_four

                HLT
        
START_ADRESS    DAT 200
CNT             DAT 0
END_ADRESS      DAT 232


// step one registers [H1 = Hx0 + Hx1]
H00             DAT 0
H01             DAT 0  
H10             DAT 0
H11             DAT 0
H20             DAT 0
H21             DAT 0
H30             DAT 0
H31             DAT 0



// read characters and stop when encountre -1
// put two 8 bits chars on a single register:
//              1 char on first 8 bits
//              2 char on last 8 bits

read            PSH {LR}
                MOV R2, #0 // Stores -1
                SUB R2, #1

read_l1         MOV R1, #0 // used to retain first charachter in memory on addres R0
                JMS read_char
                CMP R1, R2 // if char = -1 end function
                BEQ end_read 
                LSL R1, R1, #8
                STR R1, [R0]

                LDR R4, CNT // increase counter
                ADD R4, #1 
                STR R4, CNT

                MOV R1, #0 // used to retain second charachter
                LDR R3, [R0] // used as first char
                JMS read_char
                CMP R1, R2 // if char = -1, set second char on 0
                BEQ end_read
                ORR R3, R3, R1
                STR R3, [R0]
                ADD R0, #1
            
                LDR R4, CNT // increase counter
                ADD R4, #1 
                STR R4, CNT 

                BRA read_l1
end_read        POP {PC}

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
                ADD R5, R1, R2 // R5 - register where to put append 1
                LDR R6, [R5]
                ORR R4, R4, R6
                STR R4, [R5]
                BRA end_append_one

lsb_append_one  LSL R4, R4, #7
                ADD R5, R1, R2 // R5 - register where to put append 1
                LDR R6, [R5]
                ORR R4, R4, R6
                STR R4, [R5]
                BRA end_append_one

end_append_one  POP {PC}
                
            
append_length   PSH {LR}        
                MUL R1, #8
                STR R1, [R0]
                POP {PC}



step_four       PSH {LR}

                MOV R1, #0    // used as aux                                
                MOV R2, #0    // used as aux                                
                MOV R3, #32   // used as i
                
step_four_l1    MOV R2, #160
                CMP R3, R2      // loop until 160
                BGT end_step_four


                MOV R4, #0 // used as W1
                MOV R5, #0 // used as W2

                // find w(i-3) 
                MOV R6, #0 
                MOV R1, #6
                SUB R6, R3, R1
                ADD R6, R0
                LDR R6, [R6]

                MOV R7, #0 
                MOV R1, #5
                SUB R7, R3, R1 
                ADD R7, R0
                LDR R7, [R7]

                // mov w(i-3) in 
                MOV R4, R4
                MOV R5, R5

                // find w(i-8) 
                MOV R6, #0 
                MOV R1, #16
                SUB R6, R3, R1 
                ADD R6, R0
                LDR R6, [R6]

                MOV R7, #0 
                MOV R1, #15
                SUB R7, R3, R1 
                ADD R7, R0
                LDR R7, [R7]

                // w(i-3) or w(i - 8)
                ORR R4, R4, R6
                ORR R5, R5, R7

                // find w(i-14) 
                MOV R6, #0 
                MOV R1, #28
                SUB R6, R3, R1
                ADD R6, R0
                LDR R6, [R6]

                MOV R7, #0 
                MOV R1, #27
                SUB R7, R3, R1
                ADD R7, R0
                LDR R7, [R7]

                // w(i-3) or w(i - 8) or w(i - 14)
                ORR R4, R4, R6
                ORR R5, R5, R7

                // find w(i-16) 
                MOV R6, #0 
                MOV R1, #32
                SUB R6, R3, R1
                ADD R6, R0
                LDR R6, [R6]

                MOV R7, #0 
                MOV R1, #31
                SUB R7, R3, R1
                ADD R7, R0
                LDR R7, [R7]

                // w(i-3) or w(i - 8) or w(i - 14) or w(i-15)
                ORR R4, R4, R6
                ORR R5, R5, R7


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
                STR R4, [R2]
                ADD R3, #1

                ADD R2, R0, R3
                STR R5, [R2]
                ADD R3, #1                

                BRA step_four_l1

end_step_four   POP {PC}                