@echo off
chcp 65001
title 远程控制工具安装脚本

echo ========================================
echo       远程控制工具安装脚本
echo ========================================
echo.

echo 正在检查Conda环境...
conda --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Conda，请先安装Anaconda或Miniconda
    echo 下载地址: https://docs.conda.io/en/latest/miniconda.html
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)

echo Conda环境检查通过！
echo.

echo 正在检查Python环境...
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Python，请先安装Python 3.8+
    echo 下载地址: https://www.python.org/downloads/
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)

echo Python环境检查通过！
echo.

echo 正在检查虚拟环境...
conda env list | findstr "venv" >nul 2>&1
if errorlevel 1 (
    echo 虚拟环境不存在，正在创建...
    echo 这可能需要几分钟时间，请耐心等待...
    conda create -n venv python=3.8 -y
    if errorlevel 1 (
        echo 错误: 虚拟环境创建失败
        echo 可能的原因:
        echo 1. 网络连接问题
        echo 2. Conda配置问题
        echo 3. 磁盘空间不足
        echo.
        echo 按任意键退出...
        pause >nul
        exit /b 1
    )
    echo 虚拟环境创建成功！
) else (
    echo 虚拟环境已存在，跳过创建步骤
)

echo.
echo 正在激活虚拟环境...
call conda activate venv
if errorlevel 1 (
    echo 错误: 虚拟环境激活失败
    echo 尝试重新创建虚拟环境...
    conda remove -n venv --all -y
    conda create -n venv python=3.8 -y
    if errorlevel 1 (
        echo 错误: 重新创建虚拟环境失败
        echo 按任意键退出...
        pause >nul
        exit /b 1
    )
    call conda activate venv
    if errorlevel 1 (
        echo 错误: 虚拟环境激活仍然失败
        echo 按任意键退出...
        pause >nul
        exit /b 1
    )
)

echo 虚拟环境已激活，正在安装依赖包...
echo 正在检查requirements.txt文件...
if not exist "requirements.txt" (
    echo 错误: 未找到requirements.txt文件
    echo 请确保在正确的目录中运行此脚本
    echo.
    echo 按任意键退出...
    pause >nul
    exit /b 1
)

echo 开始安装依赖包...
pip install -r requirements.txt
if errorlevel 1 (
    echo 错误: 依赖包安装失败
    echo 可能的原因:
    echo 1. 网络连接问题
    echo 2. Python版本不兼容
    echo 3. 某些包安装失败
    echo.
    echo 尝试单独安装每个包...
    pip install flask
    pip install websockets
    pip install Pillow
    pip install google-generativeai
    if errorlevel 1 (
        echo 错误: 依赖包安装仍然失败
        echo 按任意键退出...
        pause >nul
        exit /b 1
    )
)

echo 依赖包安装完成！
echo.
echo 正在创建目录结构...
if not exist "templates" (
    mkdir templates
    echo 创建templates目录
)
if not exist "static" (
    mkdir static
    echo 创建static目录
)

echo.
echo 正在检查配置文件...
if not exist "config.json" (
    echo 创建配置文件模板...
    (
        echo {
        echo     "gemini_api_key": "YOUR_GEMINI_API_KEY_HERE",
        echo     "server_port": 8080,
        echo     "websocket_port": 8765
        echo }
    ) > config.json
    echo 配置文件已创建
) else (
    echo 配置文件已存在
)

echo.
echo ========================================
echo            安装完成！
echo ========================================
echo.
echo 使用步骤:
echo 1. 编辑 config.json 文件，填入您的 Gemini API 密钥
echo 2. 运行 start.bat 启动服务器
echo 3. 用手机浏览器访问 http://您的电脑IP:8080
echo.
echo 获取 Gemini API 密钥:
echo https://makersuite.google.com/app/apikey
echo.
echo 注意: 服务器将在虚拟环境 'venv' 中运行
echo.
echo 按任意键退出...
pause >nul