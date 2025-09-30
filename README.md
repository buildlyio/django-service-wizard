# Django Service Wizard 🧙‍♂️

**Generate production-ready Django microservices for Buildly Core in minutes.**

The Django Service Wizard is an interactive command-line tool that scaffolds complete Django microservices with best practices, Docker support, API documentation, and seamless Buildly Core integration. No more manual setup - just describe your service and get a fully configured project ready for development.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python Version](https://img.shields.io/badge/python-3.8%2B-blue)](https://python.org)
[![Django Version](https://img.shields.io/badge/django-4.2%2B-green)](https://djangoproject.com)

## ✨ What Gets Generated

The wizard creates a complete Django microservice with:

- 🏗️ **Django Project Structure** - Properly organized settings, apps, and configurations
- 🐳 **Docker Support** - Dockerfile, docker-compose.yml, and production-ready containers  
- 📊 **API Documentation** - Swagger/OpenAPI integration with interactive docs
- 🔧 **Buildly Core Integration** - Pre-configured for seamless service discovery
- ⚡ **Health Checks** - Built-in health monitoring endpoints
- 🔒 **Security** - JWT authentication, CORS, and permission handling
- 📝 **CI/CD Ready** - Travis CI configuration and Docker registry support
- 🛠️ **Development Tools** - Gunicorn, static files handling, and environment configs

## 🚀 Quick Start

### Prerequisites
- Docker and docker-compose
- 2GB+ available disk space
- Internet connection for downloading dependencies

### Generate Your Service

```bash
# Clone or navigate to the django-service-wizard directory
cd django-service-wizard

# Run the interactive wizard
docker-compose run --rm django_service_wizard

# Follow the prompts:
# 1. Service name (e.g., "customer_service")  
# 2. Application name (e.g., "customer")
# 3. Docker support? (Y/n) 
# 4. Travis CI? (y/N)
# 5. Swagger docs? (Y/n)
# 6. Service display name (e.g., "Customer Management Service")
# 7. Service description

# Your new service is ready!
```

### Example Interaction

```
Welcome to the Buildly Core (Micro)Service wizard!
 _           _ _     _ _
| |__  _   _(_) | __| | |_   _  
| '_ \| | | | | |/ _` | | | | |
| |_) | |_| | | | (_| | | |_| |
|_.__/ \__,_|_|_|\__,_|_|\__, |
                         |___/

Type in the name of your service (e.g.: appointments_service): customer_service
✅ The Django project "customer_service" was successfully created

Type in the name of your application (e.g.: appointment): customer  
✅ Django application "customer" was successfully created

Add Docker support? (y/N): y
✅ Docker support added successfully

Add travis CI test support? (y/N): n

Add Swagger docs? (Y/n): y
Type in the displayed Name of your service: Customer Management Service
Type in the description of your service: A microservice for managing customer data and profiles

✅ Great! Your new project "customer_service" is ready!
```

## 📁 Generated Project Structure

```
customer_service/
├── 📄 README.md                    # Project documentation
├── 🐳 Dockerfile                   # Production container
├── 🐳 docker-compose.yml          # Development environment  
├── ⚙️ manage.py                    # Django management
├── 📋 requirements/                # Dependencies
│   ├── base.txt                   # Core requirements
│   └── production.txt             # Production requirements
├── 📂 customer/                    # Django application
│   ├── __init__.py
│   ├── admin.py                   # Django admin
│   ├── apps.py                    # App configuration
│   ├── models.py                  # Database models
│   ├── serializers.py             # API serializers
│   ├── views.py                   # API views
│   ├── urls.py                    # URL routing
│   └── migrations/                # Database migrations
├── 📂 customer_service/            # Project configuration
│   ├── __init__.py
│   ├── permissions.py             # Custom permissions
│   ├── gunicorn_conf.py          # Gunicorn configuration
│   ├── urls.py                   # Main URL configuration
│   ├── wsgi.py                   # WSGI application
│   └── settings/                 # Settings modules
│       ├── __init__.py
│       ├── base.py              # Base settings
│       └── production.py        # Production settings
├── 🔧 scripts/                    # Utility scripts
│   ├── run-collectstatic.sh      # Static files collection
│   ├── run-tests.sh              # Test runner
│   └── wait-for-it.sh            # Service dependency waiting
└── 📊 .travis.yml                 # CI/CD configuration (optional)
```

## 🔧 Features in Detail

### 🏗️ Django Best Practices
- **Modular Settings** - Separate base and production configurations
- **Application Structure** - Clean separation of concerns
- **Database Ready** - PostgreSQL configuration with environment variables
- **Static Files** - Proper handling for production deployment

### 🐳 Docker Integration  
- **Multi-stage Build** - Optimized container sizes
- **Development Mode** - Hot reload and debugging support
- **Production Ready** - Gunicorn, security headers, static files
- **Health Checks** - Container health monitoring

### 📊 API Documentation
- **Swagger UI** - Interactive API documentation at `/swagger/`
- **ReDoc** - Alternative documentation view at `/redoc/`  
- **Schema Generation** - Automatic OpenAPI schema from Django models
- **Authentication** - JWT token support in documentation

### 🔒 Security & Authentication
- **Buildly Core Integration** - Seamless JWT authentication
- **CORS Configuration** - Cross-origin resource sharing setup
- **Permission Classes** - Custom permission handling
- **Environment Variables** - Secure configuration management

## 🚦 Usage Examples

### Basic Service Creation
```bash
docker-compose run --rm django_service_wizard

# Minimal setup - just Django + Docker
Service name: inventory_service
App name: inventory  
Docker support: Y
Travis CI: N
Swagger docs: Y
```

### Full-Featured Service
```bash  
docker-compose run --rm django_service_wizard

# Complete setup with CI/CD
Service name: order_processing_service
App name: order
Docker support: Y
Travis CI: Y
Docker registry: Y
Registry domain: hub.docker.com
Registry folder: mycompany
Swagger docs: Y
```

### Custom Volume Mounting
```bash
# Generate service in specific directory
docker-compose run --rm \
  -v "/path/to/output:/code" \
  django_service_wizard
```

## 🛠️ Development Workflow

### 1. Generate Service
```bash
docker-compose run --rm django_service_wizard
```

### 2. Start Development
```bash
cd your_service_name
docker-compose up -d

# Your service is now running at:
# - API: http://localhost:8000/
# - Swagger: http://localhost:8000/swagger/  
# - Admin: http://localhost:8000/admin/
```

### 3. Add Your Models
```python
# your_service/your_app/models.py
from django.db import models

class Customer(models.Model):
    name = models.CharField(max_length=100)
    email = models.EmailField()
    created_at = models.DateTimeField(auto_now_add=True)
```

### 4. Create API Endpoints
```python
# your_service/your_app/serializers.py  
from rest_framework import serializers
from .models import Customer

class CustomerSerializer(serializers.ModelSerializer):
    class Meta:
        model = Customer
        fields = '__all__'

# your_service/your_app/views.py
from rest_framework import viewsets
from .models import Customer
from .serializers import CustomerSerializer

class CustomerViewSet(viewsets.ModelViewSet):
    queryset = Customer.objects.all()
    serializer_class = CustomerSerializer
```

### 5. Deploy to Buildly Core
The generated service is pre-configured to work with Buildly Core's service discovery and authentication.

## 🧪 Testing

### Run Tests Locally
```bash
# Inside your generated service directory
docker-compose exec web python manage.py test

# Or using the provided script
docker-compose exec web ./scripts/run-tests.sh
```

### Test the Wizard Itself
```bash  
# Test the wizard code
docker-compose run --entrypoint 'python -m unittest discover' --rm django_service_wizard

# Build and test
docker-compose build
docker-compose run --rm django_service_wizard --help
```

## 🏗️ Templates & Customization

### Available Templates
- **Docker** - Multi-stage Dockerfile with production optimizations
- **Settings** - Django settings split for different environments  
- **Scripts** - Utility scripts for deployment and maintenance
- **CI/CD** - Travis CI configuration with Docker registry support
- **Documentation** - README template with service-specific content

### Customizing Templates  
Edit files in `service_builder/templates/` to customize the generated output:

```bash
service_builder/templates/
├── conf/gunicorn_conf.py          # Gunicorn configuration
├── docker/Dockerfile              # Container definition
├── readme/README.md               # Project documentation template  
├── requirements/base.txt          # Python dependencies
├── scripts/                       # Utility scripts
└── settings/                      # Django settings templates
```

## 🔧 Configuration

### Environment Variables (Generated Services)
```bash
# Database Configuration
DATABASE_ENGINE=django.db.backends.postgresql
DATABASE_NAME=your_service_db
DATABASE_USER=your_user
DATABASE_PASSWORD=your_password  
DATABASE_HOST=localhost
DATABASE_PORT=5432

# Buildly Core Integration
BUILDLY_CORE_URL=http://buildly-core:8080
JWT_SECRET_KEY=your-jwt-secret

# Django Configuration
DEBUG=False
SECRET_KEY=your-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1
```

### Docker Compose Override
```yaml
# docker-compose.override.yml (in generated service)
version: '3.7'
services:
  web:
    environment:
      - DEBUG=True
    volumes:  
      - .:/code
    ports:
      - "8000:8000"
```

## 🚀 Production Deployment

### Using Docker
```bash
# Build production image
docker build -t your-service:latest .

# Run in production
docker run -d \
  --name your-service \
  -p 8000:8000 \
  -e DATABASE_URL=postgresql://... \
  your-service:latest
```

### Using Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: your-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: your-service
  template:
    metadata:
      labels:
        app: your-service
    spec:
      containers:
      - name: web
        image: your-service:latest
        ports:
        - containerPort: 8000
```

## 📚 Documentation

- **[Getting Started Guide](docs/getting-started.md)** - Detailed tutorial with examples
- **[Template Reference](docs/templates.md)** - Customizing generated code  
- **[Buildly Integration](docs/buildly-integration.md)** - Service discovery and authentication
- **[Deployment Guide](docs/deployment.md)** - Production deployment strategies

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Report Bugs** - Found an issue? Open a GitHub issue
2. **Improve Templates** - Enhance the generated code templates
3. **Add Features** - New wizard options or integrations  
4. **Documentation** - Help improve our guides and examples

### Development Setup
```bash
# Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/django-service-wizard.git
cd django-service-wizard

# Make changes to templates or wizard code
# Test your changes
docker-compose build
docker-compose run --rm django_service_wizard

# Submit a Pull Request
```

## 📋 Requirements

### System Requirements
- **Docker** 20.10+ and docker-compose 1.29+
- **Python** 3.8+ (for development)  
- **Git** (for version control)

### Generated Service Requirements  
- **Django** 4.2+ (specified in requirements/base.txt)
- **PostgreSQL** 12+ (recommended database)
- **Redis** (for caching, optional)

## ⚖️ License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation** - Check our [docs folder](docs/) for detailed guides
- **GitHub Issues** - Report bugs and request features
- **Community** - Join the Buildly Discord community
- **Professional Support** - Contact enterprise@buildly.io

---

**Ready to build your first microservice?** [Get started now!](docs/getting-started.md) 🚀
