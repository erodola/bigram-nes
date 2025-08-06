:: Uncomment the line below to temporarily update the system path
:: set path=%path%;..\tools\cc65\bin\

IF NOT EXIST asm\bin (
    echo ERROR: Folder "asm\bin" not found.
    echo You should run extract.bat before running the build.
	pause
    goto :eof
)

IF NOT EXIST asm\dat (
    echo ERROR: Folder "asm\dat" not found.
    echo You should run extract.bat before running the build.
	pause
    goto :eof
)


if not exist build (
    mkdir build
)

ca65 asm/bank_01.asm
ca65 asm/bank_09.asm
ca65 asm/bank_0B.asm
ca65 asm/bank_0C.asm
ca65 asm/bank_0D.asm
ca65 asm/bank_0F.asm
ca65 asm/bank_0E.asm

:: inference code
ca65 asm/inference.asm
ca65 asm/T_matrix.asm

ld65 -C asm/nes.cfg ^
    asm/bank_01.o ^
    asm/bank_09.o ^
    asm/bank_0B.o ^
    asm/bank_0C.o ^
    asm/bank_0D.o ^
    asm/bank_0E.o ^
    asm/bank_0F.o ^
    asm/inference.o ^
    asm/T_matrix.o ^
    --mapfile build/map.txt

copy /B ^
    asm\nesheader.bin + ^
    asm\dat\bank_00.dat + ^
    bank_01.bin + ^
    asm\dat\bank_02.dat + ^
    asm\dat\bank_03.dat + ^
    asm\dat\bank_04.dat + ^
    asm\dat\bank_05.dat + ^
    asm\dat\bank_06.dat + ^
    asm\dat\bank_07.dat + ^
    asm\dat\bank_08.dat + ^
    bank_09.bin + ^
    asm\dat\bank_0A.dat + ^
    bank_0B.bin + ^
    bank_0C.bin + ^
    bank_0D.bin + ^
    bank_0E.bin + ^
    bank_0F.bin ^
    build\FinalFantasy.nes

cd asm
del *.o
cd ..

del bank_*.bin

powershell -ExecutionPolicy Bypass -File "scripts/check_limits.ps1"

pause
