@echo off
chcp 65001
title 环境检查工具

echo ========================================
echo        远程控制工具环境检查
echo ========================================
echo.

REM 系统信息
echo [系统信息]
echo 操作系统: %OS%
echo 计算机名: %COMPUTERNAME%
echo 用户名: %USERNAME%
echo 当前目录: %CD%
echo.

REM Python环境检查
echo [Python环境检查]
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python: 未安装
    echo    请从 https://www.python.org/downloads/ 下载安装
) else (
    echo ✓ Python: 
    python --version
    echo    安装路径: 
    where python
)
echo.

REM Conda环境检查
echo [Conda环境检查]
conda --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Conda: 未安装
    echo    可选安装: https://docs.conda.io/en/latest/miniconda.html
) else (
    echo ✓ Conda: 
    conda --version
    echo    虚拟环境列表:
    conda env list
)
echo.

REM 网络环境检查
echo [网络环境检查]
echo 本机IP地址:
ipconfig | findstr /C:"IPv4"

echo.
echo 端口占用检查:
netstat -an | findstr ":8080" >nul 2>&1
if errorlevel 1 (
    echo ✓ 端口8080: 可用
) else (
    echo ❌ 端口8080: 已被占用
)

netstat -an | findstr ":8765" >nul 2>&1
if errorlevel 1 (
    echo ✓ 端口8765: 可用
) else (
    echo ❌ 端口8765: 已被占用
)
echo.

REM 文件结构检查
echo [项目文件检查]
if exist "server.py" (
    echo ✓ server.py: 存在
) else (
    echo ❌ server.py: 缺失
)

if exist "requirements.txt" (
    echo ✓ requirements.txt: 存在
) else (
    echo ❌ requirements.txt: 缺失
)

if exist "config.json" (
    echo ✓ config.json: 存在
) else (
    echo ❌ config.json: 缺失 (运行setup.bat创建)
)

if exist "templates" (
    echo ✓ templates目录: 存在
    if exist "templates\mobile.html" (
        echo   ✓ mobile.html: 存在
    ) else (
        echo   ❌ mobile.html: 缺失
    )
) else (
    echo ❌ templates目录: 缺失
)
echo.

REM 依赖包检查 - 系统环境
echo [系统Python依赖包检查]
python -c "import flask; print('✓ Flask: ' + flask.__version__)" 2>nul
if errorlevel 1 echo ❌ Flask: 未安装

python -c "import websockets; print('✓ WebSockets: ' + websockets.__version__)" 2>nul  
if errorlevel 1 echo ❌ WebSockets: 未安装

python -c "import PIL; print('✓ Pillow: ' + PIL.__version__)" 2>nul
if errorlevel 1 echo ❌ Pillow: 未安装

python -c "import google.generativeai; print('✓ Google AI: 已安装')" 2>nul
if errorlevel 1 echo ❌ Google AI: 未安装

echo.

REM Conda虚拟环境检查
conda --version >nul 2>&1
if not errorlevel 1 (
    echo [Conda虚拟环境依赖包检查]
    conda env list | findstr "remote_control" >nul 2>&1
    if errorlevel 1 (
        echo ❌ remote_control环境: 不存在
        echo    运行setup.bat创建虚拟环境
    ) else (
        echo ✓ remote_control环境: 存在
        echo 正在检查虚拟环境中的依赖包...
        call conda activate remote_control >nul 2>&1
        if not errorlevel 1 (
            python -c "import flask; print('  ✓ Flask: ' + flask.__version__)" 2>nul
            if errorlevel 1 echo   ❌ Flask: 未安装
            
            python -c "import websockets; print('  ✓ WebSockets: ' + websockets.__version__)" 2>nul
            if errorlevel 1 echo   ❌ WebSockets: 未安装
            
            python -c "import PIL; print('  ✓ Pillow: ' + PIL.__version__)" 2>nul
            if errorlevel 1 echo   ❌ Pillow: 未安装
            
            python -c "import google.generativeai; print('  ✓ Google AI: 已安装')" 2>nul
            if errorlevel 1 echo   ❌ Google AI: 未安装
            
            call conda deactivate >nul 2>&1
        )
    )
    echo.
)

REM 防火墙检查
echo [防火墙规则检查]
netsh advfirewall firewall show rule name="RemoteControl_8080" >nul 2>&1
if errorlevel 1 (
    echo ❌ 端口8080防火墙规则: 未配置
) else (
    echo ✓ 端口8080防火墙规则: 已配置
)

netsh advfirewall firewall show rule name="RemoteControl_8765" >nul 2>&1
if errorlevel 1 (
    echo ❌ 端口8765防火墙规则: 未配置
) else (
    echo ✓ 端口8765防火墙规则: 已配置
)
echo.

echo ========================================
echo            检查完成
echo ========================================
echo.
echo 根据上述检查结果:
echo 1. 如果Python或依赖包有问题，运行 setup.bat
echo 2. 如果使用Conda，推荐运行 start_venv.bat
echo 3. 如果使用系统Python，运行 start.bat
echo 4. 如果端口被占用，请关闭占用的程序
echo.
echo 获取帮助: 查看 README.md 文件
echo.
pause