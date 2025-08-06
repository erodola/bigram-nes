@echo off
setlocal enabledelayedexpansion

set "ROM=ff1.nes"

echo Checking hash...

:: Extract expected hash from ff1.md5
for /f "tokens=1,2" %%a in (ff1.md5) do (
    set "EXPECTED=%%a"
    set "FILENAME=%%b"
)

:: Compute actual hash using certutil
for /f "skip=1 tokens=1" %%h in ('certutil -hashfile %ROM% MD5') do (
    set "ACTUAL=%%h"
    goto check_hash
)

:check_hash
if /I not "!EXPECTED!"=="!ACTUAL!" (
    echo ERROR: MD5 hash mismatch for %ROM%
    echo Expected: !EXPECTED!
    echo Actual:   !ACTUAL!
    exit /b 1
)

echo OK
echo.
echo Extracting game assets...

python scripts\extract_from_rom.py %ROM% scripts\offsets

if errorlevel 1 (
    echo Extraction failed.
    exit /b 1
)

echo OK
echo.
echo You can now run the build.bat script.

pause