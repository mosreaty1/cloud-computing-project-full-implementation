# Running the Project in VS Code on Windows

Complete guide for developing and running the Cloud-Based Learning Platform in Visual Studio Code on Windows.

## 📋 Table of Contents

1. [Installing VS Code](#installing-vs-code)
2. [Required Extensions](#required-extensions)
3. [Opening the Project](#opening-the-project)
4. [First-Time Setup](#first-time-setup)
5. [Running Services](#running-services)
6. [Development Workflow](#development-workflow)
7. [Debugging](#debugging)
8. [Tips & Tricks](#tips--tricks)

## 🎯 Installing VS Code

### Step 1: Download and Install

1. Go to: https://code.visualstudio.com/
2. Click "Download for Windows"
3. Run the installer
4. **Important selections during install:**
   - ✅ Add "Open with Code" to context menu
   - ✅ Add to PATH
   - ✅ Register Code as editor for supported file types

### Step 2: Launch VS Code

```powershell
# From PowerShell, navigate to your project folder
cd C:\
code .
```

Or just open VS Code from Start Menu.

## 🔌 Required Extensions

### Must-Have Extensions (Install These First)

Open VS Code, press `Ctrl+Shift+X` to open Extensions, then search and install:

#### 1. **Docker** (by Microsoft)
- Extension ID: `ms-azuretools.vscode-docker`
- Why: Manage containers, view logs, build images
- Install: Search "Docker" → Click Install

#### 2. **PowerShell** (by Microsoft)
- Extension ID: `ms-vscode.powershell`
- Why: PowerShell syntax highlighting and debugging
- Install: Search "PowerShell" → Click Install

#### 3. **Python** (by Microsoft)
- Extension ID: `ms-python.python`
- Why: Python development for services
- Install: Search "Python" → Click Install

#### 4. **YAML** (by Red Hat)
- Extension ID: `redhat.vscode-yaml`
- Why: Docker Compose, Kubernetes files
- Install: Search "YAML" → Click Install

#### 5. **HashiCorp Terraform**
- Extension ID: `hashicorp.terraform`
- Why: Terraform syntax and validation
- Install: Search "Terraform" → Click Install

### Recommended Extensions

#### 6. **Remote - WSL** (by Microsoft)
- Extension ID: `ms-vscode-remote.remote-wsl`
- Why: Better Docker integration via WSL

#### 7. **GitLens**
- Extension ID: `eamodio.gitlens`
- Why: Enhanced Git capabilities

#### 8. **REST Client**
- Extension ID: `humao.rest-client`
- Why: Test APIs directly from VS Code

#### 9. **Error Lens**
- Extension ID: `usernamehw.errorlens`
- Why: Inline error messages

#### 10. **Better Comments**
- Extension ID: `aaron-bond.better-comments`
- Why: Color-coded comments

### Install All Extensions at Once

Create file `.vscode/extensions.json`:

```json
{
  "recommendations": [
    "ms-azuretools.vscode-docker",
    "ms-vscode.powershell",
    "ms-python.python",
    "redhat.vscode-yaml",
    "hashicorp.terraform",
    "ms-vscode-remote.remote-wsl",
    "eamodio.gitlens",
    "humao.rest-client",
    "usernamehw.errorlens",
    "aaron-bond.better-comments"
  ]
}
```

VS Code will prompt to install all recommended extensions!

## 📂 Opening the Project

### Method 1: From VS Code

1. Open VS Code
2. File → Open Folder
3. Navigate to `C:\cloud-computing-project-full-implementation`
4. Click "Select Folder"

### Method 2: From PowerShell

```powershell
cd C:\cloud-computing-project-full-implementation
code .
```

### Method 3: Right-Click Context Menu

1. Navigate to project folder in File Explorer
2. Right-click on folder
3. Select "Open with Code"

## ⚙️ First-Time Setup

### Step 1: Open Integrated Terminal

Press `` Ctrl+` `` (backtick) or View → Terminal

**Make sure it's PowerShell:**
- Look at terminal dropdown (should say "PowerShell")
- If not, click dropdown → Select "PowerShell"

### Step 2: Run Setup Script

In the VS Code terminal:

```powershell
# Run setup script
.\scripts\setup-local.ps1

# This will:
# ✓ Check prerequisites (Docker, Git)
# ✓ Create .env file
# ✓ Generate secure secrets
# ✓ Create directories
```

### Step 3: Configure Environment

```powershell
# Open .env file in VS Code
code .env
```

**Add your configuration:**

```ini
# Get from https://platform.openai.com/api-keys
OPENAI_API_KEY=sk-your-actual-key-here

# Generated secrets (copy from setup script output)
JWT_SECRET=your-generated-jwt-secret
DB_PASSWORD=your-generated-db-password

# AWS (for deployment - optional for local)
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012
```

Save the file: `Ctrl+S`

### Step 4: Verify Docker Desktop

Make sure Docker Desktop is running:
- Check system tray for whale icon
- Should NOT say "Docker Desktop is starting..."

If not running:
1. Open Docker Desktop from Start Menu
2. Wait for it to fully start
3. Continue when ready

## 🚀 Running Services

### Using VS Code Docker Extension

#### View Docker Extension

Click Docker icon in left sidebar (whale icon)

You'll see:
- Containers
- Images
- Registries
- Networks
- Volumes

#### Start All Services

**Option 1: Using Docker Compose File**

1. In VS Code Explorer, find `docker-compose.yml`
2. Right-click on it
3. Select "Compose Up"
4. Wait 2-3 minutes for initialization

**Option 2: Using Terminal**

```powershell
# Start all services
docker-compose up -d

# View logs in real-time
docker-compose logs -f
```

**Option 3: Using Docker Extension**

1. Right-click on `docker-compose.yml` in Docker Extension
2. Click "Compose Up"

#### Check Service Status

**In Docker Extension:**
- Expand "Containers"
- Should see all services with green dots
- Right-click any service → "View Logs"

**In Terminal:**

```powershell
# Check service health
.\scripts\health-check.ps1

# Or manually
docker-compose ps
```

### Access Services

Open in your browser:
- **API Gateway**: http://localhost:8000/health
- **TTS Service**: http://localhost:8001/health
- **STT Service**: http://localhost:8002/health
- **Chat Service**: http://localhost:8003/health
- **Document Reader**: http://localhost:8004/health
- **Quiz Service**: http://localhost:8005/health

## 💻 Development Workflow

### Working with Services

#### 1. View Service Logs

**Using Docker Extension:**
1. Expand "Containers"
2. Right-click service (e.g., "tts-service")
3. Select "View Logs"
4. Logs open in new terminal

**Using Terminal:**

```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f tts-service

# Exit with Ctrl+C
```

#### 2. Restart a Service

**After making code changes:**

```powershell
# Rebuild and restart specific service
docker-compose up -d --build tts-service

# Or restart without rebuild
docker-compose restart tts-service
```

**Using Docker Extension:**
1. Right-click service
2. Select "Restart"

#### 3. Stop Services

```powershell
# Stop all services
docker-compose down

# Stop and remove volumes (fresh start)
docker-compose down -v
```

### Editing Service Code

#### 1. Navigate to Service

```
services/
├── tts-service/
│   ├── src/
│   │   ├── main.py          ← Edit this
│   │   ├── models.py
│   │   └── services/
│   ├── Dockerfile
│   └── requirements.txt
```

#### 2. Make Changes

Edit files in VS Code with full IntelliSense support.

#### 3. Test Changes Locally

**Option A: Run service directly (faster for development)**

```powershell
# Stop Docker version first
docker-compose stop tts-service

# Navigate to service
cd services\tts-service

# Create virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt

# Run service directly
$env:AWS_ENDPOINT_URL="http://localhost:4566"
$env:S3_BUCKET_NAME="tts-service-storage-dev"
python -m uvicorn src.main:app --reload --port 8001

# Service will auto-reload on code changes!
```

**Option B: Rebuild Docker container**

```powershell
# From project root
docker-compose up -d --build tts-service
```

### Testing APIs

#### Using REST Client Extension

Create file `tests/api-test.http`:

```http
### Health Check
GET http://localhost:8000/health

### Test TTS
POST http://localhost:8000/api/tts/synthesize
Content-Type: application/json

{
  "text": "Hello from VS Code",
  "language": "en",
  "user_id": "test-user"
}

### Test with variable
@apiUrl = http://localhost:8000

GET {{apiUrl}}/health
```

Click "Send Request" above each request to test!

#### Using PowerShell in Terminal

```powershell
# Test TTS
$body = @{
    text = "Testing from VS Code"
    language = "en"
    user_id = "test-user"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8000/api/tts/synthesize" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

## 🐛 Debugging

### Debug Python Service

#### 1. Create Launch Configuration

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: TTS Service",
      "type": "python",
      "request": "launch",
      "module": "uvicorn",
      "args": [
        "src.main:app",
        "--reload",
        "--port",
        "8001"
      ],
      "cwd": "${workspaceFolder}/services/tts-service",
      "env": {
        "AWS_ENDPOINT_URL": "http://localhost:4566",
        "S3_BUCKET_NAME": "tts-service-storage-dev",
        "KAFKA_BOOTSTRAP_SERVERS": "localhost:9092"
      }
    }
  ]
}
```

#### 2. Set Breakpoints

1. Open `services/tts-service/src/main.py`
2. Click left of line number to set breakpoint (red dot)

#### 3. Start Debugging

1. Press `F5` or Run → Start Debugging
2. Service starts with debugger attached
3. Execution stops at breakpoints
4. Inspect variables, step through code

### Debug Container

#### 1. Attach to Running Container

**Using Docker Extension:**
1. Right-click running container
2. Select "Attach Shell"
3. You're inside the container!

```bash
# Inside container
ls -la
cat /app/src/main.py
python --version
```

#### 2. Inspect Container

```powershell
# View container details
docker inspect tts-service

# Check environment variables
docker exec tts-service env

# Run command in container
docker exec tts-service python --version
```

## 📊 Workspace Settings

### Create VS Code Settings

Create `.vscode/settings.json`:

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/services/tts-service/venv/Scripts/python.exe",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "python.formatting.provider": "black",
  "editor.formatOnSave": true,
  "files.exclude": {
    "**/__pycache__": true,
    "**/*.pyc": true,
    "**/.pytest_cache": true
  },
  "terminal.integrated.defaultProfile.windows": "PowerShell",
  "docker.showStartPage": false,
  "yaml.schemas": {
    "https://json.schemastore.org/docker-compose.json": "docker-compose.yml"
  },
  "files.associations": {
    "*.tfvars": "terraform"
  }
}
```

### Create Tasks

Create `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start All Services",
      "type": "shell",
      "command": "docker-compose up -d",
      "problemMatcher": [],
      "group": {
        "kind": "build",
        "isDefault": true
      }
    },
    {
      "label": "Stop All Services",
      "type": "shell",
      "command": "docker-compose down"
    },
    {
      "label": "View Logs",
      "type": "shell",
      "command": "docker-compose logs -f"
    },
    {
      "label": "Health Check",
      "type": "shell",
      "command": ".\\scripts\\health-check.ps1"
    }
  ]
}
```

Run tasks: `Ctrl+Shift+P` → "Tasks: Run Task"

## 💡 Tips & Tricks

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `` Ctrl+` `` | Toggle Terminal |
| `Ctrl+Shift+P` | Command Palette |
| `Ctrl+P` | Quick Open File |
| `Ctrl+Shift+F` | Search in Files |
| `F5` | Start Debugging |
| `Ctrl+Shift+D` | Debug View |
| `Ctrl+Shift+E` | Explorer |
| `Ctrl+Shift+X` | Extensions |
| `Ctrl+B` | Toggle Sidebar |

### Multi-Terminal Windows

```powershell
# Terminal 1: Run services
docker-compose up

# Terminal 2: View specific service logs
docker-compose logs -f tts-service

# Terminal 3: Run commands
.\scripts\health-check.ps1
```

To create new terminal: Click `+` in terminal panel

### File Search

```
Ctrl+P then type:
tts  → Shows all files with "tts"
@tts → Shows all symbols named "tts"
:50  → Go to line 50
```

### Quick Service Access

Add to `.vscode/settings.json`:

```json
{
  "terminal.integrated.profiles.windows": {
    "PowerShell": {
      "source": "PowerShell",
      "args": ["-NoExit", "-Command", "cd services\\tts-service"]
    }
  }
}
```

### Git Integration

- View changes: Click Source Control icon (Ctrl+Shift+G)
- Stage files: Click `+` next to file
- Commit: Type message and click checkmark
- Push: Click `...` → Push

### Docker Compose Override

For development, create `docker-compose.override.yml`:

```yaml
version: '3.8'
services:
  tts-service:
    volumes:
      - ./services/tts-service/src:/app/src
    environment:
      - LOG_LEVEL=DEBUG
```

Changes apply automatically without editing main file!

### Quick Commands in Command Palette

Press `Ctrl+Shift+P` and type:

- `Docker: Compose Up`
- `Docker: Compose Down`
- `Python: Select Interpreter`
- `Terminal: Create New Terminal`
- `Format Document`

## 🚀 Full Development Workflow Example

### Day-to-Day Development

```powershell
# 1. Open VS Code
code C:\cloud-computing-project-full-implementation

# 2. Start services (if not running)
docker-compose up -d

# 3. Check health
.\scripts\health-check.ps1

# 4. Make changes to code
# Edit services/tts-service/src/main.py

# 5. Test changes
# Option A: Direct Python (faster)
cd services\tts-service
python -m uvicorn src.main:app --reload --port 8001

# Option B: Rebuild container
docker-compose up -d --build tts-service

# 6. Test API
$body = @{text="test"} | ConvertTo-Json
Invoke-RestMethod -Uri http://localhost:8001/api/tts/synthesize -Method Post -Body $body -ContentType application/json

# 7. View logs
docker-compose logs -f tts-service

# 8. Stop when done
docker-compose down
```

## 🆘 Common Issues in VS Code

### Issue: Terminal Shows CMD Instead of PowerShell

**Fix:**
1. Click terminal dropdown
2. Select "PowerShell"
3. Or: Settings → Default Profile → PowerShell

### Issue: Docker Extension Not Working

**Fix:**
1. Ensure Docker Desktop is running
2. Restart VS Code
3. Click Docker icon → should show containers

### Issue: Python Extension Can't Find Interpreter

**Fix:**
```powershell
# Create virtual environment
cd services\tts-service
python -m venv venv

# In VS Code: Ctrl+Shift+P
# Type: Python: Select Interpreter
# Choose: .\services\tts-service\venv\Scripts\python.exe
```

### Issue: Ports Already in Use

**Fix in VS Code terminal:**
```powershell
# Find process
netstat -ano | findstr :8000

# Kill process
taskkill /PID <PID> /F
```

### Issue: File Changes Not Reflecting

**Fix:**
```powershell
# For Docker: Rebuild
docker-compose up -d --build service-name

# For Python: Use --reload flag
uvicorn src.main:app --reload
```

## ✅ Final Checklist

- [ ] VS Code installed
- [ ] All extensions installed
- [ ] Docker Desktop running
- [ ] Project opened in VS Code
- [ ] Terminal set to PowerShell
- [ ] `.env` file configured
- [ ] Services started with `docker-compose up -d`
- [ ] Health check passed
- [ ] Can view logs in Docker Extension
- [ ] Can test APIs

## 📚 Next Steps

1. **Explore Code**: Browse services in VS Code
2. **Make Changes**: Edit a service and see it reload
3. **Test APIs**: Use REST Client or PowerShell
4. **Debug**: Set breakpoints and debug services
5. **Deploy**: Use Terraform from integrated terminal

---

**You're all set for VS Code development on Windows!** 🎉

Everything runs locally, all tools integrated, ready to code! 🚀
