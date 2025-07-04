@echo off
REM Check if conda is installed
where conda >nul 2>&1
if %errorlevel% neq 0 (
    echo Conda is not installed. Please install Conda and try again.
    exit /b 1
)

REM Create the conda environment
echo Creating conda environment remote-screenshot-env...
conda create --name remote-screenshot-env --yes

REM Activate the conda environment
echo Activating conda environment remote-screenshot-env...
call conda activate remote-screenshot-env

REM Install dependencies from requirements.txt
echo Installing dependencies from requirements.txt...
pip install -r requirements.txt

echo Conda environment setup complete.
pause
