;*****************************************************************************
;   PROJETO DE ARQUITETURA DE COMPUTADORES (CIÊNCIAS DA COMPUTAÇÃO - 2º ANO)
;*****************************************************************************
;       NOME:               BATALHA NAVAL
;       DESENVOLVIDO POR:   GRUPO Nº8 (UAN-FC-CC)
;       ESCRITO EM:         ASSEMBLY
;       PARA:               ARCHITECTURE SIMULATOR 2019
;       VERSÃO ESTÁVEL:     V.6.5
;       DOCENTE:            JOÃO COSTA
;       ANO:                21/03/2020 - 21/03/2021
;*****************************************************************************
;       UNIVERSIDADE AGOSTINHO NETO
;       FACULDADE DE CIÊNCIAS
;       DEPARTAMENTO DE CIÊNCIAS DA COMPUTAÇÃO
;*****************************************************************************

PIXEL	EQU	8000H
PIN     EQU	0E000H	; endereço do porto de E/S do teclado
POUT2   EQU 0C000H
POUT1   EQU 0A000H
POUT3   EQU 06000H
ON      EQU 2
OFF     EQU 1

; AS POSIÇÕES DE MEMÓRIAS (PLACE) FORAM ESCOLHIDAS ALEATORIAMENTE

PLACE 2000H
; ENDEREÇO ONDE ESTÃO CONTIDOS OS VALORES DAS TECLAS DA LINHA 1
linha1:  STRING  0, 0H, 1H, 0, 2H, 0, 0, 0, 3H
; ENDEREÇO ONDE ESTÃO CONTIDOS OS VALORES DAS TECLAS DA LINHA 2
linha2:  STRING  0, 4H, 5H, 0, 6H, 0, 0, 0, 7H
; ENDEREÇO ONDE ESTÃO CONTIDOS OS VALORES DAS TECLAS DA LINHA 3
linha3:  STRING  0, 8H, 9H, 0, 0aH, 0, 0, 0, 0bH
; ENDEREÇO ONDE ESTÃO CONTIDOS OS VALORES DAS TECLAS DA LINHA 4
linha4:  STRING  0, 0cH, 0dH, 0, 0eH, 0, 0, 0, 0fH

PLACE 2500H
score:  STRING  0

PLACE 4000H
ender_lin:  STRING  23  ; ENDEREÇO DA LINHA DO SUBMARINO
ender_col:  STRING  10  ; ENDEREÇO DA COLUNA DO SUBMARINO

PLACE 4500H
game_over:  STRING  OFF

PLACE 5000H
barco_lin:  STRING  8   ; ENDEREÇO DA LINHA DO BARCO 1
barco_col:  STRING  2   ; ENDEREÇO DA COLUNA DO BARCO 1
barco2_lin:  STRING  8  ; ENDEREÇO DA LINHA DO BARCO 2
barco2_col:  STRING  22 ; ENDEREÇO DA COLUNA DO BARCO 2

PLACE 3000H
torpedo_lin:    STRING  0   ; ENDEREÇO DA LINHA DO TORPEDO
torpedo_col:    STRING  0   ; ENDEREÇO DA COLUNA DO TORPEDO
torpedo_ativo:  STRING  OFF ; CONFIRMAÇÃO DA ATIVAÇÃO DO TORPEDO
; ON DISPARO DO TORPEDO É ATIVADO / OFF DISPARO DO TORPEDO É DESATIVADO
; ESTE ÚLTIMO É COLOCADO QUANDO, É O ESTADO INICIAL OU FINAL DO TORPEDO
desenha_trpd:   STRING  ON  ; CONFIRMAÇÃO DO DESENHO DO TORPEDO
; ON - DESENHA O TORPEDO / OFF - APAGA O TORPEDO

PLACE 3500H
bala_lin_col:   STRING  23, 0   ; ENDEREÇO DA LINHA E DA COLUNA DA BALA
desenha_bala:   STRING  ON  ; SEMELHANTE AO "desenha_trpd" SÓ QUE COM A BALA

PLACE 1000H
pilha:	TABLE 100H	; espaço reservado para a pilha
SP_inicial: ; este é o endereço (1200H) com que o SP deve ser

PLACE   0

inicio:
    MOV	SP, SP_inicial  ; INICIALIZAÇÃO DA PILHA
    MOV R1, PIXEL
    MOV R3, 0
    MOV R2, 23   ; LINHA DO SUBMARINO
    MOV R9, 10  ; COLUNA DO SUBMARINO
    MOV R0, POUT1   ; ENDEREÇO DOS DISPLAY DA PONTUAÇÃO
    MOVB [R0], R3   ; INICIALIZA COM ZERO
    MOV R4, 0
    MOV R5, 0
    MOV R6, 0
    MOV R7, 0   ; TECLA PRESSIONADA, DO TECLADO
    MOV R8, 0
    MOV R10, 0  ; INICIALIZAÇÕES GERAIS

;*****************************************************************************

; VARIAS ROTINAS SÃO CHAMADAS VARIAS VEZES POR MOTIVOS DE PERFORMANCE DA MESMA
; "infinito" É O CICLO PRINCIPAL ONDE TODAS AS ROTINAS PRINCIPAIS SÃO CHAMADAS

infinito:
    CALL submarino  ; DESENHA O SUBMARINO
    CALL varredura  ; CHAMA A VARREDURA DO TECLADO
    CALL disparo    ; DISPARO DO TORPEDO
    CALL disparo
    CALL disparo_da_bala    ; DISPARO DA BALA
    CALL fim_de_jogo
    CALL varredura
    CALL set_barco_1    ; DESENHO DO BARCO 1
    CALL set_barco_2    ; DESENHO DO BARCO 2
    CALL varredura
    CALL disparo
    CALL disparo
    CALL disparo_da_bala
    CALL fim_de_jogo
    CALL varredura
    CALL movimento_do_barco_1   ; MOVIMENTO DO BARCO 1
    CALL movimento_do_barco_2   ; MOVIMENTO DO BARCO 2
    CALL varredura
    CALL disparo
    CALL disparo_da_bala
    CALL fim_de_jogo
    CALL varredura
    CALL disparo
    CALL disparo_da_bala
    CALL fim_de_jogo
    JMP infinito    ; SALTA NOVAMENTE PARA O CICLO ("infinito")

; ROTINAS DE TÉRMINO DO JOGO

fase1:  ; ESTA FASE ELIMINA TODOS PIXEIS EXISTENTES
    CALL submarino_eli
    CALL eli_barco_1
    CALL eli_barco_2
    CALL eli_torpedo
    CALL eli_bala

fase2:  ; ESTA FASE COLOCA OS VALORES DEFAULTS NA MEMÓRIA
    MOV R0, 0
    MOV R1, 0
    MOV R0, ender_lin
    MOV R1, 23
    MOVB [R0], R1   ; REINICIA A LIN DO SUBMARINO
    MOV R0, ender_col
    MOV R1, 10
    MOVB [R0], R1   ; REINICIA A COL DO SUBMARINO
    MOV R0, game_over
    MOV R1, OFF
    MOVB [R0], R1   ; DESLIGA O GAME OVER
    MOV R0, barco_lin
    MOV R1, 8
    MOVB [R0], R1   ; REINICIA A LIN DO BARCO 1
    MOV R0, barco_col
    MOV R1, 2
    MOVB [R0], R1   ; REINICIA A COL DO BARCO 1
    MOV R0, barco2_lin
    MOV R1, 8
    MOVB [R0], R1   ; REINICIA A LIN DO BARCO 2
    MOV R0, barco2_col
    MOV R1, 22
    MOVB [R0], R1   ; REINICIA A COL DO BARCO 2
    MOV R0, torpedo_lin
    MOV R1, 0
    MOVB [R0], R1   ; REINICIA A LIN DO TORPEDO
    MOV R0, torpedo_col
    MOVB [R0], R1   ; REINICIA A COL DO TORPEDO
    MOV R0, torpedo_ativo
    MOV R1, OFF
    MOVB [R0], R1   ; DESATIVA O TORPEDO
    MOV R0, desenha_trpd
    MOV R1, ON
    MOVB [R0], R1
    MOV R0, bala_lin_col
    MOV R1, 23
    MOVB [R0], R1   ; REINICIA A LIN DA BALA
    ADD R0, 1
    MOV R1, 0
    MOVB [R0], R1   ; REINICIA A COL DA BALA
    MOV R0, desenha_bala
    MOV R1, ON
    MOVB [R0], R1
    CALL escrita_especial

final:
    CALL varredura_especial
    JMP final

;*****************************************************************************

; ROTINAS DE POSICIONAMENTO DO SUBMARINO

; POSICIONAMENTO DE UM PIXEL NA LINHA (R2) E NA COLUNA (R9)
pixel_xy:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R9
    PUSH R10
    MOV R1, PIXEL
    MOV R10, 4
    MOV R5, R9  ; Guarda o valor da coluna
    MUL R2, R10 ; Multiplicação da linha por 4
    MOV R10, 8
    DIV R9, R10 ; Divisão da coluna por 8
    ADD R2, R9
    ADD R1, R2  ; Endereço do pixel avança linha + coluna
    MOV R9, R5
    MOV R10, 8
    MOD R9, R10 ; Resto da divisão da coluna por 8
    MOV R3, 128
ciclo_sub_xy:
    CMP R9, 0
    JZ para
    SHR R3, 1
    SUB R9, 1
    JMP ciclo_sub_xy
para:
    MOVB R4, [R1]
    OR R3, R4
    MOVB [R1], R3
    POP R10
    POP R9
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; ELIMINAÇÃO DE UM PIXEL NA LINHA (R2) E NA COLUNA (R9)
eli_xy:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R9
    PUSH R10
    MOV R1, PIXEL
    MOV R10, 4
    MOV R5, R9      ; Guarda o valor da coluna
    MUL R2, R10     ; Multiplicação da linha por 4
    MOV R10, 8
    DIV R9, R10     ; Divisão da coluna por 8
    ADD R2, R9
    ADD R1, R2      ; Endereço do pixel avança linha + coluna
    MOV R9, R5
    MOV R10, 8
    MOD R9, R10     ; Resto da divisão da coluna por 8
    MOV R3, 128
ciclo_sub_xy_2:
    CMP R9, 0
    JZ para_eli
    SHR R3, 1
    SUB R9, 1
    JMP ciclo_sub_xy_2
para_eli:
    MOVB R4, [R1]
    NOT R3
    AND R3,R4
    MOVB [R1], R3
    POP R10
    POP R9
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    RET

; POSICIONAMENTO COMPLETO DO SUBMARINO
submarino:
    PUSH R2
    PUSH R5
    PUSH R8
    PUSH R9
    PUSH R10

    MOV R0, ender_col
    MOV R3, ender_lin
    MOVB R2, [R3]   ; LINHA DO SUBMARINO
    MOVB R9, [R0]  ; COLUNA DO SUBMARINO

    MOV R8, 6
    MOV R5, R9
    MOV R10, R2
ciclo_s1:
    CMP R8, 0
    JZ ciclo_s2
    CALL pixel_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_s1
ciclo_s2:
    MOV R9, R5
    ADD R9, 3
    SUB R2, 1
    CALL pixel_xy
    JMP ciclo_s3
ciclo_s3:
    MOV R9, R5
    MOV R2, R10
    SUB R2, 2
    ADD R9, 2
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    JMP termina_sub
termina_sub:
    POP R10
    POP R9
    POP R8
    POP R5
    POP R2
    RET

; ELIMINAÇÃO COMPLETA DO SUBMARINO
submarino_eli:
    PUSH R2
    PUSH R5
    PUSH R8
    PUSH R9
    PUSH R10

    MOV R0, ender_col
    MOV R3, ender_lin
    MOVB R2, [R3]   ; LINHA DO SUBMARINO
    MOVB R9, [R0]  ; COLUNA DO SUBMARINO

    MOV R8, 6
    MOV R5, R9
    MOV R10, R2
ciclo_s1_xy:
    CMP R8, 0
    JZ ciclo_s2_xy
    CALL eli_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_s1_xy
ciclo_s2_xy:
    MOV R9, R5
    ADD R9, 3
    SUB R2, 1
    CALL eli_xy
    JMP ciclo_s3_xy
ciclo_s3_xy:
    MOV R9, R5
    MOV R2, R10
    SUB R2, 2
    ADD R9, 2
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    JMP termina_sub_xy
termina_sub_xy:
    POP R10
    POP R9
    POP R8
    POP R5
    POP R2
    RET
; FIM DE ROTINAS DE POSICIONAMENTO DO SUBMARINO

;*****************************************************************************

; VARREDURA COMPLETA DO TECLADO

varredura:
    ; NOTA: ATIVAR A VARREDURA APENAS QUANDO O SINAL DO RELÓGIO VARIA (0 -> 1)
    ; OU GUARDA O VALOR DA TECLA QUANDO O SINAL DO RELÓGIO VARIA (0 -> 1)
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R10    ; GUARDA TODOS OS REGISTOS ANTES DE ENTRAR NA ROTINA
    ; CASO ALGUMA TECLA SEJA PRESSIONADA, A TECLA ESTARÁ EM R7
	MOV	R0, 1   ; R0 GUARDA O VALOR DA LINHA DO TECLADO (INICIALIZA COM 1)
	MOV	R6, POUT2
    MOV R10, PIN
    MOV R1, POUT3
    MOV R8, 16  ; GUARDA O EXCESSO EM QUE LINHA NÃO DEVE CHEGAR
    JMP ciclo_var
sai_varredura:
    POP R10
    POP R8
    POP R7
    POP R6
    POP R4
    POP R3
    POP R1
    POP R0  ; RECUPERA OS REGISTOS ANTES DE SAIR
    RET

ciclo_var:
    CMP R0, R8  ; COMPARA SE A LINHA CHEGOU NO LIMITE PROIBIDO (16)
    JZ reinicia ; CASO SIM, REINICIA O VALOR DA LINHA COM 1
    MOVB [R6], R0   ; ATIVA A LINHA (R0), NO TECLADO
    MOVB R3, [R10]  ; LÊ A SAÍDA DO TECLADO QUE POR CONSEQUÊNCIA FAZ A LEITURA
    ; DOS RELÓGIOS TAMBÉM. R3 <- COLUNA DO TECLADO
    SHL R0, 1   ; PASSA A LINHA PARA O PRÓXIMO VALOR
    MOV R8, 000fH   ; COLOCA O VALOR F (HEX) TEMPORARIAMENTE EM R8
    AND R3, R8  ; OPERAÇÃO AND EM R3 COM F (HEX) PARA AFETAR OS BITS (0-3)
    MOV R8, 16  ; RESTABELECE O VALOR DE R8 PARA 16
	AND R3, R3  ; OPERAÇÃO AND EM R3 PARA SABER SE ALGUMA TECLA FOI PRESSIONA-
    ; DA, CASO SIM, BIT DE ESTADO ESTARÁ DESATIVADO, CASO NÃO...
    JZ ciclo_var    ; SALTO OCORRERÁ CASO R3 SEJA IGUAL A 0
    ; UMA TECLA FOI PRESSIONADA (RESTA SABER QUAL)
    SHR R0, 1   ; VALOR DA LINHA PASSA PARA A ANTERIOR
    ; ATÉ ESTE PONTO JÁ SE SABE A LINHA E A COLUNA EM QUE SE ENCONTRA A TECLA
    ; RESTA CONVERTER EM VALOR
    CMP R0, 1   ; COMPARA SE A LINHA = 1
    JZ l1
    CMP R0, 2   ; COMPARA SE A LINHA = 2
    JZ l2
    CMP R0, 4   ; COMPARA SE A LINHA = 3
    JZ l3
    JMP l5  ; SE CHEGOU AQUI, ENTÃO, LINHA = 4

reinicia:
    MOV R0, 1
    JMP sai_varredura    ; NENHUMA TECLA FOI PRESSIONADA (SAI DA ROTINA)
    ; SAI E DÁ LUGAR A OUTROS PROCESSOS

; L1, L2, L3 E L5, REFEREM-SE AS LABELS DAS LINHAS 1, 2, 3 E 4 RESPETIVAMENTE
; COLOCA EM R4 OS ENDEREÇOS ONDE ESTÃO OS VALORES DAS LINHAS CORRESPONDENTES

l1:
    ; TECLA ESTÁ NA 1ª LINHA (0, 1, 2, 3)
    ; NESTE PROJETO OS TECLAS DESTA LINHA SE ENCARREGAM SOMENTE DO MOVIMENTO
    MOV R4, linha1
    ADD R4, R3
    MOVB R7, [R4]
    MOVB [R1], R7   ; COLOCA O VALOR DA TECLA NO DISPLAY (HEXADECIMAL)
    ; ESTA INSTRUÇÃO DEVE SER, POSTERIORMENTE, ELIMINADA
    JMP movimento

l2:
    ; TECLA ESTÁ NA 2ª LINHA (4, 5, 6, 7)
    MOV R4, linha2
    ADD R4, R3
    MOVB R7, [R4]
    MOVB [R1], R7   ; COLOCA O VALOR DA TECLA NO DISPLAY (HEXADECIMAL)
    ; ESTA INSTRUÇÃO DEVE SER, POSTERIORMENTE, ELIMINADA
    CMP R7, 7
    JZ ativa_torpedo
    JMP sai_varredura

l3:
    ; TECLA ESTÁ NA 3ª LINHA (8, 9, A, B)
    MOV R4, linha3
    ADD R4, R3
    MOVB R7, [R4]
    MOVB [R1], R7   ; COLOCA O VALOR DA TECLA NO DISPLAY (HEXADECIMAL)
    ; ESTA INSTRUÇÃO DEVE SER, POSTERIORMENTE, ELIMINADA
    JMP sai_varredura

l5:
    ; TECLA ESTÁ NA 4ª LINHA (C, D, E, F)
    MOV R4, linha4
    ADD R4, R3
    MOVB R7, [R4]
    MOVB [R1], R7   ; COLOCA O VALOR DA TECLA NO DISPLAY (HEXADECIMAL)
    ; ESTA INSTRUÇÃO DEVE SER, POSTERIORMENTE, ELIMINADA
    JMP sai_varredura

; FUNÇÕES DE ATIVAÇÃO DO TORPEDO
ativa_torpedo:
    MOV R0, PIN
    MOVB R0, [R0]
    BIT R0, 5
    JZ sai_varredura
    MOV R0, torpedo_ativo
    MOVB R1, [R0]
    CMP R1, ON
    JZ sai_varredura
    MOV R1, 2
    MOVB [R0], R1
    MOV R7, ender_lin
    MOVB R7, [R7]
    SUB R7, 3
    MOV R8, ender_col
    MOVB R8, [R8]
    ADD R8, 1
    MOV R10, torpedo_lin
    MOVB [R10], R7
    MOV R10, torpedo_col
    MOVB [R10], R8
    JZ sai_varredura

; FUNÇÕES DE MOVIMENTO DO SUBMARINO
movimento:
    CMP R7, 0
    JZ move_sub_cim
    CMP R7, 1
    JZ move_sub_des
    CMP R7, 2
    JZ move_sub_esq
    CMP R7, 3
    JZ move_sub_dir
    JMP sai_varredura

move_sub_esq:
    MOV R0, ender_col
    MOVB R9, [R0]  ; COLUNA DO SUBMARINO

    CMP R9, 0
    JZ sai_varredura
    CALL submarino_eli

    SUB R9, 1

    MOVB [R0], R9
    
    JMP sai_varredura

move_sub_dir:
    MOV R0, ender_col
    MOVB R9, [R0]  ; COLUNA DO SUBMARINO
    MOV R5, 26

    CMP R9, R5
    JZ sai_varredura
    CALL submarino_eli

    ADD R9, 1

    MOVB [R0], R9
    
    JMP sai_varredura

move_sub_cim:
    MOV R3, ender_lin
    MOVB R2, [R3]   ; LINHA DO SUBMARINO
    MOV R5, 15

    CMP R2, R5
    JZ sai_varredura
    CALL submarino_eli

    SUB R2, 1

    MOVB [R3], R2
    
    JMP sai_varredura

move_sub_des:
    MOV R3, ender_lin
    MOVB R2, [R3]   ; LINHA DO SUBMARINO
    MOV R5, 31

    CMP R2, R5
    JZ sai_varredura
    CALL submarino_eli

    ADD R2, 1

    MOVB [R3], R2
    
    JMP sai_varredura

; FIM DA FUNÇÃO QUE FAZ A VARREDURA DO TECLADO COMPLETO

;*****************************************************************************

; ROTINAS DE POSICIONAMENTO DO BARCO_1

set_barco_1:
    PUSH R2
    PUSH R5
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R3
    PUSH R0

    MOV R0, barco_col
    MOV R3, barco_lin
    MOVB R2, [R3]   ; LINHA DO BARCO 1
    MOVB R9, [R0]  ; COLUNA DO BARCO 1

    MOV R8, 4
    MOV R5, R9  ; CÓPIA DA COLUNA
    MOV R10, R2 ; CÓPIA DA LINHA

ciclo_b1:   ; BASE Nº1 DO BARCO
    CMP R8, 0
    JZ ini_ciclo_b2
    CALL pixel_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b1

ini_ciclo_b2:
    MOV R8, 6
    MOV R9, R5
    SUB R9, 1
    MOV R2, R10
    SUB R2, 1

ciclo_b2:
    CMP R8, 0
    JZ ini_ciclo_b3
    CALL pixel_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b2

ini_ciclo_b3:
    MOV R8, 8
    MOV R9, R5
    SUB R9, 2
    MOV R2, R10
    SUB R2, 2

ciclo_b3:
    CMP R8, 0
    JZ ciclo_b4_5_6
    CALL pixel_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b3

ciclo_b4_5_6:
    MOV R9, R5
    MOV R2, R10
    SUB R2, 3
    CALL pixel_xy
    SUB R2, 1
    CALL pixel_xy
    SUB R2, 1
    SUB R9, 1
    CALL pixel_xy

termina_b1:
    POP R0
    POP R3
    POP R10
    POP R9
    POP R8
    POP R5
    POP R2
    RET

; FIM DA FUNÇÃO QUE FAZ O POSICIONAMENTO DO BARCO_1

;*****************************************************************************

; ROTINAS DE ELIMINAÇÃO DO BARCO_1

eli_barco_1:
    PUSH R2
    PUSH R5
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R3
    PUSH R0

    MOV R0, barco_col
    MOV R3, barco_lin
    MOVB R2, [R3]   ; LINHA DO BARCO 1
    MOVB R9, [R0]  ; COLUNA DO BARCO 1

    MOV R8, 4
    MOV R5, R9  ; CÓPIA DA COLUNA
    MOV R10, R2 ; CÓPIA DA LINHA

ciclo_b1_eli:   ; BASE Nº1 DO BARCO
    CMP R8, 0
    JZ ini_ciclo_b2_eli
    CALL eli_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b1_eli

ini_ciclo_b2_eli:
    MOV R8, 6
    MOV R9, R5
    SUB R9, 1
    MOV R2, R10
    SUB R2, 1

ciclo_b2_eli:
    CMP R8, 0
    JZ ini_ciclo_b3_eli
    CALL eli_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b2_eli

ini_ciclo_b3_eli:
    MOV R8, 8
    MOV R9, R5
    SUB R9, 2
    MOV R2, R10
    SUB R2, 2

ciclo_b3_eli:
    CMP R8, 0
    JZ ciclo_b4_5_6_eli
    CALL eli_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b3_eli

ciclo_b4_5_6_eli:
    MOV R9, R5
    MOV R2, R10
    SUB R2, 3
    CALL eli_xy
    SUB R2, 1
    CALL eli_xy
    SUB R2, 1
    SUB R9, 1
    CALL eli_xy

termina_b1_eli:
    POP R0
    POP R3
    POP R10
    POP R9
    POP R8
    POP R5
    POP R2
    RET

;*****************************************************************************

; ROTINAS DE POSICIONAMENTO DO BARCO_2

set_barco_2:
    PUSH R2
    PUSH R5
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R3
    PUSH R0

    MOV R0, barco2_col
    MOV R3, barco2_lin
    MOVB R2, [R3]   ; LINHA DO BARCO 2
    MOVB R9, [R0]  ; COLUNA DO BARCO 2

    MOV R8, 4
    MOV R5, R9  ; CÓPIA DA COLUNA
    MOV R10, R2 ; CÓPIA DA LINHA

ciclo_b2_1:   ; BASE Nº1 DO BARCO
    CMP R8, 0
    JZ ini_ciclo_b2_2
    CALL pixel_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b2_1

ini_ciclo_b2_2:
    MOV R8, 6
    MOV R9, R5
    SUB R9, 1
    MOV R2, R10
    SUB R2, 1

ciclo_b2_2:
    CMP R8, 0
    JZ ciclo_b2_4_5_6
    CALL pixel_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b2_2

ciclo_b2_4_5_6:
    MOV R9, R5
    MOV R2, R10
    SUB R2, 2
    ADD R9, 1
    CALL pixel_xy
    SUB R2, 1
    CALL pixel_xy
    SUB R2, 1
    SUB R9, 1
    CALL pixel_xy

termina_b2_1:
    POP R0
    POP R3
    POP R10
    POP R9
    POP R8
    POP R5
    POP R2
    RET

; FIM DA FUNÇÃO QUE FAZ O POSICIONAMENTO DO BARCO_2

;*****************************************************************************

; ROTINAS DE ELIMINAÇÃO DO BARCO_1

eli_barco_2:
    PUSH R2
    PUSH R5
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R3
    PUSH R0

    MOV R0, barco2_col
    MOV R3, barco2_lin
    MOVB R2, [R3]   ; LINHA DO BARCO 2
    MOVB R9, [R0]  ; COLUNA DO BARCO 2

    MOV R8, 4
    MOV R5, R9  ; CÓPIA DA COLUNA
    MOV R10, R2 ; CÓPIA DA LINHA

ciclo_b2_1_eli:   ; BASE Nº1 DO BARCO
    CMP R8, 0
    JZ ini_ciclo_b2_2_eli
    CALL eli_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b2_1_eli

ini_ciclo_b2_2_eli:
    MOV R8, 6
    MOV R9, R5
    SUB R9, 1
    MOV R2, R10
    SUB R2, 1

ciclo_b2_2_eli:
    CMP R8, 0
    JZ ciclo_b2_4_5_6_eli
    CALL eli_xy
    ADD R9, 1
    SUB R8, 1
    JMP ciclo_b2_2_eli

ciclo_b2_4_5_6_eli:
    MOV R9, R5
    MOV R2, R10
    SUB R2, 2
    ADD R9, 1
    CALL eli_xy
    SUB R2, 1
    CALL eli_xy
    SUB R2, 1
    SUB R9, 1
    CALL eli_xy

termina_b2_1_eli:
    POP R0
    POP R3
    POP R10
    POP R9
    POP R8
    POP R5
    POP R2
    RET

;*****************************************************************************

; ROTINAS DE MOVIMENTO DOS BARCOS (1 E 2) EM FUNÇÃO DO RTC 2

; MOVIMENTO DO BARCO 1
movimento_do_barco_1:
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    MOV R0, PIN
    MOVB R1, [R0]
    BIT R1, 4
    JZ sai_do_movimento_do_barco_1
    JMP move_barco_1

sai_do_movimento_do_barco_1:
    POP R5
    POP R4
    POP R3
    POP R1
    POP R0
    RET

move_barco_1:
    MOV R3, barco_col
    MOVB R4, [R3]
    MOV R5, 11
    CMP R4, R5
    JZ reinicia_coluna_do_barco_1
    CALL eli_barco_1
    ADD R4, 1
    MOVB [R3], R4
    JMP sai_do_movimento_do_barco_1

reinicia_coluna_do_barco_1:
    CALL eli_barco_1
    MOV R4, 2
    MOVB [R3], R4
    JMP sai_do_movimento_do_barco_1

; MOVIMENTO DO BARCO 2
movimento_do_barco_2:
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    MOV R0, PIN
    MOVB R1, [R0]
    BIT R1, 4
    JZ sai_do_movimento_do_barco_2
    JMP move_barco_2

sai_do_movimento_do_barco_2:
    POP R5
    POP R4
    POP R3
    POP R1
    POP R0
    RET

move_barco_2:
    MOV R3, barco2_col
    MOVB R4, [R3]
    MOV R5, 27
    CMP R4, R5
    JZ reinicia_coluna_do_barco_2
    CALL eli_barco_2
    ADD R4, 1
    MOVB [R3], R4
    JMP sai_do_movimento_do_barco_2

reinicia_coluna_do_barco_2:
    CALL eli_barco_2
    MOV R4, 18
    MOVB [R3], R4
    JMP sai_do_movimento_do_barco_2

; FIM DAS ROTINAS DE MOVIMENTO DOS BARCOS (1 E 2) EM FUNÇÃO DO RTC 2

;*****************************************************************************

; ROTINAS DO TORPEDO

set_torpedo:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R9
    MOV R0, torpedo_lin ; ENDEREÇO ONDE ESTÁ GUARDADA A LINHA DO TORPEDO
    MOV R1, torpedo_col ; ENDEREÇO ONDE ESTÁ GUARDADA A COLUNA DO TORPEDO
    MOVB R3, [R0]   ; LINHA DO TORPEDO
    MOVB R4, [R1]   ; COLUNA DO TORPEDO
    MOV R2, R3
    MOV R9, R4
    CALL pixel_xy
    SUB R2, 1
    CALL pixel_xy
    SUB R2, 1
    CALL pixel_xy
termina_set_torpedo:
    POP R9
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

eli_torpedo:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R9
    MOV R0, torpedo_lin ; ENDEREÇO ONDE ESTÁ GUARDADA A LINHA DO TORPEDO
    MOV R1, torpedo_col ; ENDEREÇO ONDE ESTÁ GUARDADA A COLUNA DO TORPEDO
    MOVB R3, [R0]   ; LINHA DO TORPEDO
    MOVB R4, [R1]   ; COLUNA DO TORPEDO
    MOV R2, R3
    MOV R9, R4
    CALL eli_xy
    SUB R2, 1
    CALL eli_xy
    SUB R2, 1
    CALL eli_xy
termina_eli_torpedo:
    POP R9
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

disparo:
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R10
    MOV R0, PIN
    MOVB R1, [R0]
    BIT R1, 5
    JZ termina_disparo
    MOV R0, torpedo_ativo
    MOVB R1, [R0]
    CMP R1, OFF
    JZ termina_disparo
    MOV R8, desenha_trpd
    MOVB R3, [R8]
    CMP R3, ON
    JZ disparo_p1
    CMP R3, OFF
    JZ disparo_p2
    
termina_disparo:
    POP R10
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R1
    POP R0
    RET

disparo_p1:
    CALL colisao_torpedo_barcos
    CALL set_torpedo
    MOV R3, 1
    MOVB [R8], R3
    JMP termina_disparo

disparo_p2:
    MOV R4, torpedo_lin
    MOVB R5, [R4]
    CMP R5, 3
    JZ desativa
    CALL eli_torpedo
    SUB R5, 1
    MOVB [R4], R5
    MOV R3, 2
    MOVB [R8], R3
    JMP termina_disparo

desativa:
    CALL eli_torpedo
    MOV R1, 1
    MOVB [R0], R1
    MOV R1, 2
    MOVB [R8], R1
    JMP termina_disparo

colisao_torpedo_barcos:
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R10
    MOV R0, PIN
    MOVB R1, [R0]
    BIT R1, 5
    JZ fim_de_colisao
    MOV R0, torpedo_ativo
    MOV R1, 0
    MOVB R1, [R0]
    CMP R1, 1
    JZ fim_de_colisao
    MOV R3, torpedo_lin
    MOVB R4, [R3]   ; LINHA DO TORPEDO
    SUB R4, 3
    MOV R7, 8   ; LINHA GERAL DOS NAVIOS
    CMP R4, R7
    JNZ fim_de_colisao
    MOV R5, torpedo_col
    MOVB R6, [R5]   ; COLUNA DO TORPEDO
    MOV R1, 16  ; COLUNA SEPARADORA
    CMP R6, R1
    JGT verifica_barco_2
    JMP verifica_barco_1
fim_de_colisao:
    POP R10
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R1
    POP R0
    RET

verifica_barco_1:
    MOV R7, barco_col
    MOVB R1, [R7]   ; COLUNA DO BARCO 1
    ; FALTA COMPARAR AS COLUNAS DOS TORPEDOS/NAVIOS
    SUB R1, 2
    CMP R6, R1
    JLT fim_de_colisao
    ADD R1, 7
    CMP R6, R1
    JGT fim_de_colisao
    MOV R8, POUT1
    MOV R0, score
    MOVB R10, [R0]
    ADD R10, 1
    MOVB [R8], R10
    MOVB [R0], R10
    JMP fim_de_colisao

verifica_barco_2:
    MOV R7, barco2_col
    MOVB R1, [R7]   ; COLUNA DO BARCO 1
    ; FALTA COMPARAR AS COLUNAS DOS TORPEDOS/NAVIOS
    SUB R1, 1
    CMP R6, R1
    JLT fim_de_colisao
    ADD R1, 5
    CMP R6, R1
    JGT fim_de_colisao
    MOV R8, POUT1
    MOV R0, score
    MOVB R10, [R0]
    ADD R10, 1
    MOVB [R8], R10
    MOVB [R0], R10
    JMP fim_de_colisao

; FIM DAS ROTINAS DO TORPEDO

;*****************************************************************************

; ROTINA DA BALA

set_bala:
    PUSH R0
    PUSH R2
    PUSH R9
    MOV R0, bala_lin_col
    MOVB R2, [R0]
    ADD R0, 1
    MOVB R9, [R0]
    CALL pixel_xy
termina_bala:
    POP R9
    POP R2
    POP R0
    RET

eli_bala:
    PUSH R0
    PUSH R2
    PUSH R9
    MOV R0, bala_lin_col
    MOVB R2, [R0]
    ADD R0, 1
    MOVB R9, [R0]
    CALL eli_xy
termina_bala_eli:
    POP R9
    POP R2
    POP R0
    RET

disparo_da_bala:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    MOV R0, PIN
    MOVB R1, [R0]
    BIT R1, 5
    JZ termina_disparo_da_bala
    MOV R0, desenha_bala
    MOV R1, 0
    MOVB R1, [R0]
    CMP R1, ON
    JZ disparo_da_bala_p1
    JMP disparo_da_bala_p2
termina_disparo_da_bala:
    POP R10
    POP R9
    POP R8
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

disparo_da_bala_p1:
    CALL set_bala
    MOV R6, OFF
    MOVB [R0], R6
    CALL colisao_bala_submarino
    JMP termina_disparo_da_bala

disparo_da_bala_p2:
    MOV R2, bala_lin_col
    ADD R2, 1
    MOVB R3, [R2]
    CALL eli_bala
    ADD R3, 1
    MOV R4, 32
    CMP R3, R4
    JZ reinicia_bala
    MOVB [R2], R3
    MOV R6, ON
    MOVB [R0], R6
    JMP termina_disparo_da_bala

reinicia_bala:
    MOV R6, 0
    MOVB [R2], R6
    MOV R6, ON
    MOVB [R0], R6
    CALL atualiza_bala_lin
    JMP termina_disparo_da_bala

atualiza_bala_lin:
    PUSH R0
    PUSH R1
    MOV R0, ender_lin
    MOVB R0, [R0]   ; VALOR DA LINHA DO SUBMARINO
    MOV R1, bala_lin_col
    MOVB [R1], R0
    POP R1
    POP R0
    RET

colisao_bala_submarino:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    MOV R0, ender_lin   ; ENDEREÇO DA LINHA DO SUBMARINO
    MOV R1, ender_col   ; ENDEREÇO DA COLUNA DO SUBMARINO
    MOVB R0, [R0]   ; VALOR DA LINHA DO SUBMARINO
    MOVB R1, [R1]   ; VALOR DA COLUNA DO SUBMARINO
    MOV R4, bala_lin_col    ; ENDEREÇO DA LINHA E DA COLUNA DA BALA
    MOV R2, 0   ; INICIALIZA R2 E R3 COM 0, PARA PREVENIR ERROS NOS VALORES
    MOV R3, 0
    MOVB R2, [R4]   ; VALOR DA LINHA DA BALA
    ADD R4, 1   ; INCREMENTA O ENDEREÇO EM UMA UNIDADE (AGORA É A COLUNA)
    MOVB R3, [R4]   ; VALOR DA COLUNA DA BALA
    CMP R2, R0
    JZ verifica_colisao_1
    SUB R0, 1
    CMP R2, R0
    JZ verifica_colisao_2
    SUB R0, 1
    CMP R2, R0
    JZ verifica_colisao_3
termina_colisao_bala_submarino:
    POP R6
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

verifica_colisao_1:
    CMP R3, R1
    JLT termina_colisao_bala_submarino
    ADD R1, 5
    CMP R3, R1
    JGT termina_colisao_bala_submarino
    MOV R5, game_over
    MOV R6, ON
    MOVB [R5], R6
    JMP termina_colisao_bala_submarino

verifica_colisao_2:
    ADD R1, 3
    CMP R3, R1
    JNZ termina_colisao_bala_submarino
    MOV R5, game_over
    MOV R6, ON
    MOVB [R5], R6
    JMP termina_colisao_bala_submarino

verifica_colisao_3:
    ADD R1, 2
    CMP R3, R1
    JLT termina_colisao_bala_submarino
    ADD R1, 1
    CMP R3, R1
    JGT termina_colisao_bala_submarino
    MOV R5, game_over
    MOV R6, ON
    MOVB [R5], R6
    JMP termina_colisao_bala_submarino

fim_de_jogo:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    MOV R0, game_over
    MOVB R0, [R0]
    CMP R0, OFF
    JZ termina_fim_de_jogo
    JMP fase1
termina_fim_de_jogo:
    POP R5
    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

varredura_especial:
    ; NOTA: ATIVAR A VARREDURA APENAS QUANDO O SINAL DO RELÓGIO VARIA (0 -> 1)
    ; OU GUARDA O VALOR DA TECLA QUANDO O SINAL DO RELÓGIO VARIA (0 -> 1)
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R10    ; GUARDA TODOS OS REGISTOS ANTES DE ENTRAR NA ROTINA
    ; CASO ALGUMA TECLA SEJA PRESSIONADA, A TECLA ESTARÁ EM R7
	MOV	R0, 1   ; R0 GUARDA O VALOR DA LINHA DO TECLADO (INICIALIZA COM 1)
	MOV	R6, POUT2
    MOV R10, PIN
    MOV R1, POUT3
    MOV R8, 16  ; GUARDA O EXCESSO EM QUE LINHA NÃO DEVE CHEGAR
    JMP ciclo_var_especial
sai_varredura_especial:
    POP R10
    POP R8
    POP R7
    POP R6
    POP R4
    POP R3
    POP R1
    POP R0  ; RECUPERA OS REGISTOS ANTES DE SAIR
    RET

ciclo_var_especial:
    CMP R0, R8  ; COMPARA SE A LINHA CHEGOU NO LIMITE PROIBIDO (16)
    JZ reinicia_especial ; CASO SIM, REINICIA O VALOR DA LINHA COM 1
    MOVB [R6], R0   ; ATIVA A LINHA (R0), NO TECLADO
    MOVB R3, [R10]  ; LÊ A SAÍDA DO TECLADO QUE POR CONSEQUÊNCIA FAZ A LEITURA
    ; DOS RELÓGIOS TAMBÉM. R3 <- COLUNA DO TECLADO
    SHL R0, 1   ; PASSA A LINHA PARA O PRÓXIMO VALOR
    MOV R8, 000fH   ; COLOCA O VALOR F (HEX) TEMPORARIAMENTE EM R8
    AND R3, R8  ; OPERAÇÃO AND EM R3 COM F (HEX) PARA AFETAR OS BITS (0-3)
    MOV R8, 16  ; RESTABELECE O VALOR DE R8 PARA 16
	AND R3, R3  ; OPERAÇÃO AND EM R3 PARA SABER SE ALGUMA TECLA FOI PRESSIONA-
    ; DA, CASO SIM, BIT DE ESTADO ESTARÁ DESATIVADO, CASO NÃO...
    JZ ciclo_var_especial    ; SALTO OCORRERÁ CASO R3 SEJA IGUAL A 0
    ; UMA TECLA FOI PRESSIONADA (RESTA SABER QUAL)
    SHR R0, 1   ; VALOR DA LINHA PASSA PARA A ANTERIOR
    ; ATÉ ESTE PONTO JÁ SE SABE A LINHA E A COLUNA EM QUE SE ENCONTRA A TECLA
    ; RESTA CONVERTER EM VALOR
    CMP R0, 2   ; COMPARA SE A LINHA = 2
    JZ l2_especial

reinicia_especial:
    MOV R0, 1
    JMP sai_varredura_especial    ; NENHUMA TECLA FOI PRESSIONADA (SAI DA ROTINA)
    ; SAI E DÁ LUGAR A OUTROS PROCESSOS

l2_especial:
    ; TECLA ESTÁ NA 2ª LINHA (4, 5, 6, 7)
    MOV R4, linha2
    ADD R4, R3
    MOVB R7, [R4]
    MOVB [R1], R7   ; COLOCA O VALOR DA TECLA NO DISPLAY (HEXADECIMAL)
    ; ESTA INSTRUÇÃO DEVE SER, POSTERIORMENTE, ELIMINADA
    CMP R7, 6
    JNZ sai_varredura_especial
    CALL eliminacao_especial
    JMP infinito

; AS ROTINAS ABAIXO ESCREVEM E APAGAM "FIM" NO PIXELSCREEN, REPETIVAMENTE

escrita_especial:
    PUSH R2
    PUSH R9
    MOV R2, 10  ; PRIMEIRA LINHA
    MOV R9, 7
    ; 7,8,9,10,13,16,17,20,21
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    ADD R9, 3
    CALL pixel_xy
    ADD R9, 3
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    ADD R9, 3
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    ;****************************
    ADD R2, 1   ; SEGUNDA LINHA
    MOV R9, 7
    ; 7,16,18,19,21
    CALL pixel_xy
    ADD R9, 7
    ADD R9, 2
    CALL pixel_xy
    ADD R9, 2
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    ADD R9, 2
    CALL pixel_xy
    ;****************************
    ADD R2, 1   ; TERCEIRA LINHA
    MOV R9, 7
    ; 7,13,16,21
    CALL pixel_xy
    ADD R9, 6
    CALL pixel_xy
    ADD R9, 3
    CALL pixel_xy
    ADD R9, 5
    CALL pixel_xy
    ;****************************
    ADD R2, 1   ; QUARTA LINHA
    MOV R9, 7
    ; 7,8,9,10,13,16,21
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    ADD R9, 1
    CALL pixel_xy
    ADD R9, 3
    CALL pixel_xy
    ADD R9, 3
    CALL pixel_xy
    ADD R9, 5
    CALL pixel_xy
    ;****************************
    ADD R2, 1   ; QUINTA LINHA
    MOV R9, 7
    ; 7,13,16,21
    CALL pixel_xy
    ADD R9, 6
    CALL pixel_xy
    ADD R9, 3
    CALL pixel_xy
    ADD R9, 5
    CALL pixel_xy
    ;****************************
    ADD R2, 1   ; SEXTA LINHA
    MOV R9, 7
    ; 7,13,16,21
    CALL pixel_xy
    ADD R9, 6
    CALL pixel_xy
    ADD R9, 3
    CALL pixel_xy
    ADD R9, 5
    CALL pixel_xy
    ;****************************
    POP R9
    POP R2
    RET

eliminacao_especial:
    PUSH R2
    PUSH R9
    MOV R2, 10  ; PRIMEIRA LINHA
    MOV R9, 7
    ; 7,8,9,10,13,16,17,20,21
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    ADD R9, 3
    CALL eli_xy
    ADD R9, 3
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    ADD R9, 3
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    ;****************************
    ADD R2, 1   ; SEGUNDA LINHA
    MOV R9, 7
    ; 7,16,18,19,21
    CALL eli_xy
    ADD R9, 7
    ADD R9, 2
    CALL eli_xy
    ADD R9, 2
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    ADD R9, 2
    CALL eli_xy
    ;****************************
    ADD R2, 1   ; TERCEIRA LINHA
    MOV R9, 7
    ; 7,13,16,21
    CALL eli_xy
    ADD R9, 6
    CALL eli_xy
    ADD R9, 3
    CALL eli_xy
    ADD R9, 5
    CALL eli_xy
    ;****************************
    ADD R2, 1   ; QUARTA LINHA
    MOV R9, 7
    ; 7,8,9,10,13,16,21
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    ADD R9, 1
    CALL eli_xy
    ADD R9, 3
    CALL eli_xy
    ADD R9, 3
    CALL eli_xy
    ADD R9, 5
    CALL eli_xy
    ;****************************
    ADD R2, 1   ; QUINTA LINHA
    MOV R9, 7
    ; 7,13,16,21
    CALL eli_xy
    ADD R9, 6
    CALL eli_xy
    ADD R9, 3
    CALL eli_xy
    ADD R9, 5
    CALL eli_xy
    ;****************************
    ADD R2, 1   ; SEXTA LINHA
    MOV R9, 7
    ; 7,13,16,21
    CALL eli_xy
    ADD R9, 6
    CALL eli_xy
    ADD R9, 3
    CALL eli_xy
    ADD R9, 5
    CALL eli_xy
    ;****************************
    POP R9
    POP R2
    RET
