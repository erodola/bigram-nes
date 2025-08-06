@echo off

set name="gen"

::Uncomment the line below to temporarily update the system path
::set path=%path%;..\..\tools\cc65\bin\

cc65 -Oirs src/%name%.c --add-source
ca65 lib/crt0.s
ca65 src/%name%.s -g

ld65 -C src/nrom_32k_vert.cfg -o %name%.nes lib/crt0.o src/%name%.o nes.lib -Ln labels.txt

cd lib
del *.o
cd ..

cd src
del *.o
cd ..

if not exist build (
    mkdir build
)

move /Y labels.txt build\ 
move /Y src\%name%.s build\ 
move /Y %name%.nes build\ 

pause