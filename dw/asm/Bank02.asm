.segment "BANK_02"
.org $8000

.include "Defines.inc"

;--------------------------------------[ Imports ]--------------------------------------

; Import Bank01 functions for BRK mechanism
.import InitMusicSFX

;--------------------------------------[ Forward declarations ]--------------------------------------

GetJoypadStatus = $C608
PrepSPPalLoad   = $C632
PrepBGPalLoad   = $C63D
AddPPUBufEntry  = $C690
WaitForNMI      = $FF74
_DoReset        = $FF8E

;-----------------------------------------[ Start of code ]------------------------------------------

;The following table contains functions called from bank 3 through the IRQ interrupt.

BankPointers:
L8000:  .word DoIntroRoutine    ;($BCB0)
L8002:  .word TextBlock1        ;($8028)
L8004:  .word TextBlock2        ;($8286)
L8006:  .word TextBlock3        ;($8519)
L8008:  .word TextBlock4        ;($8713)
L800A:  .word TextBlock5        ;($894C)
L800C:  .word TextBlock6        ;($8D12)
L800E:  .word TextBlock7        ;($906E)
L8010:  .word TextBlock8        ;($9442)
L8012:  .word TextBlock9        ;($981E)
L8014:  .word TextBlock10       ;($9C88)
L8016:  .word TextBlock11       ;($9F3F)
L8018:  .word TextBlock12       ;($A28A)
L801A:  .word TextBlock13       ;($A6DC)
L801C:  .word TextBlock14       ;($AA2E)
L801E:  .word TextBlock15       ;($AC61)
L8020:  .word TextBlock16       ;($AE28)
L8022:  .word TextBlock17       ;($AFEE)
L8024:  .word TextBlock18       ;($B68B)
L8026:  .word TextBlock19       ;($BA65)

;-------------------------------------------[Game Dialog]--------------------------------------------

;The text below has special control characters in it.  The following is a description
;of those special control characters:

;PLRL - Prints the letter "s " or " "(space).
;PNTS - Prints the word "Point" or "Points".
;ENM2 - An enemy's name, preceeded by "a" or "an".
;AMTP - Displays a numeric value followed by "Point" or "Points".
;ENMY - An enemy's name.
;AMNT - Displays a numeric value.
;SPEL - A spell's name.
;ITEM - An item's name.
;NAME - The player's name.
;WAIT - Wait for the user to press a button.
;INDT - Indent any following text lines by 1 space.
;END  - End of text.
;\n   - New line.

TextBlock1:
TB1E0:
.incbin "bin/Bank02/TB1E0.bin"
TB1E1:
.incbin "bin/Bank02/TB1E1.bin"
TB1E2:
.incbin "bin/Bank02/TB1E2.bin"
TB1E3:
.incbin "bin/Bank02/TB1E3.bin"
TB1E4:
.incbin "bin/Bank02/TB1E4.bin"
TB1E5:
.incbin "bin/Bank02/TB1E5.bin"
TB1E6:
.incbin "bin/Bank02/TB1E6.bin"
TB1E7:
.incbin "bin/Bank02/TB1E7.bin"
TB1E8:
.incbin "bin/Bank02/TB1E8.bin"
TB1E9:
;              '    G    o    o    d    _    n    i    g    h    t    .'   \n  END  
L819D:  .byte $50, $2A, $18, $18, $0D, $5F, $17, $12, $10, $11, $1D, $52, $FD, $FC

;----------------------------------------------------------------------------------------------------

TB1E10:
.incbin "bin/Bank02/TB1E10.bin"
TB1E11:
.incbin "bin/Bank02/TB1E11.bin"
TB1E12:
.incbin "bin/Bank02/TB1E12.bin"
TB1E13:
.incbin "bin/Bank02/TB1E13.bin"
TB1E14:
.incbin "bin/Bank02/TB1E14.bin"
TB1E15:
.incbin "bin/Bank02/TB1E15.bin"
TextBlock2:
TB2E0:
.incbin "bin/Bank02/TB2E0.bin"
TB2E1:
.incbin "bin/Bank02/TB2E1.bin"
TB2E2:
.incbin "bin/Bank02/TB2E2.bin"
TB2E3:
.incbin "bin/Bank02/TB2E3.bin"
TB2E4:
.incbin "bin/Bank02/TB2E4.bin"
TB2E5:
.incbin "bin/Bank02/TB2E5.bin"
TB2E6:
.incbin "bin/Bank02/TB2E6.bin"
TB2E7:
;              '    I    _    a    m    _    s    o    r    r    y    .'  WAIT END  
L83FC:  .byte $50, $2C, $5F, $0A, $16, $5F, $1C, $18, $1B, $1B, $22, $52, $FB, $FC

;----------------------------------------------------------------------------------------------------

TB2E8:
.incbin "bin/Bank02/TB2E8.bin"
TB2E9:
.incbin "bin/Bank02/TB2E9.bin"
TB2E10:
.incbin "bin/Bank02/TB2E10.bin"
TB2E11:
.incbin "bin/Bank02/TB2E11.bin"
TB2E12:
.incbin "bin/Bank02/TB2E12.bin"
TB2E13:
.incbin "bin/Bank02/TB2E13.bin"
TB2E14:
.incbin "bin/Bank02/TB2E14.bin"
TB2E15:
.incbin "bin/Bank02/TB2E15.bin"
TextBlock3:
TB3E0:
.incbin "bin/Bank02/TB3E0.bin"
TB3E1:
.incbin "bin/Bank02/TB3E1.bin"
TB3E2:
.incbin "bin/Bank02/TB3E2.bin"
TB3E3:
.incbin "bin/Bank02/TB3E3.bin"
TB3E4:
.incbin "bin/Bank02/TB3E4.bin"
TB3E5:
.incbin "bin/Bank02/TB3E5.bin"
TB3E6:
.incbin "bin/Bank02/TB3E6.bin"
TB3E7:
.incbin "bin/Bank02/TB3E7.bin"
TB3E8:
.incbin "bin/Bank02/TB3E8.bin"
TB3E9:
;              '    T    h    e    _   ITEM  ?    '   WAIT END  
L8654:  .byte $50, $37, $11, $0E, $5F, $F7, $4B, $40, $FB, $FC

;----------------------------------------------------------------------------------------------------

TB3E10:
.incbin "bin/Bank02/TB3E10.bin"
TB3E11:
.incbin "bin/Bank02/TB3E11.bin"
TB3E12:
.incbin "bin/Bank02/TB3E12.bin"
TB3E13:
.incbin "bin/Bank02/TB3E13.bin"
TB3E14:
;              '    I    _    t    h    a    n    k    _    t    h    e    e    .'   \n  END  
L86EE:  .byte $50, $2C, $5F, $1D, $11, $0A, $17, $14, $5F, $1D, $11, $0E, $0E, $52, $FD, $FC

;----------------------------------------------------------------------------------------------------

TB3E15:
.incbin "bin/Bank02/TB3E15.bin"
TextBlock4:
TB4E0:
.incbin "bin/Bank02/TB4E0.bin"
TB4E1:
.incbin "bin/Bank02/TB4E1.bin"
TB4E2:
.incbin "bin/Bank02/TB4E2.bin"
TB4E3:
.incbin "bin/Bank02/TB4E3.bin"
TB4E4:
.incbin "bin/Bank02/TB4E4.bin"
TB4E5:
.incbin "bin/Bank02/TB4E5.bin"
TB4E6:
.incbin "bin/Bank02/TB4E6.bin"
TB4E7:
.incbin "bin/Bank02/TB4E7.bin"
TB4E8:
.incbin "bin/Bank02/TB4E8.bin"
TB4E9:
.incbin "bin/Bank02/TB4E9.bin"
TB4E10:
.incbin "bin/Bank02/TB4E10.bin"
TB4E11:
.incbin "bin/Bank02/TB4E11.bin"
TB4E12:
.incbin "bin/Bank02/TB4E12.bin"
TB4E13:
.incbin "bin/Bank02/TB4E13.bin"
TB4E14:
.incbin "bin/Bank02/TB4E14.bin"
TB4E15:
.incbin "bin/Bank02/TB4E15.bin"
TextBlock5:
TB5E0:
.incbin "bin/Bank02/TB5E0.bin"
TB5E1:
.incbin "bin/Bank02/TB5E1.bin"
TB5E2:
.incbin "bin/Bank02/TB5E2.bin"
TB5E3:
.incbin "bin/Bank02/TB5E3.bin"
TB5E4:
.incbin "bin/Bank02/TB5E4.bin"
TB5E5:
.incbin "bin/Bank02/TB5E5.bin"
TB5E6:
.incbin "bin/Bank02/TB5E6.bin"
TB5E7:
.incbin "bin/Bank02/TB5E7.bin"
TB5E8:
.incbin "bin/Bank02/TB5E8.bin"
TB5E9:
.incbin "bin/Bank02/TB5E9.bin"
TB5E10:
.incbin "bin/Bank02/TB5E10.bin"
TB5E11:
.incbin "bin/Bank02/TB5E11.bin"
TB5E12:
.incbin "bin/Bank02/TB5E12.bin"
TB5E13:
.incbin "bin/Bank02/TB5E13.bin"
TB5E14:
.incbin "bin/Bank02/TB5E14.bin"
TB5E15:
.incbin "bin/Bank02/TB5E15.bin"
TextBlock6:
TB6E0:
.incbin "bin/Bank02/TB6E0.bin"
TB6E1:
.incbin "bin/Bank02/TB6E1.bin"
TB6E2:
.incbin "bin/Bank02/TB6E2.bin"
TB6E3:
.incbin "bin/Bank02/TB6E3.bin"
TB6E4:
.incbin "bin/Bank02/TB6E4.bin"
TB6E5:
.incbin "bin/Bank02/TB6E5.bin"
TB6E6:
.incbin "bin/Bank02/TB6E6.bin"
TB6E7:
.incbin "bin/Bank02/TB6E7.bin"
TB6E8:
.incbin "bin/Bank02/TB6E8.bin"
TB6E9:
.incbin "bin/Bank02/TB6E9.bin"
TB6E10:
.incbin "bin/Bank02/TB6E10.bin"
TB6E11:
.incbin "bin/Bank02/TB6E11.bin"
TB6E12:
.incbin "bin/Bank02/TB6E12.bin"
TB6E13:
.incbin "bin/Bank02/TB6E13.bin"
TB6E14:
.incbin "bin/Bank02/TB6E14.bin"
TB6E15:
.incbin "bin/Bank02/TB6E15.bin"
TextBlock7:
TB7E0:
.incbin "bin/Bank02/TB7E0.bin"
TB7E1:
.incbin "bin/Bank02/TB7E1.bin"
TB7E2:
.incbin "bin/Bank02/TB7E2.bin"
TB7E3:
.incbin "bin/Bank02/TB7E3.bin"
TB7E4:
.incbin "bin/Bank02/TB7E4.bin"
TB7E5:
.incbin "bin/Bank02/TB7E5.bin"
TB7E6:
.incbin "bin/Bank02/TB7E6.bin"
TB7E7:
.incbin "bin/Bank02/TB7E7.bin"
TB7E8:
.incbin "bin/Bank02/TB7E8.bin"
TB7E9:
.incbin "bin/Bank02/TB7E9.bin"
TB7E10:
.incbin "bin/Bank02/TB7E10.bin"
TB7E11:
.incbin "bin/Bank02/TB7E11.bin"
TB7E12:
.incbin "bin/Bank02/TB7E12.bin"
TB7E13:
.incbin "bin/Bank02/TB7E13.bin"
TB7E14:
.incbin "bin/Bank02/TB7E14.bin"
TB7E15:
.incbin "bin/Bank02/TB7E15.bin"
TextBlock8:
TB8E0:
.incbin "bin/Bank02/TB8E0.bin"
TB8E1:
.incbin "bin/Bank02/TB8E1.bin"
TB8E2:
.incbin "bin/Bank02/TB8E2.bin"
TB8E3:
.incbin "bin/Bank02/TB8E3.bin"
TB8E4:
.incbin "bin/Bank02/TB8E4.bin"
TB8E5:
.incbin "bin/Bank02/TB8E5.bin"
TB8E6:
.incbin "bin/Bank02/TB8E6.bin"
TB8E7:
.incbin "bin/Bank02/TB8E7.bin"
TB8E8:
.incbin "bin/Bank02/TB8E8.bin"
TB8E9:
.incbin "bin/Bank02/TB8E9.bin"
TB8E10:
.incbin "bin/Bank02/TB8E10.bin"
TB8E11:
.incbin "bin/Bank02/TB8E11.bin"
TB8E12:
.incbin "bin/Bank02/TB8E12.bin"
TB8E13:
.incbin "bin/Bank02/TB8E13.bin"
TB8E14:
;              '    W    e    l    c    o    m    e    !    '   END  
L97DB:  .byte $50, $3A, $0E, $15, $0C, $18, $16, $0E, $4C, $40, $FC

;----------------------------------------------------------------------------------------------------

TB8E15:
.incbin "bin/Bank02/TB8E15.bin"
TextBlock9:
TB9E0:
.incbin "bin/Bank02/TB9E0.bin"
TB9E1:
.incbin "bin/Bank02/TB9E1.bin"
TB9E2:
.incbin "bin/Bank02/TB9E2.bin"
TB9E3:
.incbin "bin/Bank02/TB9E3.bin"
TB9E4:
.incbin "bin/Bank02/TB9E4.bin"
TB9E5:
.incbin "bin/Bank02/TB9E5.bin"
TB9E6:
.incbin "bin/Bank02/TB9E6.bin"
TB9E7:
.incbin "bin/Bank02/TB9E7.bin"
TB9E8:
.incbin "bin/Bank02/TB9E8.bin"
TB9E9:
.incbin "bin/Bank02/TB9E9.bin"
TB9E10:
.incbin "bin/Bank02/TB9E10.bin"
TB9E11:
.incbin "bin/Bank02/TB9E11.bin"
TB9E12:
.incbin "bin/Bank02/TB9E12.bin"
TB9E13:
.incbin "bin/Bank02/TB9E13.bin"
TB9E14:
.incbin "bin/Bank02/TB9E14.bin"
TB9E15:
.incbin "bin/Bank02/TB9E15.bin"
TextBlock10:
TB10E0:
.incbin "bin/Bank02/TB10E0.bin"
TB10E1:
.incbin "bin/Bank02/TB10E1.bin"
TB10E2:
.incbin "bin/Bank02/TB10E2.bin"
TB10E3:
.incbin "bin/Bank02/TB10E3.bin"
TB10E4:
.incbin "bin/Bank02/TB10E4.bin"
TB10E5:
.incbin "bin/Bank02/TB10E5.bin"
TB10E6:
;             END  
L9D80:  .byte $FC

;----------------------------------------------------------------------------------------------------

TB10E7:
.incbin "bin/Bank02/TB10E7.bin"
TB10E8:
.incbin "bin/Bank02/TB10E8.bin"
TB10E9:
.incbin "bin/Bank02/TB10E9.bin"
TB10E10:
.incbin "bin/Bank02/TB10E10.bin"
TB10E11:
.incbin "bin/Bank02/TB10E11.bin"
TB10E12:
.incbin "bin/Bank02/TB10E12.bin"
TB10E13:
.incbin "bin/Bank02/TB10E13.bin"
TB10E14:
.incbin "bin/Bank02/TB10E14.bin"
TB10E15:
.incbin "bin/Bank02/TB10E15.bin"
TextBlock11:
TB11E0:
.incbin "bin/Bank02/TB11E0.bin"
TB11E1:
.incbin "bin/Bank02/TB11E1.bin"
TB11E2:
.incbin "bin/Bank02/TB11E2.bin"
TB11E3:
;              '    O    h    ,    _    b    r    a    v    e    _   NAME  .'  END  
LA016:  .byte $50, $32, $11, $48, $5F, $0B, $1B, $0A, $1F, $0E, $5F, $F8, $52, $FC

;----------------------------------------------------------------------------------------------------

TB11E4:
.incbin "bin/Bank02/TB11E4.bin"
TB11E5:
.incbin "bin/Bank02/TB11E5.bin"
TB11E6:
.incbin "bin/Bank02/TB11E6.bin"
TB11E7:
.incbin "bin/Bank02/TB11E7.bin"
TB11E8:
;              '    N    o    w    ,    _    g    o    .'  END  
LA0BF:  .byte $50, $31, $18, $20, $48, $5F, $10, $18, $52, $FC

;----------------------------------------------------------------------------------------------------

TB11E9:
.incbin "bin/Bank02/TB11E9.bin"
TB11E10:
.incbin "bin/Bank02/TB11E10.bin"
TB11E11:
.incbin "bin/Bank02/TB11E11.bin"
TB11E12:
.incbin "bin/Bank02/TB11E12.bin"
TB11E13:
.incbin "bin/Bank02/TB11E13.bin"
TB11E14:
.incbin "bin/Bank02/TB11E14.bin"
TB11E15:
.incbin "bin/Bank02/TB11E15.bin"
TextBlock12:
TB12E0:
.incbin "bin/Bank02/TB12E0.bin"
TB12E1:
.incbin "bin/Bank02/TB12E1.bin"
TB12E2:
.incbin "bin/Bank02/TB12E2.bin"
TB12E3:
.incbin "bin/Bank02/TB12E3.bin"
TB12E4:
.incbin "bin/Bank02/TB12E4.bin"
TB12E5:
.incbin "bin/Bank02/TB12E5.bin"
TB12E6:
.incbin "bin/Bank02/TB12E6.bin"
TB12E7:
.incbin "bin/Bank02/TB12E7.bin"
TB12E8:
;              '    I    '    m    _    s    o    _    h    a    p    p    y    !    '   END  
LA4BB:  .byte $50, $2C, $53, $16, $5F, $1C, $18, $5F, $11, $0A, $19, $19, $22, $4C, $40, $FC

;----------------------------------------------------------------------------------------------------

TB12E9:
.incbin "bin/Bank02/TB12E9.bin"
TB12E10:
.incbin "bin/Bank02/TB12E10.bin"
TB12E11:
.incbin "bin/Bank02/TB12E11.bin"
TB12E12:
;             WAIT  '    F    a    r    e    w    e    l    l    ,    _   NAME  .'  WAIT END  
LA64F:  .byte $FB, $50, $29, $0A, $1B, $0E, $20, $0E, $15, $15, $48, $5F, $F8, $52, $FB, $FC

;----------------------------------------------------------------------------------------------------

TB12E13:
.incbin "bin/Bank02/TB12E13.bin"
TB12E14:
.incbin "bin/Bank02/TB12E14.bin"
TB12E15:
.incbin "bin/Bank02/TB12E15.bin"
TextBlock13:
TB13E0:
.incbin "bin/Bank02/TB13E0.bin"
TB13E1:
.incbin "bin/Bank02/TB13E1.bin"
TB13E2:
.incbin "bin/Bank02/TB13E2.bin"
TB13E3:
;             END  
LA7AC:  .byte $FC

;----------------------------------------------------------------------------------------------------

TB13E4:
.incbin "bin/Bank02/TB13E4.bin"
TB13E5:
.incbin "bin/Bank02/TB13E5.bin"
TB13E6:
.incbin "bin/Bank02/TB13E6.bin"
TB13E7:
.incbin "bin/Bank02/TB13E7.bin"
TB13E8:
.incbin "bin/Bank02/TB13E8.bin"
TB13E9:
.incbin "bin/Bank02/TB13E9.bin"
TB13E10:
.incbin "bin/Bank02/TB13E10.bin"
TB13E11:
.incbin "bin/Bank02/TB13E11.bin"
TB13E12:
.incbin "bin/Bank02/TB13E12.bin"
TB13E13:
.incbin "bin/Bank02/TB13E13.bin"
TB13E14:
.incbin "bin/Bank02/TB13E14.bin"
TB13E15:
.incbin "bin/Bank02/TB13E15.bin"
TextBlock14:
TB14E0:
.incbin "bin/Bank02/TB14E0.bin"
TB14E1:
.incbin "bin/Bank02/TB14E1.bin"
TB14E2:
.incbin "bin/Bank02/TB14E2.bin"
TB14E3:
.incbin "bin/Bank02/TB14E3.bin"
TB14E4:
.incbin "bin/Bank02/TB14E4.bin"
TB14E5:
.incbin "bin/Bank02/TB14E5.bin"
TB14E6:
.incbin "bin/Bank02/TB14E6.bin"
TB14E7:
.incbin "bin/Bank02/TB14E7.bin"
TB14E8:
.incbin "bin/Bank02/TB14E8.bin"
TB14E9:
.incbin "bin/Bank02/TB14E9.bin"
TB14E10:
.incbin "bin/Bank02/TB14E10.bin"
TB14E11:
.incbin "bin/Bank02/TB14E11.bin"
TB14E12:
.incbin "bin/Bank02/TB14E12.bin"
TB14E13:
;             END  
LAC36:  .byte $FC

;----------------------------------------------------------------------------------------------------

TB14E14:
.incbin "bin/Bank02/TB14E14.bin"
TB14E15:
.incbin "bin/Bank02/TB14E15.bin"
TextBlock15:
TB15E0:
.incbin "bin/Bank02/TB15E0.bin"
TB15E1:
.incbin "bin/Bank02/TB15E1.bin"
TB15E2:
;              A   ENM2  _    d    r    a    w    s    _    n    e    a    r    !   END  
LAC83:  .byte $24, $F1, $5F, $0D, $1B, $0A, $20, $1C, $5F, $17, $0E, $0A, $1B, $4C, $FC

;----------------------------------------------------------------------------------------------------

TB15E3:
.incbin "bin/Bank02/TB15E3.bin"
TB15E4:
.incbin "bin/Bank02/TB15E4.bin"
TB15E5:
;             NAME  _    a    t    t    a    c    k    s    !   END  
LACD0:  .byte $F8, $5F, $0A, $1D, $1D, $0A, $0C, $14, $1C, $4C, $FC

;----------------------------------------------------------------------------------------------------

TB15E6:
.incbin "bin/Bank02/TB15E6.bin"
TB15E7:
.incbin "bin/Bank02/TB15E7.bin"
TB15E8:
;              _    \n   C    o    m    m    a    n    d    ?   END  
LAD37:  .byte $60, $FD, $26, $18, $16, $16, $0A, $17, $0D, $4B, $FC

;----------------------------------------------------------------------------------------------------

TB15E9:
.incbin "bin/Bank02/TB15E9.bin"
TB15E10:
.incbin "bin/Bank02/TB15E10.bin"
TB15E11:
.incbin "bin/Bank02/TB15E11.bin"
TB15E12:
.incbin "bin/Bank02/TB15E12.bin"
TB15E13:
.incbin "bin/Bank02/TB15E13.bin"
TB15E14:
.incbin "bin/Bank02/TB15E14.bin"
TB15E15:
.incbin "bin/Bank02/TB15E15.bin"
TextBlock16:
TB16E0:
.incbin "bin/Bank02/TB16E0.bin"
TB16E1:
.incbin "bin/Bank02/TB16E1.bin"
TB16E2:
.incbin "bin/Bank02/TB16E2.bin"
TB16E3:
.incbin "bin/Bank02/TB16E3.bin"
TB16E4:
;             ENMY  _    l    o    o    k    s    _    h    a    p    p    y    .   END  
LAEEE:  .byte $F4, $5F, $15, $18, $18, $14, $1C, $5F, $11, $0A, $19, $19, $22, $47, $FC

;----------------------------------------------------------------------------------------------------

TB16E5:
.incbin "bin/Bank02/TB16E5.bin"
TB16E6:
.incbin "bin/Bank02/TB16E6.bin"
TB16E7:
.incbin "bin/Bank02/TB16E7.bin"
TB16E8:
.incbin "bin/Bank02/TB16E8.bin"
TB16E9:
.incbin "bin/Bank02/TB16E9.bin"
TB16E10:
.incbin "bin/Bank02/TB16E10.bin"
TB16E11:
.incbin "bin/Bank02/TB16E11.bin"
TB16E12:
;              _    \n  ENMY END  
LAFA2:  .byte $60, $FD, $F4, $FC

;----------------------------------------------------------------------------------------------------

TB16E13:
.incbin "bin/Bank02/TB16E13.bin"
TB16E14:
.incbin "bin/Bank02/TB16E14.bin"
TB16E15:
.incbin "bin/Bank02/TB16E15.bin"
TextBlock17:
TB17E0:
.incbin "bin/Bank02/TB17E0.bin"
TB17E1:
.incbin "bin/Bank02/TB17E1.bin"
TB17E2:
.incbin "bin/Bank02/TB17E2.bin"
TB17E3:
.incbin "bin/Bank02/TB17E3.bin"
TB17E4:
;              E    x    c    e    l    l    e    n    t    _    m    o    v    e    !   END  
LB523:  .byte $28, $21, $0C, $0E, $15, $15, $0E, $17, $1D, $5F, $16, $18, $1F, $0E, $4C, $FC

;----------------------------------------------------------------------------------------------------

TB17E5:
.incbin "bin/Bank02/TB17E5.bin"
TB17E6:
.incbin "bin/Bank02/TB17E6.bin"
TB17E7:
.incbin "bin/Bank02/TB17E7.bin"
TB17E8:
;              _    \n  NAME  _    a    w    a    k    e    s    .   END  
LB5A0:  .byte $60, $FD, $F8, $5F, $0A, $20, $0A, $14, $0E, $1C, $47, $FC

;----------------------------------------------------------------------------------------------------

TB17E9:
.incbin "bin/Bank02/TB17E9.bin"
TB17E10:
;              I    t    _    i    s    _    d    o    d    g    i    n    g    !   END  
LB5C2:  .byte $2C, $1D, $5F, $12, $1C, $5F, $0D, $18, $0D, $10, $12, $17, $10, $4C, $FC

;----------------------------------------------------------------------------------------------------

TB17E11:
.incbin "bin/Bank02/TB17E11.bin"
TB17E12:
.incbin "bin/Bank02/TB17E12.bin"
TB17E13:
.incbin "bin/Bank02/TB17E13.bin"
TB17E14:
.incbin "bin/Bank02/TB17E14.bin"
TB17E15:
.incbin "bin/Bank02/TB17E15.bin"
TextBlock18:
TB18E0:
.incbin "bin/Bank02/TB18E0.bin"
TB18E1:
.incbin "bin/Bank02/TB18E1.bin"
TB18E2:
.incbin "bin/Bank02/TB18E2.bin"
TB18E3:
;              '    N    o    w    ,    _    g    o    ,    _   NAME  !    '   END  
LB710:  .byte $50, $31, $18, $20, $48, $5F, $10, $18, $48, $5F, $F8, $4C, $40, $FC

;----------------------------------------------------------------------------------------------------

TB18E4:
.incbin "bin/Bank02/TB18E4.bin"
TB18E5:
;              '    ..   ..   '   END  
LB757:  .byte $50, $45, $45, $40, $FC

;----------------------------------------------------------------------------------------------------

TB18E6:
;              '    R    e    a    l    l    y    ?    '    \n  END  
LB75C:  .byte $50, $35, $0E, $0A, $15, $15, $22, $4B, $40, $FD, $FC

;----------------------------------------------------------------------------------------------------

TB18E7:
.incbin "bin/Bank02/TB18E7.bin"
TB18E8:
.incbin "bin/Bank02/TB18E8.bin"
TB18E9:
.incbin "bin/Bank02/TB18E9.bin"
TB18E10:
.incbin "bin/Bank02/TB18E10.bin"
TB18E11:
.incbin "bin/Bank02/TB18E11.bin"
TB18E12:
.incbin "bin/Bank02/TB18E12.bin"
TB18E13:
.incbin "bin/Bank02/TB18E13.bin"
TB18E14:
.incbin "bin/Bank02/TB18E14.bin"
TB18E15:
.incbin "bin/Bank02/TB18E15.bin"
TextBlock19:
TB19E0:
.incbin "bin/Bank02/TB19E0.bin"
TB19E1:
.incbin "bin/Bank02/TB19E1.bin"
TB19E2:
.incbin "bin/Bank02/TB19E2.bin"
TB19E3:
.incbin "bin/Bank02/TB19E3.bin"
TB19E4:
.incbin "bin/Bank02/TB19E4.bin"
TB19E5:
.incbin "bin/Bank02/TB19E5.bin"
TB19E6:
.incbin "bin/Bank02/TB19E6.bin"
TB19E7:
;              '    G    o    _   NAME  !    '   END  
LBBC5:  .byte $50, $2A, $18, $5F, $F8, $4C, $40, $FC

;----------------------------------------------------------------------------------------------------

TB19E8:
.incbin "bin/Bank02/TB19E8.bin"
TB19E9:
.incbin "bin/Bank02/TB19E9.bin"
DoIntroRoutine:
LBCB0:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
LBCB3:  LDA IntroPalPtr1        ;
LBCB6:  STA PalPtrLB            ;Get pointer to palette data.
LBCB8:  LDA IntroPalPtr1+1      ;
LBCBB:  STA PalPtrUB            ;Hide intro text.

LBCBD:  LDA #$00                ;No palette modification.
LBCBF:  STA PalModByte          ;

LBCC1:  JSR PrepBGPalLoad       ;($C63D)Setup PPU buffer
LBCC4:  JSR SetBlackBackDrop    ;($BDE0)Set black background.

LBCC7:  LDA #MSC_INTRO          ;Start intro music.
LBCC9:  BRK                     ;
LBCCA:  .byte $04, $17          ;($81A0)InitMusicSFX, bank 1.

LBCCC:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
LBCCF: JSR GetJoypadStatus     ;($C608)Get input button presses.
LBCD2:  LDA JoypadBtns          ;
LBCD4:  AND #IN_SEL_STRT        ;Is select or start being pressed?
LBCD6:  BNE ShowIntroText       ;If so, branch to show intro text.

LBCD8:  LDA MusicTrigger        ;Has music trigger been reached?
LBCDB:  CMP #$FC                ;
LBCDD:  BEQ ShowIntroText       ;If so, branch to show intro text.
LBCDF:  BNE LBCCF                   ;Else branch to wait more.

ShowIntroText:
LBCE1:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
LBCE4:  LDA IntroPalPtr2        ;
LBCE7:  STA PalPtrLB            ;Get pointer to palette data.
LBCE9:  LDA IntroPalPtr2+1      ;
LBCEC:  STA PalPtrUB            ;Show intro text.

LBCEE:  LDA #$00                ;No palette modification.
LBCF0:  STA PalModByte          ;

LBCF2:  JSR PrepBGPalLoad       ;($C63D)Setup PPU buffer

LBCF5:  LDA #$37                ;
LBCF7:  STA PPUDataByte         ;
LBCF9:  LDA #$17                ;Set sprite color for the starburst
LBCFB:  STA PPUAddrLB           ;effect to a light pink color.
LBCFD:  LDA #$3F                ;
LBCFF:  STA PPUAddrUB           ;

LBD01:  JSR AddPPUBufEntry      ;($C690)Add data to PPU buffer.
LBD04:  JSR SetBlackBackDrop    ;($BDE0)Set black background.
LBD07:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.

LBD0A:  LDX #$00                ;
LBD0C: LDA DrgSprites,X        ;
LBD0F:  STA SpriteRAM,X         ;Load dragon sprites onto the intro screen.
LBD12:  INX                     ;
LBD13:  CPX #$24                ;36 bytes total (9 sprites).
LBD15:  BNE LBD0C                   ;

LBD17:  LDA #$00                ;Frame counter for starburst effect.
LBD19:  STA IntroCounter        ;

LBD1B:  LDA #$FF                ;Offset into StarburstPtrTbl.
LBD1D:  STA IntroPointer        ;

LBD1F:  LDA #$0B                ;
LBD21:  STA _CharXPos           ;
LBD23:  LDA #$0C                ;
LBD25:  STA CharXPixelsLB       ;
LBD27:  LDA #$10                ;Initialize some variables but
LBD29:  STA _CharYPos           ;does not appear to be used.
LBD2B:  LDA #$17                ;
LBD2D:  STA CharYPixelsLB       ;
LBD2F:  LDA #$01                ;
LBD31:  STA MessageSpeed        ;

IntroLoop:
LBD33:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
LBD36:  LDX #$00                ;
LBD38:  LDA IntroPointer        ;Is pointer to sprite table valid?
LBD3A:  CMP #$FF                ;If not, branch to skip loading sprites.
LBD3C:  BEQ LBD8D                 ;

LBD3E:  LDY IntroPointer        ;
LBD40:  LDA StarburstPtrTbl,Y   ;
LBD43:  STA DatPntr1LB          ;Get pointer to current sprite data table
LBD45:  LDA StarburstPtrTbl+1,Y ;and store it in $99, $9A.
LBD48:  STA DatPntrlUB          ;
LBD4A:  LDY #$00                ;

IntroSpLoadLoop:
LBD4C:  LDA (DatPntr1),Y        ;Done loading sprite data? 
LBD4E:  CMP #$FF                ;If so, branch to exit loop.
LBD50:  BEQ LBD76                   ;

LBD52:  STA SpriteRAM+$40,X     ;
LBD55:  INY                     ;Store sprite Y position.
LBD56:  INX                     ;

LBD57:  LDA (DatPntr1),Y        ;
LBD59:  STA SpriteRAM+$40,X     ;Store sprite pattern table value.
LBD5C:  INY                     ;
LBD5D:  INX                     ;

LBD5E:  LDA (DatPntr1),Y        ;
LBD60:  AND #$C0                ;Get upper 2 bits of sprite data and store
LBD62:  ORA #$01                ;them as the sprite attribute byte.
LBD64:  STA SpriteRAM+$40,X     ;
LBD67:  INX                     ;

LBD68:  LDA (DatPntr1),Y        ;
LBD6A:  AND #$3F                ;Use the same byte but this time keep the
LBD6C:  CLC                     ;lower 6 bits for the sprite x position.
LBD6D:  ADC #$B4                ;
LBD6F:  STA SpriteRAM+$40,X     ;Add 180 to the x position and store it.
LBD72:  INY                     ;
LBD73:  INX                     ;

LBD74:  BNE IntroSpLoadLoop     ;Looop to load more sprite data.

LBD76: LDA IntroCounter        ;Working on the second and third starbursts? If so,
LBD78:  CMP #$80                ;branch to increment the table pointer. This has
LBD7A:  BCS LBD7F                   ;the effect of doubling the starburst animation.

LBD7C:  LSR                     ;Branch to skip pointer increment. X is above the sprite
LBD7D:  BCC LBD8D                  ;offsets so the effect is slowing down the starburst.

LBD7F: INC IntroPointer        ;Move to next pointer in the table.
LBD81:  INC IntroPointer        ;

LBD83:  LDA IntroPointer        ;At the end of the table?
LBD85:  CMP #$18                ;If so, branch to clear sprites.
LBD87:  BNE LBD8D                   ;

LBD89:  LDA #$FF                ;Not time to load sprite data.
LBD8B:  STA IntroPointer        ;Invalidate pointer.

LBD8D: LDA #$F0                ;
LBD8F: STA SpriteRAM+$40,X     ;
LBD92:  INX                     ;Clear all sprites except the dragon sprites.
LBD93:  CPX #$C0                ;
LBD95:  BNE LBD8F                   ;

LBD97:  INC IntroCounter        ;
LBD99:  LDA IntroCounter        ;Start starburst effect at 32 frames.
LBD9B:  CMP #$20                ;
LBD9D:  BEQ LBDA7                   ;

LBD9F:  CMP #$A0                ;Start starburst effect at 160 frames.
LBDA1:  BEQ LBDA7                   ;

LBDA3:  CMP #$C0                ;Start starburst effect at 192 frames.
LBDA5:  BNE LBDAB                  ;

LBDA7: LDA #$00                ;Point to the beginning of the StarburstPtrTbl.
LBDA9:  STA IntroPointer        ;

LBDAB: LDA JoypadBtns          ;Get old button values and store them on the stack.
LBDAD:  PHA                     ;
LBDAE:  JSR GetJoypadStatus     ;($C608)Get input button presses.
LBDB1:  PLA                     ;Get the old values again and branch if something
LBDB2:  BNE LBDDD                   ;was previously pressed. 

LBDB4:  LDA JoypadBtns          ;Get joypad button presses.
LBDB6:  AND #IN_START           ;Has start been pressed?
LBDB8:  BEQ LBDDD                   ;If not, branch to loop.

LBDBA:  LDA IntroPalPtr3        ;
LBDBD:  STA PalPtrLB            ;Get pointer to palette data.
LBDBF:  LDA IntroPalPtr3+1      ;
LBDC2:  STA PalPtrUB            ;

LBDC4:  LDA #$00                ;No palette modification.
LBDC6:  STA PalModByte          ;

LBDC8:  JSR PrepBGPalLoad       ;($C63D)Clear background palette.

LBDCB:  LDA IntroPalPtr3        ;
LBDCE:  STA PalPtrLB            ;Get pointer to palette data.
LBDD0:  LDA IntroPalPtr3+1      ;
LBDD3:  STA PalPtrUB            ;

LBDD5:  LDA #$00                ;No palette modification.
LBDD7:  STA PalModByte          ;

LBDD9:  JSR PrepSPPalLoad       ;($C632)Clear sprite palette.
LBDDC:  RTS                     ;Exit intro routine.

LBDDD: JMP IntroLoop           ;($BD33)Loop until the player presses start.

SetBlackBackDrop:
LBDE0:  LDA #$0F                ;Black.
LBDE2:  STA PPUDataByte         ;
LBDE4:  LDA #$00                ;Store black value in $3F00 which makes background black.
LBDE6:  STA PPUAddrLB           ;
LBDE8:  LDA #$3F                ;
LBDEA:  STA PPUAddrUB           ;
LBDEC:  JMP AddPPUBufEntry      ;($C690)Add data to PPU buffer.

;----------------------------------------------------------------------------------------------------

IntroPalPtr1:
LBDEF:  .word IntroPalTbl1      ;Palette that hides text during intro.
IntroPalTbl1:
LBDF1:  .byte $30, $10, $00, $27, $37, $17, $0F, $0F, $0F, $0F, $0F, $0F

IntroPalPtr2:
LBDFD:  .word IntroPalTbl2      ;Palette that displays text during intro.
IntroPalTbl2:
LBDFF:  .byte $30, $10, $00, $27, $37, $17, $0F, $27, $27, $0F, $24, $24

;----------------------------------------------------------------------------------------------------

;Intro screen dragon sprites.

DrgSprites:
.incbin "bin/Bank02/DrgSprites.bin"
StarburstPtrTbl:
LBE2F:  .word Starburst1        ;($BE47)
LBE31:  .word Starburst2        ;($BE4E)
LBE33:  .word Starburst2        ;($BE4E)
LBE35:  .word Starburst3        ;($BE64)
LBE37:  .word Starburst3        ;($BE64)
LBE39:  .word Starburst4        ;($BE8F)
LBE3B:  .word Starburst4        ;($BE8F)
LBE3D:  .word Starburst4        ;($BE8F)
LBE3F:  .word Starburst3        ;($BE64)
LBE41:  .word Starburst3        ;($BE64)
LBE43:  .word Starburst2        ;($BE4E)
LBE45:  .word Starburst1        ;($BE47)

Starburst1:
.incbin "bin/Bank02/Starburst1.bin"
Starburst2:
.incbin "bin/Bank02/Starburst2.bin"
Starburst3:
.incbin "bin/Bank02/Starburst3.bin"
Starburst4:
.incbin "bin/Bank02/Starburst4.bin"
IntroPalPtr3:
LBEC3:  .word IntroPalTbl3      ;Black out sprites when intro is done.
IntroPalTbl3:
.incbin "bin/Bank02/IntroPalTbl3.bin"
NMI:
RESET:
IRQ:
LBFD8:  SEI                     ;Disable interrupts.
LBFD9:  INC MMCReset1           ;Reset MMC1 chip.
LBFDC:  JMP _DoReset            ;($FF8E)Continue with the reset process.

;----------------------------------------------------------------------------------------------------

;                   D    R    A    G    O    N    _    W    A    R    R    I    O    R    _
LBFDF:  .byte $80, $44, $52, $41, $47, $4F, $4E, $20, $57, $41, $52, $52, $49, $4F, $52, $20
LBFEF:  .byte $20, $56, $DE, $30, $70, $01, $04, $01, $0F, $07, $00 

LBFFA:  .word NMI               ;($BFD8)NMI vector.
LBFFC:  .word RESET             ;($BFD8)Reset vector.
LBFFE:  .word IRQ               ;($BFD8)IRQ vector.

