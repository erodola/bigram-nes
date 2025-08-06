.include "variables.inc"

.import TransitionMatrix
.import lut_RNG           ; found in bin/0F_F100_rngtable.bin

.export GenerateName, Rand8

.segment "BANK_0E_INFER"

VOCAB_SIZE = 27


; ==================================
; [RETRO AI] ItoS
;
; Convert an unsigned char index to a tile address in the PPU.
;
; The result is the PPU tile representation of the number,
; starting from $8A for 'A', $8B for 'B', ..., $A3 for 'Z'.
;
; If the input value is 0, the result is a white space (tile $C1).
;
; Input: A = unsigned char (0 - VOCAB_SIZE-1)
; Output: A = PPU tile (' ' for 0, 'A' for 1, ..., 'Z' for 26)
; ==================================

ItoS:
    BNE @NotDot ; A is not 0?
    LDA #$C1    ; white space tile
    RTS
@NotDot:
    CLC
    ADC #$89    ; 'A' = $89 + 1 = $8A
    RTS


; ==================================
; [RETRO AI] Rand8
;
; Generate a random 8-bit number (0 - 255).
; Uses the frame counter as a seed to index into FF1's RNG lookup table.
;
; Input: None
; Output: rand_byte = random 8-bit number
; ==================================

Rand8:
    INC framecounter ; if not incremented, the RNG will always return the same value
    LDY framecounter
    LDA lut_RNG, Y   ; index the lut with the frame counter
    STA rand_byte
    RTS


; ==================================
; [RETRO AI] Multinomial
;
; Draw one sample from a 8bit distribution.
;
; The function iterates through the probabilities, accumulating their values until
; a randomly generated number is smaller than the accumulated value.
;
; Assumes probs_ptr has been properly set before entering.
;
; Input: probs_ptr = pointer to an array of VOCAB_SIZE probabilities (8-bit values)
; Output: A = selected index (0 to VOCAB_SIZE - 1)
; ==================================

Multinomial:
    JSR Rand8           ; get a random number in rand_byte
    LDA #0              ; acc = 0
    TAY                 ; i = 0

@Loop:
    CLC
    ADC (probs_ptr),Y   ; acc += probs[i]
    CMP rand_byte
    BCS @Done           ; acc >= random number?

    INY                 ; i++
    CPY #VOCAB_SIZE     ; i < VOCAB_SIZE?
    BCC @Loop

    DEY                 ; fallback to VOCAB_SIZE-1 if random number was 255

@Done:
    TYA                 ; A = i
    RTS


; ==================================
; [RETRO AI] LoadRowPtr
;
; Set the probs_ptr to point to the transition matrix row for the given index.
;
; Input: A = row index (0 - VOCAB_SIZE-1)
; Output: probs_ptr = pointer to the row in TransitionMatrix
; ==================================

LoadRowPtr:
  TAX

  LDA #<TransitionMatrix ; point probs_ptr to the transition matrix
  STA probs_ptr
  LDA #>TransitionMatrix
  STA probs_ptr+1

  TXA
  BEQ @Done              ; if index==0, we are done

@Loop:                   ; implements tok_idx*VOCAB_SIZE by summing VOCAB_SIZE for tok_idx times
  CLC
  LDA probs_ptr
  ADC #VOCAB_SIZE
  STA probs_ptr
  BCC @SkipInc
  INC probs_ptr+1

@SkipInc:
  DEX
  BNE @Loop

@Done:
  RTS


; ==================================
; [RETRO AI] GenerateName
;
; Generate a random name of 3 to 4 characters using ancestral sampling
; with a bigram model.
;
; The name is directly stored in FF1's party names buffer, pointed by 
; ptygen_name + char_index.
;
; Input: char_index = index of game character ($00 - $30)
; Output: ptygen_name + char_index = generated name (3-4 chars)
; ==================================

GenerateName:

  LDA char_index     ; first build the destination pointer
  CLC
  ADC #<ptygen_name  ; low byte  $02 + 0/10/20/30
  STA name_ptr
  LDA #>ptygen_name
  STA name_ptr+1

  LDA #0
  STA tok_idx      ; tok_idx = 0
  STA j_count      ; j = 0

@CharLoop:
  LDA #0
  STA attempts     ; attempts = 0

@AttemptLoop:
  LDA tok_idx
  JSR LoadRowPtr   ; probs_ptr = T + tok_idx*VOCAB_SIZE
  JSR Multinomial  ; A = new tok_idx (0 - VOCAB_SIZE-1)
  STA tok_idx

  INC attempts     ; attempts++
  BEQ @ForceA      ; attempts==255, force character 'A'

  LDA tok_idx
  BEQ @AttemptLoop ; do another attempt if tok_idx==0

@ForceA:
  LDA tok_idx
  BNE @GotChar     ; tok_idx != 0? then don't force 'A', otherwise...
  LDA #1           ; ...force 'A'
  STA tok_idx      ; store tok_idx for the next iteration

@GotChar:
  JSR ItoS         ; A = convert to PPU tile index
  LDY j_count
  STA (name_ptr),Y ; new_name[j] = A
  INY              ; j++
  STY j_count
  CPY #3           ; j < 3?
  BCC @CharLoop

@FourthChar:
  LDA tok_idx      ; get the last character
  JSR LoadRowPtr
  JSR Multinomial  ; sample final token
  JSR ItoS
  LDY #3
  STA (name_ptr),Y ; directly store in the last position, even if it's a white space

  RTS
