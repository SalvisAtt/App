@echo off

:: Define variables for easy configuration
set WEB_SERVICE_VENV_NAME=web-service-env
set TKINTER_CLIENT_VENV_NAME=tkinter-client-env
set EXPO_CLIENT_VENV_NAME=expo-client-env
set PROJECT_NAME=ai-chat-app
set GITHUB_REPO=https://github.com/ingus-t/ai-chat-app.git
set ORIGIN_REPO=git@github.com:your-username/your-repository.git

:: Get the current timestamp in a format suitable for file names: YYYY-MM-DD_HH-MM-SS
for /f "tokens=1-4 delims=/-. " %%A in ('echo %date% %time%') do (
    for /f "tokens=1-4 delims= " %%A in ('wmic os get localdatetime ^| find "."') do set datetime=%%A
    set timestamp=%datetime:~0,8%_%datetime:~8,6%
)

:: Set the log file name
set LOG_FILE=logs\setup_log_%timestamp%.txt

:: Redirect all output (stdout and stderr) to the log file
(

    :: Create a logs folder if it doesn't exist
    echo Step 0: checking logs folder
    if not exist logs (
        mkdir logs
        echo created a logs folder...
    ) else (
        echo logs folder already exists...
    )

    :: Step 1: Check if Git is installed
    echo Step 1: Checking if Git is installed...
    git --version >nul 2>&1
    if %ERRORLEVEL% neq 0 (
        echo Git is not installed. Downloading Git...
        start https://git-scm.com/download/win
        echo Please install Git and run this script again.
        pause
        exit /b 1
    ) else (
        echo Git is installed.
    )

    :: Step 2: Check if Python is installed
    echo Step 2: Checking if Python is installed...
    python --version >nul 2>&1

    python -c "import sys; assert sys.version_info.major >= 3"
    if ERRORLEVEL 1 (
        echo Python 3.x is required. Please install Python 3.x and run this script again.
        exit /b
    )

    if %ERRORLEVEL% neq 0 (
        echo "python" command not found, checking for "python3"...
        python3 --version >nul 2>&1
        if %ERRORLEVEL% neq 0 (
            echo Python is not installed. Downloading Python...
            start https://www.python.org/downloads/
            echo Please install Python and run this script again.
            pause
            exit /b 1
        ) else (
            echo Python is installed as "python3".
            set PYTHON_CMD=python3
        )
    ) else (
        echo Python is installed as "python".
        echo Please verify that python v3.x is on your system. It is possible that "python" refers to Python 2.x.
        set PYTHON_CMD=python
    )

    echo Using Python command: %PYTHON_CMD%

    :: Step 3: Clone the source repository
    echo Step 3: Cloning the GitHub repository...
    git clone %GITHUB_REPO%
    cd %PROJECT_NAME%

    if ERRORLEVEL 1 (
        echo Failed to clone the repository. Check your internet connection or the repository URL.
        exit /b 1
    )

    :: Step 4: Set student's GitHub repository as origin
    echo Step 4: Setting your own repository as the origin...
    git remote add origin %ORIGIN_REPO%
    git remote -v

    :: Step 5: GitHub global credential configuration
    :: Ask user if they want to save GitHub credentials globally
    echo Step 5: GitHub credentials
    echo Do you want to save your GitHub credentials globally? (y/n)
    set /p SAVE_GLOBAL=Enter y for Yes or n for No: 

    if /i "%SAVE_GLOBAL%"=="y" (
        echo Please enter your GitHub details.

        :: Prompt for GitHub credentials
        set /p GITHUB_USERNAME=Enter your GitHub username: 
        set /p GITHUB_EMAIL=Enter your GitHub email: 
        set /p GITHUB_PASSWORD=Enter your GitHub password: 

        :: Save GitHub username, email, and password globally
        git config --global user.name "%GITHUB_USERNAME%"
        git config --global user.email "%GITHUB_EMAIL%"
        git config --global user.password "%GITHUB_PASSWORD%"

        echo GitHub credentials have been configured globally.
    ) else (
        echo Skipping global GitHub credentials setup. Ensure you have configured authentication via SSH or other methods.
    )

    :: Step 6: Create the virtual environments
    echo Step 6: Creating virtual environments...
    echo   for web-service, it is called: %WEB_SERVICE_VENV_NAME%
    cd web-service
    if not exist %WEB_SERVICE_VENV_NAME% (
        %PYTHON_CMD% -m venv %WEB_SERVICE_VENV_NAME%
    ) else (
        echo Virtual environment %WEB_SERVICE_VENV_NAME% already exists. Not overwriting...
    )
    cd ..

    echo   for tkinter-client, it is called: %TKINTER_CLIENT_VENV_NAME%
    cd tkinter-client
    if not exist %TKINTER_CLIENT_VENV_NAME% (
        %PYTHON_CMD% -m venv %TKINTER_CLIENT_VENV_NAME%
    ) else (
        echo Virtual environment %TKINTER_CLIENT_VENV_NAME% already exists. Not overwriting...
    )
    cd ..

    echo   for expo-client, it is called: %EXPO_CLIENT_VENV_NAME%
    cd expo-client
    if not exist %EXPO_CLIENT_VENV_NAME% (
        %PYTHON_CMD% -m venv %EXPO_CLIENT_VENV_NAME%
    ) else (
        echo Virtual environment %EXPO_CLIENT_VENV_NAME% already exists. Not overwriting...
    )
    cd ..

    :: Step 7: Install sub-project dependencies
    echo STEP 7: Installing sub-project dependencies...

    echo   for web-service...
    cd web-service
    call %WEB_SERVICE_VENV_NAME%\Scripts\activate
    pip install -r requirements.txt
    cd ..

    echo   for tkinter-client...
    cd tkinter-client
    call %TKINTER_CLIENT_VENV_NAME%\Scripts\activate
    pip install -r requirements.txt
    cd ..

    echo   for expo-client...
    cd expo-client
    call %EXPO_CLIENT_VENV_NAME%\Scripts\activate
    pip install -r requirements.txt
    cd ..

    :: Unset GitHub credential variables
    set GITHUB_USERNAME=
    set GITHUB_EMAIL=
    set GITHUB_PASSWORD=

    :: Pause for review
    pause
) >> %LOG_FILE% 2>&1