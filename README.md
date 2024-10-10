## Purpose
This is an example app that implements a web service and multiple client apps.

## Project structure
```
project_folder/
│
├── expo-client		# Mobile app example, it consumes the web service
├── scripts		    # scripts for installing Git, Python, creating environments, etc.
├── tkinter-client	# GUI app example, it consumes the web service
├── web-service		# FastAPI web service app with 2 methods
└── README.md
```

## Project setup
### Option 1: Locally on Windows
Execute the script `scripts/windows-project-setup.bat`.
You might need to run it in administrator mode. To run it, double-click on the file, or navigate to the project folder in the terminal and run `scripts/windows-project-setup.bat`.

### Option 2: Locally on Linux
Execute the script `./remove_git_credentials.sh`
```
.scripts/remove_git_credentials.sh
```

### Option 3: replit.com platform
web-service and tkinter-client can be easily set up in replit, expo-client cannot.

1. Have a GitHub account
2. Have a replit.com account
3. Import code from this repository to your replit account
4. Activate environment (create one if it does not exist)
5. Install dependencies
6. Start the project (refer to instructions from the sub-projedt readme file)

## Remove git credentials if you are on a public laptop
Run the correct file from `scripts` folder.

## Notes
### One repository for the web service and multiple clients
Web service and client apps are bundled in one repository.  
Each of these projects uses a separate environment, because a GUI app and a backend web service have different requirements/dependencies and this is how it (often) works in real life scenarios.  

### Environment management
Sub-projects use venv. It would be better to use Poetry or vu, but these would have to be installed (another step during setup). Consider using an alternative for your own personal projects.

### Ruff
Consider using Ruff