        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(2)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB

SYSCTL_RCGCGPIO_R       EQU     0x400FE608
SYSCTL_PRGPIO_R		EQU     0x400FEA08
PORTS_BITS              EQU     0001000100100000b ; bit 5 = Port F 


GPIO_PORTN_DATA_R    	EQU     0x40064000
GPIO_PORTN_DIR_R     	EQU     0x40064400
GPIO_PORTN_DEN_R     	EQU     0x4006451C

GPIO_PORTF_DATA_R    	EQU     0x4005D000
GPIO_PORTF_DIR_R     	EQU     0x4005D400
GPIO_PORTF_DEN_R     	EQU     0x4005D51C

GPIO_PORTJ_DATA_R    	EQU     0x40060000
GPIO_PORTJ_DIR_R     	EQU     0x40060400
GPIO_PORTJ_DEN_R     	EQU     0x4006051C
GPIO_PORTJ_PUR_R        EQU     0x40060510

__iar_program_start

main    MOV R0, #PORTS_BITS
        BL iniciaport

        LDR R0, =GPIO_PORTN_DATA_R
        LDR R1, =GPIO_PORTN_DIR_R
        LDR R2, =GPIO_PORTN_DEN_R
        MOV R3, #000000011b 
        BL conf_output
        MOV R4, #000000000b
        STR R4, [R0, R3, LSL #2] 
        
        LDR R0, =GPIO_PORTF_DATA_R
        LDR R1, =GPIO_PORTF_DIR_R
        LDR R2, =GPIO_PORTF_DEN_R
        MOV R3, #000010001b  
        BL conf_output
        MOV R4, #000000000b
        STR R4, [R0, R3, LSL #2] 
        
        MOV R0, #00010011b ; 
        BL conf_input
              
        MOV R0, #1b
loop
        LDR R1, =GPIO_PORTJ_DATA_R
        MOV R2, #000000011b
        LDR R3, [R1, R2, LSL #2]
        
        CMP R3, #000000001b                             ; -> le o botao PJ0 e se estiver pressionado adiciona um na variavel
        IT EQ
          ADDEQ R0, R0, #1b
          
        CMP R3, #000000010b                             ; -> le o botao PJ1 e se estiver pressionado subtrai um na variavel
        IT EQ
          SUBEQ R0, R0, #1b
//        MOVS R4, R3 ;salva estado do botao 
//
//reading_loop
//        LDR 
//
//if_not_pressed
//        MOV R3, R4  
//        BL delay
//
//if_pressed      
//        CMP R3, #1b 
//        IT EQ
//          ADDEQ R0, R0, #1
//        
//        CMP R3, #10b 
//        IT EQ
//          SUBEQ R0, R0, #1
        
//loop        
        Bl cont
        B loop

             
        
cont    PUSH {LR, R3, R4}

        LDR R1, =GPIO_PORTN_DATA_R
        MOV R2, #000000011b
        
        AND R4, R0, #0011b
        LSR R3, R4, #1
        LSL R4, R4, #1
        ADD R4, R3
        STR R4, [R1, R2, LSL #2]
		
	LDR R1, =GPIO_PORTF_DATA_R
        MOV R2, #000010001b

        AND R3, R0, #0100b
        LSL R4, R3, #2
        
        AND R3, R0, #1000b
        LSR R3, R3, #3
        ADD R4, R3
		
        STR R4, [R1, R2, LSL #2]
        POP {R4, R3}
        BL delay
        POP {LR}
        BX LR
        

delay   PUSH {R4}
        MOVT R4, #0x005F; constante de atraso 
delayinit
        CBZ R4, ret     ; 1 clock
        SUB R4, R4, #1  ; 1 clock
        B delayinit     ; 3 clocks
ret     POP {R4}
        BX LR

        
iniciaport	
        LDR R2, =SYSCTL_RCGCGPIO_R 
	LDR R1, [R2] 
	ORR R1, R0  
	STR R1, [R2] 

        LDR R2, =SYSCTL_PRGPIO_R
wait	LDR R0, [R2] 
	TEQ R1, R0 
	BNE wait 

        BX LR

conf_output
	LDR R4, [R1] ; leitura do estado anterior
	ORR R4, R3 ; bit de sa�da
	STR R4, [R1] ; escrita do novo estado

	LDR R4, [R2] ; leitura do estado anterior
	ORR R4, R3 ; habilita fun��o digital
	STR R4, [R2] ; escrita do novo estado

        BX LR
        
conf_input
        LDR R2, =GPIO_PORTJ_DIR_R
        LDR R1, [R2]
        BIC R1, R0   
        STR R1, [R2] 
         
        LDR R2, =GPIO_PORTJ_DEN_R
        LDR R1, [R2]
        ORR R1, R0  
        STR R1, [R2]
            
        LDR R2, =GPIO_PORTJ_PUR_R    
        LDR R1, [R2]
        ORR R1, R0
        STR R1, [R2]

        BX LR
       
 
        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     sfe(CSTACK)
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler

        END