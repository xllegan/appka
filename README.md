# 🏥 AI Health Assistant

> **Version 1.0.0** | AI-Powered Medical Consultation Platform

## 📋 Project Overview

**AI Health Assistant** is an innovative web application that provides users with access to professional medical consultation through artificial intelligence. The application is specifically designed for Russian-speaking users and leverages advanced language models to analyze symptoms and provide medical recommendations.

### 🎯 Key Features

- **🔍 Symptom Analysis** — AI analyzes described symptoms and suggests possible diagnoses
- **💊 Treatment Recommendations** — Provides medication lists with dosages and forms
- **📋 Step-by-step Instructions** — Detailed recommendations for improving health conditions
- **⚠️ Critical Cases Alert** — Clear guidance on when to seek immediate medical attention
- **🔐 Safety First** — Prioritizes over-the-counter medications, with prescription recommendations only when necessary

### 🏗️ Architecture

The application is built on a modern architecture with backend and frontend separation:

- **Backend API** — FastAPI server with Mistral AI integration
- **Frontend** — Flutter application with intuitive interface
- **Database** — PostgreSQL for user and session storage
- **Authentication** — JWT tokens for secure access

### 🤖 AI Model

Uses **Mistral AI** with a custom system prompt that transforms the AI into an experienced Russian-speaking doctor. The model is trained to:

- Provide professional medical advice
- Recommend medications and dosages
- Warn about the need to consult specialists
- Maintain strict medical response format

### 📱 User Experience

- **Simple registration** and authentication
- **Intuitive chat interface** for communicating with AI doctor
- **Consultation history** for tracking recommendations
- **Fast responses** with detailed medical advice

---

## 🛠️ Tech Stack

### Backend *(by xllegan)*
```
FastAPI • SQLAlchemy • PostgreSQL • JWT Authentication • 
Mistral AI API • Python 3.13 • Uvicorn • Pydantic • 
bcrypt • python-jose • python-multipart
```

### Frontend *(by VolkovBLR)*
```
Flutter • Dart • HTTP Client • Shared Preferences • 
Provider State Management • Material Design • 
Android/iOS Cross-platform
```

---

## 🚀 Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/your-username/ai-health-assistant.git
cd ai-health-assistant
```

### 2. Backend Setup

The backend consists of two microservices: `auth_service` and `ai_service`.

#### Auth Service Setup
```bash
cd appka/auth_service

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
# Edit .env and set:
# - DB_URL
# - SECRET_KEY_ACCESS
# - SECRET_KEY_REFRESH
```

#### AI Service Setup
```bash
cd appka/ai_service

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
# Edit .env and set:
# - MISTRAL_API_KEY

# The prompt.txt file should already exist in the ai_service directory
# You can edit it to customize AI behavior
```

### 3. Running the Backend

You need to run both services in separate terminal windows.

#### Start Auth Service
```bash
cd appka
source auth_service/venv/bin/activate
uvicorn auth_service.main:app --reload --port 8000
```

#### Start AI Service
```bash
cd appka
source ai_service/venv/bin/activate
uvicorn ai_service.ai:app --reload --port 8001
```

### 4. API Documentation
- Auth Service Swagger UI: http://localhost:8000/docs
- AI Service Swagger UI: http://localhost:8001/docs

### 5. Run Frontend
```bash
cd frontend
flutter pub get
flutter run
```

---

## 🔑 Environment Variables

### Auth Service (.env)
```
DB_URL=postgresql+asyncpg://user:password@localhost:5432/dbname
SECRET_KEY_ACCESS=your-secret-key-min-32-chars
SECRET_KEY_REFRESH=another-secret-key-min-32-chars
```

### AI Service (.env)
```
MISTRAL_API_KEY=your-mistral-api-key
```

---

This project is developed for educational purposes. All medical recommendations should be confirmed by a qualified physician.

