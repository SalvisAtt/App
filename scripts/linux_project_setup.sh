#!/bin/bash

# Define variables for easy configuration
# virtual environment names
WEB_SERVICE_VENV_NAME="web-service-env"
TKINTER_CLIENT_VENV_NAME="tkinter-client-env"
EXPO_CLIENT_VENV_NAME="expo-client-env"
PROJECT_NAME="ai-chat-app"
# source repository
GITHUB_REPO="https://github.com/ingus-t/ai-chat-app.git"
# your own repository
ORIGIN_REPO="git@github.com:ingus-t/my-new-ai-chat-app.git"

# Get the current timestamp in a format suitable for file names: YYYY-MM-DD_HH-MM-SS
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# Set the log file name
LOG_FILE="logs/setup_log_$timestamp.txt"

# Create a logs folder if it doesn't exist
echo "Step 0: Checking logs folder..."
mkdir -p logs

# Redirect all output (stdout and stderr) to the log file
exec > >(tee -a "$LOG_FILE") 2>&1

# Step 1: Check if Git is installed
echo "Step 1: Checking if Git is installed..."
if ! git --version &>/dev/null; then
    echo "Git is not installed. Installing Git..."
    sudo apt-get update
    sudo apt-get install -y git
    echo "Please run this script again after installing Git."
    exit 1
else
    echo "Git is installed."
fi

# Step 2: Check if Python is installed
echo "Step 2: Checking if Python is installed..."
if ! python3 --version &>/dev/null; then
    echo "Python is not installed. Installing Python..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-venv python3-pip
    echo "Please run this script again after installing Python."
    exit 1
else
    echo "Python is installed as 'python3'."
    PYTHON_CMD="python3"
fi

echo "Using Python command: $PYTHON_CMD"

# Step 2.1: Check if Node.js is installed
echo "Step 2.1: Checking if Node.js is installed..."
if ! command -v node &> /dev/null
then
    echo "Node.js is not installed."
    echo "Please install Node.js and run this script again."
    exit 1
else
    node_version=$(node --version)
    echo "Node.js version: $node_version"
fi

# Step 2.2: Check if npm is installed
echo "Step 2.2: Checking if npm is installed..."
if ! command -v npm &> /dev/null
then
    echo "npm is not installed."
    echo "Please install npm and run this script again."
    exit 1
else
    npm_version=$(npm --version)
    echo "npm version: $npm_version"
fi

# Step 3: Clone the repository
echo "Step 3: Cloning the GitHub repository..."
if ! git clone "$GITHUB_REPO"; then
    echo "Failed to clone the repository. Check your internet connection or the repository URL."
    exit 1
fi
cd "$PROJECT_NAME" || exit

# Step 4: Set student's GitHub repository as origin
echo "Step 4: Setting your own repository as the origin..."
git remote add origin "$ORIGIN_REPO"
git remote -v

# Step 5: GitHub global credential configuration
# Ask user if they want to save GitHub credentials globally
echo "Step 5: GitHub credentials"
read -p "Do you want to save your GitHub credentials globally? (y/n): " SAVE_GLOBAL

if [[ "$SAVE_GLOBAL" == "y" ]]; then
    echo "Please enter your GitHub details."

    # Prompt for GitHub credentials
    read -p "Enter your GitHub username: " GITHUB_USERNAME
    read -p "Enter your GitHub email: " GITHUB_EMAIL

    # Save GitHub username and email globally
    git config --global user.name "$GITHUB_USERNAME"
    git config --global user.email "$GITHUB_EMAIL"

    echo "GitHub credentials have been configured globally."
else
    echo "Skipping global GitHub credentials setup. Ensure you have configured authentication via SSH or other methods."
fi

# Step 6: Create the virtual environments
echo "Step 6: Creating virtual environments..."

create_venv() {
    local venv_name=$1
    if [[ ! -d "$venv_name" ]]; then
        echo "Creating virtual environment: $venv_name"
        $PYTHON_CMD -m venv "$venv_name"
    else
        echo "Virtual environment $venv_name already exists. Not overwriting..."
    fi
}

cd web-service
create_venv "$WEB_SERVICE_VENV_NAME"
cd ..

cd tkinter-client
create_venv "$TKINTER_CLIENT_VENV_NAME"
cd ..

cd expo-client
create_venv "$EXPO_CLIENT_VENV_NAME"
cd ..

# Step 7: Install sub-project dependencies
echo "STEP 7: Installing sub-project dependencies..."

install_dependencies() {
    local venv_name=$1
    echo "Installing dependencies for $venv_name..."
    source "$venv_name/bin/activate"
    pip install -r requirements.txt
    deactivate
}

cd web-service
install_dependencies "$WEB_SERVICE_VENV_NAME"
cd ..

cd tkinter-client
install_dependencies "$TKINTER_CLIENT_VENV_NAME"
cd ..

cd expo-client
npm install
cd ..

# Unset GitHub credential variables
unset GITHUB_USERNAME
unset GITHUB_EMAIL
unset GITHUB_PASSWORD

echo "Setup complete! Review the log file at $LOG_FILE"
