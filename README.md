# Interview.AI

A locally deployed tool that supports mobile control of PC screenshots and analysis through Google Gemini AI.

## Features

- 🖥️ **Remote Screenshot**: One-click PC screen capture control from mobile
- 🤖 **AI Analysis**: Integrated Google Gemini for intelligent screen content analysis
- 📱 **Mobile Optimized**: Responsive design, perfectly adapted for mobile interface
- 🔒 **Local Deployment**: No cloud services required, data security controllable
- ⚡ **Real-time Communication**: WebSocket implementation for low-latency bidirectional communication
- 🎨 **Modern Interface**: Beautiful gradient design and smooth animations
- 🐍 **Environment Isolation**: Supports Conda virtual environment to avoid dependency conflicts

## Quick Start

### Requirements

- Windows 10/11
- Python 3.8+ or Anaconda/Miniconda
- Google Gemini API Key (free)

### File Structure

```
remote-control-tool/
├── server.py              # Main server program
├── requirements.txt       # Python dependencies
├── config.json           # Configuration file (auto-generated)
├── setup.bat            # One-click installation script
├── start.bat            # System Python startup script
├── start_venv.bat       # Conda environment startup script
├── check_env.bat        # Environment check tool
├── templates/
│   └── mobile.html      # Mobile interface
├── static/              # Static resources directory
├── logs/                # Logs directory
└── README.md           # Usage instructions
```

### Installation Steps

#### Method 1: Using Conda Environment (Recommended)

1. **Ensure Conda is installed**
   - Download [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or Anaconda

2. **Run installation script**
   ```batch
   Double-click to run setup.bat
   ```

3. **Environment check**
   ```batch
   Double-click to run check_env.bat to check installation status
   ```

4. **Configure API key**
   - Visit [Google AI Studio](https://aistudio.google.com/app/apikey) to get free API key
   - Edit `config.json` file, replace `YOUR_GEMINI_API_KEY_HERE`

5. **Start server**
   ```batch
   Double-click to run start_venv.bat (Recommended - Conda environment)
   or
   Double-click to run start.bat (System Python environment)
   ```

#### Method 2: Using System Python

1. **Ensure Python 3.8+ is installed**
2. **Run installation script** (will provide API key configuration options)

### Configure API Key

1. **Visit Google AI Studio**
   - Get free API key
   - Add key to `.env` file or directly edit `config.json`

### Start Server

```bash
python server.py
```

## Usage

### PC Operations
1. Run `start.bat` to start server
2. Note the displayed IP address
3. Keep program running

### Mobile Operations
1. Open browser and visit PC IP address
2. Wait for connection status to show "Connected"
3. Click "Take Screenshot" to get PC screen
4. Enter question in text box, click "Ask AI"
5. View AI analysis results and history

## Configuration

### config.json Parameters
```json
{
    "gemini_api_key": "your_api_key",
    "server_port": 8080,        // Web service port
    "websocket_port": 8765,     // WebSocket port
    "allow_remote_access": true,
    "max_screenshot_size": "1920x1080",
    "ai_model": "gemini-1.5-flash"
}
```

## Technical Architecture

### Backend Architecture
- **Flask**: Web server, provides mobile interface
- **WebSocket**: Real-time bidirectional communication
- **PIL**: Screen capture functionality
- **Google Generative AI**: AI analysis capabilities

### Frontend Architecture
- **Pure HTML/CSS/JS**: No framework dependencies, lightweight
- **Responsive Design**: Adapts to various mobile devices
- **WebSocket Client**: Real-time communication
- **Modern UI**: Gradient backgrounds, glassmorphism effects, smooth animations

### Communication Protocol
```javascript
// Screenshot request
{
    "command": "screenshot"
}

// AI query request
{
    "command": "ai_query",
    "question": "user_question",
    "image_data": "base64_image_data"
}

// Server response
{
    "type": "screenshot|ai_response|error",
    "data": "response_data",
    "timestamp": "timestamp"
}
```

## Security Considerations

- Only runs on local network, not exposed to internet
- No user authentication system, suitable for home/office internal use
- API keys stored locally, not uploaded to any server
- Screenshot data only transmitted in memory, not persistently stored

## Troubleshooting

### Common Issues

1. **Cannot connect to server**
   - Check firewall settings, allow ports 8080 and 8765
   - Ensure phone and PC are on same network
   - Try disabling Windows firewall

2. **Screenshot fails**
   - Check screen recording permissions
   - Ensure no fullscreen exclusive applications

3. **AI query fails**
   - Verify Gemini API key is correct
   - Check network connection
   - Ensure API quota not exhausted

4. **Dependency installation fails**
   - Update pip: `python -m pip install --upgrade pip`
   - Use domestic mirror: `pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt`

### Viewing Logs
Server displays detailed log information in console when running, including connection status, error messages, etc.

## Extension Features

Consider adding features:
- Multi-user support and authentication
- File transfer functionality
- Remote mouse/keyboard control
- Multi-screen support
- Screenshot history
- More AI model support

## License

This project is for learning and personal use only. Please comply with relevant laws and API service terms.

## Technical Support

If you encounter issues, please check:
1. Python and dependency package versions
2. Network connection status
3. API key configuration
4. Firewall settings

---

**Disclaimer**: This tool is for learning and research purposes only. Users are responsible for their own usage risks and must comply with local laws and regulations.