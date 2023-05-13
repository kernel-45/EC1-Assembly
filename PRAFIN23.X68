*-----------------------------------------------------------
* Title      : PRAFIN23
* Written by : Iker García de León Seui y Adrián Morales Orta
* Date       : 19/05/2023
* Description: Emulador de la HAL9000
*-----------------------------------------------------------
    ORG $1000
EMEM:   DC.W $E082,$E09B,$E0B4,$E01D,$2020,$C006,$2031,$C017,$F160
        DC.W $F170,$CE70,$3040,$EFFD,$501E,$4008,$8000,$0001
        DC.W $0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000
EIR:    DC.W 0 ;eregistro de instruccion
EPC:    DC.W 0 ;econtador de programa
ET0:    DC.W 0 ;eregistro T0
ET1:    DC.W 0 ;eregistro T1
EX2:    DC.W 0 ;eregistro X2
EX3:    DC.W 0 ;eregistro X3
EX4:    DC.W 0 ;eregistro X4
EX5:    DC.W 0 ;eregistro X5
EX6:    DC.W 0 ;eregistro X6
EX7:    DC.W 0 ;eregistro X7
ESR:    DC.W 0 ;eregistro de estado (00000000 00000CNZ)

START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	        ; ESCRIBID VUESTRO CODIGO AQUI	    
    LEA.L EMEM,A0
    MOVE.W EPC,D0
    ADD.W D0,D0
    MOVE.W 0(A0,D0),EIR
    ADDQ.W #1,EPC
    
     
    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    	    ; ESCRIBID VUESTRO CODIGO AQUI    	    
    
    SUBQ.W #2,(SP)
    MOVE.W EIR,-(SP)
    
    JSR DECOD
    
    MOVE.W (SP)+,EIR
    MOVE.W (SP)+,D1
    
    
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ELOA
    JMP ESTO
    JMP ELOIP
    JMP ESTIP
    JMP EGOI
    JMP EGOZ
    JMP EGON
    JMP EEXIT
    JMP ECOPY
    JMP EADD
    JMP ESUB
    JMP EAND
    JMP ESET
    JMP EADQ
    JMP ELSH
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
ELOA:
ESTO:
ELOIP:
ESTIP:
EGOI:
EGOZ:
EGON:
EEXIT:
ECOPY:
EADD:
ESUB:
EAND:
ESET:
EADQ:
ELSH:
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI
    
    
    
    
    
    
    
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	        ; ESCRIBID VUESTRO CODIGO AQUI
	        
	MOVE.W D0,-(SP)
	MOVE.W 6(SP),D0
    
    MOVE.W #EMEM,D0
    BTST.L #15,D0
    BEQ EMPIEZA_0
    
    BTST.L #14,D0
    BEQ EMPIEZA_10
    
    BTST.L #13,D0
    BEQ EMPIEZA_110
    
    BTST.L #12,D0
    BEQ EMPIEZA_1110
    MOVE.W #14, 8(SP)    ;11110:LSH
    
    
EMPIEZA_1110:
    BTST.L #11,D0
    BEQ EMPIEZA_11100
    MOVE.W #13, 8(SP)    ;11101:ADQ
    
EMPIEZA_11100:
    MOVE.W #12, 8(SP)    ;11100:SET
    
EMPIEZA_110:
    BTST.L #12,D0
    BEQ EMPIEZA_1100
    
    BTST.L #11,D0
    BEQ EMPIEZA_11010
    MOVE.W #11, 8(SP)    ;11011:AND
    
EMPIEZA_11010:
    MOVE.W #10, 8(SP)    ;11010:SUB
    
EMPIEZA_1100:
    BTST.L #11,D0
    BEQ EMPIEZA_11000
    MOVE.W #9, 8(SP)    ;11001:ADD
    
EMPIEZA_11000:
    MOVE.W #8, 8(SP)    ;11000:COPY   
    
EMPIEZA_10:
    MOVE.W #7, 8(SP)    ;10:EXIT
    
EMPIEZA_0:
    BTST.L #14,D0
    BEQ EMPIEZA_00
    
    BTST.L #13,D0
    BEQ EMPIEZA_010
    MOVE.W #6, 8(SP)    ;0110:GON
    
EMPIEZA_010:
    BTST #12,D0
    BEQ EMPIEZA_0100
    MOVE.W #5, 8(SP)    ;0101:GOZ
    
EMPIEZA_0100:
    MOVE.W #4, 8(SP)    ;0100:GOI
    
EMPIEZA_00:
    BTST.L #13,D0
    BEQ EMPIEZA_000
    
    BTST.L #12,D0
    BEQ EMPIEZA_0010
    MOVE.W #3, 8(SP)    ;0011:STIP
    
EMPIEZA_0010:
    MOVE.W #2,8(SP)     ;0010:LOIP  
    
EMPIEZA_000:
    BTST.L #12,D0
    BEQ EMPIEZA_0000
    MOVE.W #1, 8(SP)    ;0001:STO
    
EMPIEZA_0000: 
    MOVE.W #0, 8(SP)    ;0000:LOA  
    
RESULTADO:
    MOVE.W (SP)+,D0
    RTS
    
    ;--- FDECOD: FIN DECOD
    END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
