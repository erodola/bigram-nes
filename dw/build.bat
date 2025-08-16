@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "NAMEGEN=true"

rem Expected MD5 when NAMEGEN is disabled
set "EXPECTED_MD5=1CFEEAC7A20B405780EEA318D3D1AF2A"

rem Run from this script's folder
pushd "%~dp0"

echo.
echo === Checking required folders ===
if not exist "asm\bin\" (
  echo ERROR: asm\bin\ folder not found.
  echo You should run extract.bat before running the build.
  pause
  popd
  exit /b 1
)

rem Prepare optional define for ca65
set "NAMEGEN_DEFINE="
if /i "%NAMEGEN%"=="true" set "NAMEGEN_DEFINE=-D namegen"

echo.
echo === Deleting previous build files ===
if exist build rmdir /s /q build
mkdir build || goto :err

echo.
echo === Assembling with ca65 ===
rem Header (should emit exactly 16 bytes from $0000)
ca65 -o build\Header.o asm\Header.asm || goto :err

rem PRG banks
ca65 -o build\Bank00.o asm\Bank00.asm || goto :err
ca65 -o build\Bank01.o asm\Bank01.asm %NAMEGEN_DEFINE% || goto :err
ca65 -o build\Bank02.o asm\Bank02.asm || goto :err
ca65 -o build\Bank03.o asm\Bank03.asm %NAMEGEN_DEFINE% || goto :err

echo.
echo === Linking with ld65 ===
ld65 -C asm\nes.cfg build\Header.o build\Bank00.o build\Bank01.o build\Bank02.o build\Bank03.o --mapfile build\map.txt || goto :err

echo.
echo === Combining assembled banks into a ROM ===
rem Creates build\DragonWarrior.nes from Header + 4 PRG banks + CHR ROM
copy /b "build\Header.bin"+"build\Bank00.bin"+"build\Bank01.bin"+"build\Bank02.bin"+"build\Bank03.bin"+"asm\bin\CHR_ROM.bin" "build\DragonWarrior.nes" >nul || goto :err

echo.
echo === Cleaning up intermediate files ===
del /q build\*.o 2>nul
del /q build\*.bin 2>nul

if /i "%NAMEGEN%"=="false" (
  echo.
  echo === Verifying final ROM checksum (MD5) ===
  set "HASH_LINE="
  for /f "usebackq skip=1 tokens=* delims=" %%H in (`certutil -hashfile "build\DragonWarrior.nes" MD5`) do (
    if not defined HASH_LINE set "HASH_LINE=%%H"
  )
  if not defined HASH_LINE (
    echo Failed to compute MD5 with certutil.
    goto :after_md5
  )
  rem Remove spaces from the hex string
  set "FINAL_MD5=!HASH_LINE: =!"
  echo Assembled ROM md5sum = !FINAL_MD5!
  echo Expected  ROM md5sum = %EXPECTED_MD5%
  if /i "!FINAL_MD5!"=="%EXPECTED_MD5%" (
    echo Final ROM checksum matches
  ) else (
    echo Final ROM checksum mismatch - expected if assembling the hack
  )
)

echo.
echo Build complete.
echo Output written to: build\DragonWarrior.nes

pause

popd
exit /b 0

:err
echo.
echo Build failed with error %errorlevel%.

pause

popd
exit /b %errorlevel%