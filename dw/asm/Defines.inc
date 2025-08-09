;-------------------------------------[General Purpose Variables]------------------------------------

GenByte00 = $00     ;General use byte.
GenByte01 = $01     ;General use byte.

GenPtr00 = $00     ;General use pointer.
GenPtr00LB = $00     ;General use pointer, lower byte.
GenPtr00UB = $01     ;General use pointer, upper byte.

GenWrd00 = $00     ;General use word.
GenWrd00LB = $00     ;General use word, lower byte.
GenWrd00UB = $01     ;General use word, upper byte.

GenByte22 = $22     ;General use byte.

GenPtr22 = $22     ;General use pointer.
GenPtr22LB = $22     ;General use pointer, lower byte.
GenPtr22UB = $23     ;General use pointer, upper byte.

GenByte24 = $24     ;General use byte.
GenByte25 = $25     ;General use byte.

NotUsed26 = $26     ;Byte written to but never read.
NotUsed27 = $27     ;Byte written to but never read.

GenByte2C = $2C     ;General use byte.

GenByte3C = $3C     ;General use byte.
GenByte3D = $3D     ;General use byte.

GenPtr3C = $3C     ;General use pointer.
GenPtr3CLB = $3C     ;General use pointer, lower byte.
GenPtr3CUB = $3D     ;General use pointer, upper byte.

GenWord3C = $3C     ;General use word.
GenWord3CLB = $3C     ;General use word, lower byte.
GenWord3CUB = $3D     ;General use word, upper byte.

GenByte3E = $3E     ;General use byte.
GenByte3F = $3F     ;General use byte.

GenPtr3E = $3E     ;General use pointer.
GenPtr3ELB = $3E     ;General use pointer, lower byte.
GenPtr3EUB = $3F     ;General use pointer, upper byte.

GenWord3E = $3E     ;General use word.
GenWord3ELB = $3E     ;General use word, lower byte.
GenWord3EUB = $3F     ;General use word, upper byte.

GenByte42 = $42     ;General use byte.
GenByte43 = $43     ;General use byte.

GenPtr42 = $42     ;General use pointer.
GenPtr42LB = $42     ;General use pointer, lower byte.
GenPtr42UB = $43     ;General use pointer, upper byte.

GenWord42 = $42     ;General use word.
GenWord42LB = $42     ;General use word, lower byte.
GenWord42UB = $43     ;General use word, upper byte.

;-----------------------------------------[Variable Defines]-----------------------------------------

EnDamage = $00     ;Amount of damage player caused to the enemy. Subtracted from HP.
PlyrDamage = $00     ;Amount of damage enemy caused to the player. Subtracted from HP.
DmgNotUsed = $01     ;Always set to 0.
FightExpLB = $00     ;Experience gained from fight, lower byte.
FightExpUB = $01     ;Experience gained from fight, upper byte.
FightGoldLB = $00     ;Gold gained from fight, lower byte.
FightGoldUB = $01     ;Gold gained from fight, upper byte.
AmountLB = $00     ;Calculated amount used in text, lower byte.
AmountUB = $01     ;Calculated amount used in text, upper byte.

TrsrGoldLB = $00     ;Lower byte of gold received trom treasure chest.
TrsrGoldUB = $01     ;Upper byte of gold received trom treasure chest.
NMIStatus = $02     ;#$00 = in NMI(VBlank).
PPUEntCount = $03     ;Number of entries load from PPU buffer to PPU.
PPUBufCount = $04     ;Number of bytes to load from PPU buffer to PPU.
ScrollX = $05     ;PPU scroll x position.
ActiveNmTbl = $06     ;Active name table $#00= nametable0, #$01=nametable1.
ScrollY = $07     ;PPU scroll y position.
PPUDataByte = $08     ;Data byte to be stored in PPU.
IsEnMirrored = $09     ;#$80=Enemy sprites mirrored, #$00=Enemy sprites not mirrored.
PPUBufPtr = $0A     ;Pointer to RAM buffer for PPU image.
PPUBufPtrLB = $0A     ;Pointer to RAM buffer for PPU image, lower byte.
PPUBufPtrUB = $0B     ;Pointer to RAM buffer for PPU image, upper byte.
PPUAddrLB = $0A     ;Target address for PPU write, lower byte.
PPUAddrUB = $0B     ;Target address for PPU write, upper byte.
PalPtrLB = $0C     ;Pointer to PPU palette data, lower byte.
PalPtrUB = $0D     ;Pointer to PPU palette data, upper byte.

XPosFromCenter = $0F     ;Tile X position with respect to center of display. Signed.
YPosFromCenter = $10     ;Tile Y position with respect to center of display. Signed.

ShakeX = $0F     ;Scroll X offset during screen shake after player damage.
ShakeY = $10     ;Scroll Y offset during screen shake after player damage.

MapDatPtr = $11     ;Pointer to base address of map data.
MapDatPtrLB = $11     ;Pointer to base address of map data, lower byte.
MapDatPtrUB = $12     ;Pointer to base address of map data, upper byte.
MapWidth = $13     ;Width of current map in blocks.
MapHeight = $14     ;Height of current map in blocks. 
BoundryBlock = $15     ;Block ID of for blocks beyond the map boundaries.
MapType = $16     ;#$00-over world, #$10-town/castle, #$20-cave.

CoverDatPtr = $17     ;Pointer to map covered area data.
CoverDatLB = $17     ;Pointer to map covered area data, lower byte.
CoverDatUB = $18     ;Pointer to map covered area data, upper byte.
CoverStatus = $19     ;#$00=Not covered, #$08=Under cover.

ThisTempIndex = $1A     ;Working index into temp buffer.
DescEntry = $1A     ;Entry number for item description.

TextEntry = $1A     ;Entry number within text block(0-15).
TextBlock = $1B     ;Text block number(0-18).

RowsRemaining = $1A     ;When displaying dialog, remaining rows in window.
_ColsRemaining = $1B     ;When doing window calculations, cols remaining in current row.
ColsRemaining = $1C     ;When displaying dialog, remaining chars in row.

TxtRowNum = $1A     ;Target row in dialog window.
TxtRowStart = $1B     ;Offset into target row(column).

PPURowBytesLB = $1B     ;Stores lower number of bytes un a PPU row(32).
PPURowBytesUB = $1C     ;Stores upper number of bytes un a PPU row(0).

BCDByte0 = $1A     ;
BCDByte1 = $1B     ;Used to convert binary word to BCD.
BCDByte2 = $1C     ;
BCDResult = $1D     ;Hold 1 byte result of conversion.

WndColLB = $1E     ;Number of columns in window used in mult, lower byte.
WndColUB = $1F     ;Number of columns in window used in mult, upper byte(0).

_WndCol = $20     ;Working Copy of current window column selected.
_WndRow = $21     ;Working Copy of current window row selected.

GameDatPtr = $22     ;Pointer for loading/saving game data.
GameDatPtrLB = $22     ;Pointer for loading/saving game data, lower byte.
GameDatPtrUB = $23     ;Pointer for loading/saving game data, upper byte.

PlayerDatPtr = $22     ;Pointer for loading/saving player stats.
PlayerDatPtrLB = $22     ;Pointer for loading/saving player stats, lower byte.
PlayerDatPtrUB = $23     ;Pointer for loading/saving player stats, upper byte.

WndLineBufIdx = $22     ;Index into window line buffer.
AttribBufIndex = $23     ;Index into attribute table buffer

WndTypeCopy = $23     ;Temporary copy of current window type.

NPCXCheck = $22     ;X position to check for NPC.
NPCYCheck = $23     ;Y position to check for NPC.
NPCCounter = $24     ;Counter for finding direction of character sprites.
NPCOffset = $25     ;Offset to NPC position data.
NPCNewFace = $25     ;New direction NPC should face to talk to player.
NPCNumber = $26     ;NPC being worked on.
NPCSpriteCntr = $27     ;Counter used for loading NPC sprite data.
NPCSprtRAMInd = $28     ;Index into sprite RAM for current NPC sprite.

JMPFuncPtr = $0030   ;JUMP command for IRQ function pointer.
_JMPFuncPtr = $30     ;JUMP command for IRQ function pointer.

NewPRGBank = $30     ;Stores PRG bank to switch to.
BankDatPtr = $30     ;Bank data pointer.
BankDatPtrLB = $30     ;Bank data pointer, lower byte.
BankDatPtrUB = $31     ;Bank data pointer, upper byte.
BankPtrIndex = $31     ;Stores index into BankPointers table.
BankPntr = $31     ;Bank function pointer.
BankPntrLB = $31     ;Bank function pointer, lower byte.
BankPntrUB = $32     ;Bank function pointer, upper byte.

_BankFuncDatPtr = $33     ;Bank function data pointer.
_BankFuncDatLB = $33     ;Bank function data pointer, lower byte.
_BankFuncDatUB = $34     ;Bank function data pointer, upper byte.

NMIPtr = $35     ;Used to check If MMC is being accessed during NMI.
NMIPtrLB = $35     ;Special NMI check pointer, lower byte.
NMIPtrUB = $36     ;Special NMI check pointer, upper byte.

IRQStoreA = $37     ;Temp storage for A in IRQ routine.
IRQStoreX = $38     ;Temp storage for X in IRQ routine.
IRQStoreY = $39     ;Temp storage for Y in IRQ routine.

CharXPos = $3A     ;Player's X position on current map in blocks.
CharYPos = $3B     ;Player's Y position on current map in blocks.

BufByteCntr = $3C     ;Buffer byte load counter.
_EnNumber = $3C     ;Working copy of enemy number.
CalcDamage = $3C     ;Calculated damage to player/enemy.
PlyrTempStat = $3C     ;Temporary register for the player's various stats.

CharYScrPos = $3C     ;Character sprite Y position on the screen.
CharXScrPos = $3D     ;Character sprite X position on the screen.

ShopIndex = $3C     ;Index into ShopItemsTbl for current shop items list.
WrldMapXPos = $3D     ;World map X position calculation.

LevelDatPtr = $3C     ;Pointer into BaseStatsTbl.
PalModByte = $3C     ;Added to palette data to change it in some cases.
LoadBGPal = $3D     ;#$00-skip loading BG palette, #$FF-Load BG palette.

EnSprtAttribDat = $3C     ;Attribute data for enemy sprites.
EnSprtXPos = $3D     ;X position data for enemy sprite.

NPCSpriteYOfst = $3C     ;4 sprites per NPC. Y offset of current NPC sprite tile.
NPCSpriteXOfst = $3D     ;4 sprites per NPC. X offset of current NPC sprite tile.

NPCDatPtr = $3C     ;Data pointer to NPC data.
NPCDatPtrLB = $3C     ;Data pointer to NPC data, lower byte.
NPCDatPtrUB = $3D     ;Data pointer to NPC data, upper byte.

CoveredStsNext = $3D     ;Indicates the covered status after player movement.

XPosFromLeft = $3C     ;Tile X position with respect to top left of display. 
YPosFromTop = $3E     ;Tile Y position with respect to top left of display. 

TargetResults = $3C     ;Stores results byte for target check.
XTarget = $3C     ;X position to check for item, door, etc.
YTarget = $3E     ;Y position to check for item, door, etc.

NTXPos = $3C     ;Nametable X position to modify (#$00-#$3F, spans 2 nametables).
NTYPos = $3E     ;Nametable Y position to modify (#$00-#$1E).

ROMSrcPtr = $3C     ;ROM copy source pointer.
ROMSrcPtrLB = $3C     ;ROM copy source pointer, lower byte.
ROMSrcPtrUB = $3D     ;ROM copy source pointer, upper byte.

RAMTrgtPtr = $3E     ;RAM copy target pointer.
RAMTrgtPtrLB = $3E     ;RAM copy target pointer, lower byte.
RAMTrgtPtrUB = $3F     ;RAM copy target pointer, upper byte.

MultNum1LB = $3C     ;Multiply number 1, lower byte.
MultNum1UB = $3D     ;Multiply number 1, upper byte.
MultNum2LB = $3E     ;Multiply number 2, lower byte.
MultNum2UB = $3F     ;Multiply number 2, upper byte.
MultRsltLB = $40     ;Multiply results, lower byte.
MultRsltUB = $41     ;Multiply results, upper byte.

DivNum1LB = $3C     ;Divide number 1, lower byte.
DivNmu1UB = $3D     ;Divide number 1, upper byte.
DivNum2 = $3E     ;Divide number 2.
DivNum2NU = $3F     ;Divide number 2 (not used).
DivQuotient = $3C     ;Divide results, quotient.
DivRemainder = $40     ;Divide results, remainder.

EnemyOffset = $3E     ;Offset used to get enemy from EnemyGroupsTbl.
RndGoldBits = $3E     ;Bitmask for adding random gold to found treasure chests.

SpellFlagsLB = $3E     ;Stores bit flags for first 8 spells.
SpellFlagsUB = $3F     ;Stores bit flags for last 2 spells in the LSBs.

SprtPalPtr = $3E     ;Pointer to sprite palette data.
SprtPalPtrLB = $3E     ;Pointer to sprite palette data, lower byte.
SprtPalPtrUB = $3F     ;Pointer to sprite palette data, upper byte.

NPCXPixelsLB = $3E     ;NPC X pixel coordinates, lower byte.
NPCXPixelsUB = $3F     ;NPC X pixel coordinates, upper byte.
NPCYPixelsLB = $40     ;NPC Y pixel coordinates, lower byte.
NPCYPixelsUB = $41     ;NPC Y pixel coordinates, upper byte.

SpellDescByte = $40     ;#$00-#$0A represents each one of the spells in ascending order.

BGPalPtr = $40     ;Pointer to background palette data.
BGPalPtrLB = $40     ;Pointer to background palette data, lower byte.
BGPalPtrUB = $41     ;Pointer to background palette data, upper byte.

CopyCounter = $40     ;Word used to count bytes copied from ROM to RAM.
CopyCounterLB = $40     ;Copy counter, lower byte.
CopyCounterUB = $41     ;Copy counter, upper byte.

EnDatPtr = $40     ;Enemy data pointer.
EnDatPtrLB = $40     ;Enemy data pointer, lower byte.
EnDatPtrUB = $41     ;Enemy data pointer, upper byte.

BlockDataPtr = $40     ;Pointer to block graphics data.
BlockDataPtrLB = $40     ;Pointer to block graphics data, lower byte.
BlockDataPtrUB = $41     ;Pointer to block graphics data, upper byte.

CRCCopyLB = $40     ;Copy of saved game CRC, lower byte for verification purposes.
CRCCopyUB = $41     ;Copy of saved game CRC, upper byte for verification purposes.

MapBytePtr = $40     ;Pointer to map data byte.
MapBytePtrLB = $40     ;Pointer to map data byte, lower byte.
MapBytePtrUB = $41     ;Pointer to map data byte, upper byte.

WrldMapPtr = $40     ;Pointer to overworld map row data.
WrldMapPtrLB = $40     ;Pointer to overworld map row data, lower byte.
WrldMapPtrUB = $41     ;Pointer to overworld map row data, upper byte.

WindowBlock = $40     ;#$FF-No window data at selected block.
NPCOnScreen = $41     ;#$FF-NPC on screen, #$00-NPC not on screen.

_TargetX = $42     ;Target block, X position.
_TargetY = $43     ;Target block, Y position.

ShakeCounter = $42     ;Counter used to shake the screen after the player takes damage.
BaseAttack = $42     ;Base calculation of attack damage.
AttackStat = $42     ;Copy of player/enemy attack stat.
DefenseStat = $43     ;Copy of player/enemy defense stat.

ThisNPCXPos = $42     ;Copy of current NPCs X block position on map.
ThisNPCYPos = $43     ;Copy of current NPCs y block position on map.

StatBonus = $42     ;When stat penalties are applied, any value here will 
                                ;be added in as a bonus. Potential bonus of 0-3 points.
StatPenalty = $43     ;Lower 2 bits only. stat penalties work as follows:
                                ;If bit 0 is clear -> strength is reduced by 10%.
                                ;If bit 0 is set   -> max MP is reduced by 10%.
                                ;If bit 1 is clear -> agility is reduced by 10%.
                                ;If bit 1 is set   -> max HP is reduced by 10%.

MapNumber = $45     ;Current map player is on.
JoypadBit = $46     ;LSB Contains current bit read from joypad 1.
JoypadBtns = $47     ;Captured button presses on controller 1.

XFromLeftTemp = $48     ;Temporary storage for XPosFromLeft.
YFromTopTemp = $49     ;Temporary storage for YPosFromTop.

NTBlockX = $4A     ;Nametable X block position, #$00-#$1F(1/2 X tile position).
NTBlockY = $4B     ;Nametable Y block position, #$00-#$0E(1/2 y tile position).
BlkRemoveFlgs = $4C     ;Lower nibble is flags of tiles to remove when changing a map block.
                                ;1-upper left, 2-upper right, 4-lower left, 8-lower right.
BridgeFlashCntr = $4C     ;Used to count palette flash cycles when rainbow bridge is created.
TileCounter = $4D     ;Used to count tiles when modifying blocks.
RowCounter = $4D     ;Used to count block rows when clearing out nametable on map change. 
BlockClear = $4D     ;Is always 0. Maybe had some other function in Dragon's Quest.
WndForeBack = $4D     ;#$FF=Background window, #$00=Foreground window(over another window).
NPCLoopCounter = $4E     ;Counter for controlling NPC update loops.
SpriteRAMIndex = $4E     ;Index into sprite(OAM) RAM when updating NPC sprites.
NPCROMIndex = $4E     ;Index to NPC data in PRG currently being processed.
FrameCounter = $4F     ;Normally increments every frame. used for timing.

CharLeftRight = $50     ;Controls character animations. bit 3 atlernates animations.

_NPCXPos = $0051   ;NPC X block position on current map.
_NPCYPos = $0052   ;NPC Y block position on current map.
_NPCMidPos = $0053   ;NPC offset from current tile. Upper nibble=X, lower nibble=y.

NPCXPos = $51     ;Through $8A. NPC X block position on current map. Also NPC type.
NPCYPos = $52     ;Through $8B. NPC Y block position on current map. Also NPC direction.
NPCMidPos = $53     ;Through $8C. NPC offset from current tile. Used only when moving.

GwaelinXPos = $8A     ;Princess Gwaelin's X position at the end of the game.
GwaelinYPos = $8B     ;Princess Gwaelin's Y position at the end of the game.
GwaelinOffset = $8C     ;Princess Gwaelin's moving offset at the end of the game.

NPCUpdateCntr = $8D     ;Counts 0 to 4. Used to update NPCs. #$FF=No NPCs on current map.
_CharXPos = $8E     ;Copy of player's X position.
_CharYPos = $8F     ;Copy of player's Y position.
CharXPixelsLB = $90     ;Player's X position in pixels, lower byte (CharXPos*16).
CharXPixelsUB = $91     ;Player's X position in pixels, upper byte.
IntroCounter = $91     ;Counter for intro routine.
CharYPixelsLB = $92     ;Player's Y position in pixels, lower byte (CharYPos*16).
CharYPixelsUB = $93     ;Player's Y position in pixels, upper byte.
IntroPointer = $93     ;Data pointer for intro routines.
CRCLB = $94     ;Saved game CRC value, lower byte.
CRCUB = $95     ;Saved game CRC value, upper byte.
RandNumLB = $94     ;Random number, lower byte.
RandNumUB = $95     ;Random number, upper byte.
StopNPCMove = $96     ;#$FF-Stop NPCs from moving, #$00-Allow NPCs to move.
WndColPos = $97     ;Window column position, in tiles.
WndRowPos = $98     ;Window row position, in tiles.
BlockCounter = $98     ;Counts blocks placed when putting combat background on screen.

BlockAddr = $99     ;Current block address in buffer.
BlockAddrLB = $99     ;Current block address in buffer, lower byte.
BlockAddrUB = $9A     ;Current block address in buffer, upper byte.

EnSpritePtr = $99     ;Pointer to enemy sprite data.
EnSpritePtrLB = $99     ;Pointer to enemy sprite data, lower byte.
EnSpritePtrUB = $9A     ;Pointer to enemy sprite data, upper byte.

DatPntr1 = $99     ;
DatPntr1LB = $99     ;Stores a pointer to the start of data tables.
DatPntrlUB = $9A     ;

StartSignedXPos = $9D     ;Starting X position in tiles of window row. signed from center.
WndBlockWidth = $9E     ;Block width of window being removed.

DialogPtr = $9F     ;Pointer to dialog text.
DialogPtrLB = $9F     ;Pointer to dialog text, lower byte.
DialogPtrUB = $A0     ;Pointer to dialog text, upper byte.

WndDatPtr = $9F     ;Pointer to window data.
WndDatPtrLB = $9F     ;Pointer to window data, lower byte.
WndDatPtrUB = $A0     ;Pointer to window data, upper byte.

WndFcnPtr = $00A1   ;Window function pointer.
WndFcnLB = $A1     ;Window function pointer, lower byte.
WndFcnUB = $A2     ;Window function pointer, upper byte.

DescPtr = $A1     ;Pointer used for item and window descriptions.
DescPtrLB = $A1     ;Description pointer, lower byte.
DescPtrUB = $A2     ;Description pointer, upper byte.

AttribPtr = $A1     ;Pointer used for attribute table data.
AttribPtrLB = $A1     ;attribute table pointer, lower byte.
AttribPtrUB = $A2     ;attribute table pointer, upper byte.

_DescBuf = $00A3   ;Description buffer.
DescBuf = $A3     ;Through $B4. Indexes used for item descriptions.

DispName0 = $B5     ;
DispName1 = $B6     ;First four bytes of name displayed in status window.
DispName2 = $B7     ;
DispName3 = $B8     ;
GameStarted = $B9     ;Loaded with #$FA after game started and never used again.
EndCreditCount = $BA     ;Counts the number of end credit screens that have been displayed.
ExpLB = $BA     ;Current experience points, lower byte.
ExpUB = $BB     ;Current experience points, upper byte.
GoldLB = $BC     ;Current gold, lower byte.
GoldUB = $BD     ;Current gold, upper bytee.
EqippedItems = $BE     ;Current equipped items %WWWAAASS W-weapon, A-armor, S-shield
                                ;Value  Weapon           Armor            Shield
                                ;--------------------------------------------------------------------
                                ; 000   None             None             None
                                ; 001   Bamboo Pole      Clothes          Small Shield
                                ; 010   Club             Leather Armor    Large Shield
                                ; 011   Copper Sword     Chain Mail       Silver Shield
                                ; 100   Hand Axe         Half Plate       N/A
                                ; 101   Broad Sword      Full Plate       N/A
                                ; 110   Flame Sword      Magic Armor      N/A
                                ; 111   Erdrick's Sword  Erdrick's Armor  N/A
                                
                                ;Inventory
                                ;$00=None, $01=Torch, $02=Fairy Water, $03=Wings
                                ;$04=Dragon's Scale, $05=Fairy Flute, $06=Fighter's Ring
                                ;$07=Erdrick's Token, $08=Gwaelin's Love, $09=Cursed Belt
                                ;$0A=Slver Harp, $0B=Death Necklace, $0C=Stones of Sunlight                          
                                ;$0D=Staff of Rain, $0E=Rainbow Drop, $0F=Herb(can't be used).
                                ;--------------------------------------------------------------------
InventoryKeys = $BF     ;Magic key count. Not part of regular inventory.
InventoryHerbs = $C0     ;Herb count. Not part of regular inventory.
InventoryPtr = $00C1   ;Inventory pointer.
InventorySlot12 = $C1     ;First two inventory slots.
InventorySlot34 = $C2     ;Second two inventory slots.
InventorySlot56 = $C3     ;Third two inventory slots.
InventorySlot78 = $C4     ;Fourth two inventory slots.
HitPoints = $C5     ;Current hit points.
MagicPoints = $C6     ;Current magic points.
DisplayedLevel = $C7     ;Current level, for display only.
DisplayedStr = $C8     ;Strength, for display only.
DisplayedAgi = $C9     ;Agility, for display only.
DisplayedMaxHP = $CA     ;Max hit points, for display only.
DisplayedMaxMP = $CB     ;Max magic points, for display only.
DisplayedAttck = $CC     ;Attack power, for display only.
DisplayedDefns = $CD     ;Defense power, for display only.
SpellFlags = $CE     ;Flags that keep track of the player's spells.
                                ;%00000001-Heal
                                ;%00000010-Hurt
                                ;%00000100-Sleep
                                ;%00001000-Radiant
                                ;%00010000-Stopspell
                                ;%00100000-Outside
                                ;%01000000-Return
                                ;%10000000-Repel
ModsnSpells = $CF     ;Two more spell flags and stat enhancing items.
                                ;%00000001-Healmore Spell.
                                ;%00000010-Hurtmore Spell.
                                ;%00000100-Dragonlord castle secret passage found.
                                ;%00001000-Rainbow bridge created.
                                ;%00010000-Wearing Dragon's scale.
                                ;%00100000-Wearing Fighter's ring.
                                ;%01000000-Wearing Cursed belt.
                                ;%10000000-Wearing Death necklace.

LightDiameter = $D0     ;Diameter in blocks of light around player in dungeons.                             
PPUHorzVert = $D1     ;#$00=Write PPU data in vertical column(add #$20 every write).
                                ;non-zero=Write PPU data horizontally. 
AddAttribData = $D1     ;#$00=Move attrib data to buffer. Non-zero=skip attrib table data.
                               
WndTxtXCoord = $D2     ;X coordinant of current text byte relative to the window.  
WndTxtYCoord = $D3     ;Y coordinant of current text byte relative to the window.                      

RepeatCounter = $D6     ;Counts repeated PPU entry bytes.                           
SpellToCast = $D7     ;Spell player or enemy is attempting to cast.
WndSelResults = $D7     ;Stores selection results from a window.

WndCol = $D8     ;Window colum currently selected.
WndRow = $D9     ;Window row currently selected.

RadiantTimer = $DA     ;Remaining time for radiant spell.
RepelTimer = $DB     ;Remining repel spell time.

DialogTemp = $DE     ;Dialog byte used for finding correct dialog.
DescTemp = $DE     ;Temporary storage of item description byte.
PalFlashCntr = $DE     ;Counter used when flashing palette when enemy hit.
PlayerFlags = $DF     ;Additional player flags.
                                ;%00000001-Carrying Gwaelin.
                                ;%00000010-Gwaelin returned.
                                ;%00000100-Player received a death necklace.
                                ;%00001000-Player has been beyond the throne room.
                                ;%00010000-Player stopspelled.
                                ;%00100000-Enemy stopspelled.
                                ;%01000000-Enemy asleep.
                                ;%10000000-Player asleep.

EnNumber = $E0     ;Enemy number. $00 through $27.
ThisTile = $E0     ;Current block type player is standing on.
                                
EnCurntHP = $E2     ;Enemy's current hit points.
MjArmrHP = $E3     ;Increments every movement and increments HP every
                                ;3 steps if wearing magic armor.            
StoryFlags = $E4     ;Flags that keep track of major game events.
                                ;%00000001-
                                ;%00000010-Golem defeated.
                                ;%00000100-Dragonlord defeated.
                                ;%00001000-Left throne room.
                                ;%00010000-
                                ;%00100000-
                                ;%01000000-Green dragon defeated.
                                ;%10000000-
MessageSpeed = $E5     ;#$00-fast, #$01-normal, #$02-slow.

;--------------------------------------[Sound Engine Variables]--------------------------------------

SQ1IndexLB = $E6     ;Current address to SQ1 music data.
SQ1IndexUB = $E7     ;
SQ2IndexLB = $E8     ;Current address to SQ2 music data.
SQ2IndexUB = $E9     ;
TriIndexLB = $EA     ;Current address to triangle music data.
TriIndexUB = $EB     ;
NoisIndexLB = $EC     ;Current address to noise SFX data.
NoisIndexUB = $ED     ;

SQ1ReturnLB = $EE     ;Return address for SQ1 music loop.
SQ1ReturnUB = $EF     ;
SQ2ReturnLB = $F0     ;Return address for SQ2 music loop.
SQ2ReturnUB = $F1     ;
TriReturnLB = $F2     ;Return address for triangle music loop.
TriReturnUB = $F3     ;

ChannelLength = $F4     ;#$00 it is not in use. Anything else is the remaining note time.
ChannelQuiet = $F5     ;#Amount of quiet time between notes.

SQ1Length = $F4     ;SQ1 channel in use, time left for current note.
SQ1Quiet = $F5     ;SQ1 Quiet time between notes.
SQ2Length = $F6     ;SQ2 channel in use, time left for current note.
SQ2Quiet = $F7     ;SQ2 Quiet time between notes.
TRILength = $F8     ;Triangle channel in use, time left for current note.
TRIQuiet = $F9     ;TRI Quiet time between notes.
SFXActive = $FA     ;Number of frames remaining in current SFX.
Tempo = $FB     ;Controls overall speed of music.
TempoCntr = $FC     ;Increments by Tempo every frame.
NoteOffset = $FD     ;Index offset for note to play. Makes dungeon music lower.
MusicTemp = $FE     ;Used as temp variable when doing sound calcs.
SQ2Config = $FF     ;Hold config byte for SQ2 control register $4004.

;----------------------------------------------------------------------------------------------------
                                
EnBaseAtt = $0100   ;Enemy base attack attibute.
EnBaseDef = $0101   ;Enemy base defense attribute.
EnBaseHP = $0102   ;Enemy base hit points.

EnSpell = $0103   ;Enemy spells.
                                ;The enemy spells are broken into the upper and lower nibbles.
                                ;The upper nibble controls the sleep, stopspell, heal and
                                ;healmore spells.  Bits 4 and 5 control the percent the spell
                                ;will be cast:
                                ;00=0%, 01=25%, 10=50%, 11 = 75%.
                                ;Bits 6 and 7 control which spell:
                                ;00=sleep, 01=stopspell, 10=heal, 11=healmore.
                                ;The lower nibble controls the hurt, hurtmore, fire1 and fire2
                                ;spells.  Fire2 is only used by the final boss. Bits 0 and 1
                                ;control the percent the spell will be cast:
                                ;00=0%, 01=25%, 10=50%, 11 = 75%.
                                ;Bits 2 and 3 control which spell:
                                ;00=hurt, 01=hurtmore, 10=fire1, 11=fire2.

BankFuncDatLB = $0103   ;Pointer to bank function data after BRK command, lower byte.
BankFuncDatUB = $0104   ;Pointer to bank function data after BRK command, upper byte.                               
                                
EnBaseAgi = $0104   ;Enemy base agility.
EnBaseMDef = $0105   ;Enemy base magic defense.
EnBaseExp = $0106   ;Enemy base experience.
EnBaseGld = $0107   ;Enemy base gold.
                                
Stack = $0110   ;Through $01FF. CPU stack.
SpriteRAM = $0200   ;Through $02FF. Sprite DMA RAM.
BlockRAM = $0300   ;Through $03FF. Multipurpose RAM for buffering.
TrsrArray = $0320   ;Through $039B. Array of all trasure chest data.
EnPalData = $03A0   ;Through $03AB. Palette data for current enemy.
WinBufRAM = $0400   ;Through $07BF. Window data buffer. 32 by 30 bytes.  

;--------------------------------------[Hardware defines]--------------------------------------------

PPUControl0 = $2000   ;
PPUControl1 = $2001   ;
PPUStatus = $2002   ;
SPRAddress = $2003   ;PPU hardware control registers.
SPRIOReg = $2004   ;
PPUScroll = $2005   ;
PPUAddress = $2006   ;
PPUIOReg = $2007   ;

SQ1Cntrl0 = $4000   ;
SQ1Cntrl1 = $4001   ;SQ1 hardware control registers.
SQ1Cntrl2 = $4002   ;
SQ1Cntrl3 = $4003   ;

SQ2Cntrl0 = $4004   ;
SQ2Cntrl1 = $4005   ;SQ2 hardware control registers.
SQ2Cntrl2 = $4006   ;
SQ2Cntrl3 = $4007   ;

TriangleCntrl0 = $4008   ;
TriangleCntrl1 = $4009   ;Triangle hardware control registers.
TriangleCntrl2 = $400A   ;
TriangleCntrl3 = $400B   ;

NoiseCntrl0 = $400C   ;
NoiseCntrl1 = $400D   ;Noise hardware control registers.
NoiseCntrl2 = $400E   ;
NoiseCntrl3 = $400F   ;

DMCCntrl0 = $4010   ;
DMCCntrl1 = $4011   ;DMC hardware control registers.
DMCCntrl2 = $4012   ;
DMCCntrl3 = $4013   ;

SPRDMAReg = $4014   ;Sprite RAM DMA register.
APUCommonCntrl0 = $4015   ;APU common control 1 register.
CPUJoyPad1 = $4016   ;Joypad1 register.
APUCommonCntrl1 = $4017   ;Joypad2/APU common control 2 register.

;------------------------------------------[Cartridge RAM]-------------------------------------------

MMC1Config = $6001   ;Stores configuration for MMC1.
ActiveNT0 = $6002   ;Stores number of CHR ROM bank active in nametable 0.
ActiveNT1 = $6003   ;Stores number of CHR ROM bank active in nametable 1.
ActiveBank = $6004   ;Stores number of lower PRG bank that is active.
SndEngineStat = $6005   ;If not 0, sound engine is processing.

DrgnLrdPal = $600A   ;Read only once and loads a special palette when
                                ;the dradonlord is defeated. The palette does not
                                ;seemed to be used for anything.

DoorXPos = $600C   ;Through $601A. X and y positions of doors
DoorYPos = $600D   ;Through $601B. opened on the current map.
TrsrXPos = $601C   ;Through $602A. X and y positions of treasure
TrsrYPos = $601D   ;Through $602B. chests picked up on the current map.
                                
UpdateBGTiles = $602C   ;MSB set = update on-screen background tiles.

MusicTrigger = $602E   ;Certain music spots trigger events. Only used in intro routine.
CharDirection = $602F   ;Player's facing direction, 0-up, 1-right, 2-down, 3-left.
SaveSelected = $6030   ;Save slot selected(0-2).
OpnSltSelected = $6031   ;Open game slot selected for copying a saved game into.
SaveGameCntr = $6032   

_SaveBitMask = $6034   ;Working copy of saved games bitmasks.
ValidSave1 = $6035   ;#$C8=valid saved data, slot 1, #$00=not valid.
ValidSave2 = $6036   ;#$C8=valid saved data, slot 2, #$00=not valid.
ValidSave3 = $6037   ;#$C8=valid saved data, slot 3, #$00=not valid.
SaveBitMask = $6038   ;Bit mask of valid save slots. uses 3 LSBs.
SaveNumber = $6039   ;Save file number(0-2).
ThisStrtStat = $603A   ;Determines if HP and MP are restored on start for current game.
KenMasuta2 = $603B   ;Through $6044. Stores Ken Masuta's name.
StartStatus1 = $6045   ;#$78=Full HP and MP on start, #$AB=Do not restore, Save game 1.
StartStatus2 = $6046   ;#$78=Full HP and MP on start, #$AB=Do not restore, Save game 2.
StartStatus3 = $6047   ;#$78=Full HP and MP on start, #$AB=Do not restore, Save game 3.
CurrentGameDat = $6048   ;Through $6067. Game data for current game being played.
SavedGame1 = $6068   ;Through $61A7. Save game slot 1. Data repeated 10 times.
SavedGame2 = $61A8   ;Through $62E7. Save game slot 2. Data repeated 10 times.
SavedGame3 = $62E8   ;Through $6427. Save game slot 3. Data repeated 10 times.
KenMasuta1 = $6428   ;Through $6431. Stores Ken Masuta's name.
CRCFail1 = $6432   ;CRC failures for save game 1.
CRCFail2 = $6433   ;CRC failures for save game 2.
CRCFail3 = $6434   ;CRC failures for save game 3.
Unused6435 = $6435   ;Unused variable.

;------------------------------------[Text and window Variables]-------------------------------------

WndUnused6006 = $6006   ;Unused window variable.
WndEraseHght = $6007   ;Window erase height in blocks.
WndEraseWdth = $6008   ;Window erase width in tiles.
WndErasePos = $6009   ;Window erase position in blocks, Y=upper nibble, X=lower nibble.

WndLineBuf = $6436   ;Through $6471. 60 bytes. buffers 2 window tile rows.

AttribTblBuf = $6496   ;Through $64A5. Attribute table buffer for 1 on-screen block row.

WndWidthTemp = $64A6   ;Temp copy of WndWidth.
_WndPosition = $64A7   ;Working copy of WndPosition.

WndBlkTileRow = $64A9   ;Either #$02 or #$01. Which row of block is being processed.
_WndWidth = $64AA   ;Working copy of WndWidth.
WndUnused64AB = $64AB   ;Written to but never used.
WndLineBufIndex = $64AC   ;Current index into window line buffer.
WndAtrbBufIndex = $64AD   ;Current index into attribute table buffer.
WndUnused64AE = $64AE   ;Written to but never used.

DescLength = $64AF   ;Length in bytes of description string.
IndMultByte = $64AF   ;Indexed multiplication multiplicand byte.
DialogScrlY = $64AF   ;Screen coords Y offset while scrolling dialog text.

DialogScrlInd = $64B0   ;Index into dialog buffer to write to PPU while scrolling.

IndMultNum1 = $64B0   ;Indexed multiplication, 1st multiplication byte.
IndMultNum2 = $64B1   ;Indexed multiplication, 2nd multiplication byte.

WordBufIndex = $64B4   ;Search index into word buffer.

WndNTRowOffset = $64B6   ;Tile offset in nametable row for start of window row.
WndAtribDat = $64B6   ;Attribute table data byte.

ScrnTxtXCoord = $64B6   ;X coordinant of current text byte relative to the screen.
ScrnTxtYCoord = $64B7   ;Y coordinant of current text byte relative to the screen.
WndBtnPresses = $64B8   ;Button presses captured while selection window is active.

WndThisNTRow = $64B8   ;Number of tiles for window row on this nametable.
WndNextNTRow = $64B9   ;Number of tiles for window row on next nametable.

WndPPUAddrLB = $64BA   ;Lower byte PPU address for current window tile.
WndPPUAddrUB = $64BB   ;Upper byte PPU address for current window tile.

AtribBitsOfst = $64BE   ;Offset for attrib table bits in attrib table byte(0,2,4,6).
AttribByte = $64BF   ;Attribute table data byte.

WndAttribVal = $64C1   ;Attribute table value(#$00-#$03).
_WndPPUAddrLB = $64C2   ;Working copy of nametable address, lower byte.
_WndPPUAddrUB = $64C3   ;Working copy of nametable address, upper byte.
WndAtribAdrLB = $64C4   ;Attribute table address, lower byte.
WndAtribAdrUB = $64C5   ;Attribute table address, upper byte.
DispName4 = $64C6   ;
DispName5 = $64C7   ;Last four bytes of name.
DispName6 = $64C8   ;
DispName7 = $64C9   ;

TempBuffer = $64CA   ;Through $64D5. 13 bytes. For BCD conversion and other small stuff.

WindowType = $64DC   ;Window type byte.
WorkTile = $64DD   ;Current tile pattern used for building windows.
WndCcontrol = $64DE   ;Retreived control byte from window data table.
WndParam = $64DF   ;Parameters for window, such as number of times to repeat, etc.

WndXPosAW = $64E0   ;Current X position after current word is taken into account.

WndXPos = $64E0   ;Current X position in window.
WndYPos = $64E1   ;Current Y position in window(current tile row being built).
WndCounter = $64E2   ;Counter used when building window rows.

SubBufLength = $64E2   ;Sub string buffer length.

WndWidth = $64E3   ;Window width in tiles.
WndHeightblks = $64E4   ;Window height in blocks (block is 2X2 tiles).
WndHeight = $64E5   ;Window height in tiles.
WndPosition = $64E6   ;Window screen coordinates in blocks. Y in upper nibble, X in lower.
WndColumns = $64E7   ;Window columnns. Indicates how many tiles between columns.
WndDatIndex = $64E8   ;Index into window data table.
WndRepeatIndex = $64E9   ;Index in window data to return to for variable height windows.
WndBuildRow = $64EA   ;When building window on screen, keeps track of current block height.
WndCursorHome = $64EB   ;Home position of cursor. X in upper nibble, Y in lower.
WndOptions = $64EC   ;Various window options.
WndDescHalf = $64ED   ;#$00=on first part of description, #$01=on second part.
WndThisDesc = $64EE   ;In variable height windows, index to current item description.
WndDescIndex = $64EF   ;Index into description tables.
WndUnused1 = $64F0   ;Unused window variable.

WndCursorXPos = $64F2   ;Cursor X position in tiles in current selection window.
WndCursorYPos = $64F3   ;Cursor Y position in tiles in current selection window.
WndUnused64F4 = $64F4   ;Written to but never used.
WndCursorYHome = $64F5   ;Home Y coord for cursor.
WndBuildPhase = $64F6   ;Window build phase. MSB set-phase 1, bit 6 set-phase 2.

WndUnused64FB = $64FB   ;Written to but never used.

WndNameIndex = $6504   ;Index into name string when creating player's name.
WndUnused6505 = $6505   ;Written to but never used.
WndSelNumCols = $6506   ;Number of columns for command windows and alphabet window.
WndBtnRetrig = $6507   ;Controls retrigger time for button presses in windows.

TxtLineSpace = $6509   ;Always #$08. single spaced lines.
TxtIndent = $650A   ;Number if spaces to indent text line.
WrkBufBytsDone = $650B   ;Keeps track of how many work buffer bytes have been processed.
Dialog00 = $650C   ;Set to 0 on dialog init and never changed.
WordBufLen = $650D   ;Length of word buffer.
DialogEnd = $650E   ;#$FF=dialog end.

Unused6510 = $6510   ;Written to but never read.
Unused6511 = $6511   ;Written to but never read.
Unused6512 = $6512   ;Written to but never read.
Unused6513 = $6513   ;Written to but never read.
WordBuffer = $6514   ;Through $652B. 24 bytes. Buffers a single word.
WorkBuffer = $652C   ;Through $6553. 40 bytes. Sub string work buffer.
NameBuffer = $6554   ;Through $655C. 9  bytes. Buffer for storing player's name.

DialogOutBuf = $657C   ;Through $662B. 176 bytes. Final dialog output buffer.

;------------------------------------------[MMC Registers]-------------------------------------------

MMCCfg = $9FFF   ;MMC1 configuration.
MMCPRG = $FFFF   ;MMC1 PRG RAM.
MMCCHR0 = $BFFF   ;MMC1 CHR0 RAM.
MMCCHR1 = $DFFF   ;MMC1 CHR1 RAM.
MMCReset1 = $BFDF   ;Resets MMC1 configuration.
MMCReset2 = $FFDF   ;Resets MMC1 configuration.

;--------------------------------------------[Constants]---------------------------------------------

;Player flags.
F_GOT_GWAELIN = $01     ;Carrying Gwaelin.
F_RTN_GWAELIN = $02     ;Gwaelin returned.
F_GOLEM_DEAD = $02     ;Golem defeated.
F_DONE_GWAELIN = $03     ;Gwaelin being carried or saved.
F_DGNLRD_DEAD = $04     ;Dragonlord defeated.
F_PSG_FOUND = $04     ;Passage behind dragonlord throne found.
F_DTH_NCK_FOUND = $04     ;Player found the death necklace.
F_RNBW_BRDG = $08     ;Rainbow bridge created.
F_LEFT_THROOM = $08     ;Left throne room and started quest.
F_DRGSCALE = $10     ;Wearing dragon scale.
F_PLR_STOPSPEL = $10     ;Player stopspelled.
F_EN_STOPSPEL = $20     ;Enemy stopspelled.
F_FTR_RING = $20     ;Wearing the fighter's ring.
F_GDRG_DEAD = $40     ;Green dragon defeated.
F_CRSD_BELT = $40     ;Wearing cursed belt.
F_EN_ASLEEP = $40     ;Enemy is asleep.
F_PLR_ASLEEP = $80     ;Player is asleep.
F_DTH_NECKLACE = $80     ;Wearing death necklace.

;Player's weapon, armor and shield.
WP_NONE = $00     ;No weapon.
WP_BAMBOO = $20     ;Bamboo pole.
WP_CLUB = $40     ;Club.
WP_CPR_SWRD = $60     ;Copper sword.
WP_HAND_AX = $80     ;Hand axe.
WP_BRD_SWRD = $A0     ;Broad sword.
WP_FLM_SWRD = $C0     ;Flame sword.
WP_ERDK_SWRD = $E0     ;Erdrick's sword.
AR_NONE = $00     ;No armor.
AR_CLOTHES = $04     ;Clothes.
AR_LTHR_ARMR = $08     ;Leather armor.
AR_CHAIN_MAIL = $0C     ;Chain mail.
AR_HALF_PLATE = $10     ;Half plate.
AR_FULL_PLATE = $14     ;Full plate.
AR_MAGIC_ARMR = $18     ;Magic armor.
AR_ERDK_ARMR = $1C     ;Erdrick's armor.
SH_NONE = $00     ;No shield.
SH_SMLL_SHLD = $01     ;Small shield.
SH_LRG_SHLD = $02     ;Large shield.
SH_SLVR_SHLD = $03     ;Silver shield.
WP_WEAPONS = $E0     ;Bitmask for weapons.
AR_ARMOR = $1C     ;Bitmask for armor.
SH_SHIELDS = $03     ;Bitmask for shields.

;Tile removal flags.
BLK_UPPER_LEFT = $01     ;Remove upper left tile from a block.
BLK_UPPER_RIGHT = $02     ;Remove upper right tile from a block.
BLK_LOWER_LEFT = $04     ;Remove lower left tile from a block.
BLK_LOWER_RIGHT = $08     ;Remove lower right tile from a block.

;Player direction
DIR_UP = $00     ;Player facing up.
DIR_RIGHT = $01     ;Player facing right.
DIR_DOWN = $02     ;Player facing down.
DIR_LEFT = $03     ;Player facing left.

;NPC direction
NPC_UP = $00     ;NPC facing up.
NPC_RIGHT = $20     ;NPC facing right.
NPC_DOWN = $40     ;NPC facing down.
NPC_LEFT = $60     ;NPC facing left.

;Player levels.
LVL_01 = $01     ;Experience level 01.
LVL_02 = $02     ;Experience level 02.
LVL_03 = $03     ;Experience level 03.
LVL_04 = $04     ;Experience level 04.
LVL_05 = $05     ;Experience level 05.
LVL_06 = $06     ;Experience level 06.
LVL_07 = $07     ;Experience level 07.
LVL_08 = $08     ;Experience level 08.
LVL_09 = $09     ;Experience level 09.
LVL_10 = $0A     ;Experience level 10.
LVL_11 = $0B     ;Experience level 11.
LVL_12 = $0C     ;Experience level 12.
LVL_13 = $0D     ;Experience level 13.
LVL_14 = $0E     ;Experience level 14.
LVL_15 = $0F     ;Experience level 15.
LVL_16 = $10     ;Experience level 16.
LVL_17 = $11     ;Experience level 17.
LVL_18 = $12     ;Experience level 18.
LVL_19 = $13     ;Experience level 19.
LVL_20 = $14     ;Experience level 20.
LVL_21 = $15     ;Experience level 21.
LVL_22 = $16     ;Experience level 22.
LVL_23 = $17     ;Experience level 23.
LVL_24 = $18     ;Experience level 24.
LVL_25 = $19     ;Experience level 25.
LVL_26 = $1A     ;Experience level 26.
LVL_27 = $1B     ;Experience level 27.
LVL_28 = $1C     ;Experience level 28.
LVL_29 = $1D     ;Experience level 29.
LVL_30 = $1E     ;Experience level 30.

;Index to level 30 in the level up table.
LVL_TBL_LAST = $3A     ;2 bytes per level up table entry.

;Inventory items.
ITM_NONE = $00     ;No item.
ITM_TORCH = $01     ;Torch.
ITM_FRY_WATER = $02     ;Fairy water.
ITM_WINGS = $03     ;Wyvern wings.
ITM_DRG_SCALE = $04     ;Dragon scale.
ITM_FRY_FLUTE = $05     ;Fairy flute.
ITM_FTR_RING = $06     ;Fighter's ring.
ITM_ERDRICK_TKN = $07     ;Erdrick's token.
ITM_GWAELIN_LVE = $08     ;Gwaelin's love.
ITM_CRSD_BELT = $09     ;Cursed belt.
ITM_SLVR_HARP = $0A     ;Silver harp.
ITM_DTH_NEKLACE = $0B     ;Death necklace.
ITM_STNS_SNLGHT = $0C     ;Stones of sunlight.
ITM_STFF_RAIN = $0D     ;Staff of rain.
ITM_RNBW_DROP = $0E     ;Rainbow drop.
ITM_FOUND_HI = $0F     ;Item is in inventory, high nibble.
ITM_FOUND_LO = $F0     ;Item is in inventory, low nibble.
ITM_NOT_FOUND = $FF     ;Item is not in inventory.
ITM_END = $FF     ;End of item list.

;Used inventory items.
INV_NONE = $01     ;Player has no inventory.
INV_HERB = $02     ;Herb.
INV_KEY = $03     ;key.
INV_TORCH = $04     ;Torch.
INV_FAIRY = $05     ;Fairy water.
INV_WINGS = $06     ;Wyvern wings.
INV_SCALE = $07     ;Dragon's scale.
INV_FLUTE = $08     ;Fairy flute.
INV_RING = $09     ;Fighter's ring.
INV_TOKEN = $0A     ;Erdrick's token.
INV_LOVE = $0B     ;Gwaelin's love.
INV_BELT = $0C     ;Cursed belt.
INV_HARP = $0D     ;Silver harp.
INV_NECKLACE = $0E     ;Death necklace.
INV_STONES = $0F     ;Stones of sunlight.
INV_STAFF = $10     ;Staff of rain.
INV_DROP = $11     ;Rainbow drop.

;Controller bits.
IN_A = $01     ;A button.
IN_B = $02     ;B button.
IN_A_OR_B = $03     ;A or B button.
IN_SELECT = $04     ;Select button.
IN_START = $08     ;Start button.
IN_UP = $10     ;Up button.
IN_DOWN = $20     ;Down button.
IN_LEFT = $40     ;Left button.
IN_RIGHT = $80     ;Right button.
IN_SEL_STRT = $0C     ;Select and start buttons.

;Enemies.
EN_SLIME = $00     ;Slime.
EN_RSLIME = $01     ;Red slime.
EN_DRAKEE = $02     ;Drakee.
EN_GHOST = $03     ;Ghost.
EN_MAGICIAN = $04     ;Magician.
EN_MAGIDRAKE = $05     ;Magidrakee.
EN_SCORPION = $06     ;Scorpion.
EN_DRUIN = $07     ;Druin.
EN_POLTERGEIST = $08     ;Poltergeist.
EN_DROLL = $09     ;Droll.
EN_DRAKEEMA = $0A     ;Drakeema.
EN_SKELETON = $0B     ;Skeleton.
EN_WARLOCK = $0C     ;Warlock.
EN_MSCORPION = $0D     ;Metal scorpion.
EN_WOLF = $0E     ;Wolf.
EN_WRAITH = $0F     ;Wraith.
EN_MSLIME = $10     ;Metal slime.
EN_SPECTER = $11     ;Specter.
EN_WOLFLORD = $12     ;Wolflord.
EN_DRUINLORD = $13     ;Druinlord.
EN_DROLLMAGI = $14     ;Drollmagi.
EN_WYVERN = $15     ;Wyvern.
EN_RSCORPION = $16     ;Rouge scorpion.
EN_WKNIGHT = $17     ;Wraith knight.
EN_GOLEM = $18     ;Golem.
EN_GOLDMAN = $19     ;Goldman.
EN_KNIGHT = $1A     ;Knight.
EN_MAGIWYVERN = $1B     ;Magiwyvern.
EN_DKNIGHT = $1C     ;Demon knight.
EN_WEREWOLF = $1D     ;Werewolf.
EN_GDRAGON = $1E     ;Green dragon.
EN_STARWYVERN = $1F     ;Starwyvern.
EN_WIZARD = $20     ;Wizard.
EN_AXEKNIGHT = $21     ;Axe knight.
EN_BDRAGON = $22     ;Blue dragon.
EN_STONEMAN = $23     ;Stoneman.
EN_ARMORKNIGHT = $24     ;Armored knight.
EN_RDRAGON = $25     ;Red dragon.
EN_DRAGONLORD1 = $26     ;Dragonlord, initial form.
EN_DRAGONLORD2 = $27     ;Dragonlord, final form.

;Maps.
MAP_OVERWORLD = $01     ;Overworld map.
MAP_DLCSTL_GF = $02     ;Dragonlord castle, ground floor.
MAP_HAUKSNESS = $03     ;Hauksness.
MAP_TANTCSTL_GF = $04     ;Tantagel castle, ground floor.
MAP_THRONEROOM = $05     ;Tantagel castle, throne room.
MAP_DLCSTL_BF = $06     ;Dragonlord castle, bottom floor.
MAP_KOL = $07     ;Kol.
MAP_BRECCONARY = $08     ;Brecconary.
MAP_GARINHAM = $09     ;Garinham.
MAP_CANTLIN = $0A     ;Cantlin.
MAP_RIMULDAR = $0B     ;Rimuldar.
MAP_TANTCSTL_SL = $0C     ;Tantagel castle, sublevel.
MAP_RAIN = $0D     ;Staff of rain cave.
MAP_RAINBOW = $0E     ;Rainbow drop cave.
MAP_DLCSTL_SL1 = $0F     ;Dragonlord castle, sublevel 1.
MAP_DLCSTL_SL2 = $10     ;Dragonlord castle, sublevel 2.
MAP_DLCSTL_SL3 = $11     ;Dragonlord castle, sublevel 3.
MAP_DLCSTL_SL4 = $12     ;Dragonlord castle, sublevel 4.
MAP_DLCSTL_SL5 = $13     ;Dragonlord castle, sublevel 5.
MAP_DLCSTL_SL6 = $14     ;Dragonlord castle, sublevel 6.
MAP_SWAMPCAVE = $15     ;Swamp cave.
MAP_RCKMTN_B1 = $16     ;Rock mountain cave, B1.
MAP_RCKMTN_B2 = $17     ;Rock mountain cave, B2.
MAP_CVGAR_B1 = $18     ;Cave of Garinham, B1.
MAP_CVGAR_B2 = $19     ;Cave of Garinham, B2.
MAP_CVGAR_B3 = $1A     ;Cave of Garinham, B3.
MAP_CVGAR_B4 = $1B     ;Cave of Garinham, B4.
MAP_ERDRCK_B1 = $1C     ;Erdrick's cave B1.
MAP_ERDRCK_B2 = $1D     ;Erdrick's cave B2.

;Music/Sounds.
MSC_NOSOUND = $00     ;No sound.
MSC_INTRO = $01     ;Intro music.
MSC_THRN_ROOM = $02     ;Throne room castle music.
MSC_TANTAGEL2 = $03     ;Tantagel 2 castle music.
MSC_VILLAGE = $04     ;Village/pre-game music.
MSC_OUTDOOR = $05     ;Outdoor music.
MSC_DUNGEON1 = $06     ;Dungeon 1 music.
MSC_DUNGEON2 = $07     ;Dungeon 2 music.
MSC_DUNGEON3 = $08     ;Dungeon 3 music.
MSC_DUNGEON4 = $09     ;Dungeon 4 music.
MSC_DUNGEON5 = $0A     ;Dungeon 5 music.
MSC_DUNGEON6 = $0B     ;Dungeon 6 music.
MSC_DUNGEON7 = $0C     ;Dungeon 7 music.
MSC_DUNGEON8 = $0D     ;Dungeon 8 music.
MSC_ENTR_FGHT = $0E     ;Enter fight music.
MSC_END_BOSS = $0F     ;End boss music.
MSC_END = $10     ;End music.
MSC_SILV_HARP = $11     ;Silver harp music.
MSC_FRY_FLUTE = $12     ;Fairy flute music.
MSC_RNBW_BRDG = $13     ;Rainbow bridge music.
MSC_DEATH = $14     ;Player death music.
MSC_INN = $15     ;Inn music.
MSC_PRNCS_LOVE = $16     ;Princess Gwaelin's love music.
MSC_CURSED = $17     ;Cursed Music.
MSC_REG_FGHT = $18     ;Regular fight music.
MSC_VICTORY = $19     ;Victory music.
MSC_LEVEL_UP = $1A     ;Level up music.
SFX_FFDAMAGE = $80     ;Force field damage SFX.
SFX_WVRN_WNG = $81     ;Wyvern wing SFX.
SFX_STAIRS = $82     ;Stairs SFX.
SFX_RUN = $83     ;Run away SFX.
SFX_SWMP_DMG = $84     ;Swamp damage SFX.
SFX_MENU_BTN = $85     ;Menu button SFX.
SFX_CONFIRM = $86     ;Confirmation SFX.
SFX_ENMY_HIT = $87     ;Enemy hit SFX.
SFX_EXCLNT_MOVE = $88     ;Excellent move SFX.
SFX_ATTACK = $89     ;Attack SFX.
SFX_PLYR_HIT1 = $8A     ;Player hit 1 SFX.
SFX_PLYR_HIT2 = $8B     ;Player hit 2 SFX.
SFX_ATCK_PREP = $8C     ;Attack prep SFX.
SFX_MISSED1 = $8D     ;Missed 1 SFX.
SFX_MISSED2 = $8E     ;Missed 2 SFX.
SFX_WALL_BUMP = $8F     ;Wall bump SFX.
SFX_TEXT = $90     ;Text SFX.
SFX_SPELL = $91     ;Spell cast SFX.
SFX_RADIANT = $92     ;Radiant spell SFX.
SFX_TRSR_CHEST = $93     ;Open chest SFX.
SFX_DOOR = $94     ;Open door SFX.
SFX_FIRE = $95     ;Breath fire SFX.

;Sound control bytes.
MCTL_SQ1_SW = $00     ;Index to SQ1 channel software regs.
MCTL_SQ2_SW = $02     ;Index to SQ2 channel software regs.
MCTL_TRI_SW = $04     ;Index to TRI channel software regs.
MCTL_NOIS_SW = $06     ;Index to noise channel software regs.
MCTL_SQ1_HW = $00     ;Index to SQ1 channel hardware regs.
MCTL_SQ2_HW = $04     ;Index to SQ2 channel hardware regs.
MCTL_TRI_HW = $08     ;Index to TRI channel hardware regs.
MCTL_DMC_HW = $10     ;Index to DMC channel hardware regs (not used).
MCTL_NOTE = $80     ;*2 is index into note table to load musical note.
MCTL_NOISE_CFG = $E0     ;Noise channel period config byte.
MCTL_END_SPACE = $F6     ;Stop adding quiet time between notes.
MCTL_ADD_SPACE = $F7     ;Add quiet time between notes.
MCTL_NOISE_VOL = $F8     ;Noise volume control byte.
MCTL_NOTE_OFST = $F9     ;Note offset control byte.
MCTL_CNTRL1 = $FA     ;Channel control 1 byte.
MCTL_CNTRL0 = $FB     ;Channel control 0 byte.
MCTL_NO_OP = $FC     ;Skip byte and move to the next byte.
MCTL_RETURN = $FD     ;Return to old music data address.
MCTL_JUMP = $FE     ;Jump to new music data address.
MCTL_TEMPO = $FF     ;Change music tempo.

;Nibble bit masks.
NBL_LOWER = $0F     ;Lower nibble.
NBL_UPPER = $F0     ;Upper nibble.

;Message speed.
MSG_FAST = $00     ;Fast message speed.
MSG_NORMAL = $01     ;Normal message speed.
MSG_SLOW = $02     ;Slow message speed.

;PRG banks.
PRG_BANK_0 = $00     ;PRG bank 0
PRG_BANK_1 = $01     ;PRG bank 1
PRG_BANK_2 = $02     ;PRG bank 2
PRG_BANK_3 = $03     ;PRG bank 3
PRG_B3_NO_RAM = $13     ;PRG bank 3, disable PRG RAM.

;CHR banks.
CHR_BANK_0 = $00     ;CHR bank 0
CHR_BANK_1 = $01     ;CHR bank 1
CHR_BANK_2 = $02     ;CHR bank 2
CHR_BANK_3 = $03     ;CHR bank 3

;Spells
SPL_HEAL = $00     ;Heal.
SPL_HURT = $01     ;Hurt
SPL_SLEEP = $02     ;Sleep.
SPL_RADIANT = $03     ;Radiant.
SPL_STOPSPELL = $04     ;Stopspell.
SPL_OUTSIDE = $05     ;Outside.
SPL_RETURN = $06     ;Return.
SPL_REPEL = $07     ;Repel.
SPL_HEALMORE = $08     ;Healmore.
SPL_HURTMORE = $09     ;Hurtmore.

;Text control characters and other misc. characters.
TXT_LWR_N = $17     ;Lowercase n.
TXT_LWR_S = $1C     ;Lowercase s.
TXT_UPR_A = $24     ;Uppercase A.
TXT_UPR_E = $28     ;Uppercase E.
TXT_UPR_I = $2C     ;Uppercase I.
TXT_UPR_O = $32     ;Uppercase O.
TXT_UPR_U = $38     ;Uppercase U.
TXT_APOS = $40     ;Apostrophe.
TXT_PERIOD = $47     ;Period.
TXT_COMMA = $48     ;Comma.
TXT_DASH = $49     ;Dash.
TXT_QUESTION = $4B     ;Question mark.
TXT_EXCLAIM = $4C     ;Exclaimation point.
TXT_CLS_PAREN = $4E     ;Closed parenthesis.
TXT_OPN_PAREN = $4F     ;Open parenthesis.
TXT_OPN_QUOTE = $50     ;Open quote.
TXT_PRD_QUOTE = $52     ;Period followed by and end quote.
TXT_INDENT = $57     ;Indent character. Causes subsequent lines to be indented.
TXT_BLANK1 = $60     ;Blank space.
TXT_PLRL = $EF     ;Prints the letter " s" or " " (space).
TXT_PNTS = $F0     ;Prints the word " Point" or " Points".
TXT_ENM2 = $F1     ;An enemy's name preceeded by 'a' or 'an'.
TXT_DESC = $F2     ;Object description preceeded by 'a' or 'an'.
TXT_AMTP = $F3     ;Displays a numeric value followed by "Point" or "Points".
TXT_ENMY = $F4     ;An enemy's name.
TXT_AMNT = $F5     ;Displays a numeric value.
TXT_SPEL = $F6     ;A spell's name.
TXT_ITEM = $F7     ;An item's name.
TXT_NAME = $F8     ;The player's name.
TXT_COPY = $F9     ;Copy description buffer to work buffer.
TXT_SUBEND = $FA     ;End of substring contents.
TXT_WAIT = $FB     ;Wait for the user to press a button.
TXT_END1 = $FC     ;End of text entry marker.
TXT_NEWL = $FD     ;New line.
TXT_NOP = $FE     ;Byte skipped while processing.
TXT_END2 = $FF     ;End of text entry marker.

;Intro/end control bytes.
END_RPT = $F7     ;Loop control byte.
END_TXT_END = $FC     ;End marker for text data.
END_RPT_END = $FD     ;End marker for repeated data.

;Window types.
WND_POPUP = $00     ;Pop-up window with name, level, HP, MP gold and experience.
WND_STATUS = $01     ;Status window.
WND_DIALOG = $02     ;Dialog window.
WND_CMD_NONCMB = $03     ;Command window, non-combat.
WND_CMD_CMB = $04     ;Command window, combat.
WND_SPELL1 = $05     ;Spell window, not used.
WND_SPELL2 = $06     ;Spell window, points to same window data as above.
WND_INVTRY1 = $07     ;Inventory window, player inventory.
WND_INVTRY2 = $08     ;Inventory window, Shop inventory.
WND_YES_NO1 = $09     ;Yes/no selection window, variant 1.
WND_BUY_SELL = $0A     ;Buy/sell window.
WND_ALPHBT = $0B     ;Alphabet window.
WND_MSG_SPEED = $0C     ;Message speed window.
WND_INPT_NAME = $0D     ;Input name window.
WND_NM_ENTRY = $0E     ;Name entry window.
WND_CNT_CH_ER = $0F     ;Continue, change, erase window.
WND_FULL_MNU = $10     ;Full menu window.
WND_NEW_QST = $11     ;Begin new quest window.
WND_LOG_1_1 = $12     ;Log list window, only entry 1, variant 1.
WND_ERASE = $20     ;Erase log window.
WND_YES_NO2 = $21     ;Yes/no selection window, variant 2.

;Description entries.
DSC_NONE = $00     ;No text.
DSC_BMB_POLE = $01     ;Bamboo pole text.
DSC_CLUB = $02     ;Club text.
DSC_CPR_SWD = $03     ;Copper sword text.
DSC_HND_AXE = $04     ;Hand Axe text.
DSC_BROAD_SWD = $05     ;Broad sword text.
DSC_FLAME_SWD = $06     ;Flame Sword text.
DSC_ERD_SWD = $07     ;Erdrick's sword text.
DSC_CLOTHES = $08     ;Clothes text.
DSC_LTHR_ARMR = $09     ;Leather armor text.
DSC_CHAIN_ML = $0A     ;Chain mail text.
DSC_HALF_PLT = $0B     ;Half plate text.
DSC_FULL_PLT = $0C     ;Full plate text.
DSC_MAG_ARMR = $0D     ;Magic armor text.
DSC_ERD_ARMR = $0E     ;Erdrick's armor text.
DSC_SM_SHLD = $0F     ;Small shield text.
DSC_LG_SHLD = $10     ;Large shield text.
DSC_SLVR_SHLD = $11     ;Silver shield text.
DSC_HERB = $12     ;Herb text.
DSC_TORCH = $13     ;Torch text.
DSC_DRGN_SCL = $14     ;Dragon's scale text.
DSC_WINGS = $15     ;Wyvern wings text.
DSC_KEY = $16     ;Magic key text.
DSC_FRY_WATER = $17     ;Fairy water text.
DSC_BL_LIGHT = $18     ;Ball of light text.
DSC_ERD_TBLT = $19     ;Erdrick's tablet text.
DSC_FRY_FLUTE = $1A     ;Fairy flute text.
DSC_SLVR_HARP = $1B     ;Silver harp text.
DSC_RN_STAFF = $1C     ;Staff of rain text.
DSC_STN_SUN = $1D     ;Stones of sunlight text.
DSC_GWLN_LOVE = $1E     ;Gwaelin's love text.
DSC_RNBW_DRP = $1F     ;Rainbow drop text.
DSC_CRSD_BLT = $20     ;Cursed belt text.
DSC_DTH_NCK = $21     ;Death necklace text.
DSC_FGHTR_RNG = $22     ;Fighter's ring text.
DSC_ERD_TKN = $23     ;Erdrick's token text.
DSC_SCRT_PSG = $24     ;Secret passage text.
DSC_HEAL = $14     ;Heal spell text.
DSC_HURT = $15     ;Hurt spell text.
DSC_SLEEP = $16     ;Sleep spell text.
DSC_RADIANT = $17     ;Radiant spell text.
DSC_STOPSPELL = $18     ;Stopspell spell text.
DSC_OUTSIDE = $19     ;Outside spell text.
DSC_RETURN = $1A     ;Return spell text.
DSC_REPEL = $1B     ;Repel spell text.
DSC_HEALMORE = $1C     ;Healmore spell text.
DSC_HURTMORE = $1D     ;Hurtmore spell text.
DSC_END = $FF     ;Marks the end of the description buffer.

;Window border constants.
NULL = $0000   ;Null pointer.
TL_RIGHT_ARROW = $42     ;Right pointing arrow.
TL_BLANK_TILE1 = $5F     ;Blank tile 1 tile pattern number.
TL_BLANK_TILE2 = $60     ;Blank tile 2 tile pattern number.
TL_LEFT = $61     ;Left window border.
TL_TOP1 = $62     ;Upper window border.
TL_TOP2 = $63     ;Upper window border.
TL_UPPER_LEFT = $64     ;Upper left window border.
TL_BOT_LEFT = $65     ;Lower left window border.
TL_RIGHT = $66     ;Right window border.
TL_UPPER_RIGHT = $67     ;Upper right window border.
TL_BOTTOM = $68     ;Bottom window border.
TL_BOT_RIGHT = $69     ;Lower right window border.

;Graphic block constants.
BLK_GRASS = $00     ;Grass block.
BLK_SAND = $01     ;Sand block.
BLK_HILL = $02     ;Hill block.
BLK_STAIR_UP = $03     ;Stairs up block.
BLK_BRICK = $04     ;Bricks block.
BLK_STAIR_DN = $05     ;Stairs down block.
BLK_SWAMP = $06     ;Swamp block.
BLK_TOWN = $07     ;Town block.
BLK_CAVE = $08     ;Cave block.
BLK_CASTLE = $09     ;Castle block.
BLK_BRIDGE = $0A     ;Bridge block.
BLK_TREES = $0B     ;Trees block.
BLK_CHEST = $0C     ;Treasure chest block.
BLK_FFIELD = $0D     ;Force field block.
BLK_LRG_TILE = $0E     ;Large tile/shop counter block.
BLK_WATER = $0F     ;Water block.
BLK_STONE = $10     ;Stone block.
BLK_DOOR = $11     ;Door block.
BLK_MOUNTAIN = $12     ;Mountain block.
BLK_SHOP = $13     ;Shop sign block.
BLK_INN = $14     ;Inn sign block.
BLK_SML_TILES = $15     ;Small tiles block.
BLK_BLANK = $16     ;Black square block.
BLK_PRINCESS = $17     ;Princess Gwaelin block.
BLK_WTR_T = $18     ;Water - shore at top.
BLK_WTR_L = $19     ;Water - shore at left.
BLK_WTR_TL = $1A     ;Water - shore at top, left.
BLK_WTR_R = $1B     ;Water - shore at right.
BLK_WTR_TR = $1C     ;Water - shore at top, right.
BLK_WTR_LR = $1D     ;Water - shore at left, right.
BLK_WTR_TLR = $1E     ;Water - shore at top, left, right.
BLK_WTR_B = $1F     ;Water - shore at bottom.
BLK_WTR_TB = $20     ;Water - shore at top, bottom.
BLK_WTR_LB = $21     ;Water - shore at left, bottom.
BLK_WTR_TLB = $22     ;Water - shore at top, left, bottom.
BLK_WTR_RB = $23     ;Water - shore at right, bottom.
BLK_WTR_TRB = $24     ;Water - shore at top, right, bottom.
BLK_WTR_LRB = $25     ;Water - shore at left, right and bottom.
BLK_WTR_TLRB = $26     ;Water - shore at all sides.

;Treasure chest constants.
TRSR_HERB = $02     ;Herb.
TRSR_KEY = $03     ;Magic key.
TRSR_TORCH = $04     ;Torch.
TRSR_WINGS = $06     ;Wyvern wings.
TRSR_RING = $09     ;Fighter's ring.
TRSR_BELT = $0C     ;Cursed belt.
TRSR_HARP = $0D     ;Silver harp.
TRSR_NCK = $0E     ;Death necklace or 100-131 gold.
TRSR_SUN = $0F     ;Stones of sunlight
TRSR_RAIN = $10     ;Staff of rain.
TRSR_ERSD = $11     ;Erdrick's sword.
TRSR_GLD1 = $12     ;5-20 gold.
TRSR_GLD2 = $13     ;6-13  gold.
TRSR_GLD3 = $14     ;10-17 gold.
TRSR_GLD4 = $15     ;500-755 gold.
TRSR_GLD5 = $16     ;120 gold.
TRSR_TBLT = $17     ;Erdrick's tablet.

;Non-combat command window commands.
NCC_TALK = $00     ;Talk.
NCC_STATUS = $01     ;Status.
NCC_STAIRS = $02     ;Stairs.
NCC_SEARCH = $03     ;Search.
NCC_SPELL = $04     ;Spell.
NCC_ITEM = $05     ;Item.
NCC_DOOR = $06     ;Door.
NCC_TAKE = $07     ;Take.

;Combat command window commands.
CC_FIGHT = $00     ;Fight.
CC_RUN = $01     ;Run.
CC_SPELL = $02     ;Spell.
CC_ITEM = $03     ;Item.

;Map types.
MAP_OVRWLD = $00     ;Overworld map.
MAP_TOWN = $10     ;Town/castle map.
MAP_DUNGEON = $20     ;Dungeon map.

;Palette addresses.
PAL_BKG_LB = $00     ;Lower byte starting address of background palettes.
PAL_SPR_LB = $10     ;Lower byte starting address of sprite palettes.
PAL_UB = $3F     ;Upper byte address of all palettes.

;Misc. constants.
NT_NAMETBL0_LB = $00     ;Nametable 0 base address lower byte.
NT_NAMETBL0_UB = $20     ;Nametable 0 base address upper byte.
NT_NAMETBL1_LB = $00     ;Nametable 1 base address lower byte.
NT_NAMETBL1_UB = $24     ;Nametable 1 base address upper byte.
AT_ATRBTBL0_UB = $23     ;Attribute table 0 base address upper byte.
AT_ATRBTBL1_UB = $27     ;Attribute table 1 base address upper byte.
NPC_MOVE = $00     ;Allow NPCs to move.
NPC_STOP = $FF     ;Stop NPCs from moving.
WND_ABORT = $FF     ;Window cancelled.
STRT_FULL_HP = $78     ;Restore HP and MP on restart.
STRT_NO_HP = $AB     ;Do not restore HP and MP on restart.
IS_CURSED = $C0     ;Bitmask for checking if player is cursed.
WND_YES = $00     ;Yes selected from Yes/no window.
WND_NO = $01     ;No selected from Yes/no window.
WND_BUY = $00     ;Buy selected from Buy/sell window.
WND_SELL = $01     ;Sell selected from Buy/sell window.
ITM_TBL_END = $FD     ;End of shop items list.
PAL_LOAD_BG = $FF     ;Load background palette data.
PAL_SKIP_BG = $00     ;Skip loading background palette.
PAL_BLACK = $0F     ;Black background palette value.
WND_FOREGROUND = $00     ;Window overlaps another window.
WND_BACKGROUND = $FF     ;Window is a background window.
INV_FULL = $04     ;Player's inventory is full.
