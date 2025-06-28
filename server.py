import asyncio
import websockets
import json
import base64
import io
from PIL import ImageGrab
import google.generativeai as genai
from flask import Flask, render_template, send_from_directory
import threading
import time
import os
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RemoteControlServer:
    def __init__(self):
        self.app = Flask(__name__)
        self.clients = set()
        self.gemini_api_key = None
        self.load_config()
        self.setup_routes()
        
    def load_config(self):
        """Load configuration file"""
        try:
            if os.path.exists('config.json'):
                with open('config.json', 'r') as f:
                    config = json.load(f)
                    self.gemini_api_key = config.get('gemini_api_key')
            else:
                # Create default configuration file
                config = {
                    "gemini_api_key": "YOUR_GEMINI_API_KEY_HERE",
                    "server_port": 8080,
                    "websocket_port": 8765
                }
                with open('config.json', 'w') as f:
                    json.dump(config, f, indent=4)
                logger.info("Created config.json file, please add your Gemini API key")
        except Exception as e:
            logger.error(f"Failed to load configuration file: {e}")

    def setup_routes(self):
        """Setup Flask routes"""
        @self.app.route('/')
        def index():
            return render_template('mobile.html')
        
        @self.app.route('/static/<path:filename>')
        def static_files(filename):
            return send_from_directory('static', filename)

    def capture_screen(self):
        """Capture screen"""
        try:
            screenshot = ImageGrab.grab()
            buffer = io.BytesIO()
            screenshot.save(buffer, format='PNG')
            img_data = buffer.getvalue()
            return base64.b64encode(img_data).decode('utf-8')
        except Exception as e:
            logger.error(f"Screenshot failed: {e}")
            return None

    async def query_gemini(self, image_data, question):
        """Query Gemini API"""
        try:
            if not self.gemini_api_key or self.gemini_api_key == "YOUR_GEMINI_API_KEY_HERE":
                return "Error: Please configure a valid Gemini API key in config.json"
            
            genai.configure(api_key=self.gemini_api_key)
            model = genai.GenerativeModel('gemini-1.5-flash')
            
            # Decode image data
            img_bytes = base64.b64decode(image_data)
            img = io.BytesIO(img_bytes)
            
            # Build prompt
            prompt = f"Please analyze this screenshot and answer the following question: {question}"
            
            response = model.generate_content([prompt, {"mime_type": "image/png", "data": img_bytes}])
            return response.text
        except Exception as e:
            logger.error(f"Gemini query failed: {e}")
            return f"Query failed: {str(e)}"

    async def handle_websocket(self, websocket, path):
        """Handle WebSocket connections"""
        self.clients.add(websocket)
        logger.info(f"New client connected: {websocket.remote_address}")
        
        try:
            async for message in websocket:
                try:
                    data = json.loads(message)
                    command = data.get('command')
                    
                    if command == 'screenshot':
                        # Execute screenshot
                        img_data = self.capture_screen()
                        if img_data:
                            await websocket.send(json.dumps({
                                'type': 'screenshot',
                                'data': img_data,
                                'timestamp': datetime.now().isoformat()
                            }))
                        else:
                            await websocket.send(json.dumps({
                                'type': 'error',
                                'message': 'Screenshot failed'
                            }))
                    
                    elif command == 'ai_query':
                        # AI query
                        question = data.get('question', '')
                        image_data = data.get('image_data', '')
                        
                        if not question:
                            await websocket.send(json.dumps({
                                'type': 'error',
                                'message': 'Question cannot be empty'
                            }))
                            continue
                        
                        # If no image data, take screenshot first
                        if not image_data:
                            image_data = self.capture_screen()
                        
                        if image_data:
                            # Query AI
                            answer = await self.query_gemini(image_data, question)
                            await websocket.send(json.dumps({
                                'type': 'ai_response',
                                'question': question,
                                'answer': answer,
                                'timestamp': datetime.now().isoformat()
                            }))
                        else:
                            await websocket.send(json.dumps({
                                'type': 'error',
                                'message': 'Unable to get screenshot'
                            }))
                    
                    elif command == 'ping':
                        await websocket.send(json.dumps({
                            'type': 'pong',
                            'timestamp': datetime.now().isoformat()
                        }))
                        
                except json.JSONDecodeError:
                    await websocket.send(json.dumps({
                        'type': 'error',
                        'message': 'Invalid JSON format'
                    }))
                except Exception as e:
                    logger.error(f"Failed to process message: {e}")
                    await websocket.send(json.dumps({
                        'type': 'error',
                        'message': f'Processing failed: {str(e)}'
                    }))
                    
        except websockets.exceptions.ConnectionClosed:
            logger.info("Client connection closed")
        except Exception as e:
            logger.error(f"WebSocket handling exception: {e}")
        finally:
            self.clients.discard(websocket)

    def run_websocket_server(self):
        """Run WebSocket server"""
        try:
            # Create new event loop for current thread
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            
            # Create WebSocket server
            start_server = websockets.serve(self.handle_websocket, "0.0.0.0", 8765)
            
            # Start server
            loop.run_until_complete(start_server)
            logger.info("WebSocket server started on port 8765")
            
            # Run event loop
            loop.run_forever()
        except Exception as e:
            logger.error(f"WebSocket server startup failed: {e}")
        finally:
            try:
                loop.close()
            except:
                pass

    def run_flask_app(self):
        """Run Flask application"""
        logger.info("Flask server started on port 8080")
        self.app.run(host='0.0.0.0', port=8080, debug=False)

    def start(self):
        """Start server"""
        # Create necessary directories
        os.makedirs('templates', exist_ok=True)
        os.makedirs('static', exist_ok=True)
        
        # Start WebSocket server thread
        websocket_thread = threading.Thread(target=self.run_websocket_server, daemon=True)
        websocket_thread.start()
        
        # Start Flask application
        try:
            self.run_flask_app()
        except KeyboardInterrupt:
            logger.info("Server stopped")

if __name__ == "__main__":
    server = RemoteControlServer()
    server.start()