#!/bin/bash

# Check if the script is executed with sudo and determine the real user
if [ ! -z "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$(whoami)"
fi
echo "Real user: $REAL_USER"

# Use getent to get the path to the real user's home directory
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
echo "User's home directory: $USER_HOME"

# Define the Klipper directory using USER_HOME instead of HOME
KLIPPER_DIR="$USER_HOME/klipper"
echo "Klipper directory: $KLIPPER_DIR"

# Define the project directory
PROJECT_DIR="$PWD"
echo "Project directory: $PROJECT_DIR"

# Define the cleanup function
function cleanup {
  
}

# Check if the script was called with the "remove" argument
if [ "$1" == "remove" ]; then
  # Call the cleanup function
  cleanup
else
  # Create the variables.cfg file in the printer_data directory, if it doesn't exist
  if [ ! -f $USER_HOME/printer_data/config/variables.cfg ]; then
    touch $USER_HOME/printer_data/config/variables.cfg && echo "variables.cfg created successfully." || echo "Error creating variables.cfg."
  fi

  # Copy the project files to the Klipper directory
  cp $PROJECT_DIR/plr.cfg $USER_HOME/printer_data/config/ && echo "plr.cfg copied successfully." || echo "Error copying plr.cfg."
  # Use rsync to copy, overwriting existing files and create the folder if it does not exist
  rsync -av "$PROJECT_DIR/plr.sh" "$USER_HOME/printer_data/plr/" && echo "plr.sh copied successfully." || echo "Error copying plr.sh."
  # Use rsync to copy, overwriting existing files
  rsync -av "$PROJECT_DIR/clear_plr.sh" "$USER_HOME/printer_data/plr/" && echo "clear_plr.sh copied successfully." || echo "Error copying clear_plr.sh."
  cp $PROJECT_DIR/gcode_shell_command.py $KLIPPER_DIR/klippy/extras/ && echo "gcode_shell_command.py copied successfully." || echo "Error copying gcode_shell_command.py."

  # Make plr.sh & clear_plr.sh executable
  chmod +x $USER_HOME/printer_data/plr/plr.sh && echo "plr.sh made executable." || echo "Error making plr.sh executable."
  chmod +x $USER_HOME/printer_data/plr/clear_plr.sh && echo "clear_plr.sh made executable." || echo "Error making clear_plr.sh executable."

  # Check if printer.cfg exists, create it if it doesn't
  if [ ! -f $USER_HOME/printer_data/config/printer.cfg ]; then
      touch $USER_HOME/printer_data/config/printer.cfg && echo "printer.cfg created successfully." || echo "Error creating printer.cfg."
  fi

  # Check if the file exists
  if [ ! -f $USER_HOME/printer_data/config/printer.cfg ]; then
    echo "Error: $USER_HOME/printer_data/config/printer.cfg does not exist."
  fi

  # Check if the string is already present in the file
  if grep -Fxq '[include plr.cfg]' $USER_HOME/printer_data/config/printer.cfg; then
      echo "The string [include plr.cfg] is already present in the file."
  else
      # Create a temporary file
      temp_file=$(mktemp)

      # Add the line [include plr.cfg] at the beginning of the file
      echo "[include plr.cfg]" > "$temp_file"
      cat $USER_HOME/printer_data/config/printer.cfg >> "$temp_file"

      # Replace the original file with the temporary file
      mv "$temp_file" $USER_HOME/printer_data/config/printer.cfg

      # Check if the string was added successfully
      if grep -q '[include plr.cfg]' $USER_HOME/printer_data/config/printer.cfg; then
          echo "The string [include plr.cfg] was successfully added."
      else
          echo "Error: the string [include plr.cfg] was not added."
      fi
  fi

  # Check if the variables.cfg file exists
  if [ ! -f $USER_HOME/printer_data/config/variables.cfg ]; then
    echo "The file $USER_HOME/printer_data/config/variables.cfg does not exist. Creating..."
    # Attempt to create the variables.cfg file
    touch $USER_HOME/printer_data/config/variables.cfg

    # Check if the file was created successfully
    if [ -f $USER_HOME/printer_data/config/variables.cfg ]; then
      echo "The file $USER_HOME/printer_data/config/variables.cfg was created successfully."
    else
      echo "Error: Creating the file $USER_HOME/printer_data/config/variables.cfg failed."
    fi
  else
    echo "The file $USER_HOME/printer_data/config/variables.cfg already exists."
  fi

  # Check if the moonraker.conf file exists
  if [ ! -f $USER_HOME/printer_data/config/moonraker.conf ]; then
      echo "The file moonraker.conf does not exist, creating the file..."
      touch $USER_HOME/printer_data/config/moonraker.conf
  fi

  # Check if the string [include update_plr.cfg] is already present in the file
  if grep -Fxq "[include update_plr.cfg]" $USER_HOME/printer_data/config/moonraker.conf; then
      echo "The string [include update_plr.cfg] is already present in the file moonraker.conf."
  else
      echo "Adding the string [include update_plr.cfg] to the file moonraker.conf..."
      # Create a temporary file
      temp_file=$(mktemp)

      # Add the line [include update_plr.cfg] at the beginning of the file
      echo "[include update_plr.cfg]" > "$temp_file"
      cat $USER_HOME/printer_data/config/moonraker.conf >> "$temp_file"

      # Replace the original file with the temporary file
      mv "$temp_file" $USER_HOME/printer_data/config/moonraker.conf
  fi

  # Check if the update_plr.cfg file exists
  if [ -f $USER_HOME/printer_data/config/update_plr.cfg ]; then
      echo "The file update_plr.cfg already exists, deleting the file..."
      rm $USER_HOME/printer_data/config/update_plr.cfg
  fi

  # Create a new update_plr.cfg file with cat EOF
  echo "Creating a new update_plr.cfg file with cat EOF..."
  cat > $USER_HOME/printer_data/config/update_plr.cfg << EOF
# plr-klipper update_manager entry
[update_manager YUMI_PLR]
type: git_repo
path: ~/YUMI_PLR
origin: https://github.com/Yumi-Lab/YUMI_PLR.git
primary_branch: main
install_script: install.sh
is_system_service: False

EOF

  # Change permissions so the "pi" user retains rights on the files created or modified
  chown -R $REAL_USER:$REAL_USER $USER_HOME/printer_data/config/

  # Print a message to the user
  echo "Installation complete"
fi
