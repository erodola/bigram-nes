.segment "BANK_01"
.org $8000

.include "Defines.inc"

;--------------------------------------[ Imports ]--------------------------------------

; [BIGRAM-NES] Import all Bank03 functions instead of hard-coding addresses
.import ClearPPU
.import CalcPPUBufAddr
.import GetJoypadStatus
.import AddPPUBufEntry
.import ClearSpriteRAM
.import DoWindow
.import DoDialogHiBlock
.import WndLoadGameDat
.import Bank0ToCHR0
.import GetAndStrDatPtr
.import GetBankDataByte
.import WaitForNMI
.import _DoReset

.ifdef namegen
.import UpdateRandNum        ; [BIGRAM-NES] needed for multinomial sampling
.import TransitionMat_0_23   ; [BIGRAM-NES] transition matrix, split in two parts
.import TransitionMat_24_26
.endif

;--------------------------------------[ Exports ]--------------------------------------

; [BIGRAM-NES] Export Bank01 functions that other banks call via BRK mechanism
.export BankPointers
.export UpdateSound

;-----------------------------------------[ Start of code ]------------------------------------------

;The following table contains functions called from bank 3 through the IRQ interrupt.

BankPointers:
L8000:  .word WndEraseParams    ;($AF24)Get parameters for removing windows from the screen.
L8002:  .word WndShowHide       ;($ABC4)Show/hide window on the screen.
L8004:  .word ClearSoundRegs    ;($8178)Silence all sound.
L8006:  .word WaitForMusicEnd   ;($815E)Wait for the music clip to end.
L8008:  .word InitMusicSFX      ;($81A0)Initialize new music/SFX.
L800A:  .word ExitGame          ;($9362)Shut down game after player chooses not to continue.
L800C:  .word NULL              ;Unused.
L800E:  .word NULL              ;Unused.
L8010:  .word CopyTrsrTbl       ;($994F)Copy treasure table into RAM.
L8012:  .word NULL              ;Unused.
L8014:  .word CopyROMToRAM      ;($9981)Copy a ROM table into RAM.
L8016:  .word EnSpritesPtrTbl   ;($99E4)Table of pointers to enemy sprites.
L8018:  .word LoadEnemyStats    ;($9961)Load enemy stats when initiaizing a battle.
L801A:  .word SetBaseStats      ;($99B4)Get player's base stats for their level.
L801C:  .word DoEndCredits      ;($939A)Show end credits.
L801E:  .word NULL              ;Unused.
L8020:  .word ShowWindow        ;($A194)Display a window.
L8022:  .word WndEnterName      ;($AE02)Do name entering functions.
L8024:  .word DoDialog          ;($B51D)Display in-game dialog.
L8026:  .word NULL              ;Unused.

UpdateSound:
L8028:  PHA                     ;
L8029:  TXA                     ;
L802A:  PHA                     ;Store X, Y and A.
L802B:  TYA                     ;
L802C:  PHA                     ;

L802D:  LDX #MCTL_NOIS_SW       ;Noise channel software regs index.
L802F:  LDY #MCTL_SQ2_HW        ;SQ2 channel hardware regs index.
L8031:  LDA SFXActive           ;Is an SFX active?
L8033:  BEQ L805F                   ;If not, branch to skip SFX processing.

L8035:  LDA NoteOffset          ;
L8037:  PHA                     ;Save a copy of note offset and then clear
L8038:  LDA #$00                ;it as it is not used in SFX processing.
L803A:  STA NoteOffset          ;

L803C:  JSR GetNextNote         ;($80CB)Check to see if time to get next channel note.
L803F:  TAX                     ;

L8040:  PLA                     ;Restore note offset value.
L8041:  STA NoteOffset          ;

L8043:  TXA                     ;Is SFX still processing?
L8044:  BNE L805F                   ;If so, branch to continue or else reset noise and SQ2.

L8046:  LDA #%00000101          ;Silence SQ2 and noise channels.
L8048:  STA APUCommonCntrl0     ;
L804B:  LDA #%00001111          ;Enable SQ1, SQ2, TRI and noise channels.
L804D:  STA APUCommonCntrl0     ;

L8050:  LDA SQ2Config           ;Update SQ2 control byte 0.
L8052:  STA SQ2Cntrl0           ;

L8055:  LDA #%00001000          ;Disable sweep generator on SQ2.
L8057:  STA SQ2Cntrl1           ;

L805A:  LDA #%00110000          ;Turn off volume for noise channel.
L805C:  STA NoiseCntrl0         ;

L805F: LDA TempoCntr           ;Tempo counter has the effect of slowing down the length
L8061:  CLC                     ;The music plays.  If the tempo is less than 150, the
L8062:  ADC Tempo               ;amount it slows down is linear.  For example, if tempo is
L8064:  STA TempoCntr           ;125, the music will slow down by 150/125 = 1.2 times.
L8066:  BCC SoundUpdateEnd      ;The values varies if tempo is greater than 150.

L8068:  SBC #$96                ;Subtract 150 from tempo counter.
L806A:  STA TempoCntr           ;

L806C:  LDX #MCTL_TRI_SW        ;TRI channel software regs index.
L806E:  LDY #MCTL_TRI_HW        ;TRI channel hardware regs index.
L8070:  JSR GetNextNote         ;($80CB)Check to see if time to get next channel note.

L8073:  LDX #MCTL_SQ2_SW        ;SQ2 channel software regs index.
L8075:  LDY #MCTL_SQ2_HW        ;SQ2 channel hardware regs index.
L8077:  LDA SFXActive           ;Is an SFX currenty active?
L8079:  BEQ L807D                   ;If not, branch.

L807B:  LDY #MCTL_DMC_HW        ;Set hardware register index to DMC regs (not used).
L807D: JSR GetNextNote         ;($80CB)Check to see if time to get next channel note.

L8080:  LDX #MCTL_SQ1_SW        ;SQ1 channel software regs index.
L8082:  LDY #MCTL_SQ1_HW        ;SQ1 channel hardware regs index.
L8084:  JSR GetNextNote         ;($80CB)Check to see if time to get next channel note.

SoundUpdateEnd:
L8087:  LDY #$00                ;
L8089:  LDA (SQ1IndexLB),Y      ;Update music trigger value.
L808B:  STA MusicTrigger        ;

L808E:  PLA                     ;
L808F:  TAY                     ;
L8090:  PLA                     ;Restore X, Y and A.
L8091:  TAX                     ;
L8092:  PLA                     ;
L8093:  RTS                     ;

;----------------------------------------------------------------------------------------------------

MusicReturn:
L8094:  LDA SQ1ReturnLB,X       ;
L8096:  STA SQ1IndexLB,X        ;Load return address into sound channel
L8098:  LDA SQ1ReturnUB,X       ;data address.  Process byte if not $00.
L809A:  STA SQ1IndexUB,X        ;
L809C:  BNE ProcessAudioByte    ;

;----------------------------------------------------------------------------------------------------

LoadMusicNote:
L809E:  CLC                     ;Add any existing offset into note table.
L809F:  ADC NoteOffset          ;Used to change the sound of various dungeon levels.

L80A1:  ASL                     ;*2.  Each table value is 2 bytes.
L80A2:  STX MusicTemp           ;Save X.
L80A4:  TAX                     ;Use calculated value as index into note table.

L80A5:  LDA MusicalNotesTbl,X   ;
L80A8:  STA SQ1Cntrl2,Y         ;Store note data bytes into its
L80AB:  LDA MusicalNotesTbl+1,X ;corresponding hardware registers.
L80AE:  STA SQ1Cntrl3,Y         ;

L80B1:  LDX MusicTemp           ;Restore X.
L80B3:  CPX #MCTL_NOIS_SW       ;Is noise channel being processed?
L80B5:  BEQ ProcessAudioByte    ;If so, branch to get next audio data byte.

L80B7:  LDA ChannelQuiet,X      ;Is any quiet time between notes expired?
L80B9:  BEQ ProcessAudioByte    ;If so, branch to get next audio byte.

L80BB:  BNE UpdateChnlUsage     ;Wait for quiet time between notes to end. Branch always.

;----------------------------------------------------------------------------------------------------

ChnlQuietTime:
L80BD:  JSR GetAudioData        ;($8155)Get next music data byte.
L80C0:  STA ChannelQuiet,X      ;Store quiet time byte.
L80C2:  JMP ProcessAudioByte    ;($80D3)Determine what to do with music data byte.

;----------------------------------------------------------------------------------------------------

EndChnlQuietTime:
L80C5:  LDA #$00                ;Clear quiet time byte.
L80C7:  STA ChannelQuiet,X      ;
L80C9:  BEQ ProcessAudioByte    ;($80D3)Determine what to do with music data byte.

;----------------------------------------------------------------------------------------------------

GetNextNote:
L80CB:  LDA ChannelLength,X     ;Is channel enabled?
L80CD:  BEQ UpdateReturn        ;If not, branch to exit.

L80CF:  DEC ChannelLength,X     ;Decrement length remaining.
L80D1:  BNE UpdateReturn        ;Time to get new data? if not, branch to exit.

;----------------------------------------------------------------------------------------------------

ProcessAudioByte:
L80D3:  JSR GetAudioData        ;($8155)Get next music data byte.
L80D6:  CMP #MCTL_JUMP          ;
L80D8:  BEQ MusicJump           ;Check if need to jump to new music data address.

L80DA:  BCS ChangeTempo         ;Check if tempo needs to be changed.

L80DC:  CMP #MCTL_NO_OP         ;Check if no-op byte.
L80DE:  BEQ ProcessAudioByte    ;If so, branch to get next byte.

L80E0:  BCS MusicReturn         ;Check if need to jump back to previous music data adddress.

L80E2:  CMP #MCTL_CNTRL1        ;Check if channel control 1 byte.
L80E4:  BEQ ChnlCntrl1          ;If so, branch to load config byte.

L80E6:  BCS ChnlCntrl0          ;Check if channel control 0 byte.

L80E8:  CMP #MCTL_NOISE_VOL     ;Check if noise channel volume control byte.
L80EA:  BEQ NoiseVolume         ;If so, branch to load noise volume.

L80EC:  BCS GetNoteOffset       ;Is this a note offset byte? If so, branch.

L80EE:  CMP #MCTL_END_SPACE     ;Check if end quiet time between notes byte.
L80F0:  BEQ EndChnlQuietTime    ;If so, branch to end quiet time.

L80F2:  BCS ChnlQuietTime       ;Add quiet time between notes? if so branch to get quiet time.

L80F4:  CMP #MCTL_NOISE_CFG     ;Is byte a noise channel config byte?
L80F6:  BCS LoadNoise           ;If so, branch to configure noise channel.

L80F8:  CMP #MCTL_NOTE          ;Is byte a musical note? 
L80FA:  BCS LoadMusicNote       ;If so, branch to load note.

;If no control bytes match the cases above, byte Is note length counter.

UpdateChnlUsage:
L80FC:  STA ChannelLength,X     ;Update channel note counter.

UpdateReturn:
L80FE:  RTS                     ;Finished with current processing.

;----------------------------------------------------------------------------------------------------

ChangeTempo:
L80FF:  JSR GetAudioData        ;($8155)Get next music data byte.
L8102:  STA Tempo               ;Update music speed.
L8104:  JMP ProcessAudioByte    ;($80D3)Determine what to do with music data byte.

;----------------------------------------------------------------------------------------------------

MusicJump:
L8107:  JSR GetAudioData        ;($8155)Get next music data byte.
L810A:  PHA                     ;
L810B:  JSR GetAudioData        ;($8155)Get next music data byte.
L810E:  PHA                     ;Get jump address from music data.
L810F:  LDA SQ1IndexLB,X        ;
L8111:  STA SQ1ReturnLB,X       ;
L8113:  LDA SQ1IndexUB,X        ;Save current address in return address variables.
L8115:  STA SQ1ReturnUB,X       ;
L8117:  PLA                     ;
L8118:  STA SQ1IndexUB,X        ;Jump to new music data address and get data byte.
L811A:  PLA                     ;
L811B:  STA SQ1IndexLB,X        ;
L811D:  JMP ProcessAudioByte    ;($80D3)Determine what to do with music data byte.

;----------------------------------------------------------------------------------------------------

ChnlCntrl0:
L8120:  JSR GetAudioData        ;($8155)Get next music data byte.
L8123:  CPX #$02                ;Is SQ2 currently being handled?
L8125:  BNE L8129                   ;If not, branch to load into corresponding SQ register.

L8127:  STA SQ2Config           ;Else store a copy of the data byte in SQ2 config register.

L8129: STA SQ1Cntrl0,Y         ;Load control byte into corresponding control register.
L812C:  JMP ProcessAudioByte    ;($80D3)Determine what to do with music data byte.

;----------------------------------------------------------------------------------------------------

NoiseVolume:
L812F:  JSR GetAudioData        ;($8155)Get next music data byte.
L8132:  STA NoiseCntrl0         ;Set noise volume byte.
L8135:  JMP ProcessAudioByte    ;($80D3)Determine what to do with music data byte.

;----------------------------------------------------------------------------------------------------

LoadNoise:
L8138:  AND #$0F                ;Set noise period.
L813A:  STA NoiseCntrl2         ;
L813D:  LDA #%00001000          ;Set length counter to 1.
L813F:  STA NoiseCntrl3         ;
L8142:  BNE ProcessAudioByte    ;($80D3)Determine what to do with music data byte.

;----------------------------------------------------------------------------------------------------

GetNoteOffset:
L8144:  JSR GetAudioData        ;($8155)Get next music data byte.
L8147:  STA NoteOffset          ;Get note offset byte.
L8149:  JMP ProcessAudioByte    ;($80D3)Determine what to do with music data byte.

;----------------------------------------------------------------------------------------------------

ChnlCntrl1:
L814C:  JSR GetAudioData        ;($8155)Get next music data byte.
L814F:  STA SQ1Cntrl1,Y         ;Store byte in square wave config register.
L8152:  JMP ProcessAudioByte    ;($80D3)Determine what to do with music data byte.

;----------------------------------------------------------------------------------------------------

GetAudioData:
L8155:  LDA (SQ1IndexLB,X)      ;Get data byte from ROM.

IncAudioPtr:
L8157:  INC SQ1IndexLB,X        ;
L8159:  BNE L815D                   ;Increment data pointer.
L815B:  INC SQ1IndexUB,X        ;
L815D: RTS                     ;

;----------------------------------------------------------------------------------------------------

WaitForMusicEnd:
L815E:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
L8161:  LDA #MCTL_NO_OP         ;Load no-op character. Its also used for end of music segment.
L8163:  LDX #MCTL_SQ1_SW        ;
L8165:  CMP (SQ1IndexLB,X)      ;Is no-op found in SQ1 data? if so, end found.  Branch to end.
L8167:  BEQ L8175                   ;

L8169:  LDX #MCTL_NOIS_SW       ;
L816B:  CMP (SQ1IndexLB,X)      ;Is no-op found in noise data? if so, end found.  Branch to end.
L816D:  BEQ L8175                   ;

L816F:  LDX #MCTL_TRI_SW        ;
L8171:  CMP (SQ1IndexLB,X)      ;Is no-op found in triangel data? if so, end found.  Branch to end.
L8173:  BNE WaitForMusicEnd     ;
L8175: JMP IncAudioPtr         ;($8157)Increment audio data pointer.

;----------------------------------------------------------------------------------------------------

ClearSoundRegs:
L8178:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.

L817B:  LDA #$00                ;
L817D:  STA DMCCntrl0           ;Clear hardware control registers.
L8180:  STA APUCommonCntrl1     ;
L8183:  STA APUCommonCntrl0     ;

L8186:  STA SQ1Length           ;
L8188:  STA SQ2Length           ;Indicate the channels are not in use.
L818A:  STA TRILength           ;

L818C:  STA SFXActive           ;No SFX active.

L818E:  LDA #%00001111          ;
L8190:  STA APUCommonCntrl0     ;Enable sound channels.

L8193:  LDA #$FF                ;Initialize tempo.
L8195:  STA Tempo               ;

L8197:  LDA #$08                ;
L8199:  STA SQ1Cntrl1           ;Disable SQ1 and SQ2 sweep units.
L819C:  STA SQ2Cntrl1           ;
L819F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

InitMusicSFX:
L81A0:  LDX #$FF                ;Indicate the sound engine is active.
L81A2:  STX SndEngineStat       ;
L81A5:  TAX                     ;
L81A6:  BMI DoSFX               ;If MSB set, branch to process SFX.

DoMusic:
L81A8:  ASL                     ;Index into table is 4*n + 4. Points to last word in table entry.
L81A9:  STA MusicTemp           ;
L81AB:  ASL                     ;There are 3 words for each music entry in the table.
L81AC:  ADC MusicTemp           ;The entries are for SQ1, SQ2 and TRI from left to right.
L81AE:  ADC #$04                ;
L81B0:  TAY                     ;Use Y as index into table.

L81B1:  LDX #$04                ;Prepare to loop 3 times.

ChnlInitLoop:
L81B3:  LDA MscStrtIndxTbl+1,Y  ;Get upper byte of pointer from table.
L81B6:  BNE L81C3                   ;Is there a valid pointer? If so branch to save pointer.

L81B8:  LDA MscStrtIndxTbl+1,X  ;
L81BB:  STA SQ1IndexUB,X        ;No music data for this chnnel in the table.  Load
L81BD:  LDA MscStrtIndxTbl,X    ;the "no sound" data instead.
L81C0:  JMP L81C8                  ;

L81C3: STA SQ1IndexUB,X        ;
L81C5:  LDA MscStrtIndxTbl,Y    ;Store pointer to audio data.
L81C8: STA SQ1IndexLB,X        ;

L81CA:  LDA #$01                ;Indicate the channel has valid sound data.
L81CC:  STA ChannelLength,X     ;

L81CE:  DEY                     ;Move to the next pointer in the pointer table and in the RAM.
L81CF:  DEY                     ;
L81D0:  DEX                     ;
L81D1:  DEX                     ;Have three pointers been picked up?
L81D2:  BPL ChnlInitLoop        ;If not, branch to get the next pointer.

L81D4:  LDA #$00                ;
L81D6:  STA NoteOffset          ;
L81D8:  STA SQ1Quiet            ;
L81DA:  STA SQ2Quiet            ;Clear various status variables.
L81DC:  STA TRIQuiet            ;
L81DE:  STA SndEngineStat       ;
L81E1:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DoSFX:
L81E2:  ASL                     ;*2. Pointers in table are 2 bytes.
L81E3:  TAX                     ;

L81E4:  LDA #$01                ;Indicate a SFX is active.
L81E6:  STA SFXActive           ;

L81E8:  LDA SFXStrtIndxTbl,X    ;
L81EB:  STA NoisIndexLB         ;Get pointer to SFX data from table.
L81ED:  LDA SFXStrtIndxTbl+1,X  ;
L81F0:  STA NoisIndexUB         ;

L81F2:  LDA #$08                ;Disable SQ2 sweep unit.
L81F4:  STA SQ2Cntrl1           ;

L81F7:  LDA #$30                ;Disable length counter and set constant
L81F9:  STA SQ2Cntrl0           ;volume for SQ2 and noise channels.
L81FC:  STA NoiseCntrl0         ;

L81FF:  LDA #$00                ;
L8201:  STA SndEngineStat       ;Indicate sound engine finished.
L8204:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The LSB of the length counter is always written when loading the frequency data into the 
;counter registers.  This plays the note for the longest possible time if the halt flag is
;cleared.  The first byte contains the low bits of the timer while the second byte contains
;the upper 3 bits.  The formula for figuring out the frequency is as follows: 
;1790000/16/(hhhllllllll + 1).

MusicalNotesTbl:
.incbin "bin/Bank01/MusicalNotesTbl.bin"
MscStrtIndxTbl:
L8297:  .word SQNoSnd,     SQNoSnd,     TRINoSnd    ;($84CB, $84CB, $84CE)No sound.
L829D:  .word SQ1Intro,    SQ2Intro,    TriIntro    ;($8D6D, $8E3D, $8F06)Intro.
L82A3:  .word SQ1ThrnRm,   NULL,        TRIThrnRm   ;($84D3, $0000, $853E)Throne room.
L82A9:  .word SQ1Tantagel, NULL,        TRITantagel ;($85AA, $0000, $85B4)Tantagel castle.
L82AF:  .word SQ1Village,  NULL,        TRIVillage  ;($872F, $0000, $87A2)Village/pre-game.
L82B5:  .word SQ1Outdoor,  NULL,        TRIOutdoor  ;($8844, $0000, $8817)Outdoors.
L82BB:  .word SQ1Dngn,     NULL,        TRIDngn1    ;($888B, $0000, $891D)Dungeon 1.
L82C1:  .word SQ1Dngn,     NULL,        TRIDngn2    ;($888B, $0000, $8924)Dungeon 2.
L82C7:  .word SQ1Dngn,     NULL,        TRIDngn3    ;($888B, $0000, $892B)Dungeon 3.
L82CD:  .word SQ1Dngn,     NULL,        TRIDngn4    ;($888B, $0000, $8932)Dungeon 4.
L82D3:  .word SQ1Dngn,     NULL,        TRIDngn5    ;($888B, $0000, $8937)Dungeon 5.
L82D9:  .word SQ1Dngn,     NULL,        TRIDngn6    ;($888B, $0000, $893E)Dungeon 6.
L82DF:  .word SQ1Dngn,     NULL,        TRIDngn7    ;($888B, $0000, $8945)Dungeon 7.
L82E5:  .word SQ1Dngn,     NULL,        TRIDngn8    ;($888B, $0000, $894C)Dungeon 8.
L82EB:  .word SQ1EntFight, NULL,        TRIEntFight ;($89A9, $0000, $8ACF)Enter fight.
L82F1:  .word SQ1EndBoss,  SQ2EndBoss,  TRIEndBoss  ;($8B62, $8BE6, $8C1A)End boss.
L82F7:  .word SQ1EndGame,  SQ2EndGame,  TRIEndGame  ;($8F62, $90B2, $922E)End game.
L82FD:  .word SQ1SlvrHrp,  SQ2SlvrHrp,  NULL        ;($8C3F, $8C3E, $0000)Silver harp.
L8303:  .word NULL,        NULL,        TRIFryFlute ;($0000, $0000, $8C9A)Fairy flute.
L8309:  .word SQ1RnbwBrdg, SQ2RnbwBrdg, NULL        ;($8CE2, $8CE1, $0000)Rainbow bridge.
L830F:  .word SQ1Death,    SQ2Death,    NULL        ;($8D24, $8D23, $0000)Player death.
L8315:  .word SQ1Inn,      SQ2Inn,      NULL        ;($86CC, $86EB, $0000)Inn.
L831B:  .word SQ1Princess, SQ2Princess, TRIPrincess ;($8653, $867B, $86AC)Princess Gwaelin.
L8321:  .word SQ1Cursed,   SQ2Cursed,   NULL        ;($8D4B, $8D4A, $0000)Cursed.
L8327:  .word SQ1Fight,    NULL,        TRIFight    ;($89BF, $0000, $8AE1)Regular fight.
L832D:  .word SQ1Victory,  SQ2Victory,  NULL        ;($870E, $8707, $0000)Victory.
L8333:  .word SQ1LevelUp,  SQ2LevelUp,  NULL        ;($862A, $8640, $0000)Level up.

SFXStrtIndxTbl:
L8339:  .word FFDamageSFX                           ;($836E)Force field damage.
L833B:  .word WyvernWngSFX                          ;($8377)Wyvern wing.
L833D:  .word StairsSFX                             ;($839E)Stairs.
L833F:  .word RunSFX                                ;($83C2)Run away.
L8341:  .word SwmpDmgSFX                            ;($83F8)Swamp damage.
L8343:  .word MenuSFX                               ;($8401)Menu button.
L8345:  .word ConfirmSFX                            ;($8406)Confirmation.
L8347:  .word EnHitSFX                              ;($8411)Enemy hit.
L8349:  .word ExclntMvSFX                           ;($8420)Excellent move.
L834B:  .word AttackSFX                             ;($843B)Attack.
L834D:  .word HitSFX                                ;($844A)Player hit 1.
L834F:  .word HitSFX                                ;($844A)Player hit 2.
L8351:  .word AtckPrepSFX                           ;($8459)Attack prep.
L8353:  .word Missed1SFX                            ;($8468)Missed 1.
L8355:  .word Missed2SFX                            ;($8471)Missed 2.
L8357:  .word WallSFX                               ;($847A)Wall bump.
L8359:  .word TextSFX                               ;($8486)Text.
L835B:  .word SpellSFX                              ;($848E)Spell cast.
L835D:  .word RadiantSFX                            ;($84A0)Radiant.
L835F:  .word OpnChestSFX                           ;($84AB)Open chest.
L8361:  .word OpnDoorSFX                            ;($84B6)Open door.
L8363:  .word FireSFX                               ;($8365)Breath fire.

FireSFX:
.incbin "bin/Bank01/FireSFX.bin"
FFDamageSFX:
.incbin "bin/Bank01/FFDamageSFX.bin"
WyvernWngSFX:
.incbin "bin/Bank01/WyvernWngSFX.bin"
StairsSFX:
.incbin "bin/Bank01/StairsSFX.bin"
RunSFX:
.incbin "bin/Bank01/RunSFX.bin"
SwmpDmgSFX:
.incbin "bin/Bank01/SwmpDmgSFX.bin"
MenuSFX:
.incbin "bin/Bank01/MenuSFX.bin"
ConfirmSFX:
.incbin "bin/Bank01/ConfirmSFX.bin"
EnHitSFX:
.incbin "bin/Bank01/EnHitSFX.bin"
ExclntMvSFX:
.incbin "bin/Bank01/ExclntMvSFX.bin"
AttackSFX:
.incbin "bin/Bank01/AttackSFX.bin"
HitSFX:
.incbin "bin/Bank01/HitSFX.bin"
AtckPrepSFX:
.incbin "bin/Bank01/AtckPrepSFX.bin"
Missed1SFX:
.incbin "bin/Bank01/Missed1SFX.bin"
Missed2SFX:
.incbin "bin/Bank01/Missed2SFX.bin"
WallSFX:
.incbin "bin/Bank01/WallSFX.bin"
TextSFX:
.incbin "bin/Bank01/TextSFX.bin"
SpellSFX:
.incbin "bin/Bank01/SpellSFX.bin"
RadiantSFX:
.incbin "bin/Bank01/RadiantSFX.bin"
OpnChestSFX:
.incbin "bin/Bank01/OpnChestSFX.bin"
OpnDoorSFX:
.incbin "bin/Bank01/OpnDoorSFX.bin"
SQNoSnd:
.incbin "bin/Bank01/SQNoSnd.bin"
TRINoSnd:
.incbin "bin/Bank01/TRINoSnd.bin"
SQ1ThrnRm:
.incbin "bin/Bank01/SQ1ThrnRm.bin"
SQ1ThrnRmLoop:
L84D5:  .byte $FB,    $8F   ;50% duty, len counter yes, env yes, vol=15.
L84D7:  .byte $FE             ;Jump to new music address.
L84D8:  .word SQ1Tantagel2          ;($85BA).
L84DA:  .byte $FB,    $82   ;50% duty, len counter yes, env yes, vol=2.
L84DC:  .byte $F7, $06   ;6 counts between notes.
L84DE:  .byte $95                   ;A3.
L84DF:  .byte $FE             ;Jump to new music address.
L84E0:  .word SQ1ThrnRm2            ;($851E).
L84E2:  .byte $93                   ;G3.
L84E3:  .byte $FE             ;Jump to new music address.
L84E4:  .word SQ1ThrnRm2            ;($851E).
L84E6:  .byte $FB,    $87   ;50% duty, len counter yes, env yes, vol=7.
L84E8:  .byte $F7, $0C   ;12 counts between notes.
L84EA:  .byte $A3, $9F, $A4, $9F    ;B4,  G4,  C5,  G4.
L84EE:  .byte $A9, $A1, $A4, $A1    ;F5,  A4,  C5,  A4.
L84F2:  .byte $A8, $9C, $A0, $A3    ;E5,  E4,  Ab4, B4.
L84F6:  .byte $A8, $9F, $A5, $A8    ;E5,  G4,  C#5, E5.
L84FA:  .byte $FB,    $82   ;50% duty, len counter yes, env yes, vol=2.
L84FC:  .byte $F7, $06   ;6 counts between notes.
L84FE:  .byte $8E                   ;D3.
L84FF:  .byte $FE             ;Jump to new music address.
L8500:  .word SQ1ThrnRm3            ;($852E).
L8502:  .byte $8C                   ;C3.
L8503:  .byte $FE             ;Jump to new music address.
L8504:  .word SQ1ThrnRm3            ;($852E).
L8506:  .byte $FB,    $87   ;50% duty, len counter yes, env yes, vol=7.
L8508:  .byte $F7, $0C   ;12 counts between notes.
L850A:  .byte $A3, $9F, $A4, $9F    ;B4,  G4,  C5,  G4.
L850E:  .byte $A9, $A1, $A4, $A9    ;F5,  A4,  C5,  F5.
L8512:  .byte $A8, $A1, $A0, $9D    ;E5,  A4,  Ab4, F4.
L8516:  .byte $9C, $9A, $98, $97    ;E4,  D4,  C4,  B3.
L851A:  .byte $F6        ;Disable counts between notes.
L851B:  .byte $FE             ;Jump to new music address.
L851C:  .word SQ1ThrnRmLoop         ;($84D5).

SQ1ThrnRm2:
.incbin "bin/Bank01/SQ1ThrnRm2.bin"
SQ1ThrnRm3:
.incbin "bin/Bank01/SQ1ThrnRm3.bin"
TRIThrnRm:
L853E:  .byte $FE             ;Jump to new music address.
L853F:  .word TRITantagel2          ;($85EB).
.incbin "bin/Bank01/TRIThrnRm.bin"
L85A8:  .word TRIThrnRm             ;($853E).
SQ1Tantagel:
L85AA:  .byte $FF,     $7D   ;60/1.2=50 counts per second.
L85AC:  .byte $FB,    $4F   ;25% duty, len counter yes, env yes, vol=15.
L85AE:  .byte $FE             ;Jump to new music address.
L85AF:  .word SQ1Tantagel2          ;($85BA).
L85B1:  .byte $FE             ;Jump to new music address.
L85B2:  .word SQ1Tantagel           ;($85AA).

TRITantagel:
L85B4:  .byte $FE             ;Jump to new music address.
L85B5:  .word TRITantagel2          ;($85EB).
L85B7:  .byte $FE             ;Jump to new music address.
L85B8:  .word TRITantagel           ;($85B4).

SQ1Tantagel2:
.incbin "bin/Bank01/SQ1Tantagel2.bin"
TRITantagel2:
.incbin "bin/Bank01/TRITantagel2.bin"
SQ1LevelUp:
.incbin "bin/Bank01/SQ1LevelUp.bin"
SQ2LevelUp:
.incbin "bin/Bank01/SQ2LevelUp.bin"
SQ1Princess:
.incbin "bin/Bank01/SQ1Princess.bin"
SQ2Princess:
.incbin "bin/Bank01/SQ2Princess.bin"
TRIPrincess:
.incbin "bin/Bank01/TRIPrincess.bin"
SQ1Inn:
.incbin "bin/Bank01/SQ1Inn.bin"
SQ2Inn:
.incbin "bin/Bank01/SQ2Inn.bin"
SQ2Victory:
L8707:  .byte $06                   ;6 counts.
L8708:  .byte $FE             ;Jump to new music address.
L8709:  .word SQVictory             ;($8717).
L870B:  .byte $FB,    $30   ;12.5% duty, len counter no, env no, vol=0.
L870D:  .byte $00                   ;End music.

SQ1Victory:
L870E:  .byte $FF,     $78   ;60/1.25=48 counts per second.
L8710:  .byte $FE             ;Jump to new music address.
L8711:  .word SQVictory             ;($8717).
L8713:  .byte $B0, $2F              ;C6,  47 counts.
L8715:  .byte $00                   ;End music.
L8716:  .byte $FC            ;Continue last music.

SQVictory:
.incbin "bin/Bank01/SQVictory.bin"
SQ1Village:
.incbin "bin/Bank01/SQ1Village.bin"

SQ1VillageLoop:
.incbin "bin/Bank01/SQ1VillageLoop.bin"
L8750:  .word SQ1Village2           ;($8772).
.incbin "bin/Bank01/SQ1VillageLoop_0.bin"
L875E:  .word SQ1Village2           ;($8772).
.incbin "bin/Bank01/SQ1VillageLoop_1.bin"
L8770:  .word SQ1VillageLoop        ;($8731).

SQ1Village2:
.incbin "bin/Bank01/SQ1Village2.bin"
TRIVillage:
L87A2:  .byte $FB,    $00   ;12.5% duty, len counter yes, env yes, vol=0.
L87A4:  .byte $18                   ;24 counts.
L87A5:  .byte $FB,    $FF   ;75% duty, len counter no, env no, vol=15.
L87A7:  .byte $F7, $0C   ;12 counts between notes.
L87A9:  .byte $9D, $A1, $A4, $A9    ;F4,  A4,  C5,  F5.
L87AD:  .byte $9E, $A1, $A4, $A6    ;F#4, A4,  C5,  D5.
L87B1:  .byte $9F, $A2, $A6, $AB    ;G4,  A#4, D5,  G5.
L87B5:  .byte $9E, $A6, $9D, $A6    ;F#4, D5,  F4,  D5.
L87B9:  .byte $9C, $A4, $A2, $A4    ;E4,  C5,  A#4, C5.
L87BD:  .byte $98, $9F, $9C, $9F    ;C4,  G4,  E4,  G4.
L87C1:  .byte $9D, $A4, $9F, $A4    ;F4,  C5,  G4,  C5.
L87C5:  .byte $A1, $A7              ;A4,  D#5.
L87C7:  .byte $FE             ;Jump to new music address.
L87C8:  .word TRIVillage2           ;($87EE).
L87CA:  .byte $A3                   ;B4.
L87CB:  .byte $0C                   ;12 counts.
L87CC:  .byte $A6                   ;D5.
L87CD:  .byte $0C                   ;12 counts.
L87CE:  .byte $A3                   ;B4.
L87CF:  .byte $0C                   ;12 counts.
L87D0:  .byte $A4, $A6, $A4         ;C5,  D5,  C5.
L87D3:  .byte $0C                   ;12 counts.
L87D4:  .byte $A6                   ;D5.
L87D5:  .byte $0C                   ;12 counts.
L87D6:  .byte $A8                   ;E5.
L87D7:  .byte $0C                   ;12 counts.
L87D8:  .byte $FE             ;Jump to new music address.
L87D9:  .word TRIVillage2           ;($87EE).
L87DB:  .byte $9D, $9F, $A0, $A3    ;F4,  G4,  Ab4, B4.
L87DF:  .byte $A4, $A5, $A6, $A8    ;C5,  C#5, D5,  E5.
L87E3:  .byte $FB,    $18   ;12.5% duty, len counter yes, env no, vol=8.
L87E5:  .byte $A9                   ;F5.
L87E6:  .byte $0C                   ;12 counts.
L87E7:  .byte $A4                   ;C5.
L87E8:  .byte $0C                   ;12 counts.
L87E9:  .byte $A1                   ;A4.
L87EA:  .byte $0C                   ;12 counts.
L87EB:  .byte $FE             ;Jump to new music address.
L87EC:  .word TRIVillage            ;($87A2).

TRIVillage2:
.incbin "bin/Bank01/TRIVillage2.bin"
TRIOutdoor:
.incbin "bin/Bank01/TRIOutdoor.bin"
TRIOutdoorLoop:
.incbin "bin/Bank01/TRIOutdoorLoop.bin"
L8842:  .word TRIOutdoorLoop        ;($881B).
SQ1Outdoor:
.incbin "bin/Bank01/SQ1Outdoor.bin"
SQ1OutdoorLoop:
.incbin "bin/Bank01/SQ1OutdoorLoop.bin"
L8889:  .word SQ1OutdoorLoop        ;($8848).
SQ1Dngn:
L888B:  .byte $FE             ;Jump to new music address.
L888C:  .word SQ1Dngn2              ;($88CA).
L888E:  .byte $FE             ;Jump to new music address.
L888F:  .word SQ1Dngn2              ;($88CA).
L8891:  .byte $FE             ;Jump to new music address.
L8892:  .word SQ1Dngn2              ;($88CA).
L8894:  .byte $FE             ;Jump to new music address.
L8895:  .word SQ1Dngn2              ;($88CA).
L8897:  .byte $FE             ;Jump to new music address.
L8898:  .word SQ1Dngn3              ;($88E1).
L889A:  .byte $FE             ;Jump to new music address.
L889B:  .word SQ1Dngn3              ;($88E1).
L889D:  .byte $FE             ;Jump to new music address.
L889E:  .word SQ1Dngn4              ;($88ED).
L88A0:  .byte $FE             ;Jump to new music address.
L88A1:  .word SQ1Dngn4              ;($88ED).
L88A3:  .byte $FE             ;Jump to new music address.
L88A4:  .word SQ1Dngn5              ;($88F9).
L88A6:  .byte $FE             ;Jump to new music address.
L88A7:  .word SQ1Dngn5              ;($88F9).
L88A9:  .byte $FE             ;Jump to new music address.
L88AA:  .word SQ1Dngn5              ;($88F9).
L88AC:  .byte $FE             ;Jump to new music address.
L88AD:  .word SQ1Dngn5              ;($88F9).
L88AF:  .byte $FE             ;Jump to new music address.
L88B0:  .word SQ1Dngn6              ;($8905).
L88B2:  .byte $FE             ;Jump to new music address.
L88B3:  .word SQ1Dngn6              ;($8905).
L88B5:  .byte $96, $0C              ;A#3, 12 counts.
L88B7:  .byte $FB,    $30   ;12.5% duty, len counter no, env no, vol=0.
L88B9:  .byte $24                   ;36 counts.
L88BA:  .byte $FB,    $B6   ;50% duty, len counter no, env no, vol=6.
L88BC:  .byte $FE             ;Jump to new music address.
L88BD:  .word SQ1Dngn7              ;($8911).
L88BF:  .byte $FE             ;Jump to new music address.
L88C0:  .word SQ1Dngn7              ;($8911).
L88C2:  .byte $95, $0C              ;A3,  12 counts.
L88C4:  .byte $FB,    $30   ;12.5% duty, len counter no, env no, vol=0.
L88C6:  .byte $24                   ;36 counts.
L88C7:  .byte $FE             ;Jump to new music address.
L88C8:  .word SQ1Dngn               ;($888B).

SQ1Dngn2:
.incbin "bin/Bank01/SQ1Dngn2.bin"
SQ1Dngn3:
.incbin "bin/Bank01/SQ1Dngn3.bin"
SQ1Dngn4:
.incbin "bin/Bank01/SQ1Dngn4.bin"
SQ1Dngn5:
.incbin "bin/Bank01/SQ1Dngn5.bin"
SQ1Dngn6:
.incbin "bin/Bank01/SQ1Dngn6.bin"
SQ1Dngn7:
.incbin "bin/Bank01/SQ1Dngn7.bin"
TRIDngn1:
L891D:  .byte $F9, $09   ;Note offset of 9 notes.
L891F:  .byte $FF,     $69   ;60/1.43=42 counts per second.
L8921:  .byte $FE             ;Jump to new music address.
L8922:  .word TRIDngn               ;($8950).

TRIDngn2:
L8924:  .byte $F9, $06   ;Note offset of 6 notes.
L8926:  .byte $FF,     $64   ;60/1.5=40 counts per second.
L8928:  .byte $FE             ;Jump to new music address.
L8929:  .word TRIDngn               ;($8950).

TRIDngn3:
L892B:  .byte $F9, $03   ;Note offset of 3 notes.
L892D:  .byte $FF,     $5F   ;60/1.58=38 counts per second.
L892F:  .byte $FE             ;Jump to new music address.
L8930:  .word TRIDngn               ;($8950).

TRIDngn4:
L8932:  .byte $FF,     $5A   ;60/1.67=36 counts per second.
L8934:  .byte $FE             ;Jump to new music address.
L8935:  .word TRIDngn               ;($8950).

TRIDngn5:
L8937:  .byte $F9, $FD   ;Note offset of 253 notes.
L8939:  .byte $FF,     $55   ;60/1.76=34 counts per second.
L893B:  .byte $FE             ;Jump to new music address.
L893C:  .word TRIDngn               ;($8950).

TRIDngn6:
L893E:  .byte $F9, $FA   ;Note offset of 250 notes.
L8940:  .byte $FF,     $50   ;60/1.88=32 counts per second.
L8942:  .byte $FE             ;Jump to new music address.
L8943:  .word TRIDngn               ;($8950).

TRIDngn7:
L8945:  .byte $F9, $F7   ;Note offset of 247 notes.
L8947:  .byte $FF,     $4B   ;60/2.0=30 counts per second.
L8949:  .byte $FE             ;Jump to new music address.
L894A:  .word TRIDngn               ;($8950).
TRIDngn8:
.incbin "bin/Bank01/TRIDngn8.bin"
TRIDngn:
.incbin "bin/Bank01/TRIDngn.bin"
L897F:  .word TRIDngn9              ;($8991).
L8981:  .byte $FE             ;Jump to new music address.
L8982:  .word TRIDngn9              ;($8991).
L8984:  .byte $AA, $30              ;F#5, 48 counts.
L8986:  .byte $FE             ;Jump to new music address.
L8987:  .word TRIDngn10             ;($899D).
L8989:  .byte $FE             ;Jump to new music address.
L898A:  .word TRIDngn10             ;($899D).
L898C:  .byte $A9, $30              ;F5,  48 counts.
L898E:  .byte $FE             ;Jump to new music address.
L898F:  .word TRIDngn               ;($8950).
TRIDngn9:
.incbin "bin/Bank01/TRIDngn9.bin"
TRIDngn10:
.incbin "bin/Bank01/TRIDngn10.bin"
SQ1EntFight:
L89A9:  .byte $FF,     $50   ;60/1.88=32 counts per second.
L89AB:  .byte $FB,    $4F   ;25% duty, len counter yes, env yes, vol=15.
L89AD:  .byte $FE             ;Jump to new music address.
L89AE:  .word EntFight              ;($8AAB).
L89B0:  .byte $FE             ;Jump to new music address.
L89B1:  .word EntFight              ;($8AAB).
L89B3:  .byte $FF,     $78   ;60/1.25=48 counts per second.
L89B5:  .byte $98, $24              ;C4,  36 counts.
L89B7:  .byte $98, $06              ;C4,   6 counts.
L89B9:  .byte $99, $06              ;C#4,  6 counts.
L89BB:  .byte $9A, $06              ;D4,   6 counts.
L89BD:  .byte $9C, $06              ;E4,   6 counts.

SQ1Fight:
.incbin "bin/Bank01/SQ1Fight.bin"

SQ1FightLoop:
.incbin "bin/Bank01/SQ1FightLoop_0.bin"
L89D8:  .word SQ1Fight2             ;($8ABF).
.incbin "bin/Bank01/SQ1FightLoop_1.bin"
L89F9:  .word SQ1Fight2             ;($8ABF).
L89FB:  .byte $FE             ;Jump to new music address.
L89FC:  .word SQ1Fight2             ;($8ABF).
.incbin "bin/Bank01/SQ1FightLoop.bin"
L8AA9:  .word SQ1FightLoop          ;($89C1).

EntFight:
.incbin "bin/Bank01/EntFight.bin"
SQ1Fight2:
.incbin "bin/Bank01/SQ1Fight2.bin"
TRIEntFight:
L8ACF:  .byte $FB,    $30   ;12.5% duty, len counter no, env no, vol=0.
L8AD1:  .byte $FE             ;Jump to new music address.
L8AD2:  .word EntFight              ;($8AAB).
L8AD4:  .byte $FE             ;Jump to new music address.
L8AD5:  .word EntFight              ;($8AAB).
L8AD7:  .byte $98, $24              ;C4,  36 counts.
L8AD9:  .byte $98, $06              ;C4,   6 counts.
L8ADB:  .byte $99, $06              ;C#4,  6 counts.
L8ADD:  .byte $9A, $06              ;D4,   6 counts.
L8ADF:  .byte $9C, $06              ;E4,   6 counts.

TRIFight:
.incbin "bin/Bank01/TRIFight.bin"
SQ1EndBoss:
.incbin "bin/Bank01/SQ1EndBoss.bin"
SQ1EndBoss2:
L8B64:  .byte $FE             ;Jump to new music address.
L8B65:  .word SQ1EndBoss3           ;($8BA1).
L8B67:  .byte $FE             ;Jump to new music address.
L8B68:  .word SQEndBoss             ;($8BB4).
L8B6A:  .byte $FE             ;Jump to new music address.
L8B6B:  .word SQ1EndBoss3           ;($8BA1).
.incbin "bin/Bank01/SQ1EndBoss2.bin"
L8B9F:  .word SQ1EndBoss2           ;($8B64).
SQ1EndBoss3:
.incbin "bin/Bank01/SQ1EndBoss3.bin"
SQEndBoss:
.incbin "bin/Bank01/SQEndBoss.bin"
SQ2EndBoss:
L8BE6:  .byte $F7, $0C   ;12 counts between notes.
L8BE8:  .byte $FE             ;Jump to new music address.
L8BE9:  .word SQ2EndBoss2           ;($8C00).
L8BEB:  .byte $FE             ;Jump to new music address.
L8BEC:  .word SQ2EndBoss3           ;($8C11).
L8BEE:  .byte $FE             ;Jump to new music address.
L8BEF:  .word SQ2EndBoss3           ;($8C11).
L8BF1:  .byte $FE             ;Jump to new music address.
L8BF2:  .word SQ2EndBoss3           ;($8C11).
L8BF4:  .byte $FE             ;Jump to new music address.
L8BF5:  .word SQ2EndBoss4           ;($8C15).
L8BF7:  .byte $FE             ;Jump to new music address.
L8BF8:  .word SQ2EndBoss2           ;($8C00).
L8BFA:  .byte $FE             ;Jump to new music address.
L8BFB:  .word SQEndBoss             ;($8BB4).
L8BFD:  .byte $FE             ;Jump to new music address.
L8BFE:  .word SQ2EndBoss            ;($8BE6).

SQ2EndBoss2:
.incbin "bin/Bank01/SQ2EndBoss2.bin"
SQ2EndBoss3:
.incbin "bin/Bank01/SQ2EndBoss3.bin"
SQ2EndBoss4:
.incbin "bin/Bank01/SQ2EndBoss4.bin"
TRIEndBoss:
.incbin "bin/Bank01/TRIEndBoss.bin"
TRIEndBossLoop:
L8C1E:  .byte $9A, $98, $9A, $98    ;D4,  C4,  D4,  C4.
L8C22:  .byte $9A, $98, $9A, $98    ;D4,  C4,  D4,  C4.
L8C26:  .byte $FE             ;Jump to new music address.
L8C27:  .word TRIEndBoss2           ;($8C35).
L8C29:  .byte $FE             ;Jump to new music address.
L8C2A:  .word TRIEndBoss2           ;($8C35).
L8C2C:  .byte $FE             ;Jump to new music address.
L8C2D:  .word TRIEndBoss2           ;($8C35).
L8C2F:  .byte $FE             ;Jump to new music address.
L8C30:  .word TRIEndBoss3           ;($8C39).
L8C32:  .byte $FE             ;Jump to new music address.
L8C33:  .word TRIEndBossLoop        ;($8C1E).

TRIEndBoss2:
.incbin "bin/Bank01/TRIEndBoss2.bin"
TRIEndBoss3:
.incbin "bin/Bank01/TRIEndBoss3.bin"
SQ2SlvrHrp:
.incbin "bin/Bank01/SQ2SlvrHrp.bin"
SQ1SlvrHrp:
.incbin "bin/Bank01/SQ1SlvrHrp.bin"
TRIFryFlute:
.incbin "bin/Bank01/TRIFryFlute.bin"
SQ2RnbwBrdg:
.incbin "bin/Bank01/SQ2RnbwBrdg.bin"
SQ1RnbwBrdg:
.incbin "bin/Bank01/SQ1RnbwBrdg.bin"
SQ2Death:
.incbin "bin/Bank01/SQ2Death.bin"
SQ1Death:
.incbin "bin/Bank01/SQ1Death.bin"
SQ2Cursed:
.incbin "bin/Bank01/SQ2Cursed.bin"
SQ1Cursed:
L8D4B:  .byte $FF,     $96   ;60/1 = 60 counts per second.
L8D4D:  .byte $FB,    $45   ;25% duty, len counter yes, env yes, vol=5.
L8D4F:  .byte $F7, $06   ;6 counts between notes.
L8D51:  .byte $FE             ;Jump to new music address.
L8D52:  .word SQCursed2             ;($8D68).
L8D54:  .byte $FE             ;Jump to new music address.
L8D55:  .word SQCursed2             ;($8D68).
L8D57:  .byte $FE             ;Jump to new music address.
L8D58:  .word SQCursed2             ;($8D68).
L8D5A:  .byte $FE             ;Jump to new music address.
L8D5B:  .word SQCursed2             ;($8D68).
L8D5D:  .byte $F6        ;Disable counts between notes.
L8D5E:  .byte $90, $14              ;E3,  20 counts.
L8D60:  .byte $91, $02              ;F3,   2 counts.
L8D62:  .byte $92, $02              ;F#3,  2 counts.
L8D64:  .byte $8A, $30              ;A#2, 48 counts.
L8D66:  .byte $00                   ;End music.
L8D67:  .byte $FC            ;Continue previous music.

SQCursed2:
.incbin "bin/Bank01/SQCursed2.bin"
SQ1Intro:
.incbin "bin/Bank01/SQ1Intro.bin"
SQ1IntroLoop:
.incbin "bin/Bank01/SQ1IntroLoop.bin"
L8E3B:  .word SQ1IntroLoop          ;($8DA6).
SQ2Intro:
.incbin "bin/Bank01/SQ2Intro.bin"
SQ2IntroLoop:
.incbin "bin/Bank01/SQ2IntroLoop.bin"
L8F04:  .word SQ2IntroLoop          ;($8E72).
TriIntro:
.incbin "bin/Bank01/TriIntro.bin"
TRIIntroLoop:
.incbin "bin/Bank01/TRIIntroLoop.bin"
L8F60:  .word TRIIntroLoop          ;($8F13).

SQ1EndGame:
.incbin "bin/Bank01/SQ1EndGame.bin"
L8FA3:  .word SQ1EndGame2           ;($902F).
L8FA5:  .byte $FE             ;Jump to new music address.
L8FA6:  .word SQ1EndGame3           ;($9072).
L8FA8:  .byte $FE             ;Jump to new music address.
L8FA9:  .word SQ1EndGame2           ;($902F).
L8FAB:  .byte $FE             ;Jump to new music address.
L8FAC:  .word SQ1EndGame3           ;($9072).
L8FAE:  .byte $FE             ;Jump to new music address.
L8FAF:  .word SQ1EndGame2           ;($902F).
.incbin "bin/Bank01/SQ1EndGame_0.bin"
L8FF7:  .word SQ1EndGame4           ;($901D).
L8FF9:  .byte $FE             ;Jump to new music address.
L8FFA:  .word SQ1EndGame4           ;($901D).
L8FFC:  .byte $FE             ;Jump to new music address.
L8FFD:  .word SQ1EndGame4           ;($901D).
L8FFF:  .byte $FE             ;Jump to new music address.
L9000:  .word SQ1EndGame4           ;($901D).
L9002:  .byte $FF,     $69   ;60/1.43=42 counts per second.
L9004:  .byte $FE             ;Jump to new music address.
L9005:  .word SQ1EndGame5           ;($9026).
L9007:  .byte $FE             ;Jump to new music address.
L9008:  .word SQ1EndGame5           ;($9026).
L900A:  .byte $FE             ;Jump to new music address.
L900B:  .word SQ1EndGame5           ;($9026).
L900D:  .byte $FE             ;Jump to new music address.
L900E:  .word SQ1EndGame5           ;($9026).
.incbin "bin/Bank01/SQ1EndGame_1.bin"

SQ1EndGame4:
.incbin "bin/Bank01/SQ1EndGame4.bin"
SQ1EndGame5:
.incbin "bin/Bank01/SQ1EndGame5.bin"
SQ1EndGame2:
.incbin "bin/Bank01/SQ1EndGame2.bin"
SQ1EndGame3:
.incbin "bin/Bank01/SQ1EndGame3.bin"
SQ2EndGame:
.incbin "bin/Bank01/SQ2EndGame.bin"
L90E9:  .word SQ2EndGame2           ;($9159).
L90EB:  .byte $FB,    $8F   ;50% duty, len counter yes, env yes, vol=15.
L90ED:  .byte $FE             ;Jump to new music address.
L90EE:  .word SQ2EndGame3           ;($91A0).
L90F0:  .byte $FE             ;Jump to new music address.
L90F1:  .word SQ2EndGame2           ;($9159).
L90F3:  .byte $FB,    $4F   ;25% duty, len counter yes, env yes, vol=15.
L90F5:  .byte $FE             ;Jump to new music address.
L90F6:  .word SQ2EndGame3           ;($91A0).
L90F8:  .byte $FE             ;Jump to new music address.
L90F9:  .word SQ2EndGame2           ;($9159).
.incbin "bin/Bank01/SQ2EndGame_2.bin"
L9125:  .word SQ2EndGame4           ;($9147).
L9127:  .byte $FE             ;Jump to new music address.
L9128:  .word SQ2EndGame4           ;($9147).
L912A:  .byte $FE             ;Jump to new music address.
L912B:  .word SQ2EndGame4           ;($9147).
L912D:  .byte $FE             ;Jump to new music address.
L912E:  .word SQ2EndGame4           ;($9147).
L9130:  .byte $FE             ;Jump to new music address.
L9131:  .word SQ2EndGame5           ;($9150).
L9133:  .byte $FE             ;Jump to new music address.
L9134:  .word SQ2EndGame5           ;($9150).
L9136:  .byte $FE             ;Jump to new music address.
L9137:  .word SQ2EndGame5           ;($9150).
L9139:  .byte $FE             ;Jump to new music address.
L913A:  .word SQ2EndGame5           ;($9150).
L913C:  .byte $FB,    $49   ;25% duty, len counter yes, env yes, vol=9.
L913E:  .byte $F7, $08   ;8 counts between notes.
L9140:  .byte $9F                   ;G4.
L9141:  .byte $10                   ;16 counts.
L9142:  .byte $8C, $8C, $8C, $8C    ;C3,  C3,  C3,  C3.
L9146:  .byte $00                   ;End music.

SQ2EndGame4:
.incbin "bin/Bank01/SQ2EndGame4.bin"
SQ2EndGame5:
.incbin "bin/Bank01/SQ2EndGame5.bin"
SQ2EndGame2:
.incbin "bin/Bank01/SQ2EndGame2.bin"
SQ2EndGame3:
.incbin "bin/Bank01/SQ2EndGame3.bin"
TRIEndGame:
.incbin "bin/Bank01/TriEndGame_0.bin"
L925E:  .word TRIEndGame2           ;($92BF).
L9260:  .byte $FE             ;Jump to new music address.
L9261:  .word TRIEndGame3           ;($92F2).
L9263:  .byte $FE             ;Jump to new music address.
L9264:  .word TRIEndGame2           ;($92BF).
L9266:  .byte $FE             ;Jump to new music address.
L9267:  .word TRIEndGame3           ;($92F2).
L9269:  .byte $FE             ;Jump to new music address.
L926A:  .word TRIEndGame2           ;($92BF).
.incbin "bin/Bank01/TRIEndGame.bin"
TRIEndGame2:
.incbin "bin/Bank01/TRIEndGame2.bin"
TRIEndGame3:
.incbin "bin/Bank01/TRIEndGame3.bin"
EndGameClearPPU:
L9354:  LDA #%00000000          ;Turn off sprites and background.
L9356:  STA PPUControl1         ;

L9359:  JSR ClearPPU            ;($C17A)Clear the PPU.

L935C:  LDA #%00011000          ;
L935E:  STA PPUControl1         ;Turn on sprites and background.
L9361:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ExitGame:
L9362:  LDA #MSC_NOSOUND        ;Silence music.
L9364:  BRK                     ;
L9365:  .byte $04, $17          ;($81A0)InitMusicSFX, bank 1.

L9367:  BRK                     ;Load palettes for end credits.
L9368:  .byte $06, $07          ;($AA62)LoadCreditsPals, bank 0.

L936A:  LDA #$00                ;
L936C:  STA ExpLB               ;
L936E:  STA ScrollX             ;Clear various RAM values.
L9370:  STA ScrollY             ;
L9372:  STA ActiveNmTbl         ;
L9374:  STA NPCUpdateCntr       ;

L9376:  LDX #$3B                ;Prepare to clear NPC position RAM.

L9378: STA NPCXPos,X           ;
L937A:  DEX                     ;Clear NPC map position RAM (60 bytes).
L937B:  BPL L9378                   ;

L937D:  LDA #EN_DRAGONLORD2     ;Set enemy number.
L937F:  STA EnNumber            ;

L9381:  JSR ClearSpriteRAM      ;($C6BB)Clear sprite RAM.
L9384:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
L9387:  JSR EndGameClearPPU     ;($9354)Clear the display contents of the PPU.

L938A:  LDA #$FF                ;Set hit points.
L938C:  STA HitPoints           ;

L938E:  BRK                     ;Load BG and sprite palettes for selecting saved game.
L938F:  .byte $01, $07          ;($AA7E)LoadStartPals, bank 0.

L9391:  JSR DoWindow            ;($C6F0)display on-screen window.
L9394:  .byte WND_DIALOG        ;Dialog window.

L9395:  JSR DoDialogHiBlock     ;($C7C5)Please press reset, hold it in...
L9398:  .byte $28               ;TextBlock19, entry 8.
L9399:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DoEndCredits:
L939A:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.

L939D:  LDA #MSC_END            ;End music.
L939F:  BRK                     ;
L93A0:  .byte $04, $17          ;($81A0)InitMusicSFX, bank 1.

L93A2:  BRK                     ;Wait for the music clip to end.
L93A3:  .byte $03, $17          ;($815E)WaitForMusicEnd, bank 1.

L93A5:  BRK                     ;Load palettes for end credits.
L93A6:  .byte $06, $07          ;($AA62)LoadCreditsPals, bank 0.

L93A8:  JSR ClearSpriteRAM      ;($C6BB)Clear sprites.

L93AB:  LDA #%00000000          ;Turn off sprites and background.
L93AD:  STA PPUControl1         ;

L93B0:  JSR Bank0ToCHR0         ;($FCA3)Load data into CHR0.

L93B3:  LDA #$00                ;
L93B5:  STA ExpLB               ;
L93B7:  STA ScrollX             ;
L93B9:  STA ScrollY             ;Clear various RAM values.
L93BB:  STA ActiveNmTbl         ;
L93BD:  LDA #EN_DRAGONLORD2     ;
L93BF:  STA EnNumber            ;

L93C1:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
L93C4:  JSR EndGameClearPPU     ;($9354)Clear the display contents of the PPU.

L93C7:  LDA #$23                ;
L93C9:  STA PPUAddrUB           ;
L93CB:  LDA #$C8                ;Set attribute table bytes for nametable 0.
L93CD:  STA PPUAddrLB           ;
L93CF:  LDA #$55                ;
L93D1:  STA PPUDataByte         ;

L93D3:  LDY #$08                ;Load 8 bytes of attribute table data.
L93D5: JSR AddPPUBufEntry      ;($C690)Add data to PPU buffer.
L93D8:  DEY                     ;Done loading attribute table bytes? 
L93D9:  BNE L93D5               ;If not, branch to load more.

L93DB:  LDA #$AA                ;Load different attribute table data.
L93DD:  STA PPUDataByte         ;

L93DF:  LDY #$20                ;Fill the remainder of the attribute table with the data.
L93E1: JSR AddPPUBufEntry      ;($C690)Add data to PPU buffer.
L93E4:  DEY                     ;Done loading attribute table bytes? 
L93E5:  BNE L93E1               ;If not, branch to load more.

L93E7:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.

L93EA:  LDA EndCreditDatPtr     ;
L93ED:  STA DatPntr1LB          ;Get pointer to end credits data.
L93EF:  LDA EndCreditDatPtr+1   ;
L93F2:  STA DatPntrlUB          ;

L93F4:  JMP RollCredits         ;($93FA)Display credits on the screen.

DoClearPPU:
L93F7:  JSR EndGameClearPPU     ;($9354)Clear the display contents of the PPU.

RollCredits:
L93FA:  LDY #$00                ;
L93FC:  LDA (DatPntr1),Y        ;First 2 bytes of data block are the PPU address.
L93FE:  STA PPUAddrLB           ;Load those bytes into the PPU data buffer as the
L9400:  INY                     ;target address for the data write.
L9401:  LDA (DatPntr1),Y        ;
L9403:  STA PPUAddrUB           ;

L9405:  LDY #$02                ;Move to data after PPU address.

GetNextEndByte:
L9407:  LDA (DatPntr1),Y        ;
L9409:  STA PPUDataByte         ;Is the byte a repeat control byte?
L940B:  CMP #END_RPT            ;
L940D:  BNE DoNonRepeatedValue  ;If not, branch to check for other byte types.

DoRepeatedValue:
L940F:  INY                     ;
L9410:  LDA (DatPntr1),Y        ;Get next byte. It is the number of times to repeat.
L9412:  STA GenByte3C           ;
L9414:  INY                     ;
L9415:  LDA (DatPntr1),Y        ;Get next byte. It is the byte to repeatedly load.
L9417:  STA PPUDataByte         ;Store byte in PPU buffer.

L9419: JSR AddPPUBufEntry      ;($C690)Add data to PPU buffer.
L941C:  DEC GenByte3C           ;More data to load?
L941E:  BNE L9419               ;If so, branch to load next byte.

L9420:  INY                     ;Increment data index.
L9421:  BNE GetNextEndByte      ;Get next data byte.

DoNonRepeatedValue:
L9423:  CMP #END_TXT_END        ;
L9425:  BEQ FinishEndDataBlock  ;Has an end of data block byte been found?
L9427:  CMP #END_RPT_END        ;If so, display credits and move to next data block.
L9429:  BEQ FinishEndDataBlock  ;

L942B:  JSR AddPPUBufEntry      ;($C690)Add data to PPU buffer.

L942E:  INY                     ;Increment data index.
L942F:  BNE GetNextEndByte      ;Get next data byte.

FinishEndDataBlock:
L9431:  INY                     ;Increment data index and prepare to add
L9432:  TYA                     ;it to the data pointer.

L9433:  CLC                     ;
L9434:  ADC DatPntr1LB          ;Move pointer to start of next block of credits.
L9436:  STA DatPntr1LB          ;
L9438:  BCC L943C                   ;Does upper byte of pointer need to be incremented?
L943A:  INC DatPntrlUB          ;If not, branch to skip.

L943C: LDA PPUDataByte         ;Has the end of this segment been found?
L943E:  CMP #END_TXT_END        ;If so, branch to get next segment.
L9440:  BEQ RollCredits         ;($93FA)Loop to keep rolling credits.

L9442:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.

L9445:  BRK                     ;Fade in credits.
L9446:  .byte $07, $07          ;($AA3D)DoPalFadeIn, bank 0.

L9448:  LDA EndCreditCount      ;Get the number of credit screens that have been shown.
L944A:  BNE CheckCredits1       ;Is this the first one? If not, branch.

L944C:  LDY #$08                ;First credit screen.  Wait for 8 music timing events.
L944E:  BNE WaitForMusTmng      ;Branch always.

CheckCredits1:
L9450:  CMP #$01                ;Is this the second credit screen?
L9452:  BNE CheckCredits2       ;If not, branch.

L9454:  LDY #$02                ;Second credit screen.  Wait for 2 music timing events.
L9456:  BNE WaitForMusTmng      ;Branch always.

CheckCredits2:
L9458:  CMP #$02                ;Is this the third credit screen?
L945A:  BEQ CheckCreditEnd      ;if so, branch to wait for 3 music timing events.

L945C:  CMP #$03                ;Is this the fourth credit screen?
L945E:  BEQ CheckCreditEnd      ;if so, branch to wait for 3 music timing events.

L9460:  CMP #$04                ;Is this the fifth credit screen?
L9462:  BEQ CheckCreditEnd      ;if so, branch to wait for 3 music timing events.

L9464:  CMP #$0D                ;Is this the 14th or less credit screen?
L9466:  BEQ MusicTiming2        ;
L9468:  BCC MusicTiming2        ;if so, branch to wait for 2 music timing events.

CheckCreditEnd:
L946A:  CMP #$12                ;Have all 18 screens of credits been shown?
L946C:  BCC MusicTiming3        ;If not, branch to do more.

FinishCredits:
L946E:  LDY #$A0                ;Wait 160 frames.
L9470: JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
L9473:  DEY                     ;Done waiting 160 frames?
L9474:  BNE L9470               ;If not, branch to wait more.
L9476:  RTS                     ;

MusicTiming3:
L9477:  LDY #$03                ;Wait for 3 music timing events.
L9479:  BNE WaitForMusTmng      ;Branch always.

MusicTiming2:
L947B:  LDY #$02                ;Wait for 2 music timing events.

WaitForMusTmng:
L947D: BRK                     ;Wait for timing queue in music.
L947E:  .byte $03, $17          ;($815E)WaitForMusicEnd, bank 1.

L9480:  DEY                     ;Is it time to move to the next set of credits?
L9481:  BNE L947D               ;If not, branch to wait more.
L9483:  INC EndCreditCount      ;Increment credit screen counter.

L9485:  BRK                     ;Fade out credits.
L9486:  .byte $08, $07          ;($AA43)DoPalFadeOut, bank 0.

L9488:  JMP DoClearPPU          ;($93F7)Prepare to load next screen of credits.

;----------------------------------------------------------------------------------------------------

EndCreditDatPtr:
L948B:  .word EndCreditDat      ;($948D)Start of data below.
EndCreditDat:
.incbin "bin/Bank01/EndCreditDat.bin"
CopyTrsrTbl:
L994F:  PHA                     ;
L9950:  TXA                     ;Save A and X.
L9951:  PHA                     ;

L9952:  LDX #$7B                ;Prepare to copy 124 bytes.

L9954: LDA TreasureTbl,X       ;Copy treasure table into RAM starting at $0320.
L9957:  STA BlockRAM+$20,X      ;
L995A:  DEX                     ;Have 124 bytes been copied?
L995B:  BPL L9954                   ;If not, branch to copy more.

L995D:  PLA                     ;
L995E:  TAX                     ;Restore X and A.
L995F:  PLA                     ;
L9960:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LoadEnemyStats:
L9961:  PHA                     ;
L9962:  TYA                     ;Store A and Y.
L9963:  PHA                     ;

L9964:  LDY #$0F                ;16 bytes per enemy in EnStatTbl.
L9966:  LDA EnDatPtrLB          ;
L9968:  CLC                     ;
L9969:  ADC EnStatTblPtr        ;Add enemy data offset to the table pointer.
L996C:  STA GenPtr3CLB          ;
L996E:  LDA EnDatPtrUB          ;
L9970:  ADC EnStatTblPtr+1      ;Save a copy of the pointer in a general use pointer.
L9973:  STA GenPtr3CUB          ;

L9975: LDA (GenPtr3C),Y        ;Use the general pointer to load the enemy data.
L9977:  STA EnBaseAtt,Y         ;
L997A:  DEY                     ;
L997B:  BPL L9975                   ;More data to load? If so, branch to load more.

L997D:  PLA                     ;
L997E:  TAY                     ;Restore A and Y and return.
L997F:  PLA                     ;
L9980:  RTS                     ;

;----------------------------------------------------------------------------------------------------

CopyROMToRAM:
L9981:  PHA                     ;
L9982:  TYA                     ;Save A and Y.
L9983:  PHA                     ;

L9984:  LDY #$00                ;
L9986:  LDA CopyCounterLB       ;Is copy counter = 0?
L9988:  ORA CopyCounterUB       ;If so, branch.  Nothing to copy.
L998A:  BEQ CopyROMDone         ;

CopyROMLoop:
L998C:  LDA (ROMSrcPtr),Y       ;Get byte from ROM and put it into RAM.
L998E:  STA (RAMTrgtPtr),Y      ;

L9990:  LDA CopyCounterLB       ;
L9992:  SEC                     ;
L9993:  SBC #$01                ;
L9995:  STA CopyCounterLB       ;Decrement copy counter.
L9997:  LDA CopyCounterUB       ;
L9999:  SBC #$00                ;
L999B:  STA CopyCounterUB       ;

L999D:  ORA CopyCounterLB       ;Is copy counter = 0?
L999F:  BEQ CopyROMDone         ;If so, branch.  Done copying.

L99A1:  INC ROMSrcPtrLB         ;
L99A3:  BNE L99A7                   ;Increment ROM source pointer.
L99A5:  INC ROMSrcPtrUB         ;

L99A7: INC RAMTrgtPtrLB        ;
L99A9:  BNE L99AD                   ;Increment RAM target pointer.
L99AB:  INC RAMTrgtPtrUB        ;

L99AD: JMP CopyROMLoop         ;($998C)Loop to copy more data.

CopyROMDone:
L99B0:  PLA                     ;
L99B1:  TAY                     ;Restore Y and A and return.
L99B2:  PLA                     ;
L99B3:  RTS                     ;

;----------------------------------------------------------------------------------------------------

SetBaseStats:
L99B4:  TYA                     ;Save Y on the stack.
L99B5:  PHA                     ;

L99B6:  LDA BaseStatsTbl-2      ;
L99B9:  STA PlayerDatPtrLB      ;Load base address for the BaseStatsTbl.
L99BB:  LDA BaseStatsTbl-1      ;
L99BE:  STA PlayerDatPtrUB      ;
L99C0:  LDY LevelDatPtr         ;Load offset for player's level in the table.

L99C2:  LDA (PlayerDatPtr),Y    ;
L99C4:  STA DisplayedStr        ;Load player's base strength.
L99C6:  INY                     ;

L99C7:  LDA (PlayerDatPtr),Y    ;
L99C9:  STA DisplayedAgi        ;Load player's base agility.
L99CB:  INY                     ;

L99CC:  LDA (PlayerDatPtr),Y    ;
L99CE:  STA DisplayedMaxHP      ;Load player's base max HP.
L99D0:  INY                     ;

L99D1:  LDA (PlayerDatPtr),Y    ;
L99D3:  STA DisplayedMaxMP      ;Load player's base MP.
L99D5:  INY                     ;

L99D6:  LDA (PlayerDatPtr),Y    ;
L99D8:  ORA ModsnSpells         ;Load player's healmore/hurtmore spells.
L99DA:  STA ModsnSpells         ;
L99DC:  INY                     ;

L99DD:  LDA (PlayerDatPtr),Y    ;Load player's other spells.
L99DF:  STA SpellFlags          ;

L99E1:  PLA                     ;
L99E2:  TAY                     ;Restore Y and return.
L99E3:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table contains the pointers to the enemy sprites.  The MSB for the pointer is not
;set for some entries.  The enemies that have the MSB set in the table below are mirrored from left
;to right on the display.  For example, the knight and armored knight have the same foot forward
;while the axe knight has the opposite foot forward.  This is because the axe knight is mirrored
;while the other two are not. The code that accesses the table sets the MSB when it accesses it.

EnSpritesPtrTbl:
L99E4:  .word SlimeSprts -$8000 ;($1B0E)Slime.
L99E6:  .word SlimeSprts -$8000 ;($1B0E)Red slime.
L99E8:  .word DrakeeSprts-$8000 ;($1AC4)Drakee.
L99EA:  .word GhstSprts  -$8000 ;($1BAA)Ghost.
L99EC:  .word MagSprts   -$8000 ;($1B30)Magician.
L99EE:  .word DrakeeSprts-$8000 ;($1AC4)Magidrakee.
L99F0:  .word ScorpSprts -$8000 ;($1CD1)Scorpion.
L99F2:  .word DruinSprts -$8000 ;($1AE0)Druin.
L99F4:  .word GhstSprts  -$8000 ;($1BAA)Poltergeist.
L99F6:  .word DrollSprts -$8000 ;($1A87)Droll.
L99F8:  .word DrakeeSprts-$8000 ;($1AC4)Drakeema.
L99FA:  .word SkelSprts         ;($9A3E)Skeleton.
L99FC:  .word WizSprts   -$8000 ;($1B24)Warlock.
L99FE:  .word ScorpSprts        ;($9CD1)Metal scorpion.
L9A00:  .word WolfSprts  -$8000 ;($1C15)Wolf.
L9A02:  .word SkelSprts  -$8000 ;($1A3E)Wraith.
L9A04:  .word SlimeSprts -$8000 ;($1B0E)Metal slime.
L9A06:  .word GhstSprts         ;($9BAA)Specter.
L9A08:  .word WolfSprts         ;($9C15)Wolflord.
L9A0A:  .word DruinSprts        ;($9AE0)Druinlord.
L9A0C:  .word DrollSprts -$8000 ;($1A87)Drollmagi.
L9A0E:  .word WyvrnSprts -$8000 ;($1BD5)Wyvern.
L9A10:  .word ScorpSprts -$8000 ;($1CD1)Rouge scorpion.
L9A12:  .word DKnightSprts      ;($9A32)Wraith knight.
L9A14:  .word GolemSprts        ;($9C70)Golem.
L9A16:  .word GolemSprts -$8000 ;($1C70)Goldman.
L9A18:  .word KntSprts   -$8000 ;($1D20)Knight.
L9A1A:  .word WyvrnSprts        ;($9BD5)Magiwyvern.
L9A1C:  .word DKnightSprts      ;($9A32)Demon knight.
L9A1E:  .word WolfSprts  -$8000 ;($1C15)Werewolf.
L9A20:  .word DgnSprts   -$8000 ;($1D81)Green dragon.
L9A22:  .word WyvrnSprts -$8000 ;($1BD5)Starwyvern.
L9A24:  .word WizSprts          ;($9B24)Wizard.
L9A26:  .word AxKntSprts        ;($9D0E)Axe knight.
L9A28:  .word RBDgnSprts -$8000 ;($1D7B)Blue dragon.
L9A2A:  .word GolemSprts -$8000 ;($1C70)Stoneman.
L9A2C:  .word ArKntSprts -$8000 ;($1D02)Armored knight.
L9A2E:  .word RBDgnSprts -$8000 ;($1D7B)Red dragon.
L9A30:  .word DgLdSprts  -$8000 ;($1B67)Dragonlord, initial form.

DKnightSprts:
.incbin "bin/Bank01/DKnightSprts.bin"
SkelSprts:
.incbin "bin/Bank01/SkelSprts.bin"
DrollSprts:
.incbin "bin/Bank01/DrollSprts.bin"
DrakeeSprts:
.incbin "bin/Bank01/DrakeeSprts.bin"
DruinSprts:
.incbin "bin/Bank01/DruinSprts.bin"
SlimeSprts:
.incbin "bin/Bank01/SlimeSprts.bin"
WizSprts:
.incbin "bin/Bank01/WizSprts.bin"
MagSprts:
.incbin "bin/Bank01/MagSprts.bin"
DgLdSprts:
.incbin "bin/Bank01/DgLdSprts.bin"
GhstSprts:
.incbin "bin/Bank01/GhstSprts.bin"
WyvrnSprts:
.incbin "bin/Bank01/WyvrnSprts.bin"
WolfSprts:
.incbin "bin/Bank01/WolfSprts.bin"
GolemSprts:
.incbin "bin/Bank01/GolemSprts.bin"
ScorpSprts:
.incbin "bin/Bank01/ScorpSprts.bin"
ArKntSprts:
.incbin "bin/Bank01/ArKntSprts.bin"
AxKntSprts:
.incbin "bin/Bank01/AxKntSprts.bin"
KntSprts:
.incbin "bin/Bank01/KntSprts.bin"
RBDgnSprts:
.incbin "bin/Bank01/RBDgnSprts.bin"
DgnSprts:
.incbin "bin/Bank01/DgnSprts.bin"
TreasureTbl:
L9DCD:  .byte MAP_TANTCSTL_GF, $01, $0D, TRSR_GLD2  ;Tant castle, GF at 1,13: 6-13g.
L9DD1:  .byte MAP_TANTCSTL_GF, $01, $0F, TRSR_GLD2  ;Tant castle, GF at 1,15: 6-13g.
L9DD5:  .byte MAP_TANTCSTL_GF, $02, $0E, TRSR_GLD2  ;Tant castle, GF at 2,14: 6-13g.
L9DD9:  .byte MAP_TANTCSTL_GF, $03, $0F, TRSR_GLD2  ;Tant castle, GF at 3,15: 6-13g.
L9DDD:  .byte MAP_THRONEROOM,  $04, $04, TRSR_GLD5  ;Throne room at 4,4: 120g.
L9DE1:  .byte MAP_THRONEROOM,  $05, $04, TRSR_TORCH ;Throne room at 5,4: Torch.
L9DE5:  .byte MAP_THRONEROOM,  $06, $01, TRSR_KEY   ;Throne room at 6,1: Magic key.
L9DE9:  .byte MAP_RIMULDAR,    $18, $17, TRSR_WINGS ;Rumuldar at 24,23: wings.
L9DED:  .byte MAP_GARINHAM,    $08, $05, TRSR_GLD3  ;Garingham at 8,5: 10-17g.
L9DF1:  .byte MAP_GARINHAM,    $08, $06, TRSR_HERB  ;Garingham at 8,6: Herb.
L9DF5:  .byte MAP_GARINHAM,    $09, $05, TRSR_TORCH ;Garingham at 9,5: Torch.
L9DF9:  .byte MAP_DLCSTL_BF,   $0B, $0B, TRSR_HERB  ;Drgnlrd castle BF at 11,11: Herb.
L9DFD:  .byte MAP_DLCSTL_BF,   $0B, $0C, TRSR_GLD4  ;Drgnlrd castle BF at 11,12: 500-755g.
L9E01:  .byte MAP_DLCSTL_BF,   $0B, $0D, TRSR_WINGS ;Drgnlrd castle BF at 11,13: wings.
L9E04:  .byte MAP_DLCSTL_BF,   $0C, $0C, TRSR_KEY   ;Drgnlrd castle BF at 12,12: Key.
L9E09:  .byte MAP_DLCSTL_BF,   $0C, $0D, TRSR_BELT  ;Drgnlrd castle BF at 12,13: Cursed belt.
L9E0D:  .byte MAP_DLCSTL_BF,   $0D, $0D, TRSR_HERB  ;Drgnlrd castle BF at 13,13: Herb.
L9E11:  .byte MAP_TANTCSTL_SL, $04, $05, TRSR_SUN   ;Tant castle, SL at 4,5: Stones of sunlight.
L9E15:  .byte MAP_RAIN,        $03, $04, TRSR_RAIN  ;Staff of rain cave at 3,4: Staff of rain.
L9E19:  .byte MAP_CVGAR_B1,    $0B, $00, TRSR_HERB  ;Gar cave B1 at 11,0: Herb.
L9E1D:  .byte MAP_CVGAR_B1,    $0C, $00, TRSR_GLD1  ;Gar cave B1 at 12,0: 5-20g.
L9E21:  .byte MAP_CVGAR_B1,    $0D, $00, TRSR_GLD2  ;Gar cave B1 at 13,0: 6-13g.
L9E25:  .byte MAP_CVGAR_B3,    $01, $01, TRSR_BELT  ;Gar cave B3 at 1,1: Cursed belt.
L9E29:  .byte MAP_CVGAR_B3,    $0D, $06, TRSR_HARP  ;Gar cave B3 at 13,6: Silver harp.
L9E2D:  .byte MAP_DLCSTL_SL2,  $05, $05, TRSR_ERSD  ;Drgnlrd castle SL2 at 5,5: Erdrick's sword.
L9E31:  .byte MAP_RCKMTN_B2,   $01, $06, TRSR_NCK   ;Rock mtn B2 at 1,6: Death nck or 100-131g.
L9E35:  .byte MAP_RCKMTN_B2,   $03, $02, TRSR_TORCH ;Rock mtn B2 at 3,2: Torch.
L9E39:  .byte MAP_RCKMTN_B2,   $02, $02, TRSR_RING  ;Rock mtn B2 at 2,2: Fighter's ring.
L9E3D:  .byte MAP_RCKMTN_B2,   $0A, $09, TRSR_GLD3  ;Rock mtn B2 at 10,9: 10-17g.
L9E41:  .byte MAP_RCKMTN_B1,   $0D, $05, TRSR_HERB  ;Rock mtn B1 at 13,5: Herb.
L9E45:  .byte MAP_ERDRCK_B2,   $09, $03, TRSR_TBLT  ;Erd cave B2 at 9,3: Erdrick's tablet.

;----------------------------------------------------------------------------------------------------

;The following table contains the stats for the enemies.  There are 16 bytes per enemy.  The
;upper 8 bytes do not appear to be used.  The lower 8 bytes are the following:
;Att  - Enemy's attack power.
;Def  - Enemy's defense power.
;HP   - Enemy's base hit points.
;Spel - Enemy's spells.
;Agi  - Enemy's agility.
;Mdef - Enemy's magical defense.
;Exp  - Experience received from defeating enemy.
;Gld  - Gold received from defeating enemy.

EnStatTblPtr:                   ;Pointer to the table below.
L9E49:  .word EnStatTbl

EnStatTbl:
.incbin "bin/Bank01/EnStatTbl.bin"

;The table below provides the base stats per level.  The bytes represent the following stats:
;Byte 1-Strength, byte 2-Agility, byte 3-Max HP, byte 4-Max MP, byte 5-Healmore and Hurtmore
;spell flags, byte 6-All other spell flags.

LA0CB:  .word BaseStatsTbl
BaseStatsTbl:
.incbin "bin/Bank01/BaseStatsTbl.bin"

.ifndef namegen
    WndUnusedFunc1:
    LA181:  PLA                     ;Pull the value off the stack.

    LA182:  CLC                     ;
    LA183:  ADC #$01                ;
    LA185:  STA GenPtr3ELB          ;Add the value to the pointer.
    LA187:  PLA                     ;
    LA188:  ADC #$00                ;
    LA18A:  STA GenPtr3EUB          ;

    LA18C:  PHA                     ;
    LA18D:  LDA GenPtr3ELB          ;Push the new pointer value on the stack.
    LA18F:  PHA                     ;

    LA190:  LDY #$00                ;Use the pointer to retreive a byte from memory.
    LA192:  LDA (GenPtr3E),Y        ;
.endif

;----------------------------------------------------------------------------------------------------

ShowWindow:
LA194:  JSR DoWindowPrep        ;($AEE1)Do some initial prep before window is displayed.
LA197:  JSR WindowSequence      ;($A19B)run the window building sequence.
LA19A:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WindowSequence:
LA19B:  STA WindowType          ;Save the window type.

LA19E:  LDA WndBuildPhase       ;Indicate first phase of window build is ocurring.
LA1A1:  ORA #$80                ;
LA1A3:  STA WndBuildPhase       ;

LA1A6:  JSR WndConstruct        ;($A1B1)Do the first phase of window construction.
LA1A9:  JSR WndCalcBufAddr      ;($A879)Calculate screen buffer address for data.

LA1AC:  LDA #$40                ;Indicate second phase of window build is ocurring.
LA1AE:  STA WndBuildPhase       ;

WndConstruct:
LA1B1:  JSR GetWndDatPtr        ;($A1D0)Get pointer to window data.
LA1B4:  JSR GetWndConfig        ;($A1E4)Get window configuration data.
LA1B7:  JSR WindowEngine        ;($A230)The guts of the window engine.

LA1BA:  BIT WndBuildPhase       ;Finishing up the first phase?
LA1BD:  BMI WndConstructDone    ;If so, branch to 

LA1BF:  LDA WindowType          ;
LA1C2:  CMP #WND_SPELL1         ;Special case. Don't destroy these windows when done.
LA1C4:  BCC WndConstructDone    ;The spell 1 window is never used and the alphabet
LA1C6:  CMP #WND_ALPHBT         ;window does not disappear when an item is selected.
LA1C8:  BCS WndConstructDone    ;

LA1CA:  BRK                     ;Remove window from screen.
LA1CB:  .byte $05, $07          ;($A7A2)RemoveWindow, bank 0.

WndConstructDone:
LA1CD:  LDA WndSelResults       ;Return window selection results, if any.
LA1CF:  RTS                     ;

;----------------------------------------------------------------------------------------------------

GetWndDatPtr:
LA1D0:  LDA #$00                ;First entry in description table is for windows.
LA1D2:  JSR GetDescPtr          ;($A823)Get pointer into description table.

LA1D5:  LDA WindowType          ;*2. Pointer is 2 bytes.
LA1D8:  ASL                     ;

LA1D9:  TAY                     ;
LA1DA:  LDA (DescPtr),Y         ;
LA1DC:  STA WndDatPtrLB         ;Get pointer to desired window data table.
LA1DE:  INY                     ;
LA1DF:  LDA (DescPtr),Y         ;
LA1E1:  STA WndDatPtrUB         ;
LA1E3:  RTS                     ;

;----------------------------------------------------------------------------------------------------

GetWndConfig:
LA1E4:  LDY #$00                ;Set pointer at base of data table.
LA1E6:  LDA (WndDatPtr),Y       ;
LA1E8:  STA WndOptions          ;Get window options byte from table.

LA1EB:  INY                     ;
LA1EC:  LDA (WndDatPtr),Y       ;
LA1EE:  STA WndHeightblks       ;Get window height in block from table.
LA1F1:  ASL                     ;
LA1F2:  STA WndHeight           ;Convert window height to tiles,

LA1F5:  INY                     ;
LA1F6:  LDA (WndDatPtr),Y       ;Get window width from table.
LA1F8:  STA WndWidth            ;

LA1FB:  INY                     ;
LA1FC:  LDA (WndDatPtr),Y       ;Get window position from table.
LA1FE:  STA WndPosition         ;
LA201:  PHA                     ;

LA202:  AND #$0F                ;
LA204:  ASL                     ;Extract and save column position nibble.
LA205:  STA WndColPos           ;

LA207:  PLA                     ;
LA208:  AND #$F0                ;
LA20A:  LSR                     ;Extract and save row position nibble.
LA20B:  LSR                     ;
LA20C:  LSR                     ;
LA20D:  STA WndRowPos           ;

LA20F:  INY                     ;MSB set in window options byte indicates its
LA210:  LDA WndOptions          ;a selection window. Is this a selection window?
LA213:  BPL LA221                   ;If not, branch to skip selection window bytes.

LA215:  LDA (WndDatPtr),Y       ;A selection window.  Get byte containing
LA217:  STA WndColumns          ;column width in tiles.

LA21A:  INY                     ;A selection window. Get byte with cursor
LA21B:  LDA (WndDatPtr),Y       ;home position. X in upper nibble, Y in lower.
LA21D:  STA WndCursorHome       ;

LA220:  INY                     ;
LA221: BIT WndOptions          ;
LA224:  BVC LA22C                   ;This bit is never set. Branch always.
LA226:  LDA (WndDatPtr),Y       ;

.ifndef namegen
    LA228:  STA WndUnused1          ;
.endif

LA22B:  INY                     ;
LA22C: STY WndDatIndex         ;Save index into current window data table.
LA22F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WindowEngine:
LA230:  JSR InitWindowEngine    ;($A248)Initialize variables used by the window engine.

BuildWindowLoop:
LA233:  JSR WndUpdateWrkTile    ;($A26A)Update the working tile pattern.
LA236:  JSR GetNxtWndByte       ;($A2B7)Process next window data byte.
LA239:  JSR JumpToWndFunc       ;($A30A)Use data byte for indirect function jump.
LA23C:  JSR WndShowLine         ;($A5CE)Show window line on the screen.
LA23F:  JSR WndChkFullHeight    ;($A5F9)Check if window build is done.
LA242:  BCC BuildWindowLoop     ;Is window build done? If not, branch to do another row.

LA244:  JSR DoBlinkingCursor    ;($A63D)Show blinking cursor on selection windows.
LA247:  RTS                     ;

;----------------------------------------------------------------------------------------------------

InitWindowEngine:
LA248:  JSR ClearWndLineBuf     ;($A646)Clear window line buffer.
LA24B:  LDA #$FF                ;

.ifndef namegen
    LA24D:  STA WndUnused64FB       ;Written to but never accessed.
.endif

LA250:  LDA #$00                ;
LA252:  STA WndXPos             ;
LA255:  STA WndYPos             ;Zero out window variables.
LA258:  STA WndThisDesc         ;
LA25B:  STA WndDescHalf         ;
LA25E:  STA WndBuildRow         ;

LA261:  LDX #$0F                ;
LA263: STA AttribTblBuf,X      ;
LA266:  DEX                     ;Zero out attribute table buffer.
LA267:  BPL LA263                   ;
LA269:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndUpdateWrkTile:
LA26A:  LDA #TL_BLANK_TILE1     ;Assume working tile will be a blank tile.
LA26C:  STA WorkTile            ;

LA26F:  LDX WndXPos             ;Is position in left most column?
LA272:  BEQ CheckWndRow         ;If so, branch to check row.

LA274:  INX                     ;Is position not at right most column?
LA275:  CPX WndWidth            ;
LA278:  BNE CheckWndBottom      ;If not, branch to check if in bottom rom.

LA27A:  LDX WndYPos             ;In left most column.  In top row?
LA27D:  BEQ WndUpRightCrnr      ;If so, branch to load upper right corner tile.

LA27F:  INX                     ;
LA280:  CPX WndHeight           ;In left most column. in bottom row?
LA283:  BEQ WndBotRightCrnr     ;If so, branch to load lower right corner tile.

LA285:  LDA #TL_RIGHT           ;Border pattern - right border.
LA287:  BNE UpdateWndWrkTile    ;Done. Branch to update working tile and exit.

WndUpRightCrnr:
LA289:  LDA #TL_UPPER_RIGHT     ;Border pattern - upper right corner.
LA28B:  BNE UpdateWndWrkTile    ;Done. Branch to update working tile and exit.

WndBotRightCrnr:
LA28D:  LDA #TL_BOT_RIGHT       ;Border pattern - lower right corner.
LA28F:  BNE UpdateWndWrkTile    ;Done. Branch to update working tile and exit.

CheckWndRow:
LA291:  LDX WndYPos             ;In top row. In left most ccolumn?
LA294:  BEQ WndUpLeftCrnr       ;If so, branch to load upper left corner tile.

LA296:  INX                     ;
LA297:  CPX WndHeight           ;In top row.  In left most column?
LA29A:  BEQ WndBotLeftCrnr      ;If so, branch to load lower left corner tile.
LA29C:  LDA #TL_LEFT            ;Border pattern - left border.
LA29E:  BNE UpdateWndWrkTile    ;Done. Branch to update working tile and exit.

WndUpLeftCrnr:
LA2A0:  LDA #TL_UPPER_LEFT      ;Border pattern - Upper left corner.
LA2A2:  BNE UpdateWndWrkTile    ;Done. Branch to update working tile and exit.

WndBotLeftCrnr:
LA2A4:  LDA #TL_BOT_LEFT        ;Border pattern - Lower left corner.
LA2A6:  BNE UpdateWndWrkTile    ;Done. Branch to update working tile and exit.

CheckWndBottom:
LA2A8:  LDX WndYPos             ;Not in left most or right most columns.
LA2AB:  INX                     ;
LA2AC:  CPX WndHeight           ;In bottom column?
LA2AF:  BNE LA2B6                   ;If not, branch to keep blank tile as working tile.
LA2B1:  LDA #TL_BOTTOM          ;Border pattern - bottom border.

UpdateWndWrkTile:
LA2B3:  STA WorkTile            ;Update working tile and exit.
LA2B6: RTS                     ;

;----------------------------------------------------------------------------------------------------

GetNxtWndByte:
LA2B7:  LDA WorkTile            ;
LA2BA:  CMP #TL_BLANK_TILE1     ;Is current working byte not a blank tile? 
LA2BC:  BNE WorkTileNotBlank    ;if so, branch, nothing to do right now.

LA2BE:  LDA WndOptions          ;Is this a single spaced window?
LA2C1:  AND #$20                ;
LA2C3:  BNE GetNextWndByte      ;If so, branch to get next byte from window data table.

LA2C5:  LDA WndYPos             ;This is a double spaced window.
LA2C8:  LSR                     ;Are we at an even row?
LA2C9:  BCC GetNextWndByte      ;If so, branch to get next data byte, else nothing to do.

LA2CB:  LDA WndBuildRow         ;Is the window being built and on the first block row?
LA2CE:  CMP #$01                ;
LA2D0:  BNE ClearWndCntrlByte   ;If not branch.

LA2D2:  LDA #$00                ;Window just started being built.
LA2D4:  STA WndXPos             ;
LA2D7:  LDX WndYPos             ;Clear x and y position variables.
LA2DA:  INX                     ;
LA2DB:  STX WndHeight           ;Set window height to 1.

LA2DE:  PLA                     ;Remove last return address.
LA2DF:  PLA                     ;
LA2E0:  JMP BuildWindowLoop     ;($A233)continue building the window.

ClearWndCntrlByte:
LA2E3:  LDA #$00                ;Prepare to load a row of empty tiles.
LA2E5:  BEQ SeparateCntrlByte   ;

GetNextWndByte:
LA2E7:  LDY WndDatIndex         ;
LA2EA:  INC WndDatIndex         ;Get next byte from window data table and increment index.
LA2ED:  LDA (WndDatPtr),Y       ;
LA2EF:  BPL GotCharDat          ;Is retreived byte a control byte? if not branch.

SeparateCntrlByte:
LA2F1:  AND #$7F                ;Control byte found.  Discard bit indicating its a control byte.
LA2F3:  PHA                     ;

LA2F4:  AND #$07                ;Extract and save repeat counter bits.
LA2F6:  STA WndParam            ;

LA2F9:  PLA                     ;
LA2FA:  LSR                     ;
LA2FB:  LSR                     ;Shift control bits to lower end of byte and save.
LA2FC:  LSR                     ;
LA2FD:  STA WndCcontrol         ;
LA300:  RTS                     ;

GotCharDat:
LA301:  STA WorkTile            ;Store current byte in working tile variable.

WorkTileNotBlank:
LA304:  LDA #$10                ;
LA306:  STA WndCcontrol         ;Indicate character byte being processed.
LA309:  RTS                     ;

;----------------------------------------------------------------------------------------------------

JumpToWndFunc:
LA30A:  LDA WndCcontrol         ;Use window control byte as pointer
LA30D:  ASL                     ;into window control function table.

LA30E:  TAX                     ;
LA30F:  LDA WndCntrlPtrTbl,X    ;
LA312:  STA WndFcnLB            ;Get function address from table and jump.
LA314:  LDA WndCntrlPtrTbl+1,X  ;
LA317:  STA WndFcnUB            ;
LA319:  JMP (WndFcnPtr)         ;

;----------------------------------------------------------------------------------------------------

WndBlankTiles:
LA31C:  LDA #TL_BLANK_TILE1     ;Prepare to place blank tiles.
LA31E:  STA WorkTile            ;

LA321:  JSR SetCountLength      ;($A600)Calculate the required length of the counter.
LA324: BIT WndBuildPhase       ;In the second phase of window building?
LA327:  BVS LA32F                   ;If so, branch to skip building buffer.

LA329:  JSR BuildWndLine        ;($A546)Transfer data into window line buffer.
LA32C:  JMP NextBlankTile       ;($A332)Move to next blank tile.

LA32F: JSR WndNextXPos         ;($A573)Increment x position in current window row.

NextBlankTile:
LA332:  DEC WndCounter          ;More tiles to process?
LA335:  BNE LA324                  ;If so, branch to do another.
LA337:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndHorzTiles:
LA338:  BIT WndOptions          ;Branch always.  This bit is never set for any of the windows.
LA33B:  BVC DoHorzTiles         ;

LA33D:  LDA #TL_BLANK_TILE1     ;Blank tile.
LA33F:  STA WorkTile            ;
LA342:  JSR BuildWndLine        ;($A546)Transfer data into window line buffer.
LA345:  LDA #TL_TOP2            ;Border pattern - upper border.
LA347:  STA WorkTile            ;
LA34A:  JSR BuildWndLine        ;($A546)Transfer data into window line buffer.

DoHorzTiles:
LA34D:  LDA #TL_TOP1            ;Border pattern - upper border.
LA34F:  STA WorkTile            ;
LA352:  JSR SetCountLength      ;($A600)Calculate the required length of the counter.

HorzTilesLoop:
LA355:  JSR BuildWndLine        ;($A546)Transfer data into window line buffer.
LA358:  DEC WndCounter          ;More tiles to process?
LA35B:  BNE HorzTilesLoop       ;If so, branch to do another.
LA35D:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndHitMgcPoints:
LA35E:  LDA #$03                ;Max number is 3 digits.
LA360:  STA SubBufLength        ;Set buffer length to 3.

LA363:  LDX #HitPoints          ;Prepare to convert hitpoints to BCD.
LA365:  LDA WndParam            ;
LA368:  AND #$04                ;Is bit 2 of parameter byte set?
LA36A:  BEQ LA36E                   ;If so, branch to convert hit points.

LA36C:  LDX #MagicPoints        ;Convert magic points to BCD.

LA36E: LDY #$01                ;1 byte to convert.
LA370:  JMP WndBinToBCD         ;($A61C)Convert binary word to BCD.

;----------------------------------------------------------------------------------------------------

WndGold:
LA373:  LDA #$05                ;Max number is 5 digits.
LA375:  STA SubBufLength        ;Set buffer length to 5.
LA378:  JSR GoldToBCD           ;($A8BA)Convert player's gold to BCD.
LA37B:  JMP WndTempToLineBuf    ;($A62B)Transfer value from temp buf to window line buffer.

;----------------------------------------------------------------------------------------------------

WndShowLevel:
LA37E:  LDA WndParam            ;Is parameter not 0? If so, get level from a saved game.
LA381:  BNE WndGetSavedGame     ;Branch to get saved game level.

WndCovertLvl:
LA383:  LDA #$02                ;Set buffer length to 2.
LA385:  STA SubBufLength        ;
LA388:  LDX #DisplayedLevel     ;Load player's level.

LA38A:  LDY #$01                ;1 byte to convert.
LA38C:  JMP WndBinToBCD         ;($A61C)Convert binary word to BCD.

WndGetSavedGame:
LA38F:  JSR WndLoadGameDat      ;($F685)Load selected game into memory.
LA392:  JMP WndCovertLvl        ;($A383)Convert player level to BCD.

;----------------------------------------------------------------------------------------------------

WndShowExp:
LA395:  LDA #$05                ;Set buffer length to 5.
LA397:  STA SubBufLength        ;

LA39A:  LDX #ExpLB              ;Load index for player's experience.

LA39C:  LDY #$02                ;2 bytes to convert.
LA39E:  JMP WndBinToBCD         ;($A61C)Convert binary word to BCD.

;----------------------------------------------------------------------------------------------------

WndShowName:
LA3A1:  LDA WndParam            ;
LA3A4:  CMP #$01                ;Get the full name of the current player.
LA3A6:  BEQ WndGetfullName      ;

LA3A8:  CMP #$04                ;Get the full name of a saved character.
LA3AA:  BEQ WndFullSaved        ;The SaveSelected variable is set before this function is called.

LA3AC:  CMP #$05                ;Get the lower 4 letters of a saved character.
LA3AE:  BCS WndLwr4Saved        ;The SaveSelected variable is set with the WndParam variable.

WndPrepGetLwr:
LA3B0:  LDA #$04                ;Set buffer length to 4.
LA3B2:  STA SubBufLength        ;

LA3B5:  LDX #$00                ;Start at beginning of name registers.
LA3B7:  LDY SubBufLength        ;

WndGetLwrName:
LA3BA:  LDA DispName0,X         ;Load name character and save it in the buffer.
LA3BC:  STA TempBuffer-1,Y      ;
LA3BF:  INX                     ;
LA3C0:  DEY                     ;Have 4 characters been loaded?
LA3C1:  BNE WndGetLwrName       ;If not, branch to get next character.

LA3C3:  JMP WndTempToLineBuf    ;($A62B)Transfer value from temp buf to window line buffer.

WndGetfullName:
LA3C6:  JSR WndPrepGetLwr       ;($A3B0)Get lower 4 characters of name.

LA3C9:  LDA #$04                ;Set buffer length to 4.
LA3CB:  STA SubBufLength        ;

LA3CE:  LDX #$00                ;Start at beginning of name registers.
LA3D0:  LDY SubBufLength        ;

WndGetUprName:
LA3D3:  LDA DispName4,X         ;Load name character and save it in the buffer.
LA3D6:  STA TempBuffer-1,Y      ;
LA3D9:  INX                     ;
LA3DA:  DEY                     ;Have 4 characters been loaded?
LA3DB:  BNE WndGetUprName       ;If not, branch to get next character.

LA3DD:  JMP WndTempToLineBuf    ;($A62B)Transfer value from temp buf to window line buffer.

WndLwr4Saved:
LA3E0:  LDA #$04                ;Set buffer length to 4.
LA3E2:  STA SubBufLength        ;

LA3E5:  LDA WndParam            ;
LA3E8:  SEC                     ;Select the desired save game by subtracting 5
LA3E9:  SBC #$05                ;from the WndParam variable.
LA3EB:  STA SaveSelected        ;

LA3EE:  JSR WndLoadGameDat      ;($F685)Load selected game into memory.
LA3F1:  JMP WndPrepGetLwr       ;($A3B0)Get lower 4 letters of saved character's name.

WndFullSaved:
LA3F4:  LDA #$08                ;Set buffer length to 8.
LA3F6:  STA SubBufLength        ;
LA3F9:  JSR WndLoadGameDat      ;($F685)Load selected game into memory.
LA3FC:  JMP WndGetfullName      ;($A3C6)Get full name of saved character.

;----------------------------------------------------------------------------------------------------

WndItemDesc:
LA3FF:  LDA #$09                ;Max buffer length is 9 characters.
LA401:  STA SubBufLength        ;

LA404:  LDA WndParam            ;Is this description for player or shop inventory?
LA407:  CMP #$03                ;
LA409:  BCS WndDoInvItem        ;If so, branch.

LA40B:  LDA WndParam            ;
LA40E:  ADC #$08                ;Add 8 to the description buffer
LA410:  TAX                     ;index and get description byte.
LA411:  LDA DescBuf,X           ;

LA413:  JSR WpnArmrConv         ;($A685)Convert index to proper weapon/armor description byte.
LA416:  JSR LookupDescriptions  ;($A790)Get description from tables.
LA419:  JSR WndTempToLineBuf    ;($A62B)Transfer value from temp buf to window line buffer.
LA41C:  JMP SecondDescHalf      ;($A7D7)Change to second description half.

WndDoInvItem:
LA41F:  JSR WndGetDescByte      ;($A651)Get byte from description buffer, store in A.
LA422:  JSR DoInvConv           ;($A657)Get inventory description byte.
LA425:  PHA                     ;Push description byte on stack.

LA426:  LDA WndParam            ;Is the player's inventory the target?
LA429:  CMP #$03                ;
LA42B:  BNE WndDescNum          ;If not, branch.

LA42D:  PLA                     ;Place a copy of the description byte in A.
LA42E:  PHA                     ;

LA42F:  CMP #DSC_HERB           ;Is the description byte for herbs?
LA431:  BEQ WndDecDescLength    ;If so, branch.

LA433:  CMP #DSC_KEY            ;Is the description byte for keys?
LA435:  BNE WndDescNum          ;If not, branch.

WndDecDescLength:
LA437:  DEC SubBufLength        ;Decrement length of description buffer.

WndDescNum:
LA43A:  PLA                     ;Put description byte in A.
LA43B:  JSR LookupDescriptions  ;($A790)Get description from tables.
LA43E:  JSR WndTempToLineBuf    ;($A62B)Transfer value from temp buf to window line buffer.
LA441:  LDA WndDescHalf         ;Is the first description half being worked on?
LA444:  BNE WndDesc2ndHalf      ;If so, branch to work on second description half.

LA446:  LDA WndParam            ;Is this the player's inventory?
LA449:  CMP #$03                ;
LA44B:  BNE WndDesc2ndHalf      ;If not, branch to work on second description half.

LA44D:  LDA WndDescIndex        ;Is the current description byte for herbs?
LA450:  CMP #DSC_HERB           ;
LA452:  BEQ WndNumHerbs         ;If so, branch to get number of herbs in player's inventory.

LA454:  CMP #DSC_KEY            ;Is the current description byte for keys?
LA456:  BEQ WndNumKeys          ;If so, branch.

WndDesc2ndHalf:
LA458:  JMP SecondDescHalf      ;($A7D7)Change to second description half.

WndNumHerbs:
LA45B:  LDA InventoryHerbs      ;Get nuber of herbs player has in inventory.
LA45D:  BNE WndPrepBCD          ;More than 0? If so, branch to convert and display amount.

WndNumKeys:
LA45F:  LDA InventoryKeys       ;Get number of keys player has in inventory.

WndPrepBCD:
LA461:  STA BCDByte0            ;Load value into first BCD conversion byte.
LA463:  LDA #$00                ;
LA465:  STA BCDByte1            ;The other 2 BCD conversion bytes are not used.
LA467:  STA BCDByte2            ;
LA469:  JSR ClearTempBuffer     ;($A776)Write blank tiles to buffer.

LA46C:  LDA #$01                ;Set buffer length to 1.
LA46E:  STA SubBufLength        ;

LA471:  JSR BinWordToBCD_       ;($A625)Convert word to BCD.
LA474:  JSR WndTempToLineBuf    ;($A62B)Transfer value from temp buf to window line buffer.
LA477:  JMP SecondDescHalf      ;($A7D7)Change to second description half.

;----------------------------------------------------------------------------------------------------

WndOneSpellDesc:
LA47A:  LDA #$09                ;Set max buffer length for description to 9 bytes.
LA47C:  STA SubBufLength        ;
LA47F:  JSR WndGetDescByte      ;($A651)Get byte from description buffer and store in A.

LA482:  SEC                     ;Subtract 1 from description byte to get correct offset.
LA483:  SBC #$01                ;

LA485:  JSR WndGetSpellDesc     ;($A7EB)Get spell description.
LA488:  JSR WndTempToLineBuf    ;($A62B)Transfer value from temp buf to window line buffer.
LA48B:  INC WndThisDesc         ;Increment pointer to next position in description buffer.
LA48E:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndItemCost:
LA48F:  JSR ClearTempBuffer     ;($A776)Write blank tiles to buffer.
LA492:  LDA #$05                ;
LA494:  STA SubBufLength        ;Buffer is max. 5 characters long.

LA497:  LDA #$06                ;WndCostTbl is the table to use for item costs.
LA499:  JSR GetDescPtr          ;($A823)Get pointer into description table.

LA49C:  LDA WndDescIndex        ;Is the description index 0?
LA49F:  BEQ WndCstToLineBuf     ;If so, branch to skip getting item cost.

LA4A1:  ASL                     ;*2. Item costs are 2 bytes.
LA4A2:  TAY                     ;

LA4A3:  LDA (DescPtr),Y         ;Get lower byte of item cost.
LA4A5:  STA BCDByte0            ;

LA4A7:  INY                     ;
LA4A8:  LDA (DescPtr),Y         ;Get middle byte of item cost.
LA4AA:  STA BCDByte1            ;

LA4AC:  LDA #$00                ;Third byte is not used.
LA4AE:  STA BCDByte2            ;

LA4B0:  JSR BinWordToBCD_       ;($A625)Convert word to BCD.

WndCstToLineBuf:
LA4B3:  JMP WndTempToLineBuf    ;($A62B)Transfer value from temp buf to window line buffer.

;----------------------------------------------------------------------------------------------------

WndVariableHeight:
LA4B6:  LDA #$00                ;Zero out description index.
LA4B8:  STA WndThisDesc         ;
LA4BB:  LDA #$00                ;Start at first half of description.
LA4BD:  STA WndDescHalf         ;

LA4C0:  JSR CalcNumItems        ;($A4CD)Get number of items to display in window.
LA4C3:  STA WndBuildRow         ;Save the number of items.

LA4C6:  LDA WndDatIndex         ;
LA4C9:  STA WndRepeatIndex      ;Set this data index as loop point until all rows are built.
LA4CC:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;When a spell is cast, the description buffer is loaded with pointers for the descriptions
;of spells that the player has.  The buffer is terminated with #$FF.  For example, if the 
;player has the first three spells, the buffer will contain: #$01, #$02, #$03, #$FF.
;If the item list is for an inventory window, The window will start with #$01 and end with #$FF.

CalcNumItems:
LA4CD:  LDX #$01                ;Point to second byte in the item description buffer.
LA4CF: LDA DescBuf,X           ;
LA4D1:  CMP #ITM_END            ;Has the end been found? If so, branch to move on.
LA4D3:  BEQ NumItemsEnd         ;
LA4D5:  INX                     ;Go to the next index. Has the max been reached?
LA4D6:  BNE LA4CF               ;If not, branch to look at the next byte.

NumItemsEnd:
LA4D8:  DEX                     ;
LA4D9:  LDA DescBuf             ;If buffer starts with 1, return item count unmodified.
LA4DB:  CMP #$01                ;
LA4DD:  BEQ ReturnNumItems      ;

LA4DF:  INX                     ;
LA4E0:  CMP #$02                ;If buffer starts with 2, increment item count.
LA4E2:  BEQ ReturnNumItems      ;

LA4E4:  INX                     ;Increment item count again if anything other than 1 or 2.

ReturnNumItems:
LA4E5:  TXA                     ;Transfer item count to A.
LA4E6:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndBuildVariable:
LA4E7:  LDA WndParam            ;A parameter value of 2 will end the window
LA4EA:  CMP #$02                ;without handling the last line.
LA4EC:  BEQ WndBuildVarDone     ;

LA4EE:  AND #$03                ;Is the parameter anything but 0 or 2?
LA4F0:  BNE WndBuildEnd         ;If so, branch to finish window.

LA4F2:  LDA WndBuildRow         ;Is this the last row?
LA4F5:  BEQ WndBuildVarDone     ;If so, branch to exit. No more repeating.

LA4F7:  DEC WndBuildRow         ;Is this the second to last row?
LA4FA:  BEQ WndBuildVarDone     ;If so, branch to exit. No more repeating.

LA4FC:  LDA WndRepeatIndex      ;Repeat this data index until all rows are built.
LA4FF:  STA WndDatIndex         ;

WndBuildVarDone:
LA502:  RTS                     ;Done building row of variable height window.

;----------------------------------------------------------------------------------------------------

WndBuildEnd:
LA503:  LDA #$00                ;Start at beginning of window row.
LA505:  STA WndXPos             ;
LA508:  STA WndParam            ;Prepare to place blank tiles to end of row.

LA50B:  LDA WndYPos             ;If Y position of window line is even, add 2 to the position
LA50E:  AND #$01                ;and make it the window height.
LA510:  EOR #$01                ;
LA512:  CLC                     ;If Y position of window line is odd, add 1 to the position 
LA513:  ADC #$01                ;and make it the window height.
LA515:  ADC WndYPos             ;
LA518:  STA WndHeight           ;Required to properly form inventory windows.

LA51B:  LSR                     ;
LA51C:  STA WndHeightblks       ;/2. Block height is half the tile height.
LA51F:  LDA WndYPos             ;

LA522:  AND #$01                ;Does the last item only use a single row?
LA524:  BNE WndEndBuild         ;If not, branch to skip a blank line on bottom of window.

WndBlankLine:
LA526:  LDA #TL_LEFT            ;Border pattern - left border.
LA528:  STA WorkTile            ;
LA52B:  JSR BuildWndLine        ;($A546)Transfer data into window line buffer.
LA52E:  JMP WndBlankTiles       ;($A31C)Place blank tiles to end of row.

WndEndBuild:
LA531:  RTS                     ;End building last row.

;----------------------------------------------------------------------------------------------------

WndShowStat:
LA532:  LDX WndParam            ;
LA535:  LDA AttribVarTbl,X      ;Load desired player attribute from table.
LA538:  TAX                     ;

LA539:  LDA #$03                ;Set buffer length to 3.
LA53B:  STA SubBufLength        ;

LA53E:  LDY #$01                ;1 byte to convert.
LA540:  JMP WndBinToBCD         ;($A61C)Convert binary word to BCD.

;----------------------------------------------------------------------------------------------------

WndAddToBuf:
LA543:  JMP BuildWndLine        ;($A546)Transfer data into window line buffer.

;----------------------------------------------------------------------------------------------------

BuildWndLine:
LA546:  LDA WndYPos             ;Is this an even numbered window tile row?
LA549:  AND #$01                ;
LA54B:  BEQ BldLoadWrkTile      ;If so, branch.

LA54D:  LDA WndWidth            ;Odd row.  Prepare to save tile at end of window row.

BldLoadWrkTile:
LA550:  CLC                     ;
LA551:  ADC WndXPos             ;Move to next index in the window line buffer.
LA554:  TAX                     ;

LA555:  LDA WorkTile            ;Store working tile in the window line buffer.
LA558:  STA WndLineBuf,X        ;
LA55B:  JSR WndStorePPUDat      ;($A58B)Store window data byte in PPU buffer.

LA55E:  CMP #TL_LEFT            ;Is this tile a left border or a space?
LA560:  BCS WndNextXPos         ;If so, branch to move to next column.

LA562:  LDA WndLineBuf-1,X      ;Was the last tile a top border tile?
LA565:  CMP #TL_TOP1            ;
LA567:  BNE WndNextXPos         ;If not, branch to move to next column.

LA569:  LDA WndXPos             ;Is this the first column of this row?
LA56C:  BEQ WndNextXPos         ;If so, branch to move to next column.

LA56E:  LDA #TL_TOP2            ;Replace last tile with a top border tile.
LA570:  STA WndLineBuf-1,X      ;

WndNextXPos:
LA573:  INC WndXPos             ;Increment position in window row.
LA576:  LDA WndXPos             ;Still more space in current row?
LA579:  CMP WndWidth            ;If so, branch to exit.
LA57C:  BCC LA58A                   ;

LA57E:  LDX #$01                ;At the end of the row.  Ensure the counter agrees.
LA580:  STX WndCounter          ;

LA583:  DEX                     ;
LA584:  STX WndXPos             ;Move to the beginning of the next row.
LA587:  INC WndYPos             ;
LA58A: RTS                     ;

;----------------------------------------------------------------------------------------------------

WndStorePPUDat:
LA58B:  PHA                     ;
LA58C:  TXA                     ;
LA58D:  PHA                     ;Save a current copy of X,Y and A on the stack.
LA58E:  TYA                     ;
LA58F:  PHA                     ;

LA590:  BIT WndBuildPhase       ;Is this the second window building phase?
LA593:  BVS WndStorePPUDatEnd   ;If so, skip. Only save data on first phase.

LA595:  JSR PrepPPUAdrCalc      ;($A8AD)Address offset for start of current window row.
LA598:  LDA #$20                ;
LA59A:  STA PPURowBytesLB       ;32 bytes per screen row.
LA59C:  LDA #$00                ;
LA59E:  STA PPURowBytesUB       ;

LA5A0:  LDA WndYPos             ;Multiply 32 by current window row number.
LA5A3:  LDX #PPURowBytesLB      ;
LA5A5:  JSR IndexedMult         ;($A6EB)Calculate winidow row address offset.

LA5A8:  LDA PPURowBytesLB       ;
LA5AA:  CLC                     ;
LA5AB:  ADC WndXPos             ;Add X position of window to calculated value.
LA5AE:  STA PPURowBytesLB       ;Increment upper byte on a carry.
LA5B0:  BCC WndAddOffsetToAddr  ;
LA5B2:  INC PPURowBytesUB       ;

WndAddOffsetToAddr:
LA5B4:  CLC                     ;
LA5B5:  LDA PPURowBytesLB       ;Calculate lower byte of final PPU address.
LA5B7:  ADC PPUAddrLB           ;
LA5B9:  STA PPUAddrLB           ;

LA5BB:  LDA PPURowBytesUB       ;
LA5BD:  ADC PPUAddrUB           ;Calculate upper byte of final PPU address.
LA5BF:  STA PPUAddrUB           ;

LA5C1:  LDY #$00                ;
LA5C3:  LDA WorkTile            ;Store window tile byte in the PPU buffer.
LA5C6:  STA (PPUBufPtr),Y       ;

WndStorePPUDatEnd:
LA5C8:  PLA                     ;
LA5C9:  TAY                     ;
LA5CA:  PLA                     ;Restore X,Y and A from the stack.
LA5CB:  TAX                     ;
LA5CC:  PLA                     ;
LA5CD:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndShowLine:
LA5CE:  LDA WndYPos             ;Is this the beginning of an even numbered line?
LA5D1:  AND #$01                ;
LA5D3:  ORA WndXPos             ;
LA5D6:  BNE WndExitShowLine     ;If not, branch to exit. This row already rendered.

LA5D8:  LDA WndBuildPhase       ;Is this the second phase of window building?
LA5DB:  BMI WndExitShowLine     ;If so, branch to exit. Nothing to do here.

LA5DD:  LDA WndWidth            ;
LA5E0:  LSR                     ;Make a copy of window width and divide by 2.
LA5E1:  ORA #$10                ;Set bit 4. translated to 2(two tile rows ber block row).
LA5E3:  STA WndWidthTemp        ;

LA5E6:  LDA WndPosition         ;Create working copy of current window position.
LA5E9:  STA _WndPosition        ;Window position is represented in blocks.

LA5EC:  CLC                     ;Update window position of next row.
LA5ED:  ADC #$10                ;
LA5EF:  STA WndPosition         ;16 blocks per row.

LA5F2:  JSR WndShowHide         ;($ABC4)Show/hide window on the screen.
LA5F5:  JSR ClearWndLineBuf     ;($A646)Clear window line buffer.

WndExitShowLine:
LA5F8:  RTS                     ;Done showing window line.

;----------------------------------------------------------------------------------------------------

WndChkFullHeight:
LA5F9:  LDA WndYPos             ;Get current window height.
LA5FC:  CMP WndHeight           ;Compare with final window height.
LA5FF:  RTS                     ;

;----------------------------------------------------------------------------------------------------

SetCountLength:
LA600:  LDA WndParam            ;Get parameter data for current window control byte.
LA603:  BNE LA607                   ;Is it zero?
LA605:  LDA #$FF                ;If so, set counter length to maximum.

LA607: STA SubBufLength        ;Set counter length.

LA60A:  CLC                     ;
LA60B:  LDA WndWidth            ;Is the current x position beyond the window width?
LA60E:  SBC WndXPos             ;If so, branch to exit.
LA611:  BCC LA61B                   ;

LA613:  CMP SubBufLength        ;Is window row remainder greater than counter length?
LA616:  BCS LA61B                   ;If so, branch to exit.

LA618:  STA SubBufLength        ;Limit counter to remainder of current window row.
LA61B: RTS                     ;

;----------------------------------------------------------------------------------------------------

WndBinToBCD:
LA61C:  JSR _BinWordToBCD       ;($A622)To binary to BCD conversion.
LA61F:  JMP WndTempToLineBuf    ;($A62B)Transfer value from temp buf to window line buffer.

_BinWordToBCD:
LA622:  JSR GetBinBytesBCD      ;($A741)Load binary word to convert to BCD.

BinWordToBCD_:
LA625:  JSR ConvertToBCD        ;($A753)Convert binary word to BCD.
LA628:  JMP ClearBCDLeadZeros   ;($A764)Remove leading zeros from BCD value.

;----------------------------------------------------------------------------------------------------

WndTempToLineBuf:
LA62B: LDX SubBufLength        ;Get last unprocessed entry in temp buffer.
LA62E:  LDA TempBuffer-1,X      ;
LA631:  STA WorkTile            ;Load value into work tile byte.

LA634:  JSR BuildWndLine        ;($A546)Transfer data into window line buffer.
LA637:  DEC SubBufLength        ;
LA63A:  BNE LA62B               ;More bytes to process? If so, branch to process another byte.
LA63C:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DoBlinkingCursor:
LA63D:  LDA WndOptions          ;Is the current window a selection window?
LA640:  BPL LA645                   ;If not, branch to exit.
LA642:  JSR WndDoSelect         ;($A8D1)Do selection window routines.
LA645: RTS                     ;

;----------------------------------------------------------------------------------------------------

ClearWndLineBuf:
LA646:  LDA #TL_BLANK_TILE1     ;Blank tile index in pattern table.
LA648:  LDX #$3B                ;60 bytes in buffer.

LA64A: STA WndLineBuf,X        ;Clear window line buffer.
LA64D:  DEX                     ;Has 60 bytes been written?
LA64E:  BPL LA64A                   ;If not, branch to clear more bytes.
LA650:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndGetDescByte:
LA651:  LDX WndThisDesc         ;
LA654:  LDA DescBuf+1,X         ;Get description byte from buffer.
LA656:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DoInvConv:
LA657:  PHA                     ;Is player's inventory the target?
LA658:  LDA WndParam            ;
LA65B:  CMP #$03                ;
LA65D:  BEQ PlyrInvConv         ;If so, branch.

LA65F:  CMP #$04                ;Is item shop inventory the target?
LA661:  BEQ ShopInvConv         ;If so, branch.

LA663:  PLA                     ;No other matches. Return description
LA664:  RTS                     ;buffer byte as description byte.

PlyrInvConv:
LA665:  PLA                     ;
LA666:  TAX                     ;Get proper description byte for player's inventory.
LA667:  LDA PlyrInvConvTbl-2,X  ;
LA66A:  RTS                     ;

ShopInvConv:
LA66B:  PLA                     ;Is tool shop inventory the description?
LA66C:  CMP #$13                ;
LA66E:  BCS ToolInvConv         ;If so, branch.

LA670:  TAX                     ;
LA671:  LDA WpnShopConvTbl-2,X  ;Get proper description byte for weapon shop inventory.
LA674:  RTS                     ;

ToolInvConv:
LA675:  SEC                     ;
LA676:  SBC #$13                ;Is this the description byte for the dragon's scale?
LA678:  CMP #$05                ;If so, branch to return dragon's scale description byte.
LA67A:  BEQ DgnSclConv          ;

LA67C:  LSR                     ;
LA67D:  TAX                     ;Get proper description byte for tool shop inventory.
LA67E:  LDA ItmShopConvTbl,X    ;
LA681:  RTS                     ;

DgnSclConv:
LA682:  LDA #DSC_DRGN_SCL       ;Return dragon's scale description byte.
LA684:  RTS                     ;

WpnArmrConv:
LA685:  TAX                     ;
LA686:  LDA WpnArmrConvTbL-9,X  ;Get proper description byte for weapon, armor and shield.
LA689:  RTS                     ;

PlyrInvConvTbl:
.incbin "bin/Bank01/PlyrInvConvTbl.bin"
ItmShopConvTbl:
.incbin "bin/Bank01/ItmShopConvTbl.bin"
WpnShopConvTbl:
.incbin "bin/Bank01/WpnShopConvTbl.bin"
WpnArmrConvTbL:
.incbin "bin/Bank01/WpnArmrConvTbL.bin"
WndCntrlPtrTbl:
LA6C3:  .word WndBlankTiles     ;($A31C)Place blank tiles.
LA6C5:  .word WndHorzTiles      ;($A338)Place horizontal border tiles.
LA6C7:  .word WndHitMgcPoints   ;($A35E)Show hit points, magic points.
LA6C9:  .word WndGold           ;($A373)Show gold.
LA6CB:  .word WndShowLevel      ;($A37E)Show current/save game character level.
LA6CD:  .word WndShowExp        ;($A395)Show experience.
LA6CF:  .word WndShowName       ;($A3A1)Show name, 4 or 8 characters.
LA6D1:  .word WndItemDesc       ;($A3FF)Show weapon, armor, shield and item descriptions.
LA6D3:  .word WndOneSpellDesc   ;($A47A)Get spell description for current window row.
LA6D5:  .word WndItemCost       ;($A48F)Get item cost for store inventory windows.
LA6D7:  .word WndVariableHeight ;($A4B6)Calculate spell/inventory window height.
LA6D9:  .word WndShowStat       ;($A532)Show strength, agility max HP, max MP, attack pwr, defense pwr
LA6DB:  .word WndAddToBuf       ;($A543)Non-control character processing.
LA6DD:  .word WndBuildVariable  ;($A4E7)Do all entries in variable height windows.
LA6DF:  .word WndAddToBuf       ;($A543)Non-control character processing.
LA6E1:  .word WndAddToBuf       ;($A543)Non-control character processing.
LA6E3:  .word WndAddToBuf       ;($A543)Non-control character processing.

AttribVarTbl:
.incbin "bin/Bank01/AttribVarTbl.bin"
IndexedMult:
LA6EB:  STA IndMultByte         ;
LA6EE:  LDA #$00                ;
LA6F0:  STA IndMultNum1         ;
LA6F3:  STA IndMultNum2         ;
LA6F6: LSR IndMultByte         ;
LA6F9:  BCC LA70C                   ;The indexed register contains the multiplication word.
LA6FB:  LDA GenPtr00LB,X        ;The accumulator contains the multiplication byte.
LA6FD:  CLC                     ;
LA6FE:  ADC IndMultNum1         ;
LA701:  STA IndMultNum1         ;
LA704:  LDA GenPtr00UB,X        ;This function takes 2 bytes and multiplies them together.
LA706:  ADC IndMultNum2         ;The 16-bit result is stored in the registers indexed by X.
LA709:  STA IndMultNum2         ;
LA70C: ASL GenPtr00LB,X        ;
LA70E:  ROL GenPtr00UB,X        ;
LA710:  LDA IndMultByte         ;
LA713:  BNE LA6F6                  ;
LA715:  LDA IndMultNum1         ;
LA718:  STA GenPtr00LB,X        ;
LA71A:  LDA IndMultNum2         ;
LA71D:  STA GenPtr00UB,X        ;
LA71F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

GetBCDByte:
LA720:  TXA                     ;Save X
LA721:  PHA                     ;

LA722:  LDA #$00                ;
LA724:  STA BCDResult           ;
LA726:  LDX #$18                ;
LA728: ASL BCDByte0            ;
LA72A:  ROL BCDByte1            ;
LA72C:  ROL BCDByte2            ;
LA72E:  ROL BCDResult           ;
LA730:  SEC                     ;Convert binary number in BCDByte0 to BCDByte2 to BCD.
LA731:  LDA BCDResult           ;
LA733:  SBC #$0A                ;
LA735:  BCC LA73B                   ;
LA737:  STA BCDResult           ;
LA739:  INC BCDByte0            ;
LA73B: DEX                     ;
LA73C:  BNE LA728                  ;

LA73E:  PLA                     ;
LA73F:  TAX                     ;Restore X and return.
LA740:  RTS                     ;

;----------------------------------------------------------------------------------------------------

GetBinBytesBCD:
LA741:  LDA #$00                ;
LA743:  STA BCDByte2            ;
LA745:  STA BCDByte1            ;Assume only one byte to convert to BCD.
LA747:  LDA GenWrd00LB,X        ;
LA749:  STA BCDByte0            ;Store byte.
LA74B:  DEY                     ;Y counts how many binary bytes to convert.
LA74C:  BEQ LA752                   ;
LA74E:  LDA GenWrd00UB,X        ;Load second byte to convert if it is present.
LA750:  STA BCDByte1            ;
LA752: RTS                     ;

;----------------------------------------------------------------------------------------------------

ConvertToBCD:
LA753:  LDY #$00                ;No bytes converted yet.
LA755: JSR GetBCDByte          ;($A720)Get BCD byte.

LA758:  LDA BCDResult           ;Store result byte in BCD buffer.
LA75A:  STA TempBuffer,Y        ;

LA75D:  INY                     ;Is conversion done?
LA75E:  CPY SubBufLength        ;
LA761:  BNE LA755               ;If not, branch to convert another byte.
LA763:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ClearBCDLeadZeros:
LA764:  LDX SubBufLength        ;Point to end of BCD buffer.
LA767:  DEX                     ;

LA768: LDA TempBuffer,X        ;Decrement through buffer replacing all
LA76B:  BNE LA775                   ;leading zeros with blank tiles.
LA76D:  LDA #TL_BLANK_TILE1     ;
LA76F:  STA TempBuffer,X        ;
LA772:  DEX                     ;
LA773:  BNE LA768               ;At start of buffer? if not, branch to keep looking.
LA775: RTS                     ;

;----------------------------------------------------------------------------------------------------

ClearTempBuffer:
LA776:  PHA                     ;
LA777:  TXA                     ;Save A and X.
LA778:  PHA                     ;

LA779:  LDX #$0C                ;
LA77B:  LDA #TL_BLANK_TILE1     ;
LA77D: STA TempBuffer,X        ;Load the entire 13 bytes of the buffer with blank tiles.
LA780:  DEX                     ;
LA781:  BPL LA77D                   ;

LA783:  PLA                     ;
LA784:  TAX                     ;Restore X and A.
LA785:  PLA                     ;
LA786:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ClearAndLookup:
LA787:  JSR ClearAndSetBufLen   ;($A7AE)Initialize buffer.

LA78A:  CPX #$FF                ;End of description?
LA78C:  BEQ LA7AD                  ;If so, branch to exit.

LA78E:  LDA DescBuf,X           ;Load description index.

;----------------------------------------------------------------------------------------------------

LookupDescriptions:
LA790:  STA WndDescIndex        ;Save a copy of description table index.
LA793:  JSR ClearAndSetBufLen   ;($A7AE)Initialize buffer.

LA796:  LDA WndDescHalf         ;If on first half of description, load Y with 0.
LA799:  AND #$01                ;
LA79B:  BEQ LA79F                   ;If on second half of description, load Y with 1.
LA79D:  LDA #$01                ;
LA79F: TAY                     ;

LA7A0:  LDA WndDescIndex        ;
LA7A3:  AND #$3F                ;Remove upper 2 bits of index.
LA7A5:  STA WndDescIndex        ;

LA7A8:  BEQ LA7AD                   ;Is index 0? If so exit, no description to display.
LA7AA:  JSR PrepIndexes         ;($A7BD)Prep description index and DescPtrTbl index.
LA7AD: RTS                     ;

;----------------------------------------------------------------------------------------------------

ClearAndSetBufLen:
LA7AE:  JSR ClearTempBuffer     ;($A776)Write blank tiles to buffer.
LA7B1:  LDA WndDescHalf         ;

LA7B4:  LSR                     ;On first half of description? If so, buffer length
LA7B5:  BCC LA7BC                   ;is fine.  Branch to return.

LA7B7:  LDA #$08                ;
LA7B9:  STA SubBufLength        ;If on second half of description, buffer can be 1 byte smaller.
LA7BC: RTS                     ;

;----------------------------------------------------------------------------------------------------

PrepIndexes:
LA7BD:  PHA                     ;Is item description on second table?
LA7BE:  CMP #$20                ;
LA7C0:  BCC LA7CB                   ;If not, branch to use indexes as is.

LA7C2:  PLA                     ;Need to recompute index for ItemNames21TbL.
LA7C3:  SBC #$1F                ;Subtract 31(first table has 31 entries).
LA7C5:  PHA                     ;

LA7C6:  TYA                     ;Need to recompute index into DescPtrTbl.
LA7C7:  CLC                     ;
LA7C8:  ADC #$02                ;Add 2 to index to point to table 2.
LA7CA:  TAY                     ;

LA7CB: INY                     ;Add 2 to pointer for DescPtrTbl. Index is now ready for use.
LA7CC:  INY                     ;

LA7CD:  TYA                     ;A is used as the index.
LA7CE:  JSR GetDescPtr          ;($A823)Get pointer into description table.

LA7D1:  PLA                     ;Restore index into description table.
LA7D2:  BEQ LA7BC                  ;Is index 0? If so, branch to exit. No description.
LA7D4:  JMP WndBuildTempBuf     ;($A842)Place description in temp buffer.

;----------------------------------------------------------------------------------------------------

SecondDescHalf:
LA7D7:  LDA WndDescHalf         ;Get which description half we are currently on.
LA7DA:  EOR #$01                ;
LA7DC:  BNE LA7E1                   ;Branch if value is set to 1.

LA7DE:  INC WndThisDesc         ;Set value to 1.

LA7E1: STA WndDescHalf         ;Store the value of 1 for second half of description.
LA7E4:  RTS                     ;

;----------------------------------------------------------------------------------------------------

SetWorkTile:
LA7E5:  STA WorkTile            ;Set the value in the working tile.
LA7E8:  JMP BuildWndLine        ;($A546)Transfer data into window line buffer.

;----------------------------------------------------------------------------------------------------

WndGetSpellDesc:
LA7EB:  PHA                     ;
LA7EC:  JSR ClearTempBuffer     ;($A776)Write blank tiles to buffer.
LA7EF:  PLA                     ;

LA7F0:  STA DescEntry           ;Store a copy of the description entry byte.
LA7F2:  CMP #$FF                ;Has the end of the buffer been reached?
LA7F4:  BEQ LA800                   ;If so, branch to exit.

LA7F6:  LDA #$01                ;Spell description table.
LA7F8:  JSR GetDescPtr          ;($A823)Get pointer into description table.
LA7FB:  LDA DescEntry           ;Get index into description table.
LA7FD:  JMP WndBuildTempBuf     ;($A842)Place description in temp buffer.
LA800: RTS                     ;

;----------------------------------------------------------------------------------------------------

GetEnDescHalf:
LA801:  STA DescEntry           ;Save index into enemy descriptions.

LA803:  LDY #$07                ;Start at index to first half of enemy names.
LA805:  LDA WndDescHalf         ;Get indicator to which name half to retreive.

LA808:  LSR                     ;Do we want the first half of the name?
LA809:  BCC LA80C                   ;If so branch.

LA80B:  INY                     ;We want second half of the enemy name. Increment index.

LA80C: LDA DescEntry           ;
LA80E:  PHA                     ;
LA80F:  CMP #$33                ;This part of the code should never be executed because
LA811:  BCC LA818                   ;it is incrementing to another table entry for enemy
LA813:  PLA                     ;numbers greater than 51 but there are only 40 different
LA814:  SBC #$32                ;enemies in the entire game.
LA816:  PHA                     ;
LA817:  INY                     ;

LA818: TYA                     ;A now contains entry number into DescPtrTbl.
LA819:  JSR GetDescPtr          ;($A823)Get pointer into description table.
LA81C:  JSR ClearTempBuffer     ;($A776)Write blank tiles to buffer.
LA81F:  PLA
LA820:  JMP WndBuildTempBuf     ;($A842)Place description in temp buffer.

;----------------------------------------------------------------------------------------------------

GetDescPtr:
LA823:  ASL                     ;*2. words in table are two bytes.
LA824:  TAX                     ;

LA825:  LDA DescPtrTbl,X        ;
LA828:  STA DescPtrLB           ;Get desired address from table below.
LA82A:  LDA DescPtrTbl+1,X      ;Save in description pointer.
LA82D:  STA DescPtrUB           ;
LA82F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DescPtrTbl:
LA830:  .word WndwDataPtrTbl    ;($AF6C)Pointers to window type data bytes. 
LA832:  .word SpellNameTbl      ;($BE56)Spell names.
LA834:  .word ItemNames11TbL    ;($BAB7)Item descriptions, first table, first half.
LA836:  .word ItemNames12TbL    ;($BBB7)Item descriptions, first table, second half.
LA838:  .word ItemNames21TbL    ;($BB8F)Item descriptions, second table, first half.
LA83A:  .word ItemNames22TbL    ;($BC4F)Item descriptions, second table, second half.
LA83C:  .word WndCostTblPtr     ;($BE0E)Item costs, used in shop inventory windows.
LA83E:  .word EnNames1Tbl       ;($BC70)Enemy names, first half.
LA840:  .word EnNames2Tbl       ;($BDA2)Enemy names, second half.

WndBuildTempBuf:
LA842:  TAX                     ;Transfer description table index to X.
LA843:  LDY #$00                ;

DescSrchOuterLoop:
LA845:  DEX                     ;Subtract 1 as 0 was used to for no description.
LA846:  BEQ BaseDescFound       ;At proper index? If so, no more searching required.

DescSrchInnerLoop:
LA848:  LDA (DescPtr),Y         ;Get next byte in ROM.
LA84A:  CMP #$FF                ;Is it an end of description marker?
LA84C:  BEQ NextDescription     ;If so, branch to update pointers.

ThisDescription:
LA84E:  INY                     ;Increment index.
LA84F:  BNE DescSrchInnerLoop   ;Is it 0?
LA851:  INC DescPtrUB           ;If so, increment upper byte.
LA853:  BNE DescSrchInnerLoop   ;Should always branch.

NextDescription:
LA855:  INY                     ;Increment index.
LA856:  BNE DescSrchOuterLoop   ;Is it 0?
LA858:  INC DescPtrUB           ;If so, increment upper byte.
LA85A:  BNE DescSrchOuterLoop   ;Should always branch.

BaseDescFound:
LA85C: TYA                     ;
LA85D:  CLC                     ;
LA85E:  ADC DescPtrLB           ;Set description pointer to base of the description.
LA860:  STA DescPtrLB           ;
LA862:  BCC LA866                   ;
LA864:  INC DescPtrUB           ;

LA866: LDY #$00                ;Zero out current index into description.
LA868:  LDX SubBufLength        ;Load buffer length.

LoadDescLoop:
LA86B:  LDA (DescPtr),Y         ;Get next byte in description.
LA86D:  CMP #$FF                ;Is it the end of description marker?
LA86F:  BEQ LA878                   ;If so, branch to end.

LA871:  STA TempBuffer-1,X      ;Store byte in the temp buffer.
LA874:  INY                     ;Increment ROM pointer.
LA875:  DEX                     ;Decrement RAM pointer.
LA876:  BNE LoadDescLoop        ;Is temp buffer full? If not, branch to get more.
LA878: RTS                     ;

;----------------------------------------------------------------------------------------------------

WndCalcBufAddr:
LA879:  JSR PrepPPUAdrCalc      ;($A8AD)Prepare and calculate PPU address.

LA87C:  LDA WndHeight           ;Get window height in tiles.  Need to replace any end of text
LA87F:  STA RowsRemaining       ;control characters with no-ops so window can be processed properly.

CntrlCharSwapRow:
LA881:  LDY #$00                ;Start at beginning of window tile row.

LA883:  LDA WndWidth            ;Set remaining columns to window width.
LA886:  STA _ColsRemaining      ;

CntrlCharSwapCol:
LA888:  LDA (PPUBufPtr),Y       ;Was the end text control character found?
LA88A:  CMP #TXT_END2           ;
LA88C:  BNE CntrlNextCol        ;If not, branch to check next window character.

LA88E:  LDA #TXT_NOP            ;Replace text control character with a no-op.
LA890:  STA (PPUBufPtr),Y       ;

CntrlNextCol:
LA892:  INY                     ;Move to next columns.
LA893:  DEC _ColsRemaining      ;was that the last column?
LA895:  BNE CntrlCharSwapCol    ;If not, branch to move to next column.

LA897:  CLC                     ;
LA898:  LDA PPUAddrLB           ;
LA89A:  ADC #$20                ;Move buffer address to next row.
LA89C:  STA PPUAddrLB           ;Handle carry, if necessary.
LA89E:  BCC CntrlNextRow        ;
LA8A0:  INC PPUAddrUB           ;

CntrlNextRow:
LA8A2:  DEC RowsRemaining       ;Are there more rows to check?
LA8A4:  BNE CntrlCharSwapRow    ;If so, branch.

LA8A6:  BRK                     ;Update sprites.
LA8A7:  .byte $04, $07          ;($B6DA)DoSprites, bank 0.

LA8A9:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
LA8AC:  RTS                     ;

PrepPPUAdrCalc:
LA8AD:  LDA WndColPos           ;Convert column tile position into block position.
LA8AF:  LSR                     ;
LA8B0:  STA XPosFromLeft        ;

LA8B2:  LDA WndRowPos           ;Convert row tile position into block position.
LA8B4:  LSR                     ;
LA8B5:  STA YPosFromTop         ;
LA8B7:  JMP CalcPPUBufAddr      ;($C596)Calculate PPU address.

;----------------------------------------------------------------------------------------------------

GoldToBCD:
LA8BA:  LDA #$05                ;Set results buffer length to 5.
LA8BC:  STA SubBufLength        ;

LA8BF:  LDA GoldLB              ;
LA8C1:  STA BCDByte0            ;
LA8C3:  LDA GoldUB              ;Transfer gold value to conversion variables.
LA8C5:  STA BCDByte1            ;
LA8C7:  LDA #$00                ;
LA8C9:  STA BCDByte2            ;

LA8CB:  JSR ConvertToBCD        ;($A753)Convert gold to BCD value.
LA8CE:  JMP ClearBCDLeadZeros   ;($A764)Remove leading zeros from BCD value.

;----------------------------------------------------------------------------------------------------

WndDoSelect:
LA8D1:  LDA WndBuildPhase       ;Is the window in the first build phase?
LA8D4:  BMI WndDoSelectExit     ;If so, branch to exit.

LA8D6:  JSR WndInitSelect       ;($A918)Initialize window selection variables.

LA8D9:  LDA #IN_RIGHT           ;Disable right button retrigger.
LA8DB:  STA WndBtnRetrig        ;
LA8DE:  STA JoypadBtns          ;Initialize joypad presses to a known value.

_WndDoSelectLoop:
LA8E0:  JSR WndDoSelectLoop     ;($A8E4)Loop while selection window is active.

WndDoSelectExit:
LA8E3:  RTS                     ;Exit window selection and return results.

WndDoSelectLoop:
LA8E4:  JSR WndGetButtons       ;($A8ED)Keep track of player button presses.
LA8E7:  JSR WndProcessInput     ;($A992)Update window based on user input.
LA8EA:  JMP WndDoSelectLoop     ;($A8E4)Loop while selection window is active.

WndGetButtons:
LA8ED:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
LA8F0:  JSR UpdateCursorGFX     ;($A96C)Update cursor graphic in selection window.

LA8F3:  LDA JoypadBtns          ;Are any buttons being pressed?
LA8F5:  BEQ SetRetrigger        ;If not, branch to reset the retrigger.

LA8F7:  LDA FrameCounter        ;Reset the retrigger every 15 frames.
LA8F9:  AND #$0F                ;Is it time to reset the retrigger?
LA8FB:  BNE NoRetrigger         ;If not, branch.

SetRetrigger:
LA8FD:  STA WndBtnRetrig        ;Clear all bits. Retrigger.

NoRetrigger:
LA900:  JSR GetJoypadStatus     ;($C608)Get input button presses.
LA903:  LDA WndBtnRetrig        ;Is there a retrigger event waiting to timeout?
LA906:  BNE WndGetButtons       ;($A8ED)If so, branch to get any button presses.

LA908:  LDA WndBtnRetrig        ;
LA90B:  AND JoypadBtns          ;Remove any button status bits that have chanegd.
LA90D:  STA WndBtnRetrig        ;

LA910:  EOR JoypadBtns          ;Have any buttons changed?
LA912:  STA WndBtnPresses       ;
LA915:  BEQ WndGetButtons       ;($A8ED)If so, branch to get button presses.
LA917:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndInitSelect:
LA918:  LDA #$00                ;
LA91A:  STA WndCol              ;
LA91C:  STA WndRow              ;
LA91E:  STA WndSelResults       ;Clear various window selection control registers.
LA920:  STA WndCursorXPos       ;
LA923:  STA WndCursorYPos       ;
LA926:  STA WndBtnRetrig        ;

LA929:  LDA WndColumns          ;
LA92C:  LSR                     ;Use WndColumns to determine how many columns there
LA92D:  LSR                     ;should be in multi column windows.  The only windows
LA92E:  LSR                     ;with multiple columns are the command windows and
LA92F:  LSR                     ;the alphabet window.  The command windows have 2
LA930:  TAX                     ;columns while the alphabet window has 11.
LA931:  LDA NumColTbl,X         ;
LA934:  STA WndSelNumCols       ;

LA937:  LDA WindowType          ;Is this a message speed window?
LA93A:  CMP #WND_MSG_SPEED      ;
LA93C:  BNE WndSetCrsrHome      ;If not, branch to skip setting message speed.

LA93E:  LDX MessageSpeed        ;Use current message speed to set the cursor in the window.
LA940:  STX WndRow              ;Set the window row the same as the message speed(0,1 or 2).
LA942:  TXA                     ;
LA943:  ASL                     ;Multiply by 2 and set the Y cursor position.
LA944:  STA WndCursorYPos       ;

WndSetCrsrHome:
LA947:  LDA WndCursorHome       ;Save a copy of the cursor X,Y home position.
LA94A:  PHA                     ;

LA94B:  AND #$0F                ;Save a copy of the home X coord but it is never used.

.ifndef namegen
    LA94D:  STA WndUnused64F4       ;
.endif

LA950:  CLC                     ;
LA951:  ADC WndCursorXPos       ;Convert home X coord from window coord to screen coord.
LA954:  STA WndCursorXPos       ;

LA957:  PLA                     ;Restore cursor X,Y home position.
LA958:  AND #$F0                ;
LA95A:  LSR                     ;
LA95B:  LSR                     ;Keep only Y coord and shift to lower nibble.
LA95C:  LSR                     ;
LA95D:  LSR                     ;
LA95E:  STA WndCursorYHome      ;This is the Y coord home position for the cursor.

LA961:  ADC WndCursorYPos       ;Convert home Y coord from window coord to screen coord.
LA964:  STA WndCursorYPos       ;

LA967:  LDA #$05                ;
LA969:  STA FrameCounter        ;Set framee counter to ensure cursor is initially visible.
LA96B:  RTS                     ;

;----------------------------------------------------------------------------------------------------

UpdateCursorGFX:
LA96C:  LDX #TL_BLANK_TILE1     ;Set cursor tile as blank tile.

LA96E:  LDA FrameCounter        ;Get lower 5 bits of the frame counter.
LA970:  AND #$1F                ;

LA972:  CMP #$10                ;Is count halfway through?
LA974:  BCS SetCursorTile       ;If not, load cursor tile as right pointing arrow.

ArrowCursorGFX:
LA976:  LDX #TL_RIGHT_ARROW     ;Set cursor tile as right pointing arrow.

SetCursorTile:
LA978:  STX PPUDataByte         ;Store cursor tile.

LA97A:  LDA WndColPos           ;
LA97C:  CLC                     ;Calculate cursor X position on screen, in tiles.
LA97D:  ADC WndCursorXPos       ;
LA980:  STA ScrnTxtXCoord       ;

LA983:  LDA WndRowPos           ;
LA985:  CLC                     ;Calculate cursor Y position on screen, in tiles.
LA986:  ADC WndCursorYPos       ;
LA989:  STA ScrnTxtYCoord       ;

LA98C:  JSR WndCalcPPUAddr      ;($ADC0)Calculate PPU address for window/text byte.
LA98F:  JMP AddPPUBufEntry      ;($C690)Add data to PPU buffer.

;----------------------------------------------------------------------------------------------------

WndProcessInput:
LA992:  LDA WndBtnPresses       ;Get any buttons that have been pressed by the player.

LA995:  LSR                     ;Has the A button been pressed?
LA996:  BCS WndAPressed         ;If so, branch.

LA998:  LSR                     ;Has the B button been pressed?
LA999:  BCS WndBPressed         ;If so, branch.

LA99B:  LSR                     ;Skip select and start while in selection window.
LA99C:  LSR                     ;

LA99D:  LSR                     ;Has the up button been pressed?
LA99E:  BCS WndUpPressed        ;If so, branch.

LA9A0:  LSR                     ;Has the down button been pressed?
LA9A1:  BCS WndDownPressed      ;If so, branch.

LA9A3:  LSR                     ;Has the left button been pressed?
LA9A4:  BCS WndLeftPressed      ;If so, branch.

LA9A6:  LSR                     ;Has no button been pressed?
LA9A7:  BCC WndEndUpPressed     ;If so, branch to exit.

LA9A9:  JMP WndRightPressed     ;($AAC8)Process right button press.

WndLeftPressed:
LA9AC:  JMP WndDoLeftPressed    ;($AA67)Process left button press.

;----------------------------------------------------------------------------------------------------

WndAPressed:
LA9AF:  LDA #IN_A               ;Disable A button retrigger.
LA9B1:  STA WndBtnRetrig        ;
LA9B4:  JSR WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

LA9B7:  LDA #SFX_MENU_BTN       ;Menu button SFX.
LA9B9:  BRK                     ;
LA9BA:  .byte $04, $17          ;($81A0)InitMusicSFX, bank 1.

LA9BC:  LDA WndCol              ;
LA9BE:  STA _WndCol             ;Make a working copy of the cursor column and row.
LA9C0:  LDA WndRow              ;
LA9C2:  STA _WndRow             ;

LA9C4:  JSR WndCalcSelResult    ;($AB64)Calculate selection result based on col and row.

LA9C7:  PLA                     ;Pull last return address off of stack.
LA9C8:  PLA                     ;

LA9C9:  LDA WndSelResults       ;Load the selection results into A.
LA9CB:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndBPressed:
LA9CC:  LDA #IN_B               ;Disable B button retrigger.
LA9CE:  STA WndBtnRetrig        ;
LA9D1:  JSR WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

LA9D4:  PLA                     ;Pull last return address off of stack.
LA9D5:  PLA                     ;

LA9D6:  LDA #WND_ABORT          ;Load abort indicator into A
LA9D8:  STA WndSelResults       ;Store abort indicator in the selection results.
LA9DA:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndUpPressed:
LA9DB:  LDA #IN_UP              ;Disable up button retrigger.
LA9DD:  STA WndBtnRetrig        ;

LA9E0:  LDA WndRow              ;Is cursor already on the top row?
LA9E2:  BEQ WndEndUpPressed     ;If so, branch to exit.  Nothing to do.

LA9E4:  JSR WndClearCursor      ;($AB30)Blank out cursor tile.

LA9E7:  LDA WindowType          ;Is this the SPELL1 window?
LA9EA:  CMP #WND_SPELL1         ;Not used in the game.
LA9EC:  BEQ WndSpell1Up         ;If so, branch for special cursor update.

LA9EE:  JSR WndMoveCursorUp     ;($ABB2)Move cursor position up 1 row.
LA9F1:  JSR WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

WndEndUpPressed:
LA9F4:  RTS                     ;Up button press processed. Return.

WndSpell1Up:
LA9F5:  LDA #$03                ;
LA9F7:  STA WndCursorXPos       ;Move cursor tile position to 3,2.
LA9FA:  LDA #$02                ;
LA9FC:  STA WndCursorYPos       ;

LA9FF:  LDA #$00                ;Set cursor row position to 0.
LAA01:  STA WndRow              ;
LAA03:  JMP WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

;----------------------------------------------------------------------------------------------------

WndDownPressed:
LAA06:  LDA #IN_DOWN            ;Disable down button retrigger.
LAA08:  STA WndBtnRetrig        ;

LAA0B:  LDA WindowType          ;Is this the SPELL1 window?
LAA0E:  CMP #WND_SPELL1         ;Not used in the game.
LAA10:  BEQ WndSpell1Down       ;If so, branch for special cursor update.

LAA12:  CMP #WND_MSG_SPEED      ;Is this the message speed window?
LAA14:  BNE WndDownCont1        ;If not, branch to continue processing.

LAA16:  LDA WndRow              ;Is thos the last row of the message speed window?
LAA18:  CMP #$02                ;
LAA1A:  BEQ WndDownDone         ;If so, branch to exit. Cannot go down anymore.

WndDownCont1:
LAA1C:  SEC                     ;Get window height.
LAA1D:  LDA WndHeight           ;Subtract 3 to get bottom most row the cursor can be on.
LAA20:  SBC #$03                ;
LAA22:  LSR                     ;/2. Cursor moves 2 tile rows when going up or down.

LAA23:  CMP WndRow              ;Is the cursor on the bottom row?
LAA25:  BEQ WndDownDone         ;If so, branch to exit. Cannot go down anymore.

LAA27:  JSR WndClearCursor      ;($AB30)Blank out cursor tile as it has moved.

LAA2A:  LDA WindowType          ;Is this the alphabet window?
LAA2D:  CMP #WND_ALPHBT         ;
LAA2F:  BNE WndDownCont2        ;If not, branch to continue processing.

LAA31:  JSR WndSpclMoveCrsr     ;($AB3F)Move cursor to next position if next row is bottom.

WndDownCont2:
LAA34:  LDA WndCursorYPos       ;Is the cursor Y cord at the top?
LAA37:  BNE WndDownCont3        ;If not, branch to continue processing.

LAA39:  LDA WndCursorYHome      ;Set cursor Y coord to the Y home position.
LAA3C:  STA WndCursorYPos       ;Is cursor Y position at 0?
LAA3F:  BNE WndDownUpdate       ;If not, branch.

WndDownCont3:
LAA41:  CLC                     ;
LAA42:  ADC #$02                ;Update cursor Y position and cursor row.
LAA44:  STA WndCursorYPos       ;
LAA47:  INC WndRow              ;

WndDownUpdate:
LAA49:  JSR WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

WndDownDone:
LAA4C:  RTS                     ;Down button press processed. Return.

WndSpell1Down:
LAA4D:  LDA WndRow              ;Is this the last row(not used)?
LAA4F:  CMP #$02                ;
LAA51:  BEQ WndDownDone         ;If so, branch to exit.

LAA53:  JSR WndClearCursor      ;($AB30)Blank out cursor tile.
LAA56:  LDA #$02                ;
LAA58:  STA WndRow              ;Update window row.

LAA5A:  LDA #$03                ;Update cursor X pos.
LAA5C:  STA WndCursorXPos       ;

LAA5F:  LDA #$06                ;Update cursor Y pos.
LAA61:  STA WndCursorYPos       ;
LAA64:  JMP WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

;----------------------------------------------------------------------------------------------------

WndDoLeftPressed:
LAA67:  LDA #IN_LEFT            ;Disable left button retrigger.
LAA69:  STA WndBtnRetrig        ;

LAA6C:  LDA WindowType          ;Is this the SPELL1 window?
LAA6F:  CMP #WND_SPELL1         ;Not used in the game.
LAA71:  BEQ WndSpell1Left       ;If so, branch for special cursor update.

LAA73:  LDA WndCol              ;Is cursor already at the far left?
LAA75:  BEQ WndLeftDone         ;If so, branch to exit. Cannot go left anymore.

LAA77:  LDA WindowType          ;Is this the alphabet window?
LAA7A:  CMP #WND_ALPHBT         ;
LAA7C:  BNE WndLeftUpdate       ;If not, branch to continue processing.

LAA7E:  LDA WndRow              ;Is this the bottom row of the alphabet window?
LAA80:  CMP #$05                ;
LAA82:  BNE WndLeftUpdate       ;If not, branch to continue processing.

LAA84:  LDA WndCol              ;Is the cursor pointing to END?
LAA86:  CMP #$09                ;
LAA88:  BNE WndLeftUpdate       ;If not, branch to continue processing.

LAA8A:  LDA #$06                ;Move cursor to point to BACK.
LAA8C:  STA WndCol              ;
LAA8E:  JSR WndClearCursor      ;($AB30)Blank out cursor tile.

LAA91:  LDA #$0D                ;Prepare new cursor X position.
LAA93:  BNE WndLeftUpdtFinish   ;

WndLeftUpdate:
LAA95:  JSR WndClearCursor      ;($AB30)Blank out cursor tile.
LAA98:  DEC WndCol              ;Decrement cursor column position.

LAA9A:  LDA WndColumns          ;
LAA9D:  AND #$0F                ;Get number of tiles per column.
LAA9F:  STA WndColLB            ;

LAAA1:  LDA WndCursorXPos       ;
LAAA4:  SEC                     ;Subtract tiles to get final cursor X position.
LAAA5:  SBC WndColLB            ;

WndLeftUpdtFinish:
LAAA7:  STA WndCursorXPos       ;Update cursor X position.
LAAAA:  JSR WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

WndLeftDone:
LAAAD:  RTS                     ;Left button press processed. Return.

WndSpell1Left:
LAAAE:  LDA WndRow              ;Is this the 4th row in the SPELL1 window?
LAAB0:  CMP #$03                ;Not used in game.
LAAB2:  BEQ WndLeftDone         ;If so, branch to exit.

LAAB4:  JSR WndClearCursor      ;($AB30)Blank out cursor tile.
LAAB7:  LDA #$03                ;
LAAB9:  STA WndRow              ;Update cursor row.

LAABB:  LDA #$01                ;Update cursor X position.          
LAABD:  STA WndCursorXPos       ;

LAAC0:  LDA #$04                ;Update cursor Y position.
LAAC2:  STA WndCursorYPos       ;
LAAC5:  JMP WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

;----------------------------------------------------------------------------------------------------

WndRightPressed:
LAAC8:  LDA #IN_RIGHT           ;Disable right button retrigger.
LAACA:  STA WndBtnRetrig        ;

LAACD:  LDA WindowType          ;Is this the SPELL1 window?
LAAD0:  CMP #WND_SPELL1         ;Not used in the game.
LAAD2:  BEQ WndSpell1Right      ;If so, branch for special cursor update.

LAAD4:  LDA WndColumns          ;Is there only a single column in this window?
LAAD7:  BEQ WndEndRghtPressed   ;If so, branch to exit. Nothing to process.

LAAD9:  LDA WindowType          ;Is this the alphabet window?
LAADC:  CMP #WND_ALPHBT         ;
LAADE:  BNE WndRightCont1       ;If not, branch to continue processing.

LAAE0:  LDA WndRow              ;Is this the bottom row of the alphabet window?
LAAE2:  CMP #$05                ;
LAAE4:  BNE WndRightCont1       ;If not, branch to continue processing.

LAAE6:  LDA WndCol              ;Is the cursor pointing to BACK or END?
LAAE8:  CMP #$06                ;
LAAEA:  BCC WndRightCont1       ;If not, branch to continue processing.

LAAEC:  BNE WndEndRghtPressed   ;Is the cursor pointing to BACK? If not, must be END. Done.

LAAEE:  JSR WndClearCursor      ;($AB30)Blank out cursor tile.
LAAF1:  LDA #$09                ;
LAAF3:  STA WndCol              ;Move cursor to point to END.

LAAF5:  LDA #$13                ;Prepare new cursor X position.
LAAF7:  BNE WndRightUpdtFinish  ;

WndRightCont1:
LAAF9:  LDX WndSelNumCols       ;Is cursor in right most column?
LAAFC:  DEX                     ;
LAAFD:  CPX WndCol              ;
LAAFF:  BEQ WndEndRghtPressed   ;If so, branch to exit. Nothing to process.

LAB01:  JSR WndClearCursor      ;($AB30)Blank out cursor tile.
LAB04:  INC WndCol              ;Increment cursor column position.

LAB06:  LDA WndColumns          ;Get number of tiles per column for this window.
LAB09:  AND #$0F                ;

LAB0B:  CLC                     ;Use tiles per column from above to update cursor X pos.
LAB0C:  ADC WndCursorXPos       ;

WndRightUpdtFinish:
LAB0F:  STA WndCursorXPos       ;Update cursor X position.
LAB12:  JSR WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

WndEndRghtPressed:
LAB15:  RTS                     ;Right button press processed. Return.

WndSpell1Right:
LAB16:  LDA WndRow              ;Is this the 2nd row in the SPELL1 window?
LAB18:  CMP #$01                ;Not used in game.
LAB1A:  BEQ WndEndRghtPressed   ;If so, branch to exit.

LAB1C:  JSR WndClearCursor      ;($AB30)Blank out cursor tile.
LAB1F:  LDA #$01                ;
LAB21:  STA WndRow              ;Update cursor row.

LAB23:  LDA #$07                ;Update cursor X position.
LAB25:  STA WndCursorXPos       ;

LAB28:  LDA #$04                ;Update cursor Y position.
LAB2A:  STA WndCursorYPos       ;
LAB2D:  JMP WndUpdateCrsrPos    ;($AB35)Update cursor position on screen.

;----------------------------------------------------------------------------------------------------

WndClearCursor:
LAB30:  LDX #TL_BLANK_TILE1     ;Replace cursor with a blank tile.
LAB32:  JMP SetCursorTile       ;($A978)Set cursor tile to blank tile.

;----------------------------------------------------------------------------------------------------

WndUpdateCrsrPos:
LAB35:  LDA #$05                ;Set cursor to arrow tile for 10 frames.
LAB37:  STA FrameCounter        ;
LAB39:  JSR ArrowCursorGFX      ;($A976)Set cursor graphic to the arrow.
LAB3C:  JMP WaitForNMI          ;($FF74)Wait for VBlank interrupt.

;----------------------------------------------------------------------------------------------------

WndSpclMoveCrsr:
LAB3F:  LDA WndRow              ;Is this the second to bottom row?
LAB41:  CMP #$04                ;
LAB43:  BNE WndEndUpdateCrsr    ;If not, branch to exit.

LAB45:  LDA WndCol              ;Is this the 8th column?
LAB47:  CMP #$07                ;
LAB49:  BEQ WndSetCrsrBack      ;If so, branch to set cursor to BACK selection.

LAB4B:  CMP #$08                ;is this the 9th, 10th or 11th column?
LAB4D:  BCC WndEndUpdateCrsr    ;If so, branch to set cursor to END selection.

WndSetCrsrEnd:
LAB4F:  LDA #$09                ;Set cursor to END selection in alphabet window.
LAB51:  STA WndCol              ;
LAB53:  LDA #$13                ;
LAB55:  STA WndCursorXPos       ;
LAB58:  BNE WndEndUpdateCrsr    ;Branch always.

WndSetCrsrBack:
LAB5A:  LDA #$06                ;
LAB5C:  STA WndCol              ;Set cursor to BACK selection in alphabet window.
LAB5E:  LDA #$0D                ;
LAB60:  STA WndCursorXPos       ;

WndEndUpdateCrsr:
LAB63:  RTS                     ;Cursor update complete. Return.

;----------------------------------------------------------------------------------------------------

WndCalcSelResult:
LAB64:  LDA WindowType          ;Is this the alphabet window for entering name?
LAB67:  CMP #WND_ALPHBT         ;
LAB69:  BEQ WndCalcAlphaResult  ;If so, branch for special results processing.

LAB6B:  LDA _WndCol             ;
LAB6D:  STA WndColLB            ;Store number of columns as first multiplicand.
LAB6F:  LDA #$00                ;
LAB71:  STA WndColUB            ;

LAB73:  SEC                     ;
LAB74:  LDA WndHeight           ;
LAB77:  SBC #$03                ;Value of first multiplicand is:
LAB79:  LSR                     ;(window height in tiles-3)/2 + 1.
LAB7A:  TAX                     ;
LAB7B:  INX                     ;
LAB7C:  TXA                     ;

LAB7D:  LDX #WndColLB           ;Multiply values for selection result.
LAB7F:  JSR IndexedMult         ;($A6EB)Get first part of selection result.

LAB82:  LDA WndColLB            ;
LAB84:  CLC                     ;
LAB85:  ADC _WndRow             ;Add the window row to get final value of selection result.
LAB87:  STA WndSelResults       ;
LAB89:  RTS                     ;

WndCalcAlphaResult:
LAB8A:  LDA _WndRow             ;Get current window row selected.

LAB8C:  LDX WndColumns          ;Branch never.
LAB8F:  BEQ WndSetAlphaResult   ;

LAB91:  AND #$0F                ;
LAB93:  STA WndColLB            ;Save only lower 4 bits of window row.
LAB95:  LDA #$00                ;
LAB97:  STA WndColUB            ;

LAB99:  LDX #WndColLB           ;Multiply the current selected row       
LAB9B:  LDA WndSelNumCols       ;with the total window columns.
LAB9E:  JSR IndexedMult         ;($A6EB)Get multiplied value.

LABA1:  LDA WndColLB            ;
LABA3:  CLC                     ;Add current selected column to result for final answer.
LABA4:  ADC _WndCol             ;

WndSetAlphaResult:
LABA6:  STA WndSelResults       ;Return alphabet window selection result.
LABA8:  RTS                     ;

LABA9:  LDA WndCol              ;
LABAB:  STA _WndCol             ;
LABAD:  LDA WndRow              ;Reset working copies of the window column and row variables.
LABAF:  STA _WndRow             ;
LABB1:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndMoveCursorUp:
LABB2:  LDA WndCursorYPos       ;
LABB5:  SEC                     ;Decrease Cursor tile position in the Y direction by 2.
LABB6:  SBC #$02                ;
LABB8:  STA WndCursorYPos       ;

LABBB:  DEC WndRow              ;Decrease Cursor row position by 1.
LABBD:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;This table contains the number of columns for selection windows with more than a single column.

NumColTbl:
.incbin "bin/Bank01/NumColTbl.bin"

.ifndef namegen
    WndUnusedFunc2:
    LABC0:  LDA #$00                ;Unused window function.
    LABC2:  BNE WndShowHide+2       ;
.endif

;----------------------------------------------------------------------------------------------------

WndShowHide:
LABC4:  LDA #$00                ;Zero out A.
LABC6:  JSR WndDoRow            ;($ABCC)Fill PPU buffer with window row contents.
LABC9:  JMP WndUpdateTiles      ;($ADFA)Update background tiles next NMI.

WndDoRow:
LABCC:  PHA                     ;Save A. Always 0.
LABCD:  .byte $AD, $03, $00     ;LDA $0003(PPUEntCount)Is PPU buffer empty?
LABD0:  BEQ WndDoRowReady       ;If so, branch to fill it with window row data.

LABD2:  JSR WndUpdateTiles      ;($ADFA)Wait until next NMI for buffer to be empty.

WndDoRowReady:
LABD5:  LDA #$00                ;Zero out unused variable.

.ifndef namegen
    LABD7:  STA WndUnused64AB       ;
.endif

LABDA:  PLA                     ;Restore A. Always 0.
LABDB:  JSR WndStartRow         ;($AD10)Set nametable and X,Y start position of window line.

LABDE:  LDA #$00                ;
LABE0:  STA WndLineBufIndex     ;Zero buffer indexes.
LABE3:  STA WndAtrbBufIndex     ;

LABE6:  LDA WndWidthTemp        ;
LABE9:  PHA                     ;
LABEA:  AND #$F0                ;Will always set WndBlkTileRow to 2.
LABEC:  LSR                     ;Two rows of tiles in a window row.
LABED:  LSR                     ;
LABEE:  LSR                     ;
LABEF:  STA WndBlkTileRow       ;

LABF2:  PLA                     ;
LABF3:  AND #$0F                ;Make a copy of window width.
LABF5:  ASL                     ;
LABF6:  STA _WndWidth           ;

.ifndef namegen
    LABF9:  STA WndUnused64AE       ;Not used.
.endif 

LABFC:  .byte $AE, $04, $00     ;LDX $0004(PPUBufCount)Get index for next buffer entry.

WndRowLoop:
LABFF:  LDA PPUAddrUB           ;
LAC01:  STA WndPPUAddrUB        ;Get a copy of the address to start of window row(block).
LAC04:  LDA PPUAddrLB           ;
LAC06:  STA WndPPUAddrLB        ;

LAC09:  AND #$1F                ;Get row offset on nametable for start of window
LAC0B:  STA WndNTRowOffset      ;(row is 32 tiles long, 0-31).

LAC0E:  LDA #$20                ;Each row is 32 tiles.
LAC10:  SEC                     ;
LAC11:  SBC WndNTRowOffset      ;Calculate the difference between start of window
LAC14:  STA WndThisNTRow        ;row and end of nametable row.

LAC17:  LDA _WndWidth           ;Subtract window width from difference above
LAC1A:  SEC                     ;If the value is negative, the window spans
LAC1B:  SBC WndThisNTRow        ;both nametables.
LAC1E:  STA WndNextNTRow        ;
LAC21:  BEQ WndNoCrossNT        ;Does window run to end of this NT? if so, branch.

LAC23:  BCS WndCrossNT          ;Does window span both nametables? if so, branch.

WndNoCrossNT:
LAC25:  LDA _WndWidth           ;Entire window row is on this nametable.
LAC28:  STA WndThisNTRow        ;Store number of tiles to process on this nametable.
LAC2B:  JMP WndSingleNT         ;($AC51)Window is contained on a single nametable.

WndCrossNT:
LAC2E:  JSR WndLoadRowBuf       ;($AC83)Load buffer with window row(up to overrun).

LAC31:  LDA WndPPUAddrUB        ;
LAC34:  EOR #$04                ;Change upper address byte to other nametable.
LAC36:  STA WndPPUAddrUB        ;

LAC39:  LDA WndPPUAddrLB        ;
LAC3C:  AND #$1F                ;Save lower 5 bits of lower PPU address.
LAC3E:  STA WndNTRowOffset      ;

LAC41:  LDA WndPPUAddrLB        ;
LAC44:  SEC                     ;Subtract the saved value above to set the nametable->
LAC45:  SBC WndNTRowOffset      ;address to the beginning of the nametable row.
LAC48:  STA WndPPUAddrLB        ;

LAC4B:  LDA WndNextNTRow        ;Completed window row portion on first nametable.
LAC4E:  STA WndThisNTRow        ;Tansfer remainder for next nametable calcs.

WndSingleNT:
LAC51:  JSR WndLoadRowBuf       ;($AC83)Load buffer with window row data.

LAC54:  LDA PPUAddrUB           ;
LAC56:  AND #$FB                ;Is there at least 2 full rows before bottom of nametable?
LAC58:  CMP #$23                ;If so, branch to increment row. Won't hit attribute table.
LAC5A:  BCC WndIncPPURow        ;

LAC5C:  LDA PPUAddrLB           ;Is there 1 row before bottom of nametable?
LAC5E:  CMP #$A0                ;If so, branch to increment row. Won't hit attribute table.
LAC60:  BCC WndIncPPURow        ;

LAC62:  AND #$1F                ;Save row offset for next row.
LAC64:  STA PPUAddrLB           ;

LAC66:  LDA PPUAddrUB           ;Address is off bottom of nametable. discard lower bits
LAC68:  AND #$FC                ;to wrap window around to the top of the nametable.
LAC6A:  JMP UpdateNTAddr        ;Update nametable address.

WndIncPPURow:
LAC6D:  LDA PPUAddrLB           ;
LAC6F:  CLC                     ;
LAC70:  ADC #$20                ;Add 32 to PPU address to move to next row.
LAC72:  STA PPUAddrLB           ;32 blocks per row.
LAC74:  LDA PPUAddrUB           ;
LAC76:  ADC #$00                ;

UpdateNTAddr:
LAC78:  STA PPUAddrUB           ;Update PPU upper PPU address byte.

LAC7A:  DEC WndBlkTileRow       ;Does the second row of tiles still need to be done?
LAC7D:  BNE WndRowLoop          ;If so, branch to do second half of window row.

LAC7F:  .byte $8E, $04, $00     ;STX $0004(PPUBufCount)Update buffer index.
LAC82:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndLoadRowBuf:
LAC83:  LDA WndPPUAddrUB        ;Get upper ddress byte.
LAC86:  ORA #$80                ;MSB set = PPU control byte(counter next byte).
LAC88:  STA BlockRAM,X          ;Store in buffer.

LAC8B:  LDA WndThisNTRow        ;Load counter value for remainder of this NT row.
LAC8E:  STA BlockRAM+1,X        ;

LAC91:  LDA WndPPUAddrLB        ;Load lower PPU address byte into buffer.
LAC94:  STA BlockRAM+2,X        ;

LAC97:  INX                     ;
LAC98:  INX                     ;Move to data portion of buffer.
LAC99:  INX                     ;

LAC9A:  LDA WndThisNTRow        ;Save a copy of the count of tiles on this NT.
LAC9D:  PHA                     ;

LAC9E:  LDY WndLineBufIndex     ;Load index into line buffer.

WndBufLoadLoop:
LACA1:  LDA WndLineBuf,Y        ;
LACA4:  STA BlockRAM,X          ;Load line buffer into PPU buffer.
LACA7:  INX                     ;
LACA8:  INY                     ;
LACA9:  DEC WndThisNTRow        ;Is there more buffer data for this nametable?
LACAC:  BNE WndBufLoadLoop      ;If so, branch to get the next byte.

LACAE:  STY WndLineBufIndex     ;Update line buffer index.

LACB1:  PLA                     ;/2. Use this now to load attribute table bytes.
LACB2:  LSR                     ;1 attribute table byte per 2X2 block.
LACB3:  STA WndThisNTRow        ;

LACB6:  LDA WndBlkTileRow       ;Is this the second tile row that just finished?
LACB9:  AND #$01                ;If so, load attribute table data.
LACBB:  BEQ WndLoadRowBufEnd    ;Else branch to skip attribute table data for now.

LACBD:  LDY WndAtrbBufIndex     ;
LACC0:  LDA WndPPUAddrUB        ;Prepare to calculate attribute table addresses
LACC3:  STA _WndPPUAddrUB       ;by first starting with the nametable addresses.
LACC6:  LDA WndPPUAddrLB        ;
LACC9:  STA _WndPPUAddrLB       ;

WndLoadAttribLoop:
LACCC:  TXA                     ;
LACCD:  PHA                     ;Save BlockRAM index and AttribTblBuf index on stack.
LACCE:  TYA                     ;
LACCF:  PHA                     ;

LACD0:  LDA WndPPUAddrUB        ;Save upper byte of PPU address on stack.
LACD3:  PHA                     ;

LACD4:  LDA AttribTblBuf,Y      ;Get attibute table bits from buffer.
LACD7:  JSR WndCalcAttribAddr   ;($AD36)Update attribute table values.
LACDA:  STA WndAtribDat         ;Save a copy of the completed attribute table data byte.

LACDD:  PLA                     ;Restore upper byte of PPU address from stack.
LACDE:  STA WndPPUAddrUB        ;

LACE1:  PLA                     ;
LACE2:  TAY                     ;Restore BlockRAM index and AttribTblBuf index from stack.
LACE3:  PLA                     ;
LACE4:  TAX                     ;

LACE5:  LDA WndAtribAdrUB       ;
LACE8:  STA BlockRAM,X          ;
LACEB:  INX                     ;Save attribute table data address in buffer.
LACEC:  LDA WndAtribAdrLB       ;
LACEF:  STA BlockRAM,X          ;

LACF2:  INX                     ;
LACF3:  LDA WndAtribDat         ;Save attribute table data byte in buffer.
LACF6:  STA BlockRAM,X          ;

LACF9:  INX                     ;Increment BlockRAM index and AttribTblBuf index.
LACFA:  INY                     ;

LACFB:  INC _WndPPUAddrLB       ;Increment to next window block.
LACFE:  INC _WndPPUAddrLB       ;

LAD01:  .byte $EE, $03, $00     ;INC $0003(PPUEntCount)Update buffer entry count.

LAD04:  DEC WndThisNTRow        ;Is there still more attribute table data to load?
LAD07:  BNE WndLoadAttribLoop   ;If so, branch to do more.

LAD09:  STY WndAtrbBufIndex     ;Update attribute table buffer index.

WndLoadRowBufEnd:
LAD0C:  .byte $EE, $03, $00     ;INC $0003(PPUEntCount)Update buffer entry count.
LAD0F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndStartRow:
LAD10:  PHA                     ;Save A. Always 0.
LAD11:  JSR WndGetRowStartPos   ;($AD1F)Load X and Y start position of window row.
LAD14:  PLA                     ;Restore A. Always 0.
LAD15:  BNE WndNTSwap           ;Branch never.
LAD17:  RTS                     ;

WndNTSwap:
LAD18:  LDA PPUAddrUB           ;
LAD1A:  EOR #$04                ;Never used. Swaps between #$20 and #$24.
LAD1C:  STA PPUAddrUB           ;
LAD1E:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndGetRowStartPos:
LAD1F:  LDA _WndPosition        ;
LAD22:  ASL                     ;Get start X position in tiles
LAD23:  AND #$1E                ;relative to screen for window row.
LAD25:  STA ScrnTxtXCoord       ;

LAD28:  LDA _WndPosition        ;
LAD2B:  LSR                     ;
LAD2C:  LSR                     ;Get start Y position in tiles
LAD2D:  LSR                     ;relative to screen for window row.
LAD2E:  AND #$1E                ;
LAD30:  STA ScrnTxtYCoord       ;
LAD33:  JMP WndCalcPPUAddr      ;($ADC0)Calculate PPU address for window/text byte.

;----------------------------------------------------------------------------------------------------

WndCalcAttribAddr:
LAD36:  STA WndAttribVal        ;Save a copy of the attibute table value.

LAD39:  LDA #$1F                ;Get tile offset in row and divide by 4. This gives
LAD3B:  AND _WndPPUAddrLB       ;a value of 0-7. There are 8 bytes of attribute
LAD3E:  LSR                     ;table data per nametable row. WndPPUAddrUB now has
LAD3F:  LSR                     ;the byte number in the attribute table for this
LAD40:  STA WndPPUAddrUB        ;row offset.

LAD43:  LDA #$80                ;
LAD45:  AND _WndPPUAddrLB       ;
LAD48:  LSR                     ;Get MSB of lower address byte and shift it to the
LAD49:  LSR                     ;lower nibble.  This cuts the rows of the attribute
LAD4A:  LSR                     ;table in half.  There are now 4 possible addreses
LAD4B:  LSR                     ;in the attribute table that correspond to the target
LAD4C:  ORA WndPPUAddrUB        ;in the nametable.
LAD4F:  STA WndPPUAddrUB        ;

LAD52:  LDA #$03                ;
LAD54:  AND _WndPPUAddrUB       ;Getting the 2 LSB of the upper address selects the
LAD57:  ASL                     ;proper byte from the 4 remaining from above. Move
LAD58:  ASL                     ;The 2 bits to the upper nibble and or them with the
LAD59:  ASL                     ;lower byte of the base address of the attribute
LAD5A:  ASL                     ;table.  Finally, or the result with the other
LAD5B:  ORA #$C0                ;result to get the final result of the lower address
LAD5D:  ORA WndPPUAddrUB        ;byte of the attribute table byte.
LAD60:  STA WndAtribAdrLB       ;

LAD63:  LDX #AT_ATRBTBL0_UB     ;Assume we are working on nametable 0.
LAD65:  LDA _WndPPUAddrUB       ;
LAD68:  CMP #NT_NAMETBL1_UB     ;Are we actually working on nametable 1?
LAD6A:  BCC WndSetAtribUB       ;If not, branch to save upper address byte.

LAD6C:  LDX #AT_ATRBTBL1_UB     ;Set attribute table upper address for nametable 1.

WndSetAtribUB:
LAD6E:  STX WndAtribAdrUB       ;Save upper address byte for the attribute table.

LAD71:  LDA _WndPPUAddrLB       ;
LAD74:  AND #$40                ;
LAD76:  LSR                     ;Get bit 6 of address and move to lower nibble.
LAD77:  LSR                     ;This sets the upper bit for offset shifting.
LAD78:  LSR                     ;
LAD79:  LSR                     ;
LAD7A:  STA AtribBitsOfst       ;

LAD7D:  LDA _WndPPUAddrLB       ;
LAD80:  AND #$02                ;Get bit 1 of lower address bit.
LAD82:  ORA AtribBitsOfst       ;This sets the lower bit for offset shifting.
LAD85:  STA AtribBitsOfst       ;

LAD88:  LDA WndAtribAdrLB       ;Set attrib table pointer to lower byte of attrib table address.
LAD8B:  STA AttribPtrLB         ;

LAD8D:  LDA WndAtribAdrUB       ;Set upper byte for attribute table buffer. The atrib
LAD90:  AND #$07                ; table buffer starts at either $0300 or $0700, depending
LAD92:  STA AttribPtrUB         ;on the active nametable.

LAD94:  LDA EnNumber            ;Is player fighting the end boss?
LAD96:  CMP #EN_DRAGONLORD2     ;If so, force atribute table buffer to base address $0700.
LAD98:  BNE ModAtribByte        ;If not, branch to get attribute table byte.

LAD9A:  LDA #$07                ;Force atribute table buffer to base address $0700.
LAD9C:  STA AttribPtrUB         ;

ModAtribByte:
LAD9E:  LDY #$00                ;
LADA0:  LDA (AttribPtr),Y       ;Get attribute byte to modify from buffer.
LADA2:  STA AttribByte          ;

LADA5:  LDA #$03                ;Initialize bitmask.
LADA7:  LDY AtribBitsOfst       ;Set shift amount.
LADAA:  BEQ AddNewAtribVal      ;Is there no shifting needed? If none, branch. done.

AtribValShiftLoop:
LADAC:  ASL                     ;Shift bitmask into proper position.
LADAD:  ASL WndAttribVal        ;Shift new attribute bits into proper position.
LADB0:  DEY                     ;Is shifting done?
LADB1:  BNE AtribValShiftLoop   ;If not branch to shift by another bit.

AddNewAtribVal:
LADB3:  EOR #$FF                ;Clear the two bits to be modified.
LADB5:  AND AttribByte          ;

LADB8:  ORA WndAttribVal        ;Insert the 2 new bits.
LADBB:  LDY #$00                ;

LADBD:  STA (AttribPtr),Y       ;Save attribute table data byte back into the buffer.
LADBF:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndCalcPPUAddr:
LADC0:  LDA ActiveNmTbl         ;
LADC2:  ASL                     ;
LADC3:  ASL                     ;Calculate base upper address byte of current
LADC4:  AND #$04                ;name table. It will be either #$20 or #$24.
LADC6:  ORA #$20                ;
LADC8:  STA PPUAddrUB           ;

LADCA:  LDA ScrnTxtXCoord       ;
LADCD:  ASL                     ;*8. Convert X tile coord to X pixel coord.
LADCE:  ASL                     ;
LADCF:  ASL                     ;

LADD0:  CLC                     ;Add scroll offset.  It is a pixel offset.
LADD1:  ADC ScrollX             ;

LADD3:  STA PPUAddrLB           ;The X coordinate in pixels is now calculated.
LADD5:  BCC WndAddY             ;Did X position go past nametable boundary? If not, branch.

WndXOverRun:
LADD7:  LDA PPUAddrUB           ;Window tile ran beyond end of nametable.
LADD9:  EOR #$04                ;Move to next nametable to continue window line.
LADDB:  STA PPUAddrUB           ;

WndAddY:
LADDD:  LDA ScrollY             ;
LADDF:  LSR                     ;/8. Convert Y scroll pixel coord to tile coord.
LADE0:  LSR                     ;
LADE1:  LSR                     ;

LADE2:  CLC                     ;Add Tile Y coord of window. A now
LADE3:  ADC ScrnTxtYCoord       ;contains Y coordinate in tiles.

LADE6:  CMP #$1E                ;Did Y position go below nametable boundary?
LADE8:  BCC WndAddrCombine      ;If not, branch.

WndYOverRun:
LADEA:  SBC #$1E                ;Window tile went below end of nametable. Loop back to top.

WndAddrCombine:
LADEC:  LSR                     ;A is upper byte of result and PPUAddrLB is lower byte.
LADED:  ROR PPUAddrLB           ;
LADEF:  LSR                     ;Need to divide by 8 because X coord is still in pixel
LADF0:  ROR PPUAddrLB           ;coords.
LADF2:  LSR                     ;
LADF3:  ROR PPUAddrLB           ;Result is now calculated with respect to screen.

LADF5:  ORA PPUAddrUB           ;Combine A with PPUAddrUB to convert from
LADF7:  STA PPUAddrUB           ;screen coord to nametable coords.
LADF9:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndUpdateTiles:
LADFA:  LDA #$80                ;Indicate background tiles need to be updated.
LADFC:  STA UpdateBGTiles       ;
LADFF:  JMP WaitForNMI          ;($FF74)Wait for VBlank interrupt.

;----------------------------------------------------------------------------------------------------

; [BIGRAM-NES] comment out the name entry code, will be replaced by bigram model
.ifndef namegen
    WndEnterName:
    LAE02:  JSR InitNameWindow      ;($AE2C)Initialize window used while entering name.
    LAE05:  JSR WndShowUnderscore   ;($AEB8)Show underscore below selected letter in name window.
    LAE08:  JSR WndDoSelect         ;($A8D1)Do selection window routines.

    ProcessNameLoop:
    LAE0B:  JSR WndProcessChar      ;($AE53)Process name character selected by the player.
    LAE0E:  JSR WndMaxNameLength    ;($AEB2)Set carry if max length name has been reached.
    LAE11:  BCS WndStorePlyrName    ;Has player finished entering name? If so, branch to exit loop.
    LAE13:  JSR _WndDoSelectLoop    ;($A8E0)Wait for player to select the next character.
    LAE16:  JMP ProcessNameLoop     ;($AE0B)Loop to get name selected by player.

    WndStorePlyrName:
    LAE19:  LDX #$00                ;Set index to 0 for storing the player's name.

    StoreNameLoop:
    LAE1B:  LDA TempBuffer,X        ;Save the 8 characters of the player's name to the name registers.
    LAE1E:  STA DispName0,X         ;
    LAE20:  LDA TempBuffer+4,X      ;
    LAE23:  STA DispName4,X         ;
    LAE26:  INX                     ;
    LAE27:  CPX #$04                ;Have all 8 characters been saved?
    LAE29:  BNE StoreNameLoop       ;If not, branch to save the next 2.
    LAE2B:  RTS                     ;
.endif

.ifdef namegen

    VOCAB_SIZE = 27             ; number of tokens (alphabet + BOS/EOS)

    ;
    ; Convert token index (uchar) to tile index.
    ;
    ; Input:  A = token index (0 to VOCAB_SIZE-1)
    ; Output: A = tile index ($60, and $24 to $3D)
    ;
    ; Trashes: A
    ; 
    ItoS:                       ; ($ADDC)
        BNE @NotDot             ; A is not 0?
        LDA #TXT_BLANK1         ; white space tile
        RTS
        @NotDot:
        CLC
        ADC #$23                ; corresponding uppercase tile (TXT_UPR_A - 1)
        RTS

    ;
    ; Draw one sample from a 8bit distribution.
    ; 
    ; Input:  probs_ptr = pointer to an array of VOCAB_SIZE probabilities (8-bit values)
    ; Output: A = selected index (0 to VOCAB_SIZE-1)
    ;
    ; Trashes: A, Y
    ;
    Multinomial:                ; ($ADE5)
        JSR UpdateRandNum       ; get a random number in RandNumLB
        LDA #0                  ; acc = 0
        TAY                     ; i = 0

        @Loop:
            CLC
            ADC (probs_ptr),Y   ; acc += probs[i]
            CMP RandNumLB
            BCS @Done           ; acc >= random number?

            INY                 ; i++
            CPY #VOCAB_SIZE     ; i < VOCAB_SIZE?
            BCC @Loop

            DEY                 ; fallback to VOCAB_SIZE-1 if random number was 255

        @Done:
            TYA                 ; A = i
            RTS

    ;
    ; Set the probs_ptr to point to the transition matrix row for the given index.
    ;
    ; Input:  A = row index (0 to VOCAB_SIZE-1)
    ; Output: probs_ptr = pointer to the row in the transition matrix
    ; 
    ; Trashes: A, X
    ;
    LoadRowPtr:                  ; ($ADFA)
        TAX

        CPX #24
        BCC @UseLow              ; 0..23 => TransitionMat_0_23

        ; 24..26 => TransitionMat_24_26, then X := X-24
        LDA #<TransitionMat_24_26
        STA probs_ptr
        LDA #>TransitionMat_24_26
        STA probs_ptr+1
        TXA
        SEC
        SBC #24
        TAX
        JMP @OffsetRows

        ; 0..23
        @UseLow:
        LDA #<TransitionMat_0_23
        STA probs_ptr
        LDA #>TransitionMat_0_23
        STA probs_ptr+1

        @OffsetRows:
        CPX #0
        BEQ @Done                ; if index==0, we are done

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

    ;
    ; Show character on name window.
    ; This is a rewrite of the original ROM code.
    ;
    ; Input:  A = token index (0 to VOCAB_SIZE-1)
    ;         X = character index (0 to 7)
    ; Output: None. The character is displayed on screen.
    ;
    ; Trashes: A, X
    ;
    ShowChar:               ; ($AE2A)
        JSR ItoS
        STX WndNameIndex

        CPX #$04
        BCC @lo4            ; X = 0..3 -> DispName0

        @hi4:               ; X = 4..7 -> DispName4
        DEX                 ; X = X-4
        DEX
        DEX
        DEX
        STA DispName4,X
        LDX WndNameIndex    ; restore input X
        JMP @StoreDone

        @lo4:
        STA DispName0,X
        
        @StoreDone:
        STA PPUDataByte
        LDA #$06            ; set vertical position on screen
        STA ScrnTxtYCoord
        LDA WndNameIndex
        CLC
        ADC #$0C            ; set horizontal position on screen
        STA ScrnTxtXCoord
        JSR WndCalcPPUAddr
        JMP AddPPUBufEntry  ; (clobbers X)

    ;
    ; Generate a new name via a simple bigram model.
    ;
    ; Trashes: A, X, Y
    ;
    WndEnterName:              ; ($AE59) we jump here directly from Bank03
        JSR InitNameWindow

        ; ------------------------------------------------------------------
        ; Generate the name auto-regressively (3-8 letters)
        ; ------------------------------------------------------------------
        LDA #0
        STA tok_idx            ; tok_idx = 0
        STA j_count            ; j = 0

        @CharLoop:             ; ensure at least 3 letters
        LDA #0
        STA attempts           ; attempts = 0

        @AttemptLoop:
        LDA tok_idx
        JSR LoadRowPtr         ; probs_ptr = T + tok_idx*VOCAB_SIZE
        JSR Multinomial        ; A = new tok_idx (0 - VOCAB_SIZE-1)
        STA tok_idx

        INC attempts           ; attempts++
        BEQ @ForceA            ; attempts==255, force letter 'A'

        LDA tok_idx
        BEQ @AttemptLoop       ; resample if tok_idx==0

        @ForceA:
        LDA tok_idx
        BNE @GotChar           ; tok_idx != 0? then keep it, otherwise...
        LDA #1                 ; ...force 'A'
        STA tok_idx            ; store tok_idx for the next iteration

        @GotChar:
        LDY j_count
        STA NameBuffer,Y       ; new_name[j] = A
        INY                    ; j++
        STY j_count
        CPY #3                 ; j < 3?
        BCC @CharLoop

        ; letters 4-7 via loop

        LDA #4
        STA attempts           ; reuse variable to loop 4 times

        @MidCharsLoop:
        LDA tok_idx
        JSR LoadRowPtr
        JSR Multinomial
        STA tok_idx
        LDA tok_idx
        BEQ @Pad               ; if EOS, pad the rest with zeros

        LDY j_count
        STA NameBuffer,Y
        INY
        STY j_count
        DEC attempts
        BNE @MidCharsLoop

        @LastChar:             ; directly store in the last position, even if it's a white space
        LDA tok_idx
        JSR LoadRowPtr
        JSR Multinomial
        LDY #7
        STA NameBuffer,Y

        @EndGen:
        ; ------------------------------------------------------------------
        ; Read the name from NameBuffer, store it and show it on screen
        ; ------------------------------------------------------------------
        LDY #$00
        @loop:
            TYA
            TAX
            LDA NameBuffer,X
            JSR ShowChar
            INY
            CPY #$08
            BNE @loop

        LDA #$08
        STA WndNameIndex
        RTS

        @Pad:
        LDY j_count          ; current write position (3..6)
        LDA #0
        @PadLoop:
        STA NameBuffer,Y
        INY
        CPY #8               ; fill through index 7  
        BCC @PadLoop
        STY j_count          ; j_count = 8 (fully filled)
        JMP @EndGen
.endif

;----------------------------------------------------------------------------------------------------

InitNameWindow:
LAE2C:  LDA #$00                ;
LAE2E:  STA WndNameIndex        ;Zero out name variables.

.ifndef namegen
    LAE31:  STA WndUnused6505       ;
.endif

LAE34:  LDA #WND_NM_ENTRY       ;Show name entry window.
LAE36:  JSR ShowWindow          ;($A194)Display window.

.ifndef namegen
    LAE39:  LDA #WND_ALPHBT         ;Show alphabet window.
    LAE3B:  JSR ShowWindow          ;($A194)Display window.

    LAE3E:  LDA #$12                ;Set window columns to 18. Special value for the alphabet window.
    LAE40:  STA WndColumns          ;

    LAE43:  LDA #$21                ;Set starting cursor position to 2,1.
    LAE45:  STA WndCursorHome       ;

    LAE48:  LDA #TL_BLANK_TILE2     ;Prepare to clear temp buffer.
    LAE4A:  LDX #$0C                ;

    ClearNameBufLoop:
    LAE4C:  STA TempBuffer,X        ;Place blank tile value in temp buffer.
    LAE4F:  DEX                     ;
    LAE50:  BPL ClearNameBufLoop    ;Have 12 values been written to the buffer?
.endif

LAE52:  RTS                     ;If not, branch to write another.

;----------------------------------------------------------------------------------------------------

.ifndef namegen
    WndProcessChar:

    LAE53:  CMP #WND_ABORT          ;Did player press the B button?
    LAE55:  BEQ WndDoBackspace      ;If so, back up 1 character.

    LAE57:  CMP #$1A                ;Did player select character A-Z?
    LAE59:  BCC WndUprCaseConvert   ;If so, branch to covert to nametables values.

    LAE5B:  CMP #$21                ;Did player select symbol -'!?() or _?
    LAE5D:  BCC WndSymbConvert1     ;If so, branch to covert to nametables values.

    LAE5F:  CMP #$3B                ;Did player select character a-z?
    LAE61:  BCC WndLwrCaseConvert   ;If so, branch to covert to nametables values.

    LAE63:  CMP #$3D                ;Did player select symbol , or .?
    LAE65:  BCC WndSymbConvert2     ;If so, branch to covert to nametables values.

    LAE67:  CMP #$3D                ;Did player select BACK?
    LAE69:  BEQ WndDoBackspace      ;If so, back up 1 character.

    LAE6B:  LDA #$08                ;Player must have selected END.
    LAE6D:  STA WndNameIndex        ;Set name index to max value to indicate the end.
    LAE70:  RTS                     ;

    WndUprCaseConvert:
    LAE71:  CLC                     ;
    LAE72:  ADC #TXT_UPR_A          ;Add value to convert to nametable character.
    LAE74:  BNE WndUpdateName       ;

    WndLwrCaseConvert:
    LAE76:  SEC                     ;
    LAE77:  SBC #$17                ;Subtract value to convert to nametable character.
    LAE79:  BNE WndUpdateName       ;

    WndSymbConvert1:
    LAE7B:  TAX                     ;
    LAE7C:  LDA SymbolConvTbl-$1A,X ;Use table to convert to nametable character.
    LAE7F:  BNE WndUpdateName       ;

    WndSymbConvert2:
    LAE81:  TAX                     ;
    LAE82:  LDA SymbolConvTbl-$34,X ;Use table to convert to nametable character.
    LAE85:  BNE WndUpdateName       ;

    WndDoBackspace:
    LAE87:  LDA WndNameIndex        ;Is the name index already 0?
    LAE8A:  BEQ WndProcessCharEnd1  ;If so, branch to exit, can't go back any further.

    LAE8C:  JSR WndHideUnderscore   ;($AEBC)Remove underscore character from screen.
    LAE8F:  DEC WndNameIndex        ;Move underscore back 1 character.
    LAE92:  JSR WndShowUnderscore   ;($AEB8)Show underscore below selected letter in name window.

    WndProcessCharEnd1:
    LAE95:  RTS                     ;End character processing.

    WndUpdateName:
    LAE96:  PHA                     ;Save name character on stack.
    LAE97:  JSR WndHideUnderscore   ;($AEBC)Remove underscore character from screen.

    LAE9A:  PLA                     ;Restore name character and add it to the buffer.
    LAE9B:  LDX WndNameIndex        ;
    LAE9E:  STA TempBuffer,X        ;
    LAEA1:  JSR WndNameCharYPos     ;($AEC2)Place selected name character on screen.

    LAEA4:  INC WndNameIndex        ;Increment index for player's name.
    LAEA7:  LDA WndNameIndex        ;
    LAEAA:  CMP #$08                ;Have 8 character been entered for player's name?
    LAEAC:  BCS WndProcessCharEnd2  ;If so, branch to end.

    LAEAE:  JSR WndShowUnderscore   ;($AEB8)Show underscore below selected letter in name window.

    WndProcessCharEnd2:
    LAEB1:  RTS                     ;End character processing.

    WndMaxNameLength:
    LAEB2:  LDA WndNameIndex        ;Have 8 name characters been inputted?
    LAEB5:  CMP #$08                ;
    LAEB7:  RTS                     ;If so, set carry.
.endif

;----------------------------------------------------------------------------------------------------

.ifndef namegen
    WndShowUnderscore:
    LAEB8:  LDA #TL_TOP1            ;Border pattern - upper border(Underscore below selected entry).
    LAEBA:  BNE WndUndrscrYPos      ;Branch always.

    WndHideUnderscore:
    LAEBC:  LDA #TL_BLANK_TILE1     ;Prepare to erase underscore character.

    WndUndrscrYPos:
    LAEBE:  LDX #$09                ;Set Y position for underscore character.
    LAEC0:  BNE WndShowNameChar     ;Branch always.

    WndNameCharYPos:
    LAEC2:  LDX #$08                ;Set Y position for name character.

    WndShowNameChar:
    LAEC4:  STX ScrnTxtYCoord       ;Calculate X position for character to add to name window.
    LAEC7:  STA PPUDataByte         ;

    LAEC9:  LDA WndNameIndex        ;
    LAECC:  CLC                     ;Calculate Y position for character to add to name window.
    LAECD:  ADC #$0C                ;
    LAECF:  STA ScrnTxtXCoord       ;

    LAED2:  JSR WndCalcPPUAddr      ;($ADC0)Calculate PPU address for window/text byte.
    LAED5:  JMP AddPPUBufEntry      ;($C690)Add data to PPU buffer.
.endif

;----------------------------------------------------------------------------------------------------

;The following table converts to the symbols in the alphabet
;window to the corresponding symbols in the nametable.
SymbolConvTbl:
.incbin "bin/Bank01/SymbolConvTbl.bin"

DoWindowPrep:
LAEE1:  PHA                     ;Save window type byte on the stack.

LAEE2:  LDX #$40                ;Initialize WndBuildPhase variable.
LAEE4:  STX WndBuildPhase       ;

LAEE7:  LDX #$03                ;Prepare to look through table below for window type.
LAEE9: CMP WindowType1Tbl,X    ;
LAEEC:  BEQ LAEF3                   ;
LAEEE:  DEX                     ;If working on one of the 4 windows from the table below,
LAEEF:  BPL LAEE9                   ;Set the WndBuildPhase variable to 0.  This seems to have
LAEF1:  BMI LAEF8                  ;no effect as the MSB is set after this function is run.
LAEF3: LDA #$00                ;
LAEF5:  STA WndBuildPhase       ;

LAEF8: PLA                     ;Get window type byte again.
LAEF9:  PHA                     ;

LAEFA:  CMP #WND_CMD_NONCMB     ;Is this the command, non-combat window?
LAEFC:  BEQ DoBeepSFX           ;If so, branch to make menu button SFX.

LAEFE:  CMP #WND_CMD_CMB        ;Is this the command, combat window?
LAF00:  BEQ DoBeepSFX           ;If so, branch to make menu button SFX.

LAF02:  CMP #WND_YES_NO1        ;Is this the yes/no selection window?
LAF04:  BEQ DoConfirmSFX        ;If so, branch to make confirm SFX.

LAF06:  CMP #WND_DIALOG         ;Is this a dialog window?
LAF08:  BNE LAF13                   ;If not, branch to exit.

LAF0A:  LDA #$00                ;Dialog window being created. Set cursor to top left.
LAF0C:  STA WndTxtXCoord        ;
LAF0E:  STA WndTxtYCoord        ;
LAF10:  JSR ClearDialogOutBuf   ;($B850)Clear dialog window buffer.

LAF13: PLA                     ;Restore window type byte in A and return.
LAF14:  RTS                     ;

DoBeepSFX:
LAF15:  LDA #SFX_MENU_BTN       ;Menu button SFX.
LAF17:  BNE LAF1B                   ;Branch always.

DoConfirmSFX:
LAF19:  LDA #SFX_CONFIRM        ;Confirmation SFX.
LAF1B: BRK                     ;
LAF1C:  .byte $04, $17          ;($81A0)InitMusicSFX, bank 1.

LAF1E:  PLA                     ;Restore window type byte in A and return.
LAF1F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WindowType1Tbl:
.incbin "bin/Bank01/WindowType1Tbl.bin"
WndEraseParams:
LAF24:  CMP #WND_ALPHBT         ;Special case. Erase alphabet window.
LAF26:  BEQ WndErsAlphabet      ;

LAF28:  CMP #$FF                ;Special case. Erase unspecified window.
LAF2A:  BEQ WndErsOther         ;

LAF2C:  ASL                     ;*2. Widow data pointer is 2 bytes.
LAF2D:  TAY                     ;

LAF2E:  LDA WndwDataPtrTbl,Y    ;
LAF31:  STA GenPtr3ELB          ;Get pointer base of window data.
LAF33:  LDA WndwDataPtrTbl+1,Y  ;
LAF36:  STA GenPtr3EUB          ;

LAF38:  LDY #$01                ;
LAF3A:  LDA (GenPtr3E),Y        ;Get window height in blocks.
LAF3C:  STA WndEraseHght        ;

LAF3F:  INY                     ;
LAF40:  LDA (GenPtr3E),Y        ;Get window width in tiles.
LAF42:  STA WndEraseWdth        ;

LAF45:  INY                     ;
LAF46:  LDA (GenPtr3E),Y        ;Get window X,Y position in blocks.
LAF48:  STA WndErasePos         ;
LAF4B:  RTS                     ;

WndErsAlphabet:
LAF4C:  LDA #$07                ;Window height = 7 blocks.
LAF4E:  STA WndEraseHght        ;

LAF51:  LDA #$16                ;Window width = 22 tiles.
LAF53:  STA WndEraseWdth        ;

LAF56:  LDA #$21                ;
LAF58:  STA WndErasePos         ;Window position = 2,1.
LAF5B:  RTS                     ;

WndErsOther:
LAF5C:  LDA #$0C                ;Window height = 12 blocks.
LAF5E:  STA WndEraseHght        ;

LAF61:  LDA #$1A                ;Window width =  26 tiles.
LAF63:  STA WndEraseWdth        ;

LAF66:  LDA #$22                ;
LAF68:  STA WndErasePos         ;Window position = 2,2.
LAF6B:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WndwDataPtrTbl:
LAF6C:  .word PopupDat          ;($AFB0)Pop-up window.
LAF6E:  .word StatusDat         ;($AFC7)Status window.
LAF70:  .word DialogDat         ;($B04B)Dialog window.
LAF72:  .word CmdNonCmbtDat     ;($B054)Command window, non-combat.
LAF74:  .word CmdCmbtDat        ;($B095)Command window, combat.
LAF76:  .word SpellDat          ;($B0BA)Spell window.
LAF78:  .word SpellDat          ;($B0BA)Spell window.
LAF7A:  .word PlayerInvDat      ;($B0CC)Player inventory window.
LAF7C:  .word ShopInvDat        ;($B0DA)Shop inventory window.
LAF7E:  .word YesNo1Dat         ;($B0EB)Yes/no selection window, variant 1.
LAF80:  .word BuySellDat        ;($B0FB)Buy/sell selection window.
LAF82:  .word AlphabetDat       ;($B10D)Alphabet window.
LAF84:  .word MsgSpeedDat       ;($B194)Message speed window.
LAF86:  .word InputNameDat      ;($B1E0)Input name window.
LAF88:  .word NameEntryDat      ;($B1F7)Name entry window.
LAF8A:  .word ContChngErsDat    ;($B20B)Continue, change, erase window.
LAF8C:  .word FullMenuDat       ;($B249)Full pre-game menu window.
LAF8E:  .word NewQuestDat       ;($B2A8)Begin new quest window.
LAF90:  .word LogList1Dat1      ;($B2C2)Log list, entry 1 window 1.
LAF92:  .word LogList2Dat1      ;($B2DA)Log list, entry 2 window 1.
LAF94:  .word LogList12Dat1     ;($B2F2)Log list, entry 1,2 window 1.
LAF96:  .word LogList3Dat1      ;($B31B)Log list, entry 3 window 1.
LAF98:  .word LogList13Dat1     ;($B333)Log list, entry 1,3 window 1.
LAF9A:  .word LogList23Dat1     ;($B35C)Log list, entry 2,3 window 1.
LAF9C:  .word LogList123Dat1    ;($B385)Log list, entry 1,2,3 window 1.
LAF9E:  .word LogList1Dat2      ;($B3BF)Log list, entry 1 window 2.
LAFA0:  .word LogList2Dat2      ;($B3D9)Log list, entry 2 window 2.
LAFA2:  .word LogList12Dat2     ;($B3F3)Log list, entry 1,2 window 2.
LAFA4:  .word LogList3Dat2      ;($B420)Log list, entry 3 window 2.
LAFA6:  .word LogList13Dat2     ;($B43A)Log list, entry 1,3 window 2.
LAFA8:  .word LogList23Dat2     ;($B467)Log list, entry 2,3 window 2.
LAFAA:  .word LogList123Dat2    ;($B494)Log list, entry 1,2,3 window 2.
LAFAC:  .word EraseLogDat       ;($B4D4)Erase log window.
LAFAE:  .word YesNo2Dat         ;($B50D)Yes/no selection window, variant 2.

PopupDat:
.incbin "bin/Bank01/PopupDat.bin"
StatusDat:
.incbin "bin/Bank01/StatusDat.bin"
DialogDat:
.incbin "bin/Bank01/DialogDat.bin"
CmdNonCmbtDat:
.incbin "bin/Bank01/CmdNonCmbtDat.bin"
CmdCmbtDat:
.incbin "bin/Bank01/CmdCmbtDat.bin"
SpellDat:
.incbin "bin/Bank01/SpellDat.bin"
PlayerInvDat:
.incbin "bin/Bank01/PlayerInvDat.bin"
ShopInvDat:
.incbin "bin/Bank01/ShopInvDat.bin"
YesNo1Dat:
.incbin "bin/Bank01/YesNo1Dat.bin"
BuySellDat:
.incbin "bin/Bank01/BuySellDat.bin"
AlphabetDat:
.incbin "bin/Bank01/AlphabetDat.bin"
MsgSpeedDat:
.incbin "bin/Bank01/MsgSpeedDat.bin"
InputNameDat:
.incbin "bin/Bank01/InputNameDat.bin"

NameEntryDat:

.byte $01
.ifdef namegen
    .byte $02  ; height of the name window
    .byte $0C  ; width
    .byte $25  ; position (moved up)
    .byte $8B 
    .byte $31, $24, $30, $28 ; "NAME"
    .byte $88, $81
    .byte $60, $60, $60, $60, $60, $60, $60, $60 ; blank tiles
.else
    .byte $03
    .byte $0C
    .byte $35
    .byte $8B 
    .byte $31, $24, $30, $28
    .byte $88, $81
    .byte $41, $41, $41, $41, $41, $41, $41, $41 ; asterisk
.endif
.byte $80

ContChngErsDat:
.incbin "bin/Bank01/ContChngErsDat.bin"
FullMenuDat:
.incbin "bin/Bank01/FullMenuDat.bin"
NewQuestDat:
.incbin "bin/Bank01/NewQuestDat.bin"
LogList1Dat1:
.incbin "bin/Bank01/LogList1Dat1.bin"
LogList2Dat1:
.incbin "bin/Bank01/LogList2Dat1.bin"
LogList12Dat1:
.incbin "bin/Bank01/LogList12Dat1.bin"
LogList3Dat1:
.incbin "bin/Bank01/LogList3Dat1.bin"
LogList13Dat1:
.incbin "bin/Bank01/LogList13Dat1.bin"
LogList23Dat1:
.incbin "bin/Bank01/LogList23Dat1.bin"
LogList123Dat1:
.incbin "bin/Bank01/LogList123Dat1.bin"
LogList1Dat2:
.incbin "bin/Bank01/LogList1Dat2.bin"
LogList2Dat2:
.incbin "bin/Bank01/LogList2Dat2.bin"
LogList12Dat2:
.incbin "bin/Bank01/LogList12Dat2.bin"
LogList3Dat2:
.incbin "bin/Bank01/LogList3Dat2.bin"
LogList13Dat2:
.incbin "bin/Bank01/LogList13Dat2.bin"
LogList23Dat2:
.incbin "bin/Bank01/LogList23Dat2.bin"
LogList123Dat2:
.incbin "bin/Bank01/LogList123Dat2.bin"
EraseLogDat:
.incbin "bin/Bank01/EraseLogDat.bin"
YesNo2Dat:
.incbin "bin/Bank01/YesNo2Dat.bin"
DoDialog:
LB51D:  JSR FindDialogEntry     ;($B532)Get pointer to desired dialog text.
LB520:  JSR InitDialogVars      ;($B576)Initialize the dialog variables.

LB523: JSR CalcWordCoord       ;($B5AF)Calculate coordinates of word in text window.
LB526:  JSR WordToScreen        ;($B5E6)Send dialog word to the screen.
LB529:  JSR CheckDialogEnd      ;($B594)Check if dialog buffer is complete.
LB52C:  BCC LB523

LB52E:  JSR DialogToScreenBuf   ;($B85D)Copy dialog buffer to screen buffer.
LB531:  RTS                     ;

;----------------------------------------------------------------------------------------------------

FindDialogEntry:
LB532:  STA TextEntry           ;Store byte and process later.

LB534:  AND #NBL_UPPER          ;
LB536:  LSR                     ;
LB537:  LSR                     ;Keep upper nibble and shift it to lower nibble.
LB538:  LSR                     ;
LB539:  LSR                     ;
LB53A:  STA TextBlock           ;

LB53C:  TXA                     ;Get upper/lower text block bit and move to upper nibble.
LB53D:  ASL                     ;
LB53E:  ASL                     ;
LB53F:  ASL                     ;
LB540:  ASL                     ;
LB541:  ADC TextBlock           ;Add to text block byte. Text block calculation complete.

LB543:  CLC                     ;
LB544:  ADC #$01                ;Use TextBlock as pointer into bank table. Incremented
LB546:  STA BankPtrIndex        ;by 1 as first pointer is for intro routine.

LB548:  LDA #PRG_BANK_2         ;Prepare to switch to PRG bank 2.
LB54A:  STA NewPRGBank          ;

LB54C:  LDX #$9F                ;Store data pointer in $9F,$A0
LB54E:  JSR GetAndStrDatPtr     ;($FD00)

LB551:  LDA TextEntry           ;
LB553:  AND #NBL_LOWER          ;Keep only lower nibble for text entry number.
LB555:  STA TextEntry           ;

LB557:  TAX                     ;Keep copy of entry number in X.
LB558:  BEQ LB575                ;Entry 0? If so, done! branch to exit.

LB55A:  LDY #$00                ;No offset from pointer.
LB55C: LDX #DialogPtr          ;DialogPtr is the pointer to use.
LB55E:  LDA #PRG_BANK_2         ;PRG bank 2 is where the text is stored.

LB560:  JSR GetBankDataByte     ;($FD1C)Retreive data byte.

LB563:  INC DialogPtrLB         ;
LB565:  BNE LB569                   ;Increment dialog pointer.
LB567:  INC DialogPtrUB         ;

LB569:CMP #TXT_END1           ;At the end of current text entry?
LB56B:  BEQ LB571                   ;If so, branch to check nect entry.

LB56D:  CMP #TXT_END2           ;Also used as end of entry marker.
LB56F:  BNE LB55C                  ;Branch if not end of entry.

LB571:DEC TextEntry           ;Incremented past current text entry.
LB573:  BNE LB55C                 ;Are we at right entry? if not, branch to try next entry.

LB575:RTS                     ;Done. DialogPtr points to desired text entry.

;----------------------------------------------------------------------------------------------------

InitDialogVars:
LB576:  LDA #$00                ;
LB578:  STA TxtIndent           ;
LB57B:  STA Dialog00            ;
LB57E:  STA DialogEnd           ;
LB581:  STA WrkBufBytsDone      ;
LB584:  LDA #$08                ;Initialize the dialog variables.
LB586:  STA TxtLineSpace        ;
LB589:  LDA WndTxtXCoord        ;

.ifndef namegen
    LB58B:  STA Unused6510          ;
.endif

LB58E:  LDA WndTxtYCoord        ;

.ifndef namegen
    LB590:  STA Unused6511          ;
.endif

LB593:  RTS                     ;

;----------------------------------------------------------------------------------------------------

CheckDialogEnd:
LB594:  LDA DialogEnd           ;
LB597:  BNE LB59B                   ;Is dialog buffer complete?
LB599:  CLC                     ;If so, clear the carry flag.
LB59A:  RTS                     ;

LB59B:LDX WndTxtYCoord        ;

.ifndef namegen
    LB59D:  LDA Unused6512          ;
.endif

LB5A0:  BNE LB5A5                   ;

.ifndef namegen
    LB5A2:  STX Unused6512          ;Dialog buffer not complete. Set carry.
.endif

LB5A5:LDA Unused6513          ;The other variables have no effect.
LB5A8:  BNE LB5AD                   ;

.ifndef namegen
    LB5AA:  STX Unused6513          ;
.endif

LB5AD:SEC                     ;
LB5AE:  RTS                     ;

;----------------------------------------------------------------------------------------------------

CalcWordCoord:
LB5AF:  JSR GetTxtWord          ;($B635)Get the next word of text.

LB5B2:  BIT Dialog00            ;Should never branch.
LB5B5:  BMI CalcCoordEnd        ;

LB5B7:  LDA WndTxtXCoord        ;Make sure x coordinate after word is
LB5B9:  STA WndXPosAW           ;the same as current x coordinate.

LB5BC:  LDA #$00                ;Zero out word buffer index.
LB5BE:  STA WordBufIndex        ;

SearchWordBuf:
LB5C1:  LDX WordBufIndex        ;
LB5C4:  LDA WordBuffer,X        ;Get next character in the word buffer.
LB5C7:  INC WordBufIndex        ;

LB5CA:  CMP #TL_BLANK_TILE1     ;Has a space in the word buffer been found?
LB5CC:  BEQ WordBufBreakFound   ;If so, branch to see if it will fit it into text window.

LB5CE:  CMP #TXT_SUBEND         ;Has a sub-buffer end character been found?
LB5D0:  BCS WordBufBreakFound   ;If so, branch to see if word will fit it into text window.

LB5D2:  INC WndXPosAW           ;Increment window position pointer.

LB5D5:  JSR CheckBetweenWords   ;($B8F9)Check for non-word character.
LB5D8:  BCS SearchWordBuf       ;Still in word? If so, branch.

WordBufBreakFound:
LB5DA:  LDX WndXPosAW           ;Is X position at beginning of line?
LB5DD:  BEQ LB5E2                   ;If so, branch to skip modifying X position.

LB5DF:  DEC WndXPosAW           ;Dcrement index so it points to last character position.

LB5E2:JSR CheckForNewLine     ;($B915)Move text to new line, if necessary.

CalcCoordEnd:
LB5E5:  RTS                     ;End coordinate calculations.

;----------------------------------------------------------------------------------------------------

WordToScreen:
LB5E6:  LDX #$00                ;Zero out word buffer index.
LB5E8:  STX WordBufLen          ;

LB5EB:LDX WordBufLen          ;
LB5EE:  LDA WordBuffer,X        ;Get next character in the word buffer.
LB5F1:  INC WordBufLen          ;

LB5F4:  CMP #TXT_SUBEND         ;Is character a control character that will cause a newline?
LB5F6:  BCS TxtCntrlChars       ;If so, branch to determine the character.

LB5F8:  PHA                     ;
LB5F9:  JSR TextToPPU           ;($B9C7)Send dialog text character to the screen.
LB5FC:  PLA                     ;

LB5FD:  JSR CheckBetweenWords   ;($B8F9)Check for non-word character.
LB600:  BCS LB5EB                   ;Was the character a text character?
LB602:  RTS                     ;If so, branch to get another character.

TxtCntrlChars:
LB603:  CMP #TXT_WAIT           ;Was wait found?
LB605:  BEQ WaitFound           ;If so, branch to wait.

LB607:  CMP #TXT_END1           ;Was the end character found?
LB609:  BEQ DialogEndFound      ;If so, branch to end dialog.

LB60B:  CMP #TXT_NEWL           ;Was a newline character found?
LB60D:  BEQ NewLineFound        ;If so, branch to do newline routine.

LB60F:  CMP #TXT_NOP            ;Was a no-op found?
LB611:  BEQ NewLineFound        ;If so, branch to do newline routine.

DoDialogEnd:
LB613:  LDA #TXT_END2           ;Dialog is done. Load end of dialog marker.
LB615:  STA DialogEnd           ;Set end of dialog flag.
LB618:  RTS                     ;

NewLineFound:
LB619:  JMP DoNewline           ;($B91D)Go to next line in dialog window.

WaitFound:
LB61C:  JSR DoNewline           ;($B91D)Go to next line in dialog window.
LB61F:  JSR DoWait              ;($BA59)Wait for user interaction.

LB622:  LDA TxtIndent           ;Is an indent active?
LB625:  BNE LB62A                   ;If so, branch to skip newline.

LB627:  JSR MoveToNextLine      ;($B924)Move to the next line in the text window.
LB62A:RTS                     ;

DialogEndFound:
LB62B:  JSR DoNewline           ;($B91D)Go to next line in dialog window.
LB62E:  LDA #$00                ;Set cursor X position to beginning of line.
LB630:  STA WndTxtXCoord        ;
LB632:  JMP DoDialogEnd         ;($B613)End current dialog.

;----------------------------------------------------------------------------------------------------

GetTxtWord:
LB635:  LDA #$00                ;Zero out word buffer length.
LB637:  STA WordBufLen          ;

GetTxtByteLoop:
LB63A:  JSR GetTextByte         ;($B662)Get text byte from ROM or work buffer.
LB63D:  CMP #TXT_NOP            ;Is character a no-op character?
LB63F:  BNE BuildWordBuf        ;If not, branch to add to word buffer.

LB641:  BIT Dialog00            ;Branch always.
LB644:  BPL GetTxtByteLoop      ;Get next character.

BuildWordBuf:
LB646:  CMP #TXT_OPN_QUOTE      ;"'"(open quotes).
LB648:  BEQ TxtSetIndent        ;Has open quotes been found? If so, branch to set indent.

LB64A:  CMP #TXT_INDENT         ;" "(Special indent blank space).
LB64C:  BNE LB653                   ;Has indent character been found? If not, branch to skip indent.

TxtSetIndent:
LB64E:  LDX #$01                ;Set text indent to 1 space.
LB650:  STX TxtIndent           ;

LB653:LDX WordBufLen          ;Add character to word buffer.
LB656:  STA WordBuffer,X        ;
LB659:  INC WordBufLen          ;Increment buffer length.
LB65C:  JSR CheckBetweenWords   ;($B8F9)Check for non-word character.
LB65F:  BCS GetTxtByteLoop      ;End of word? If not, branch to get next byte.
LB661:  RTS                     ;

;----------------------------------------------------------------------------------------------------

GetTextByte:
LB662:  LDX WrkBufBytsDone      ;Are work buffer bytes waiting to be returned?
LB665:  BEQ GetROMByte          ;If not, branch to retreive a ROM byte instead.

WorkBufDone:
LB667:  LDA WorkBuffer,X        ;Grab the next byte from the work buffer.
LB66A:  INC WrkBufBytsDone      ;
LB66D:  CMP #TXT_SUBEND         ;Is it the end marker for the work buffer?
LB66F:  BNE LB678                   ;If not, branch to return another work buffer byte.

LB671:  LDX #$00                ;Work buffer bytes all processed.
LB673:  STX WrkBufBytsDone      ;
LB676:  BEQ GetROMByte          ;Branch always and grab a byte from ROM.

LB678:RTS                     ;Return work buffer byte.

GetROMByte:
LB679:  LDA #PRG_BANK_2         ;PRG bank 2 is where the text is stored.
LB67B:  LDX #DialogPtr          ;DialogPtr is the pointer to use.
LB67D:  LDY #$00                ;No offset from pointer.

LB67F:  JSR GetBankDataByte     ;($FD1C)Get text byte from PRG bank 2 and store in A.
LB682:  JSR IncDialogPtr        ;($BA9F)Increment DialogPtr.

LB685:  CMP #TXT_PLRL           ;Plural control character?
LB687:  BEQ JmpDoPLRL           ;If so, branch to process.

LB689:  CMP #TXT_DESC           ;Object description control character?
LB68B:  BEQ JmpDoDESC           ;If so, branch to process.

LB68D:  CMP #TXT_PNTS           ;"Points" control character?
LB68F:  BEQ JmpDoPNTS           ;If so, brach to process.

LB691:  CMP #TXT_AMTP           ;Numeric amount + "Points" control character?
LB693:  BEQ JmpDoAMTP           ;If so, branch to process.

LB695:  CMP #TXT_AMNT           ;Numeric amount control character?
LB697:  BEQ JmpDoAMNT           ;If so, branch to process.

LB699:  CMP #TXT_SPEL           ;Spell description control character?
LB69B:  BEQ JmpDoSPEL           ;If so, branch to process.

LB69D:  CMP #TXT_NAME           ;Name description control character?
LB69F:  BEQ JmpDoNAME           ;If so, branch to process.

LB6A1:  CMP #TXT_ITEM           ;Item description control character?
LB6A3:  BEQ JmpDoITEM           ;If so, branch to process.

LB6A5:  CMP #TXT_COPY           ;Buffer copy control character?
LB6A7:  BEQ JmpDoCOPY           ;If so, branch to process.

LB6A9:  CMP #TXT_ENMY           ;Enemy name control character?
LB6AB:  BEQ JmpDoENMY           ;If so, branch to process.

LB6AD:  CMP #TXT_ENM2           ;Enemy name control character?
LB6AF:  BEQ JmpDoENM2           ;If so, branch to process.

LB6B1:  RTS                     ;No control character. Return ROM byte.

;----------------------------------------------------------------------------------------------------

JmpDoCOPY:
LB6B2:  JMP DoCOPY              ;($B7E8)Copy description buffer straight into work buffer.

JmpDoNAME:
LB6B5:  JMP DoNAME              ;($B7F9)Jump to get player's name.

JmpDoENMY:
LB6B8:  JMP DoENMY              ;($B804)Jump to get enemy name.

JmpDoSPEL:
LB6BB:  JMP DoSPEL              ;($B7D8)Jump to get spell description.

JmpDoDESC:
LB6BE:  JMP DoDESC              ;($B794)Jump do get object description proceeded by 'a' or 'an'.

JmpDoENM2:
LB6C1:  JMP DoENM2              ;(B80F)Jump to get enemy name preceeded by 'a' or 'an'.

JmpDoITEM:
LB6C4:  JMP DoITEM              ;($B757)Jump to get item description.

JmpDoPNTS:
LB6C7:  JMP DoPNTS              ;($B71E)Jump to write "Points" to buffer.

JmpDoAMTP:
LB6CA:  JMP DoAMTP              ;($B724)Jump to do BCD converion and write "Points" to buffer.

;----------------------------------------------------------------------------------------------------

JmpDoAMNT:
LB6CD:  JSR BinWordToBCD        ;($B6DA)Convert word in $00/$01 to BCD.

WorkBufEndChar:
LB6D0:  LDA #TXT_SUBEND         ;Place termination character at end of work buffer.
LB6D2:  STA WorkBuffer,Y        ;

LB6D5:  LDX #$00                ;Set index to beginning of work buffer.
LB6D7:  JMP WorkBufDone         ;($B667)Done building work buffer.

;----------------------------------------------------------------------------------------------------

BinWordToBCD:
LB6DA:  LDA #$05                ;Largest BCD from two bytes is 5 digits.
LB6DC:  STA SubBufLength        ;

LB6DF:  LDA GenWrd00LB          ;
LB6E1:  STA BCDByte0            ;Load word to convert to BCD.
LB6E3:  LDA GenWrd00UB          ;
LB6E5:  STA BCDByte1            ;
LB6E7:  LDA #$00                ;3rd byte is always 0.
LB6E9:  STA BCDByte2            ;

LB6EB:  JSR ConvertToBCD        ;($A753)Convert binary word to BCD.
LB6EE:  JSR ClearBCDLeadZeros   ;($A764)Remove leading zeros from BCD value.

LB6F1:  LDY #$00                ;
LB6F3:LDA TempBuffer,X        ;Transfer contents of BCD buffer to work buffer.
LB6F6:  STA WorkBuffer,Y        ;
LB6F9:  INY                     ;BCD buffer is backwards so it needs to be
LB6FA:  DEX                     ;written in reverse into the work buffer.
LB6FB:  BPL LB6F3                   ;
LB6FD:  RTS                     ;

;----------------------------------------------------------------------------------------------------

JmpDoPLRL:
LB6FE:  LDA #$01                ;Start with a single byte in the buffer.
LB700:  STA SubBufLength        ;

LB703:  LDA GenWrd00UB          ;
LB705:  BNE LB70C                   ;Is the numeric value greater than 1?
LB707:  LDX GenWrd00LB          ;
LB709:  DEX                     ;If so, add an 's' to the end of the buffer.
LB70A:  BEQ EndPlrl             ;

LB70C:LDA #$1C                ;'s' character.
LB70E:  STA WorkBuffer          ;

LB711:  LDY #$01                ;Increment buffer size.
LB713:  INC SubBufLength        ;
LB716:  JMP WorkBufEndChar      ;($B6D0)Place termination character on work buffer.

EndPlrl:
LB719:  LDY #$00                ;
LB71B:  JMP WorkBufEndChar      ;($B6D0)Place termination character on work buffer.

;----------------------------------------------------------------------------------------------------

DoPNTS:
LB71E:  LDY #$00                ;BCD value is 5 bytes max.
LB720:  LDA #$05                ;
LB722:  BNE LB72D                   ;Branch always.

DoAMTP:
LB724:  JSR BinWordToBCD        ;($B6DA)Convert word in $00/$01 to BCD.

LB727:  LDA SubBufLength        ;
LB72A:  CLC                     ;Increase buffer length by 6.
LB72B:  ADC #$06                ;

LB72D:STA SubBufLength        ;Set initial buffer length.

LB730:  LDX #$05                ;
LB732:LDA PNTSTbl,X           ;
LB735:  STA WorkBuffer,Y        ;Load "Point" into work buffer.
LB738:  INY                     ;
LB739:  DEX                     ;
LB73A:  BPL LB732                   ;

LB73C:  LDA GenWrd00UB          ;
LB73E:  BNE LB745                   ;Is number to convert to BCD greater than 1? 
LB740:  LDX GenWrd00LB          ;If so, add an "s" to the end of "Point".
LB742:  DEX                     ;
LB743:  BEQ LB74E                  ;

LB745:LDA #TXT_LWR_S          ;Add "s" to the end of the buffer.
LB747:  STA WorkBuffer,Y        ;
LB74A:  INY                     ;
LB74B:  INC SubBufLength        ;Increment buffer length.
LB74E: JMP WorkBufEndChar      ;($B6D0)Place termination character on work buffer.

PNTSTbl:                        ;(Point backwards).
;              t    n    i    o    P   BLNK
LB751:  .byte $1D, $17, $12, $18, $33, $5F

;----------------------------------------------------------------------------------------------------

DoITEM:
LB757:  JSR GetDescHalves       ;($B75D)Get full description and store in work buffer.
LB75A:  JMP WorkBufEndChar      ;($B6D0)Place termination character on work buffer.

GetDescHalves:
LB75D:  LDA #$00                ;Start with first half of description.
LB75F:  STA WndDescHalf         ;

LB762:  JSR PrepGetDesc         ;($B77E)Do some prep then locate description.
LB765:  JSR UpdateDescBufLen    ;($B82B)Save desc buffer length and zero index.
LB768:  LDA #TL_BLANK_TILE1     ;
LB76A:  STA WorkBuffer,Y        ;Place a blank space between words.

LB76D:  INY                     ;
LB76E:  TYA                     ;Save pointer into work buffer.
LB76F:  PHA                     ;

LB770:  INC WndDescHalf         ;Do second half of description.
LB773:  JSR PrepGetDesc         ;($B77E)Do some prep then locate description.
LB776:  STY DescLength          ;Store length of description string.

LB779:  PLA                     ;Restore current index into the work buffer.
LB77A:  TAY                     ;
LB77B:  JMP XferTempToWork      ;($B830)Transfer temp buffer contents to work buffer.

PrepGetDesc:
LB77E:  LDA #$09                ;Set max buffer length to 9.
LB780:  STA SubBufLength        ;

LB783:  LDA #$20                ;
LB785:  STA WndOptions          ;Set some window parameters.
LB788:  LDA #$04                ;
LB78A:  STA WndParam            ;

LB78D:  LDA DescBuf             ;Load first byte from description buffer and remove upper 2 bits.
LB78F:  AND #$3F                ;
LB791:  JMP LookupDescriptions  ;($A790)Get description from tables.

DoDESC:
LB794:  JSR GetDescHalves       ;($B75D)Get full description and store in work buffer.
LB797:  JSR CheckAToAn          ;($B79D)Check if item starts with vowel and convert 'a' to 'an'.
LB79A:  JMP WorkBufEndChar      ;($B6D0)Place termination character on work buffer.

CheckAToAn:
LB79D:  JSR WorkBufShift        ;($B7CB)Shift work buffer to insert character.
LB7A0:  LDA WorkBuffer          ;Get first character in work buffer.
LB7A3:  CMP #TXT_UPR_A          ;'A'.
LB7A5:  BEQ VowelFound          ;A found?  If so, branch to add 'n'.
LB7A7:  CMP #TXT_UPR_I          ;'I'.
LB7A9:  BEQ VowelFound          ;I found?  If so, branch to add 'n'.
LB7AB:  CMP #TXT_UPR_U          ;'U'.
LB7AD:  BEQ VowelFound          ;U found?  If so, branch to add 'n'.
LB7AF:  CMP #TXT_UPR_E          ;'E'.
LB7B1:  BEQ VowelFound          ;E found?  If so, branch to add 'n'.
LB7B3:  CMP #TXT_UPR_O          ;'O'.
LB7B5:  BNE VowelNotFound       ;O found?  If so, branch to add 'n'.

VowelNotFound:
LB7B7:  LDA #TL_BLANK_TILE1     ;
LB7B9:  STA WorkBuffer          ;No vowel at start of description.  Just insert space.
LB7BC:  RTS                     ;

VowelFound:
LB7BD:  JSR WorkBufShift        ;($B7CB)Shift work buffer to insert character.
LB7C0:  LDA #TXT_LWR_N          ;'n'.
LB7C2:  STA WorkBuffer          ;Insert 'n' into work buffer.
LB7C5:  LDA #TL_BLANK_TILE1     ;
LB7C7:  STA WorkBuffer+1        ;Insert space into work buffer after 'n'.
LB7CA:  RTS                     ;

WorkBufShift:
LB7CB:  LDX #$26                ;Prepare to shift 39 bytes.

LB7CD: LDA WorkBuffer,X        ;Move buffer value over 1 byte.
LB7D0:  STA WorkBuffer+1,X      ;
LB7D3:  DEX                     ;More to shift?
LB7D4:  BPL LB7CD                   ;If so, branch to shift next byte.

LB7D6:  INY                     ;Done shifting. Buffer is now 1 byte longer.
LB7D7:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DoSPEL:
LB7D8:  LDA #$09                ;Max. buffer length is 9.
LB7DA:  STA SubBufLength        ;

LB7DD:  LDA DescBuf             ;Get spell description byte.
LB7DF:  JSR WndGetSpellDesc     ;($A7EB)Get spell description.
LB7E2:  JSR UpdateDescBufLen    ;($B82B)Save desc buffer length and zero index.
LB7E5:  JMP WorkBufEndChar      ;($B6D0)Place termination character on work buffer.

;----------------------------------------------------------------------------------------------------

DoCOPY:
LB7E8:  LDX #$00                ;Start at beginning of buffers.

LB7EA: LDA DescBuf,X           ;Copy description buffer byte into work buffer.
LB7EC:  STA WorkBuffer,X        ;
LB7EF:  INX                     ;
LB7F0:  CMP #TXT_SUBEND         ;End of buffer reached? If not, branch to copy more.
LB7F2:  BNE LB7EA               ;

LB7F4:  LDX #$00                ;Reset index.
LB7F6:  JMP WorkBufDone         ;($B667)Done building work buffer.

;----------------------------------------------------------------------------------------------------

DoNAME:
LB7F9:  JSR NameToNameBuf       ;($B87F)Copy all 8 name bytes to name buffer.
LB7FC:  JSR NameBufToWorkBuf    ;($B81D)Copy name buffer to work buffer.

BufFinished:
LB7FF:  LDX #$00                ;Zero out index.
LB801:  JMP WorkBufDone         ;($B667)Done building work buffer.

;----------------------------------------------------------------------------------------------------

DoENMY:
LB804:  LDA EnNumber            ;Get current enemy number.
LB806:  JSR GetEnName           ;($B89F)Put enemy name into name buffer.
LB809:  JSR NameBufToWorkBuf    ;($B81D)Copy name buffer to work buffer.
LB80C:  JMP BufFinished         ;($B7FF)Finish building work buffer.

DoENM2:
LB80F:  LDA EnNumber            ;Get current enemy number.
LB811:  JSR GetEnName           ;($B89F)Put enemy name into name buffer.
LB814:  JSR NameBufToWorkBuf    ;($B81D)Copy name buffer to work buffer.
LB817:  JSR CheckAToAn          ;($B79D)Check if item starts with vowel and convert 'a' to 'an'.
LB81A:  JMP BufFinished         ;($B7FF)Finish building work buffer.

;----------------------------------------------------------------------------------------------------

NameBufToWorkBuf:
LB81D:  LDX #$00                ;Zero out index.
LB81F: LDA NameBuffer,X        ;Copy name buffer byte to work buffer.
LB822:  STA WorkBuffer,X        ;

LB825:  INX                     ;
LB826:  CMP #TXT_SUBEND         ;Has end of buffer marker been reached?
LB828:  BNE LB81F               ;If not, branch to copy another byte.
LB82A:  RTS                     ;

;----------------------------------------------------------------------------------------------------

UpdateDescBufLen:
LB82B:  STY DescLength          ;Save length of description buffer.
LB82E:  LDY #$00                ;Zero index.

;----------------------------------------------------------------------------------------------------

XferTempToWork:
LB830:  LDX DescLength          ;Is there data to transfer?
LB833:  BEQ NoXfer              ;If not, branch to exit.

LB835:  LDA #$00                ;Start current index at 0.
LB837:  STA ThisTempIndex       ;
LB839:  LDX SubBufLength        ;X stores end index.

LB83C: LDA TempBuffer-1,X      ;Transfer temp buffer byte into work buffer.
LB83F:  STA WorkBuffer,Y        ;

LB842:  DEX                     ;
LB843:  INY                     ;Update indexes.
LB844:  INC ThisTempIndex       ;

LB846:  LDA ThisTempIndex       ;At end of buffer?
LB848:  CMP DescLength          ;
LB84B:  BNE LB83C               ;If not, branch to get another byte.
LB84D:  RTS                     ;

NoXfer:
LB84E:  DEY                     ;Nothing to transfer. Decrement index and exit.
LB84F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ClearDialogOutBuf:
LB850:  LDX #$00                ;Base of buffer.
LB852:  LDA #TL_BLANK_TILE1     ;Blank tile pattern table index.

LB854: STA DialogOutBuf,X      ;Loop to load blank tiles into the dialog out buffer.
LB857:  INX                     ;
LB858:  CPX #$B0                ;Have 176 bytes been written?
LB85A:  BCC LB854                   ;If not, branch to continue writing.
LB85C:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DialogToScreenBuf:
LB85D:  LDA #$08                ;Total rows=8.
LB85F:  STA RowsRemaining       ;

LB861:  LDX #$00                ;Zero out WinBufRAM index.
LB863:  LDY #$00                ;Zero out DialogOutBuf index.

NewDialogRow:
LB865:  LDA #$16                ;Total columns = 22.
LB867:  STA ColsRemaining       ;

CopyDialogByte:
LB869:  LDA DialogOutBuf,Y      ;Copy dialog buffer to background screen buffer.
LB86C:  STA WinBufRAM+$0265,X   ;

LB86F:  INX                     ;Increment screen buffer index.
LB870:  INY                     ;Increment dialog buffer index.

LB871:  DEC ColsRemaining       ;Are there stil characters left in current row?
LB873:  BNE CopyDialogByte      ;If so, branch to get next character.

LB875:  TXA                     ;
LB876:  CLC                     ;Move to next row in WinBufRAM by adding
LB877:  ADC #$0A                ;10 to the WinBufRAM index.
LB879:  TAX                     ;

LB87A:  DEC RowsRemaining       ;One more row completed.
LB87C:  BNE NewDialogRow        ;More rows left to get? If so, branch to get more.
LB87E:  RTS                     ;

;----------------------------------------------------------------------------------------------------

NameToNameBuf:
LB87F:  LDY #$00                ;Zero indexes.
LB881:  LDX #$00                ;

LB883: LDA DispName0,X         ;
LB885:  STA NameBuffer,Y        ;Copy name 2 bytes at a time into name buffer.
LB888:  LDA DispName4,X         ;
LB88B:  STA NameBuffer+4,Y      ;

LB88E:  INX                     ;Increment namme index.
LB88F:  INY                     ;Increment buffer index.

LB890:  CPY #$04                ;Has all 8 bytes been copied?
LB892:  BNE LB883               ;If not, branch to copy 2 more bytes.

LB894:  LDY #$08                ;Start at last index in name buffer.
LB896:  JSR FindNameEnd         ;($B8D9)Find index of last character in name buffer.

EndNameBuf:
LB899:  LDA #TXT_SUBEND         ;
LB89B:  STA NameBuffer,Y        ;Put end of buffer marker after last character in name buffer.
LB89E:  RTS                     ;

;----------------------------------------------------------------------------------------------------

GetEnName:
LB89F:  CLC                     ;
LB8A0:  ADC #$01                ;Increment enemy number and save it on the stack.
LB8A2:  PHA                     ;

LB8A3:  LDA #$00                ;Start with first half of name.
LB8A5:  STA WndDescHalf         ;

LB8A8:  LDA #$0B                ;Max buf length of first half of name is 11 characters.
LB8AA:  STA SubBufLength        ;

LB8AD:  PLA                     ;Restore enemy number.
LB8AE:  JSR GetEnDescHalf       ;($A801)Get first half of enemy name.

LB8B1:  LDY #$00                ;Start at beginning of name buffer.
LB8B3:  JSR AddTempBufToNameBuf ;($B8EA)Add temp buffer to name buffer.
LB8B6:  JSR FindNameEnd         ;($B8D9)Find index of last character in name buffer.

LB8B9:  LDA #TL_BLANK_TILE1     ;Store a blank tile after first half.
LB8BB:  STA NameBuffer,Y        ;

LB8BE:  INY                     ;
LB8BF:  TYA                     ;Move to next spot in name buffer and store the index.
LB8C0:  PHA                     ;

LB8C1:  INC WndDescHalf         ;Move to second half of enemy name.

LB8C4:  LDA #$09                ;Max buf length of second half of name is 9 characters.
LB8C6:  STA SubBufLength        ;

LB8C9:  LDA DescEntry           ;Not used in this set of functions.
LB8CB:  JSR GetEnDescHalf       ;($A801)Get second half of enemy name.

LB8CE:  PLA                     ;Restore index to end of namme buffer.
LB8CF:  TAY                     ;

LB8D0:  JSR AddTempBufToNameBuf ;($B8EA)Add temp buffer to name buffer.
LB8D3:  JSR FindNameEnd         ;($B8D9)Find index of last character in name buffer.
LB8D6:  JMP EndNameBuf          ;($B899)Put end of buffer character in name buffer.

;----------------------------------------------------------------------------------------------------

FindNameEnd:
LB8D9:  LDA NameBuffer-1,Y      ;Sart at end of name buffer.

LB8DC:  CMP #TL_BLANK_TILE2     ;Is current character not a blank space?
LB8DE:  BEQ LB8E4                   ;
LB8E0:  CMP #TL_BLANK_TILE1     ;
LB8E2:  BNE LB8E9                  ;If not, branch to end.  Last character found.

LB8E4: DEY                     ;Blank character space found.
LB8E5:  BMI LB8E9                   ;If no characters in buffer, branch to end.
LB8E7:  BNE FindNameEnd         ;If more characters in buffer, branch to process next character.
LB8E9: RTS                     ;

;----------------------------------------------------------------------------------------------------

AddTempBufToNameBuf:
LB8EA:  LDX SubBufLength        ;Get pointer to end of temp buffer.

LB8ED: LDA TempBuffer-1,X      ;Append temp buffer to name buffer.
LB8F0:  STA NameBuffer,Y        ;

LB8F3:  INY                     ;Increment index in name buffer.
LB8F4:  DEX                     ;Decrement index in temp buffer.

LB8F5:  BNE LB8ED               ;More byte to append? if so branch to do more.
LB8F7:  RTS                     ;
LB8F8:  RTS                     ;

;----------------------------------------------------------------------------------------------------

CheckBetweenWords:
LB8F9:  CMP #TXT_SUBEND         ;End of buffer marker.
LB8FB:  BCS NonWordChar         ;
LB8FD:  CMP #TL_BLANK_TILE1     ;Blank space.
LB8FF:  BEQ NonWordChar         ;
LB901:  CMP #TXT_PERIOD         ;"."(period).
LB903:  BEQ NonWordChar         ;
LB905:  CMP #TXT_COMMA          ;","(comma).
LB907:  BEQ NonWordChar         ;
LB909:  CMP #TXT_APOS           ;"'"(apostrophe).
LB90B:  BEQ NonWordChar         ;
LB90D:  CMP #TXT_PRD_QUOTE      ;".'"(Period end-quote).
LB90F:  BEQ NonWordChar         ;

LB911:  SEC                     ;Alpha-numberic character found. Set carry and return.
LB912:  RTS                     ;

NonWordChar:
LB913:  CLC                     ;Non-word character found. Clear carry and return.
LB914:  RTS                     ;

;----------------------------------------------------------------------------------------------------

CheckForNewLine:
LB915:  LDA WndXPosAW           ;Will this word extend to the end of the current text row?
LB918:  CMP #$16                ;If so, branch to move to the next line.
LB91A:  BCS MoveToNextLine      ;($B924)Move to the next line in the text window.
LB91C:  RTS                     ;

DoNewline:
LB91D:  LDA WndTxtXCoord        ;Update position after text word with current
LB91F:  STA WndXPosAW           ;cursor position.
LB922:  BEQ NewlineEnd          ;At beginning of text line? If so, branch to exit.

MoveToNextLine:
LB924:  LDX WndTxtYCoord        ;Move to the next line in the text window.
LB926:  INX                     ;

LB927:  CPX #$08                ;Are we at or beyond the last row in the dialog box?
LB929:  BCS ScrollDialog        ;If so, branch to scroll the dialog window.

LB92B:  LDA TxtLineSpace        ;
LB92E:  LSR                     ;
LB92F:  LSR                     ;It looks like there used to be some code for controlling
LB930:  EOR #$03                ;how many lines to skip when going to a new line. The value
LB932:  CLC                     ;in TxtLineSpace is always #$08 so the line always increments
LB933:  ADC WndTxtYCoord        ;by 1.
LB935:  STA WndTxtYCoord        ;

LineDone:
LB937:  LDA TxtIndent           ;
LB93A:  STA WndXPosAW           ;Add the indent value to the cursor X position.
LB93D:  STA WndTxtXCoord        ;

LB93F:  CLC                     ;Clear carry to indicate the line was incremented.

NewlineEnd:
LB940:  RTS                     ;End line increment.

;----------------------------------------------------------------------------------------------------

ScrollDialog:
LB941:  JSR Scroll1Line         ;($B967)Scroll dialog text up by one line.

LB944:  LDA TxtLineSpace        ;Is text double spaced?
LB947:  CMP #$04                ;If so, scroll up an additional line.
LB949:  BNE ScrollUpdate        ;Else update display with scrolled text.
LB94B:  JSR Scroll1Line         ;($B967)Scroll dialog text up by one line.

ScrollUpdate:
LB94E:  LDA #$13                ;Start dialog scrolling at line 19 on the screen.
LB950:  STA DialogScrlY         ;

LB953:  LDA #$00                ;Zero out buffer index.
LB955:  STA DialogScrlInd       ;

LB958:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.

LB95B: JSR Display2ScrollLines ;($B990)Display two scrolled lines on screen.
LB95E:  LDA DialogScrlY         ;
LB961:  CMP #$1B                ;Has entire dialog window been updated?
LB963:  BCC LB95B                   ;If not, branch to update more.
LB965:  BCS LineDone            ;($B937)Scroll done, branch to exit.

Scroll1Line:
LB967:  LDX #$00                ;Prepare to scroll dialog text.

ScrollDialogLoop:
LB969:  LDA DialogOutBuf+$16,X  ;Get byte to move up one row.
LB96C:  AND #$7F                ;
LB96E:  CMP #$76                ;Is it a text byte?
LB970:  BCS NextScrollByte      ;If not, branch to skip moving it up.

LB972:  PHA                     ;Get byte to be replaced.
LB973:  LDA DialogOutBuf,X      ;
LB976:  AND #$7F                ;
LB978:  CMP #$76                ;Is it a text byte?
LB97A:  PLA                     ;
LB97B:  BCS NextScrollByte      ;If not, branch to skip replacing byte.

LB97D:  STA DialogOutBuf,X      ;Move text byte up one row.

NextScrollByte:
LB980:  INX                     ;Increment to next byte.
LB981:  CPX #$9A                ;Have all the bytes been moved up?
LB983:  BNE ScrollDialogLoop    ;If not, branch to get next dialog byte.

_ClearDialogOutBuf:
LB985:  LDA #TL_BLANK_TILE1     ;Blank tile,
LB987: STA DialogOutBuf,X      ;Write blank tiles to the entire text buffer.
LB98A:  INX                     ;
LB98B:  CPX #$B0                ;Has 176 bytes been written?
LB98D:  BNE LB987               ;If not, branch to write more.
LB98F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

Display2ScrollLines:
LB990:  JSR Display1ScrollLine  ;($B9A0)Write one line of scrolled text to the screen.
LB993:  INC DialogScrlY         ;Move to next dialog line to scroll up.
LB996:  JSR Display1ScrollLine  ;($B9A0)Write one line of scrolled text to the screen.
LB999:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
LB99C:  INC DialogScrlY         ;Move to next dialog line to scroll up.
LB99F:  RTS                     ;

Display1ScrollLine:
LB9A0:  LDA DialogScrlY         ;
LB9A3:  STA ScrnTxtYCoord       ;Set indexes to the beginning of the line to scroll.
LB9A6:  LDA #$05                ;Dialog line starts on 5th screen tile.
LB9A8:  STA ScrnTxtXCoord       ;

DisplayScrollLoop:
LB9AB:  LDX DialogScrlInd       ;
LB9AE:  LDA DialogOutBuf,X      ;Get dialog buffer byte to update.
LB9B1:  STA PPUDataByte         ;Put it in the PPU buffer.
LB9B3:  JSR WndCalcPPUAddr      ;($ADC0)Calculate PPU address for window/text byte.
LB9B6:  JSR AddPPUBufEntry      ;($C690)Add data to PPU buffer.

LB9B9:  INC DialogScrlInd       ;
LB9BC:  INC ScrnTxtXCoord       ;Update buffer pointer and x cursor position.
LB9BF:  LDA ScrnTxtXCoord       ;

LB9C2:  CMP #$1B                ;Have all 22 text byte in the line been scrolled up?
LB9C4:  BNE DisplayScrollLoop   ;If not, branch to do the next one.
LB9C6:  RTS                     ;

;----------------------------------------------------------------------------------------------------

TextToPPU:
LB9C7:  PHA                     ;Save word buffer character.

LB9C8:  LDA WndTxtXCoord        ;Make sure x position before and after a word are the same.
LB9CA:  STA WndXPosAW           ;

LB9CD:  JSR CheckForNewLine     ;($B915)Move text to new line, if necessary.

LB9D0:  LDA WndTxtYCoord        ;Get row number.
LB9D2:  JSR CalcWndYByteNum     ;($BAA6)Calculate the byte number of row start in dialog window.
LB9D5:  ADC WndTxtXCoord        ;Add x position to get final buffer index value.
LB9D7:  TAX                     ;Save the index in X.

LB9D8:  PLA                     ;Restore the word buffer character.
LB9D9:  CMP #TL_BLANK_TILE1     ;Is it a blank tile?
LB9DB:  BEQ CheckXCoordIndent   ;If so, branch to check if the x position is at the indent mark.

LB9DD:  CMP #TXT_OPN_QUOTE      ;Is character an open quote?
LB9DF:  BNE CheckNextBufByte    ;If so, branch to skip any following spaces.

LB9E1:  LDY WndTxtXCoord        ;
LB9E3:  CPY #$01                ;Is the X coord at the indent?
LB9E5:  BNE CheckNextBufByte    ;If so, branch to skip any following spaces.

LB9E7:  DEY                     ;Move back a column to line things up properly.
LB9E8:  STY WndTxtXCoord        ;
LB9EA:  DEX                     ;
LB9EB:  JMP CheckNextBufByte    ;($B9F5)Check next buffer byte.

CheckXCoordIndent:
LB9EE:  LDY WndTxtXCoord        ;Is X position at the indent mark?
LB9F0:  CPY TxtIndent           ;
LB9F3:  BEQ EndTextToPPU        ;If so, branch to end.

CheckNextBufByte:
LB9F5:  PHA                     ;Save the word buffer character.
LB9F6:  LDA DialogOutBuf,X      ;Get next word in Dialog buffer
LB9F9:  STA PPUDataByte         ;and prepare to save it in the PPU.
LB9FB:  TAY                     ;
LB9FC:  PLA                     ;Restore original text byte. Is it a blank tile?
LB9FD:  CPY #TL_BLANK_TILE1     ;If so, branch.  This keeps the indent even.
LB9FF:  BNE LBA06

LBA01:  STA DialogOutBuf,X      ;Store original character in PPU data byte.
LBA04:  STA PPUDataByte         ;

LBA06: LDA TxtIndent           ;Is the text indented?
LBA09:  BEQ CalcTextWndPos      ;If not, branch to skip text SFX.

LBA0B:  LDA PPUDataByte         ;Is current PPU data byte a window non-character tile?
LBA0D:  CMP #TL_BLANK_TILE1     ;
LBA0F:  BCS CalcTextWndPos      ;If so, branch to skip text SFX.

LBA11:  LDA WndTxtXCoord        ;
LBA13:  LSR                     ;Only play text SFX every other printable character.
LBA14:  BCC CalcTextWndPos      ;

LBA16:  LDA #SFX_TEXT           ;Text SFX.
LBA18:  BRK                     ;
LBA19:  .byte $04, $17          ;($81A0)InitMusicSFX, bank 1.

CalcTextWndPos:
LBA1B:  LDA WndTxtXCoord        ;
LBA1D:  CLC                     ;Dialog text columns start on the 5th screen column.
LBA1E:  ADC #$05                ;Need to add current dialog column to this offset.
LBA20:  STA ScrnTxtXCoord       ;

LBA23:  LDA WndTxtYCoord        ;
LBA25:  CLC                     ;Dialog text lines start on the 19th screen line.
LBA26:  ADC #$13                ;Need to add current dialog line to this offset.
LBA28:  STA ScrnTxtYCoord       ;

LBA2B:  JSR WndCalcPPUAddr      ;($ADC0)Calculate PPU address for window/text byte.
LBA2E:  JSR AddPPUBufEntry      ;($C690)Add data to PPU buffer.

LBA31:  LDX MessageSpeed        ;Load text speed to use as counter to slow text.
LBA33: JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
LBA36:  DEX                     ;Delay based on message speed.
LBA37:  BPL LBA33                   ;Loop to slow text speed.

LBA39:  INC WndTxtXCoord        ;Set pointer to X position for next character.

EndTextToPPU:
LBA3B:  RTS                     ;Done witing text character to PPU.

;----------------------------------------------------------------------------------------------------

;This code does not appear to be used.  It looks at a text byte and sets the carry if the character
;is a lowercase vowel or uppercase or a non-alphanumeric character. It clears the carry otherwise.

LBA3C:  LDA PPUDataByte         ;Prepare to look through vowel table below.
LBA3E:  LDX #$04                ;

LBA40: CMP VowelTbl,X          ;Is text character a lowercase vowel?
LBA43:  BEQ TextSetCarry        ;If so, branch to set carry and exit.
LBA45:  DEX                     ;Done looking through vowel table?
LBA46:  BPL LBA40                   ;If not, branch to look at next entry.

LBA48:  CMP #$24                ;Lowercase letters.
LBA4A:  BCC TextClearCarry      ;Is character lower case? If so, branch to clear carry.

LBA4C:  CMP #$56                ;non-alphanumeric characters.
LBA4E:  BCC TextSetCarry        ;If uppercase of other character, set carry.

TextClearCarry:
LBA50:  CLC                     ;Clear carry and return.
LBA51:  RTS                     ;

TextSetCarry:
LBA52:  SEC                     ;Set carry and return.
LBA53:  RTS                     ;

VowelTbl:
.incbin "bin/Bank01/VowelTbl.bin"
DoWait:
LBA59:  JSR TxtCheckInput       ;($BA97)Check for player button press.
LBA5C:  BNE TxtBtnPressed       ;Has A or B been pressed? If so, branch.

LBA5E:  LDA #$10                ;Initialize animation with down arrow visible.
LBA60:  STA FrameCounter        ;

TxtWaitLoop:
LBA62:  JSR TxtWaitAnim         ;($BA76)
LBA65:  JSR WaitForNMI          ;($FF74)Wait for VBlank interrupt.
LBA68:  JSR TxtCheckInput       ;($BA97)Check for player button press.
LBA6B:  BEQ TxtWaitLoop         ;Has A or B been pressed? If not, branch to loop.

TxtBtnPressed:
LBA6D:  JSR TxtClearArrow       ;($BA80)Clear down arrow animation.
LBA70:  LDA TxtIndent           ;
LBA73:  STA WndTxtXCoord        ;Start a new line with any active indentation.
LBA75:  RTS                     ;

TxtWaitAnim:
LBA76:  LDX #$43                ;Down arrow tile.
LBA78:  LDA FrameCounter        ;
LBA7A:  AND #$1F                ;Get bottom 5 bits of frame counter.
LBA7C:  CMP #$10                ;Is value >= 16?
LBA7E:  BCS LBA82                   ;If so, branch to show down arrow tile.

TxtClearArrow:
LBA80:  LDX #TL_BLANK_TILE1     ;Blank tile.

LBA82: STX PPUDataByte         ;Prepare to load arrow animation tile into PPU.

LBA84:  LDA #$10                ;Place wait animation tile in the middle X position on the screen.
LBA86:  STA ScrnTxtXCoord       ;

LBA89:  LDA WndTxtYCoord        ;
LBA8B:  CLC                     ;Dialog window starts 19 tiles from top of screen.
LBA8C:  ADC #$13                ;This converts window Y coords to screen Y coords.
LBA8E:  STA ScrnTxtYCoord       ;

LBA91:  JSR WndCalcPPUAddr      ;($ADC0)Calculate PPU address for window/text byte.
LBA94:  JMP AddPPUBufEntry      ;($C690)Add data to PPU buffer.

TxtCheckInput:
LBA97:  JSR GetJoypadStatus     ;($C608)Get input button presses.
LBA9A:  LDA JoypadBtns          ;Get joypad button presses.
LBA9C:  AND #IN_A_OR_B          ;Mask off everything except A and B buttons.
LBA9E:  RTS                     ;

;----------------------------------------------------------------------------------------------------

IncDialogPtr:
LBA9F:  INC DialogPtrLB         ;
LBAA1:  BNE LBAA5                   ;Increment dialog pointer.
LBAA3:  INC DialogPtrUB         ;
LBAA5: RTS                     ;

;----------------------------------------------------------------------------------------------------

CalcWndYByteNum:
LBAA6:  STA TxtRowNum           ;Store row number in lower byte of multiplicand word.
LBAA8:  LDA #$00                ;
LBAAA:  STA TxtRowStart         ;Upper byte is always 0. Always start at beginning of row.

LBAAC:  LDX #TxtRowNum          ;Index to multiplicand word.
LBAAE:  LDA #$16                ;22 text characters per line.
LBAB0:  JSR IndexedMult         ;($A6EB)Find buffer index for start of row.

LBAB3:  LDA TxtRowNum           ;
LBAB5:  CLC                     ;Store results in A and return.
LBAB6:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;Item descriptions, first table, first half.
ItemNames11TbL:
.incbin "bin/Bank01/ItemNames11TbL.bin"
ItemNames21TbL:
.incbin "bin/Bank01/ItemNames21TbL.bin"
ItemNames12TbL:
.incbin "bin/Bank01/ItemNames12TbL.bin"
ItemNames22TbL:
.incbin "bin/Bank01/ItemNames22TbL.bin"
EnNames1Tbl:
.incbin "bin/Bank01/EnNames1Tbl.bin"
EnNames2Tbl:
.incbin "bin/Bank01/EnNames2Tbl.bin"
WndCostTblPtr:
LBE0E:  .word WndCostTbl        ;($BE10)Pointer to table below.

WndCostTbl:
.incbin "bin/Bank01/WndCostTbl.bin"

;----------------------------------------------------------------------------------------------------

SpellNameTbl:
.incbin "bin/Bank01/SpellNameTbl.bin"

.ifndef namegen
    ;Unused.
    LBE9F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF 
    LBEAF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBEBF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBECF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBEDF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBEEF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBEFF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF0F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF1F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF2F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF3F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF4F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF5F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF6F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF7F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF8F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBF9F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBFAF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBFBF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    LBFCF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
.endif

;----------------------------------------------------------------------------------------------------

NMI:
RESET:
IRQ:
LBFD8:  SEI                     ;Disable interrupts.
LBFD9:  INC MMCReset1           ;Reset MMC1 chip.
LBFDC:  JMP _DoReset            ;($FF8E)Continue with the reset process.

;                   D    R    A    G    O    N    _    W    A    R    R    I    O    R    _
LBFDF:  .byte $80, $44, $52, $41, $47, $4F, $4E, $20, $57, $41, $52, $52, $49, $4F, $52, $20
LBFEF:  .byte $20, $56, $DE, $30, $70, $01, $04, $01, $0F, $07, $00 

LBFFA:  .word NMI               ;($BFD8)NMI vector.
LBFFC:  .word RESET             ;($BFD8)Reset vector.
LBFFE:  .word IRQ               ;($BFD8)IRQ vector.

