# jar-lua-elf-script

This script generates an HTML page that simplifies the process of sending JAR, LUA, or ELF files to remote devices using `socat` and `python`.

## Prerequisites

- A Unix-like shell-compatible system (e.g., Linux, macOS)
- The following tools installed:
  - `socat`
  - `python`
  - `lighttpd` (or another web server capable of running shell scripts)

You can install the required tools using your package manager. For example, on Debian-based systems:

```
sudo apt-get install socat python lighttpd
```

## Configuration

Before using, make sure to configure the paths and IP address in the script:

- `ip="10.0.0.1"`: Replace with the IP address of the target device.
- Update the file paths for the .jar, .lua, and .elf files to point to their correct locations on your system.
- Copy the jar-lua-elf-script.sh script to /var/www/html/ or another location served by your lighttpd web server.

Got it! Here's the revised section of your `README.md` with that clarification:

## Creating a Queue File

You can automate sending multiple commands by placing a `.queue` text file in the `queue_path` directory.  This file should contain lines of shell-compatible commands that will be read and executed by the script. Here's how to create a simple example.queue file with three commands:

```bash
python /home/pi/lua/send_lua.py 10.0.0.1 9026 /home/pi/lua/hello.lua
sleep 5
socat FILE:/home/pi/elf/hello.elf TCP:10.0.0.1:9021
```

## Usage

1. Make sure lighttpd is running and serving the script from the correct location.

2. Open a browser and navigate to the following URL:

```
http://<lighttpd_host_ip>:<port>/jar-lua-elf-script.sh
```

Replace <lighttpd_host_ip> with the IP address of your lighttpd server, and <port> with the port number (usually 80 unless configured otherwise).

3. Follow the instructions on the generated HTML page to send the JAR, LUA, or ELF files to the target device.

Notes

- Ensure that the target device is reachable from the host machine.
- The script uses socat for transferring the files and python for managing the server-side operations.
- Modify file paths and configurations as needed for your specific use case.
- send_lua.py must be in the same root location as .lua files