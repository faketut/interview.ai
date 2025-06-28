@echo off
chcp 65001
title 远程控制服务器 - Conda环境

echo ========================================
echo      远程控制服务器启动中... 
echo ========================================
echo.

echo 正在激活Conda虚拟环境...
call conda activate remote_control
if errorlevel 1 (
    echo 错误: 无法激活虚拟环境 remote_control
    echo.
    echo 可能的解决方案:
    echo 1. 确保已运行 setup.bat 完成安装
    echo 2. 检查Conda是否正确安装
    echo 3. 手动运行: conda activate remote_control
    echo.
    pause
    exit /b 1
)

echo ✓ 虚拟环境已激活
echo 当前Python环境: 
python --version
echo 当前Conda环境: %CONDA_DEFAULT_ENV%
echo.

echo 正在验证依赖包...
python -c "import flask, websockets, PIL, google.generativeai; print('✓ 所有依赖包验证通过')" 2>nul
if errorlevel 1 (
    echo 错误: 缺少必要的依赖包
    echo 正在尝试安装缺失的依赖...
    pip install Flask websockets Pillow google-generativeai
    if errorlevel 1 (
        echo 安装失败，请手动运行: pip install -r requirements.txt
        pause
        exit /b 1
    )
)

echo.
echo 正在检查配置文件...
if not exist "config.json" (
    echo 错误: 未找到配置文件 config.json
    echo 请先运行 setup.bat 进行安装配置
    pause
    exit /b 1
)

REM 获取本机IP地址
echo 正在获取网络信息...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4"') do (
    for /f "tokens=1" %%b in ("%%a") do (
        set "LOCAL_IP=%%b"
        goto :found_ip
    )
)

:found_ip
set LOCAL_IP=%LOCAL_IP: =%

if "%LOCAL_IP%"=="" (
    echo 警告: 无法自动获取IP地址
    set LOCAL_IP=localhost
)

echo.
echo ========================================
echo           服务器信息
echo ========================================
echo Conda环境: %CONDA_DEFAULT_ENV%
echo 本机IP地址: %LOCAL_IP%
echo Web访问地址: http://%LOCAL_IP%:8080
echo WebSocket端口: 8765
echo.
echo 移动端访问:
echo http://%LOCAL_IP%:8080
echo ========================================
echo.
echo 服务器状态监控:
echo - 按 Ctrl+C 停止服务器
echo - 查看控制台日志了解运行状态
echo.

REM 检查端口占用
netstat -an | findstr ":8080" >nul 2>&1
if not errorlevel 1 (
    echo 警告: 端口8080已被占用，可能影响服务启动
)

netstat -an | findstr ":8765" >nul 2>&1  
if not errorlevel 1 (
    echo 警告: 端口8765已被占用，可能影响WebSocket连接
)

echo 正在启动服务器...
python server.py

if errorlevel 1 (
    echo.
    echo 服务器启动失败，可能的原因:
    echo 1. 端口被占用
    echo 2. 配置文件错误
    echo 3. 依赖包问题
    echo 4. 权限不足
    echo.
    echo 请检查上述日志信息
)

echo.
echo 服务器已停止运行
pause