;--------------------------------------------------------------------------------------------------------------

;Autor:       ALEJANDRO SANCHEZ
;Titulo:      CONTROL DE MOTOR
;Fecha:
;Descripcion: control de motor por variacion de temperatura
;---------------------------------------------------------------------------------------------------------------
__config _CP_OFF & _XT_OSC & _WDT_OFF & _PWRTE_ON & _LVP_OFF & _BODEN_OFF
  LIST   P=16F877A             ;PIC A USAR
  INCLUDE <P16F877A.INC>


;---------------------------------------------------------------------------------------------------------------
errorlevel -302 ;suppress "not in bank 0" message
errorlevel -203 ; elimina mensaje de error
errorlevel -305 ; elimina mensaje de error
errorlevel -205 ; elimina mensaje de error
;---------------------------------------------------------------------------------------------------------------
CBLOCK 0x20
PDel0,PDel1, PDel, PDe
ENDC

;---------------------------------------------------------------------------------------------------------------

ORG   0x00      ; INICIO DE PROGRAMA

CLRF     PORTB 
BSF      STATUS,5
CLRF     ADCON1
MOVLW    B'00001110'
MOVWF    ADCON1
MOVLW    B'00000001'
MOVWF    TRISA
CLRF     TRISB
CLRF     TRISC
MOVLW    D'255'
MOVWF    PR2 ; respecto al valor asignado variar mi periodo pwm
BCF      STATUS,5
;
;*******************************************************************************************

; SELECCIONO CANAL DE ENTRADA A CONVERTIR CHS2-0
; SELECIONO EL RELOJ DE CONVERSION  BITS 7-6
; ENERGIZO EL CONVERTIDOR
;
MOVLW   B'01000001'
MOVWF   ADCON0
;
BCF    STATUS,5
CICLO
CALL   RETARDO_20ms       ; TIEMPO DE ADQUISICION

; INICIA LA CONVERSION

BSF        ADCON0,GO
ESPERA
BTFSC      ADCON0,GO
GOTO       ESPERA         ; VERIFICO SI GO ES CERO

MOVF       ADRESL,W       ; LEO EL RESULTADO DE LA CONVERSION A/D
MOVWF      PORTB
CALL       retardo_1ms
BCF        STATUS,5
;
;
;PWM 
MOVF   ADRESH,W
MOVWF  CCPR1L             ;respecto al valor asignado variar mi duty cycle

MOVLW  B'00001100'
MOVWF  CCP1CON            ;hablito el TMR2y habilito mi salida ccp1 pin 17 del pic

MOVLW  B'00000111'
MOVWF  T2CON              ;prescaler TMR2 = 16, enciende el TMR2



GOTO   CICLO



;----------------------------------------------------------------------------------------
;                                       SUBRUTINAS
;----------------------------------------------------------------------------------------

RETARDO_20ms
        movlw     .21       ; 1 set number of repetitions (B)
        movwf     PDel0     ; 1 |
PLoop1  movlw     .237      ; 1 set number of repetitions (A)
        movwf     PDel1     ; 1 |
PLoop2  clrwdt              ; 1 clear watchdog
        decfsz    PDel1, 1  ; 1 + (1) is the time over? (A)
        goto      PLoop2    ; 2 no, loop
        decfsz    PDel0, 1  ; 1 + (1) is the time over? (B)
        goto      PLoop1    ; 2 no, loop
PDelL1  goto      PDelL2    ; 2 cycles delay
PDelL2  clrwdt              ; 1 cycle delay
        return              ; 2+2 Done


retardo_1ms
        movlw     .248      ; 1 set number of repetitions
        movwf     PDe     ; 1 |
PLoopx  clrwdt              ; 1 clear watchdog
        decfsz    PDel, 1  ; 1 + (1) is the time over?
        goto      PLoopx    ; 2 no, loop
PDelL   goto      PDelLx    ; 2 cycles delay
PDelLx  clrwdt              ; 1 cycle delay
        return              ; 2+2 Done
;



END