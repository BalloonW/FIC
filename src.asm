                LDR R0, START_ADRESS
                JMS read

                LDR R0, CNT
                OUT R0, 4
                LDR R1, START_ADRESS
                JMS append_one
                HLT
        
START_ADRESS    DAT 140
CNT             DAT 0


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
                