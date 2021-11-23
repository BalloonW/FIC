main    JMS input
input   PSH {LR}
        INP R0, 2 // lungimea
        LDR R2, ADDRESS 
L1      CMP R0, #0 
        BEQ END 
        INP R1, 2  // caractere
        SUB R0, #1
        BRA PERFORM
CONT    STR R1, [R2] 
        INP R1, 2
        SUB R0, #1
        BRA PERFORM_1
CONT_1  ADD R2, #1 
        BRA L1
PERFORM LSL R1, R1, #8
        BRA CONT
PERFORM_1 LDR R3, [R2]
        XOR R1, R1, R3
        STR R1, [R2]
        BRA CONT_1
END     RET
        POP {PC}
ADDRESS DAT 140