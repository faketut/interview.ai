@echo off
chcp 65001
title 远程控制服务器

REM 确保在正确的目录中运行
cd /d "%~dp0"

echo ========================================
echo        远程控制服务器启动中...
echo ========================================
echo.

REM 检查Conda环境
echo 正在检查Conda环境...
conda --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Conda，请先安装Anaconda或Miniconda
    echo 下载地址: https://docs.conda.io/en/latest/miniconda.html
    pause
    exit /b 1
)

echo Conda环境检查通过
echo.

REM 检查虚拟环境是否存在
echo 正在检查虚拟环境...
conda env list | findstr "venv" >nul 2>&1
if errorlevel 1 (
    echo 错误: 虚拟环境 'venv' 不存在，请先运行 setup.bat 创建环境
    pause
    exit /b 1
)

echo 虚拟环境存在，正在激活...
REM 激活虚拟环境 - 使用更可靠的方法
call conda activate venv
if errorlevel 1 (
    echo 错误: 虚拟环境激活失败，请先运行 setup.bat 创建环境
    pause
    exit /b 1
)

echo 虚拟环境已激活
echo.

REM 验证Python环境
echo 正在验证Python环境...
python --version
if errorlevel 1 (
    echo 错误: Python环境验证失败
    pause
    exit /b 1
)

echo Python环境验证通过
echo.

REM 获取本机IP地址
echo 正在获取本机IP地址...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4"') do (
    for /f "tokens=1" %%b in ("%%a") do (
        set "LOCAL_IP=%%b"
        goto :found_ip
    )
)

:found_ip
echo 本机IP地址: %LOCAL_IP%
echo 手机访问地址: http://%LOCAL_IP%:8080
echo.

REM 检查依赖是否安装
echo 正在检查依赖包...
python -c "import flask, websockets, PIL, google.generativeai" >nul 2>&1
if errorlevel 1 (
    echo 检测到缺少依赖包，正在安装...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo 错误: 依赖包安装失败
        pause
        exit /b 1
    )
    echo 依赖包安装完成
    echo.
)

REM 检查配置文件
if not exist "config.json" (
    echo 警告: 未找到配置文件，将使用默认配置
    echo 请编辑config.json文件配置您的Gemini API密钥
    echo.
)

REM 检查服务器文件
if not exist "server.py" (
    echo 错误: 未找到 server.py 文件
    pause
    exit /b 1
)

echo 所有检查完成，正在启动服务器...
echo 按 Ctrl+C 停止服务器
echo ========================================
echo.

REM 启动Python服务器 - 使用conda run确保在正确的环境中运行
echo 正在启动Python服务器...
conda run -n venv python server.py

echo.
echo 服务器已停止
pause