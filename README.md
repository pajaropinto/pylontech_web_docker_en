Pylontech Monitor for Home Assistant



Pylontech Monitor is a complete and robust application designed to monitor Pylontech battery systems through an LV-Hub, collecting real-time data and publishing it to an MQTT broker for integration with Home Assistant and other automation platforms.

📋 Introduction
This application connects directly either to the "Console" port of the main battery or to a Pylontech LV-Hub (if installed) via a Serial/TCP/IP interface.
It retrieves detailed cell-level battery data, processes system-wide and per-battery totals, and publishes all data as JSON over MQTT.

It includes a built-in web interface that allows you to:

View real-time system totals and individual battery data
Configure system parameters (interface IP, MQTT broker, number of batteries, etc.)
Access detailed per-cell data for each battery
The application is designed to run continuously in a Docker container, ensuring high availability and easy deployment.

🏗️ Architecture and Modules
🧠 Core Module (C++)
The heart of the application is written in C++ and performs the following functions:

LV-Hub Connection and Communication
Connects to the battery or LV-Hub via TCP/IP
Sends stat commands to retrieve battery cycle counts
Sends bat commands to retrieve detailed cell data
Implements automatic retries and robust data validation
Handles configurable delays between readings
Data Processing
Per-battery totals: Calculates total voltage (sum of cells), average current, average temperature, average SOC, charge/discharge status, alarms, and remaining capacity
System totals: Aggregates data from all batteries (average voltage, total current, average temperature, average SOC, etc.)
Data validation: Filters invalid values, NaN, and out-of-range data
Auto-reload: Reads the configuration file on every cycle to apply changes in real time
MQTT Publishing
Publishes raw per-battery data to topics: homeassistant/pylon/bat01, bat02, ..., bat15
Publishes per-battery totals to: homeassistant/pylon/total_battery
Publishes system totals to: homeassistant/pylon/total_system
Supports MQTT authentication and persistent connection
Built-in Web Server
Serves static files (HTML, CSS, JS)
Provides REST API for configuration management (GET /api/config, POST /api/config)
Includes WebSocket MQTT support for real-time updates
🌐 Web Interface
The web interface includes three main tabs:

Tab 1: Totals
Shows system totals table (voltage, current, temperature, SOC, status, coulomb, cycles)
Displays summary table for all batteries
Visual MQTT connection status indicator (discreet and at the top)
Tab 2: Batteries
Shows a detailed table for each battery
Each table includes all cell data (voltage, current, temperature, SOC, status, coulomb, balance)
Real-time automatic updates from MQTT
Tab 3: Configuration
Centered form with all system parameters
Labels aligned left, input fields aligned right
Load and save configuration buttons
Numeric field validation
📁 File Structure
12345678910
.├── Dockerfile                 # Docker container definition├── src/│   └── main.cpp              # Main C++ source code├── www/│   ├── index.html            # Main page with three tabs│   ├── script.js             # JavaScript logic (tab switching, MQTT, configuration)│   └── style.css             # CSS styles└── config/    └── app_config.json       # Configuration file (automatically created if missing)

⚙️ Configuration
The app_config.json file contains the following parameters:

json
123456789101112
{    "num_batteries": 15,    "delay_between_batteries": 1000,    "delay_between_cycle_battery": 1,    "battery_tcp_ip": "10.0.0.234",    "battery_tcp_port": 10034,    "mqtt_broker_ip": "10.0.0.250",    "mqtt_broker_port": 1883,    "mqtt_broker_ws_port": 9001,    "mqtt_user": "fernan",    "mqtt_password": "Nabucodonos0_"}

num_batteries: Number of batteries to monitor (1-16)
delay_between_batteries: Delay between consecutive battery readings (ms)
delay_between_cycle_battery: Complete BAT reading cycle duration (minutes)
battery_tcp_ip/port: LV-Hub address and port
mqtt_broker_*: MQTT broker configuration (including WebSocket port for web interface)
🐳 Docker Deployment
Download from Docker Hub
The image is publicly available on Docker Hub:

bash
1
docker pull pajaropinto/pylontech_monitor_es:latest

Run
bash
123456
docker run -d \  --name pylontech_monitor \  --network host \  -v $(pwd)/config:/app/config \  -v $(pwd)/www:/app/www \  pajaropinto/pylontech_monitor_es:2.1

Docker Compose
yaml
1234567891011
services:  pylontech-monitor:    image: pajaropinto/pylontech_monitor_es:latest    container_name: pylontech-monitor    volumes:      - /main/storage/docker/pylontech_monitor/config:/config      - /main/storage/docker/pylontech_monitor/log:/log    restart: always    network_mode: host    ports:      - "61616:61616"

Runtime Parameters
--network host: Enables direct access to port 61616 for the web interface
-v config:/app/config: Mounts configuration directory for persistence
-v www:/app/www: Mounts web files (optional, already included in image)
🌐 Web Interface Access
Once running, access the web interface at:

1
http://[SERVER_IP]:61616

📊 Published MQTT Topics
Topic
Content
homeassistant/pylon/bat01 - bat15
Raw per-cell data for each battery
homeassistant/pylon/total_battery
Aggregated per-battery totals
homeassistant/pylon/total_system
Complete system totals
🔒 Robustness Features
Data validation: Rejects invalid values and retries readings
Auto-reload: Applies configuration changes without restarting
Persistent connection: Automatically reconnects to LV-Hub and MQTT broker
No blocking: Responsive web interface with no freezes
Static compilation: Lightweight Docker image with no external dependencies
📝 Additional Notes
Battery/LV-Hub connection requirements: Requires a Serial/TCP interface configured according to application parameters
MQTT Broker: Must have WebSocket enabled on port 9001 for the web interface
Home Assistant: Data integrates seamlessly with Home Assistant MQTT sensors
Updates: Configuration can be modified in real-time from the web interface
📄 License
This project is open source and available under the MIT license.

Developed for the Home Assistant and solar energy community
Version 2.1 - Available on Docker Hub
