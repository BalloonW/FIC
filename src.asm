                LDR R0, START_ADRESS
                JMS read
                HLT
            
    START_ADRESS    DAT 140


    // read characters and stop when encountre -1
    // put two 8 bits chars on a single register:
    //              1 char on first 8 bits
    //              2 char on last 8 bits

    read        PSH {LR}
                MOV R2, #0 // Stores -1
                SUB R2, #1

    read_l1     MOV R1, #0 // used to retain first charachter in memory on addres R0
                JMS read_char
                CMP R1, R2 // if char = -1 end function
                BEQ end_read 
                LSL R1, R1, #8
                STR R1, [R0] 

                MOV R1, #0 // used to retain second charachter
                LDR R3, [R0] // used as first char
                JMS read_char
                CMP R1, R2 // if char = -1, set second char on 0
                BEQ end_read
                ORR R3, R3, R1
                STR R3, [R0]
                ADD R0, #1
                BRA read_l1 
    end_read    POP {PC}

    read_char   PSH {LR}

                MOV R5, #0 // stores -1
                SUB R5, #1
                MOV R4, #255 // stores 255
                
    l1_input    INP R1, 2 // input charachter 
                CMP R1, R5 // if number < -1 continue
                BLT l1_input
                CMP R1, R4 // if number > 255 continue
                BGT l1_input
                POP {PC}
