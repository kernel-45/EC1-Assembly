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

	LEA EMEM, A0 ;CARGAMOS LA DIRECCIÓN DEL VECTOR DE INSTRUCCIONES EN A0
	MOVE.W EPC, A1
	ADDQ.W #1, EPC
	ADDA.W A1, A0
	ADDA.W A1, A0
	MOVE.W (A0), EIR	    
    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1
		   SUB.W #2, A7 ;RESERVAMOS ESPACIO EN LA PILA PARA EL VALOR QUE IRÁ EN D1
		   MOVE.W EIR,-(A7)
    	   JSR DECOD ;SALTAMOS A LA SUBRUTINA QUE NOS INDICARÁ EL TIPO DE INSTRUCCIÓN DE LA QUE SE TRATA
    	   MOVE.W (A7)+, EIR
           MOVE.W (A7)+, D1 ;PONEMOS EL ID DE LA INSTRUCCION EN D1
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
    JSR OBTENERM ; M ESTA EN D5
    JSR DECODI ; Ti ESTA EN D4
    MOVE.W (D5),-(A7) ; GUARDA EL VALOR DE M EN Ti
    JSR ALMACENARTi
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ESTO:
    JSR DECODI
    JSR OBTENERI ; EL VALOR DE Ti ESTA EN D4
    JSR OBTENERM ; M ESTA EN D5
    MOVE.W D4,(D5) ; GUARDA EL VALOR DE Ti EN M
    JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ELOIP:
	;ESTA INSTRUCCIÓN NOS DEJARÁ EN D4 EL BIT DE I
	JSR DECODI
	;ESTA INSTRUCCION NOS DEJARA EN D2 EL BIT DE B
	JSR DECODB
	MOVE.W D2,D0 ; GUARDAMOS EL NUMERO DE REGISTRO PARA DESPUES
	;ESTA INSTRUCCION DEJARÁ EN D2 EL VALOR DEL REGISTRO b
	JSR OBTENERB
	;ESTA INSTRUCCIÓN ALMACENARÁ EN Ti EL VALOR DEL REGISTRO
	MOVE.W D2, -(A7) 
	JSR ALMACENARTi
	
	ADDQ.W #1,D2 ;ACTUALIZA B AUMENTANDO SU VALOR EN 1
	MOVE.W D0,-(A7)
	MOVE.W D2,-(A7)
	JSR ALMACENARENREGISTRO 
	JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ESTIP:
    JSR DECODI
    JSR OBTENERI ; EL VALOR DE Ti ESTA EN D4
    JSR DECODB
    MOVE.W D2,-(A7)
    MOVE.W D4,-(A7)
    JSR ALMACENARENREGISTRO
    JMP FETCH
    
    MOVE.W D2,-(A7) ; INTRODUCIMOS EL NUMERO DE REGISTRO
    JSR OBTENERB
    ADDQ.W #1,D2
    MOVE.W D2,-(A7) ; ACTUALIZA B AUMENTANDO SU VALOR EN 1
	JSR ALMACENARENREGISTRO 
	JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EGOI:
	;ESTA INSTRUCCION DEJA m EN D5
	JSR OBTENERM
	MOVE.W D5, EPC
	JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EGOZ:
    JSR OBTENERM ; M ESTA EN D5
    BTST #0,ESR ; SE COMPRUEBA EL FLAG Z DE ESR
    BEQ .NOSALTO
    MOVE.W D5,EPC
.NOSALTO:
    JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EGON:
	JSR OBTENERM
	BTST #1, ESR
	BEQ .NoSalto
	MOVE.W D5, EPC
.NoSalto
	JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EEXIT:
    SIMHALT
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ECOPY:
	JSR DECODB
	JSR OBTENERB
	;TENEMOS EL VALOR DE B EN D2
	JSR ACTFLAGZ
	JSR ACTFLAGN
	JSR DECODC
	;TENEMOS EL NUMERO DE REGISTRO DE C EN D3
	MOVE.W D3, -(A7)
	MOVE.W D2, -(A7)
	JSR ALMACENARENREGISTRO ;LE TENEMOS QUE PASAR EL NÚERO DE REGISTRO EN EL 
                            ;QUE QUERAMOS ALMACENAR Y EL VALOR POR LA PILA
	JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EADD:
    JSR DECODA
    JSR OBTENERA ; EL VALOR DE A ESTA EN D1
    JSR DECODB
    JSR OBTENERB ; EL VALOR DE B ESTA EN D2
    JSR DECODC ; C ESTA EN D3
    MOVE.W D3,-(A7)
    ADD.W D1,D2
    JSR ACTFLAGS
    MOVE.W D2,-(A7)
    JSR ALMACENARENREGISTRO
    JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ESUB:
	JSR DECODB
	JSR OBTENERB
	JSR DECODA
	JSR OBTENERA
	JSR DECODC
	MOVE.W D3, -(A7)
	MOVE.W D2, D0
	NEG.W D1
	ADD.W #1, D1
	ADD.W D1, D0
	JSR ACTFLAGS
	MOVE.W D0, -(A7)
	JSR ALMACENARENREGISTRO
	JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EAND:
    JSR DECODA
    JSR OBTENERA ; EL VALOR DE A ESTA EN D1
    JSR DECODB
    JSR OBTENERB ; EL VALOR DE B ESTA EN D2
    JSR DECODC ; C ESTA EN D3
    MOVE.W D3,-(A7)
    AND.W D1,D2
    JSR ACTFLAGZ
	JSR ACTFLAGN
    MOVE.W D2,-(A7)
    JSR ALMACENARENREGISTRO
    JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ESET:
	JSR DECODK
	;TENEMOS EN D0 EL VALOR DE K
	EXT.W D0
	JSR ACTFLAGZ
	JSR ACTFLAGN
	JSR DECODC
	MOVE.W D3, -(A7)
	MOVE.W D0, -(A7)
	JSR ALMACENARENREGISTRO
	JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
EADQ:
    JSR DECODK
    EXT.W D0
    JSR DECODC
    MOVE.W D3,-(A7)
    JSR OBTENERC ;EL VALOR DE C ESTA EN D3
    ADD.W D3,D0
    JSR ACTFLAGS
    MOVE.W D0,-(A7)
    JSR ALMACENARENREGISTRO
    JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ELSH:
	JSR DECODB
	MOVE.W D2, -(A7)
	JSR OBTENERB
	;AHORA TENEMOS EL CONTENIDO DE B EN D2
	JSR OBTENERP
	;AHORA TENEMOS EL VALOR DE P EN D0
	JSR OBTENERI
	;AHORA TENEMOS EL BIT N EN D4
	CMP #0, D4
	BEQ .SHL
	ASR D0, D2
	JSR ACTFLAGS
	MOVE.W D2, -(A7)
	JSR ALMACENARENREGISTRO
	JMP FETCH
.SHL
	ASL D0, D2
	JSR ACTFLAGS
	MOVE.W D2, -(A7)
	JSR ALMACENARENREGISTRO
	JMP FETCH
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DECODI:
		MOVE.W (EIR),D4
		AND #%0000000000000001, D4
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OBTENERI:
		CMP #0, D4
		BEQ .RegT0
		;SI NO HA SALTADO, ES T1
		MOVE.W (ET1),D4
		RTS
.RegT0: 
		MOVE.W (ET0),D4
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
DECODA: 
		MOVE.W (EIR), D1
		AND #%0000011100000000, D1
		ASR #8, D1
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
DECODB: 
		MOVE.W (EIR), D2
		AND #%0000000001110000, D2
		ASR #4, D2
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DECODC: 
		MOVE.W (EIR), D3
		AND #%0000000000000111, D3
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DECODK:
		MOVE.W (EIR), D0
		AND #%0000011111111000, D0
		ASR #3, D0
		RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OBTENERA:
		MOVE.W D1, -(A7)
		JSR VALORREGISTRO
		MOVE.W D0, D1
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OBTENERB:
		MOVE.W D2, -(A7)
		JSR VALORREGISTRO
		MOVE.W D0, D2
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OBTENERC:
		MOVE.W D3, -(A7)
		JSR VALORREGISTRO
		MOVE.W D0, D3
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OBTENERP:
		MOVE.W (EIR),D0
		AND #%0000011100000000, D0
		ASR #8, D0
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

VALORREGISTRO: ;OBTIENE EL VALOR DEL REGISTRO
        ;PARA QUE FUNCIONE PRIMERO HAY QUE PASAR EL NUMERO DE REGISTRO 
        ;A LA PILA
		MOVE.W 4(A7), D0
		CMP #0, D0
		BEQ .RegX0
		CMP #1, D0
		BEQ .RegX1
		CMP #2, D0
		BEQ .RegX2
		CMP #3, D0
		BEQ .RegX3
		CMP #4, D0
		BEQ .RegX4
		CMP #5, D0
		BEQ .RegX5
		CMP #6, D0
		BEQ .RegX6
		;SI LLEGA AQUÍ ES EL REGISTRO X7
		MOVE.W (EX7), D0
		RTS
.RegX0
		MOVE.W (ET0), D0
		RTS
.RegX1
		MOVE.W (ET1), D0
		RTS
.RegX2
		MOVE.W (EX2), D0
		RTS
.RegX3
		MOVE.W (EX3), D0
		RTS
.RegX4
		MOVE.W (EX4), D0
		RTS
.RegX5
		MOVE.W (EX5), D0
		RTS
.RegX6	
		MOVE.W (EX6), D0
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ALMACENARTi ;PRIMERO HAY QUE PASAR EL VALOR QUE QUEREMOS ALMACENAR A LA PILA Y
            ;TENER EN D4 EL BIT QUE INDICA QUE Ti ES
		MOVE.W 4(A7),D0
		CMP #0, D4
		BEQ .RegT0
		;SI NO HA SALTADO, ES T1
		MOVE.W D0,ET1
		JSR ACTFLAGZ
		JSR ACTFLAGN
		RTS
.RegT0: 
		MOVE.W D0,ET0
		JSR ACTFLAGZ
		JSR ACTFLAGN
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OBTENERM: 
		MOVE.W (EIR), D0
		AND #%0000000111111110, D0
		ASR #1, D0
		MOVE.W D0, D5
		RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ACTFLAGS: ;ACTUALIZA LOS FLAGS DE LA MÁQUINA VIRTUAL CNZ
		  ;LOS DEL EASY SON XNZVC
		MOVE.W SR, D6
		BTST #0, D6
		BEQ .FC0 ; SI EL FLAG C DE NUESTRA MAQUINA ESTÁ A 0
		BSET #2, ESR
		JMP .FLAGN
.FC0:	
		BCLR #2, ESR
.FLAGN: 
		BTST #3, D6
		BEQ .FN0 ; SI EL FLAG N DE NUESTRA MAQUINA ESTA A 0
		BSET #1, ESR
		JMP .FLAGZ
.FN0	
		BCLR #1, ESR
.FLAGZ
		BTST #2, D6
		BEQ .FZ0 ; SI EL FLAG Z DE NUETRAS MAQUINA ESTA A 0
		BSET #0, ESR
		RTS
.FZ0
		BCLR #0, ESR
		RTS 		
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ACTFLAGC:
    MOVE.W SR,D6
    BTST #0,D6
    BEQ .FLAGC0 ; SI EL FLAG C DE NUETRA MAQUINA ESTA A 0
    BSET #2,ESR
    RTS
.FLAGC0:
    BCLR #2,ESR
    RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ACTFLAGN:
    MOVE.W SR,D6
    BTST #3,D6
    BEQ .FLAGN0 ; SI EL FLAG N DE NUETRA MAQUINA ESTA A 0
    BSET #1,ESR
    RTS
.FLAGN0:
    BCLR #1,ESR
    RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ACTFLAGZ:
    MOVE.W SR,D6
    BTST #2,D6
    BEQ .FLAGZ0 ; SI EL FLAG Z DE NUETRA MAQUINA ESTA A 0
    BSET #0,ESR
    RTS
.FLAGZ0:
    BCLR #0,ESR
    RTS
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ALMACENARENREGISTRO: ;ALMACENA EL VALOR EN EL REGISTRO
        ;EL ÚLTIMO VALOR DE LA PILA ES EL NUMERO DE REGISTRO Y
        ;EL PENULTIMO EL VALOR A ALMACENAR
		MOVE.W 6(A7),D0
		CMP #0, D0
		BEQ .RegT0
		CMP #1, D0
		BEQ .RegT1
		CMP #2, D0
		BEQ .RegR2
		CMP #3, D0
		BEQ .RegR3
		CMP #4, D0
		BEQ .RegR4
		CMP #5, D0
		BEQ .RegR5
		CMP #6, D0
		BEQ .RegR6
		;SI LLEGA AQUÍ ES EL REGISTRO X7
		MOVE.W 4(A7),D0
		MOVE.W D0, EX7
		RTS
.RegT0
		MOVE.W 4(A7),D0
		MOVE.W D0, ET0
		RTS
.RegT1
		MOVE.W 4(A7),D0
		MOVE.W D0, ET1
		RTS
.RegR2
		MOVE.W 4(A7),D0
		MOVE.W D0, EX2
		RTS
.RegR3
		MOVE.W 4(A7),D0
		MOVE.W D0, EX3
		RTS
.RegR4
		MOVE.W 4(A7),D0
		MOVE.W D0, EX4
		RTS
.RegR5
		MOVE.W 4(A7),D0
		MOVE.W D0, EX5
		RTS
.RegR6	
		MOVE.W 4(A7),D0
		MOVE.W D0, EX6
		RTS

    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	MOVE.W D0, -(A7)
	MOVE.W 6(A7), D0
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
	MOVE.W #7, 8(A7)
	JMP FINAL
OOZ: 				 ;110
	BTST #12, D0
	BEQ OOZZ		 
					 ;1101
	BTST #11, D0
	BEQ OOZOZ
					 ;11011, ES UN AND
	MOVE.W #11, 8(A7)
	JMP FINAL	
	
OOZOZ: 				 ;11010, ES UN SUB
	MOVE.W #10, 8(A7)
	JMP FINAL
OOOZ: 				 ;1110
	BTST #11, D0
	BEQ OOOZZ
					 ;11101, ES UN ADQ
	MOVE.W #13, 8(A7)
	JMP FINAL					 
OOOZZ: 				 ;11100, ES UN SET
	MOVE.W #12, 8(A7)
	JMP FINAL
OOOOZ:				 ;11110, ES UN LSH 
	MOVE.W #14, 8(A7)
	JMP FINAL
OOZZ: 	
	BTST #11, D0
	BEQ OOZZZ		 
					 ;11001, ES UN ADD
	MOVE.W #9, 8(A7)
	JMP FINAL
OOZZZ: 				 ;11000, ES UN COPY
	MOVE.W #8, 8(A7)
	JMP FINAL
					
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
	BEQ ZOZZ		 
					 ;0101, ES UN GOZ
	MOVE.W #5, 8(A7)
	JMP FINAL					 
ZOOZ: 				 ;0110, ES UN GON
	MOVE.W #6, 8(A7)
	JMP FINAL
ZOZZ: 				 ;0100, ES UN GOI
	MOVE.W #4, 8(A7)
	JMP FINAL
ZZ: 				 ;00
	BTST #13, D0
	BEQ ZZZ			 ;000
	BTST #12, D0	 ;001
	BEQ ZZOZ		 ;0010
					 ;0011, ES UN STIP
	MOVE.W #3, 8(A7)
	JMP FINAL		
ZZOZ: 				 ;0010, ES UN LOIP
	MOVE.W #2, 8(A7)
	JMP FINAL
	RTS

ZZZ: 				 ;000
	BTST #12, D0
	BEQ ZZZZ		 ;0000
					 ;0001, ES UN STO
	MOVE.W #1, 8(A7)
	JMP FINAL
ZZZZ: 				 ;0000, ES UN LOA
	MOVE.W #0, 8(A7)
FINAL: 
	MOVE.W (A7)+, D0
	RTS
	        ; ESCRIBID VUESTRO CODIGO AQUI

    ;--- FDECOD: FIN DECOD
    END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
