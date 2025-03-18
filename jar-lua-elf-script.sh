#!/bin/sh

# Define device IP, paths and ports
ip="10.0.0.1"
jar_path="/home/pi/jar/"
lua_path="/home/pi/lua/"
elf_path="/home/pi/elf/"

jar_port="9025"
lua_port="9026"
elf_port="9021"

# Function to render the payload buttons
payload_button() {
  local label="$1"
  local payload_value="$2"
  local current_payload="$3"
  local status="$4"

  if [ "$current_payload" != "" ] && [ "$current_payload" = "$payload_value" ]; then
    status="button"
  fi

  # Remove extensions and truncate the label to 8 characters
  label="${label%.*}"
  if [ ${#label} -gt 10 ]; then
    label=$(echo "$label" | cut -c 1-10)..
  fi

  echo "<td><form method=\"post\"><div>"
  echo "<input name=\"selected_payload\" type=\"hidden\" value=\"$payload_value\"/>"
  echo "<input type=\"submit\" value=\"$label\" class=\"$status\"/>"
  echo "</div></form></td>"
}

# Function to parse query string
parse_query_string() {
  local query="$1"
  local key="$2"
  echo "$query" | sed "s/&/\n/g" | grep -oP "^$key=\K.*" | head -n 1
}

# Function to get payload filenames from directories
get_filenames_from_directory() {
  local directory="$1"
  local extension="$2"
  find "$directory" -maxdepth 1 -type f -name "*.$extension" -exec basename {} \; | sort
}

# Function to render a category of payloads
render_category() {
  local category_name="$1"
  local payloads="$2"
  local selected_payload="$3"

  # Only render the category if there are payloads
  if [ -n "$payloads" ]; then
    echo "<tr><th colspan=\"5\">$category_name</th></tr><tr>"
    counter=0
    for payload in $payloads; do
      payload_button "$payload" "$payload" "$selected_payload" "default"
      counter=$((counter + 1))
      if [ $((counter % 3)) -eq 0 ]; then
        echo "</tr><tr>"
      fi
    done
    echo "</tr>"
  fi
}

# Main function
main() {
  local selected_payload=""
  local file_type=""
  local port=""
  local path=""
  local output=""

  # Parse query string from POST request
  if [ "$REQUEST_METHOD" = "POST" ]; then
    read QUERY_STRING
    selected_payload=$(parse_query_string "$QUERY_STRING" "selected_payload")
  fi

  # Start generating HTML
  echo "<div id=\"function\"><table>"

  # Get and render payload categories dynamically
  for category_info in \
    "JAR $jar_path jar" \
    "LUA $lua_path lua" \
    "ELF $elf_path elf"; do

    # Extract category info
    set -- $category_info
    category_name="$1"
    category_path="$2"
    category_extension="$3"

    # Get payloads and render them
    payloads=$(get_filenames_from_directory "$category_path" "$category_extension")
    render_category "$category_name" "$payloads" "$selected_payload"
  done

  echo "</table></div>"

  # Verify if selected_payload is defined
  if [ -n "$selected_payload" ]; then
    file_type="${selected_payload##*.}"

    # Determine port and path
    case "$file_type" in
      "jar") port="$jar_port"; path="$jar_path" ;;
      "lua") port="$lua_port"; path="$lua_path" ;;
      "elf") port="$elf_port"; path="$elf_path" ;;
    esac

    # Send the selected_payload and capture the output
    case "$file_type" in
      "jar"|"elf") output=$(socat FILE:"$path$selected_payload" TCP:"$ip":"$port" 2>&1) ;;
      "lua") output=$(python "$path/send_lua.py" "$ip" "$port" "$path$selected_payload" 2>&1) ;;
    esac
  fi

  # Print the output
  if [ -n "$output" ]; then
    echo "<div><h3>Terminal Output:</h3><pre>$output</pre></div>"
  elif [ -n "$selected_payload" ]; then
    echo "<div>$selected_payload sent to $ip:$port</div>"
  fi

  # Close HTML tags
  echo "</div></body></html>"
}

# Output HTML header
echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>jar-lua-elf-script</title>
    <style>
        body { font-size: 0.85em; font-family: Arial, sans-serif; }
        #function .button { background: #fffbff; }
        #function input { color: #000; background: #ddd; border: none; font-size: 1.1em; height: 4.5em; 
width: 100%; padding: 0.5em; }
        #function td, #function th { height: 3.5em; text-align: center; }
        #function th { background: #555; color: #fff; font-weight: normal; }
        pre { white-space: pre-wrap; word-wrap: break-word; }
    </style>
</head>
<body>'

# Call the main function
main
