*-----------------------------------------------------------
* Title      : PRAFIN23
* Written by : <nombres completos de los autores>
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
	
	LEA EMEM, A0 ;CARGAMOS LA DIRECCI�N DEL VECTOR DE INSTRUCCIONES EN A0
	MOVE.W EPC(A0), EIR	    
        
    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    	   JSR DECOD   	    
        
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
	MOVE.W D0, -(A7) ;MOVEMOS D0 A LA PILA PARA NO PERDER SU CONTENIDO
	MOVE.W EIR, D0	 ;PONEMOS LA INSTRUCCIÓN EN D0
	BTST #15, D0	 ;MIRAMOS EL BIT MÁS SIGNIFICATIVO
	BEQ Z			 ;SALTA A Z SI EL BIT MÁS SIGNIFICATIVO ERA UN CERO
	BTST #14, D0	 ;SI ERA UN 1 SIGUE AQUÍ
	BEQ OZ			 ;10
	BTST #13, D0	 ;11
	BEQ OOZ			 ;110
	BTST #12, D0	 ;111
	BEQ OOOZ		 ;1110
	BTST #11, D0     ;1111
	BEQ OOOOZ		 ;11110
	
OZ: 				 ;10, ES UN EXIT

OOZ: 				 ;110
	BTST #12, D0
	BEQ OOZZ		 
					 ;1101
	BTST #11, D0
	BEQ OOZOZ
					 ;11011, ES UN AND
	
OOZOZ: 				 ;11010, ES UN SUB

OOOZ: 				 ;1110
	BTST #11, D0
	BEQ OOOZZ
					 ;11101, ES UN ADQ
					 
OOOZZ: 				 ;11100, ES UN SET

OOOOZ:				 ;11110, ES UN LSH 

OOZZ: 	
	BTST #11, D0
	BEQ OOZZZ		 
					 ;11001, ES UN ADD
OOZZZ: 				 ;11000, ES UN COPY

					
Z: 					 ;SI ESTÁ AQUÍ EL BIT MÁS SIGNIFICATIVO ES 0
	BTST #14, D0
	BEQ ZZ			 
					 ;01
	BTST #13, D0	 
	BEQ ZOZ			 
					 ;011
	BTST #12, D0
	BEQ ZOOZ		 
					 ;NADA
ZOZ: 			 	 ;010
	BTST #12, D0
	BEQ Z0ZZ		 
					 ;0101, ES UN GOZ
					 
Z00Z: 				 ;0110, ES UN GON

ZOZZ: 				 ;0100, ES UN GOI

ZZ: 				 ;00
	BTST #13, D0
	BEQ ZZZ			 ;000
	BTST #12, D0	 ;001
	BEQ ZZOZ		 ;0010
ZZ0Z: 				 ;0010, ES UN LOIP
					 ;0011, ES UN STIP
ZZZ: 				 ;000
	BTST #12, D0
	BEQ ZZZZ		 ;0000
					 ;0001, ES UN STO
ZZZZ: 				 ;0000, ES UN LOA
	        ; ESCRIBID VUESTRO CODIGO AQUI

    ;--- FDECOD: FIN DECOD
    END    START


