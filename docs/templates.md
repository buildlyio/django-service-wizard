# Template Reference Guide

Understanding and customizing the Django Service Wizard templates to generate exactly the code you need.

## 📁 Template Structure

The Django Service Wizard uses a comprehensive template system located in `service_builder/templates/`:

```
service_builder/templates/
├── 📂 conf/                      # Configuration files
│   └── gunicorn_conf.py          # Production server configuration
├── 📂 docker/                    # Docker configurations  
│   ├── Dockerfile               # Multi-stage container build
│   ├── docker-compose.yml      # Development environment
│   ├── docker-entrypoint.sh    # Container startup script
│   └── run-standalone-dev.sh   # Standalone development runner
├── 📂 gitignore/                # Git ignore patterns
│   └── .gitignore              # Python/Django ignore rules
├── 📂 readme/                   # Project documentation
│   ├── README.md               # Main project README template
│   └── docker.md               # Docker-specific documentation
├── 📂 requirements/             # Python dependencies
│   ├── base.txt                # Core requirements
│   ├── ci.txt                  # CI/CD requirements  
│   └── production.txt          # Production requirements
├── 📂 scripts/                  # Utility scripts
│   ├── run-collectstatic.sh   # Static files collection
│   ├── run-tests.sh           # Test runner script
│   └── wait-for-it.sh         # Service dependency waiter
├── 📂 settings/                 # Django settings
│   ├── base_appended.tpl      # Base settings additions
│   ├── base_installedapps.tpl # Installed apps configuration
│   └── production.tpl         # Production settings template
├── 📂 travis-ci/               # CI/CD configuration
│   └── .travis.yml            # Travis CI pipeline
└── 📄 permissions.py           # Custom permission classes
```

## 🏗️ Core Templates

### Django Settings Templates

#### Base Settings (`settings/base_appended.tpl`)
```python
# Template variables available:
# - {{ name_project }}: Project name
# - {{ name_app }}: Application name

# REST Framework Configuration
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        '{{ name_project }}.permissions.IsOwnerOrReadOnly',
    ],
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
}

# CORS Configuration
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
]

CORS_ALLOW_ALL_ORIGINS = DEBUG

# Swagger Configuration  
SWAGGER_SETTINGS = {
    'SECURITY_DEFINITIONS': {
        'Token': {
            'type': 'apiKey',
            'name': 'Authorization',
            'in': 'header'
        }
    },
    'USE_SESSION_AUTH': False,
    'JSON_EDITOR': True,
    'SUPPORTED_SUBMIT_METHODS': [
        'get', 'post', 'put', 'delete', 'patch'
    ]
}
```

#### Production Settings (`settings/production.tpl`)
```python
# Production-specific configurations
import os
from .base import *

# Security Settings
DEBUG = False
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')

# Database Configuration  
DATABASES = {
    'default': {
        'ENGINE': os.environ.get('DATABASE_ENGINE', 'django.db.backends.postgresql'),
        'NAME': os.environ.get('DATABASE_NAME'),
        'USER': os.environ.get('DATABASE_USER'),
        'PASSWORD': os.environ.get('DATABASE_PASSWORD'),
        'HOST': os.environ.get('DATABASE_HOST', 'localhost'),
        'PORT': os.environ.get('DATABASE_PORT', '5432'),
    }
}

# Static Files  
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATIC_URL = '/static/'

# Security Headers
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'

# Logging Configuration
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        '{{ name_project }}': {
            'handlers': ['console'],
            'level': 'INFO',
        },
    },
}
```

### Docker Templates

#### Dockerfile (`docker/Dockerfile`)
```dockerfile
# Multi-stage build for production optimization
FROM python:3.11-slim as base

# System dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies
WORKDIR /code
COPY requirements/ requirements/
RUN pip install --no-cache-dir -r requirements/production.txt

# Development stage
FROM base as development
RUN pip install --no-cache-dir -r requirements/base.txt
COPY . /code/
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# Production stage  
FROM base as production
COPY . /code/
RUN python manage.py collectstatic --noinput
EXPOSE 8000
CMD ["gunicorn", "--config", "{{ name_project }}/gunicorn_conf.py", "{{ name_project }}.wsgi:application"]
```

#### Docker Compose (`docker/docker-compose.yml`)
```yaml
version: '3.8'

services:
  web:
    build: 
      context: .
      target: development
    ports:
      - "8000:8000"
    volumes:
      - .:/code
    environment:
      - DEBUG=1
      - DATABASE_ENGINE=django.db.backends.postgresql
      - DATABASE_NAME={{ name_project }}_db
      - DATABASE_USER=postgres
      - DATABASE_PASSWORD=postgres
      - DATABASE_HOST=db
      - DATABASE_PORT=5432
    depends_on:
      - db
    command: >
      sh -c "./scripts/wait-for-it.sh db:5432 -- 
             python manage.py migrate &&
             python manage.py runserver 0.0.0.0:8000"

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB={{ name_project }}_db  
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Permission Template (`permissions.py`)
```python
"""
Custom permission classes for {{ name_project }}
Integrates with Buildly Core authentication system
"""
from rest_framework import permissions
from rest_framework.permissions import BasePermission

class IsOwnerOrReadOnly(BasePermission):
    """
    Custom permission to only allow owners of an object to edit it.
    """
    
    def has_object_permission(self, request, view, obj):
        # Read permissions for any request (GET, HEAD, OPTIONS)
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write permissions only for owner
        return obj.owner == request.user

class IsBuildlyCoreAuthenticated(BasePermission):
    """
    Permission class for Buildly Core JWT authentication
    """
    
    def has_permission(self, request, view):
        # Check if user is authenticated via Buildly Core
        return (
            request.user and 
            request.user.is_authenticated and
            hasattr(request.user, 'buildly_core_user')
        )

class IsServiceOwner(BasePermission):
    """
    Permission for service-level access control
    """
    
    def has_permission(self, request, view):
        # Allow if user belongs to the same organization/service
        if not request.user.is_authenticated:
            return False
            
        service_id = getattr(request.user, 'service_id', None)
        return service_id == '{{ name_project }}'
```

## 🔧 Customization Guide

### 1. Modifying Existing Templates

#### Update Requirements
```python
# Edit: service_builder/templates/requirements/base.txt
Django>=4.2.0,<5.0
djangorestframework>=3.14.0
django-cors-headers>=4.0.0
django-filter>=23.0
drf-yasg>=1.21.0
django-health-check>=3.17.0
psycopg2-binary>=2.9.0
gunicorn>=20.1.0

# Add your custom requirements
celery>=5.3.0          # For background tasks
redis>=4.5.0           # For caching
pillow>=10.0.0         # For image handling
```

#### Customize Django Settings
```python
# Edit: service_builder/templates/settings/base_appended.tpl

# Add caching configuration
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': os.environ.get('REDIS_URL', 'redis://localhost:6379/1'),
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

# Add custom middleware
MIDDLEWARE += [
    '{{ name_project }}.middleware.LoggingMiddleware',
    '{{ name_project }}.middleware.TimezoneMiddleware',
]

# Add custom authentication backends
AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
    '{{ name_project }}.auth.BuildlyCoreBackend',
]
```

#### Enhance Docker Configuration
```dockerfile
# Edit: service_builder/templates/docker/Dockerfile

# Add custom system dependencies
FROM python:3.11-slim as base

RUN apt-get update && apt-get install -y \
    postgresql-client \
    build-essential \
    libpq-dev \
    # Add your custom packages
    imagemagick \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add custom Python packages
COPY requirements/ requirements/
RUN pip install --no-cache-dir \
    -r requirements/production.txt \
    # Add direct pip installs if needed
    && pip install --no-cache-dir some-custom-package
```

### 2. Adding New Templates

#### Create Custom Middleware Template
```python
# Create: service_builder/templates/middleware.py
"""
Custom middleware for {{ name_project }}
"""
import logging
import time
from django.utils.timezone import now

logger = logging.getLogger(__name__)

class LoggingMiddleware:
    """Log all requests and responses"""
    
    def __init__(self, get_response):
        self.get_response = get_response
        
    def __call__(self, request):
        start_time = time.time()
        
        response = self.get_response(request)
        
        duration = time.time() - start_time
        logger.info(f"{request.method} {request.path} - {response.status_code} - {duration:.2f}s")
        
        return response

class TimezoneMiddleware:
    """Set timezone based on user preferences"""
    
    def __init__(self, get_response):
        self.get_response = get_response
        
    def __call__(self, request):
        # Custom timezone logic here
        response = self.get_response(request)
        return response
```

#### Create API Versioning Template  
```python
# Create: service_builder/templates/versioning.py
"""  
API versioning for {{ name_project }}
"""
from rest_framework.versioning import URLPathVersioning
from rest_framework.response import Response
from rest_framework import status

class {{ name_project.title() }}Versioning(URLPathVersioning):
    """Custom versioning scheme"""
    
    default_version = 'v1'
    allowed_versions = ['v1', 'v2']
    version_param = 'version'

def version_not_supported_view(request, version=None):
    """Handle unsupported API versions"""
    return Response(
        {
            'error': f'API version {version} is not supported',
            'supported_versions': ['v1', 'v2'],
            'current_version': 'v1'
        },
        status=status.HTTP_400_BAD_REQUEST
    )
```

### 3. Template Variables

#### Available Variables
```python
# These variables are available in all templates:
{{ name_project }}     # Project name (e.g., "customer_service")  
{{ name_app }}         # Application name (e.g., "customer")
{{ display_name }}     # Display name (e.g., "Customer Service")
{{ description }}      # Service description
{{ registry_domain }}  # Docker registry domain (if configured)
{{ registry_folder }}  # Docker registry folder (if configured)
```

#### Using Variables in Templates
```python
# In Python templates (.py, .tpl files):
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    # ... other apps
    '{{ name_app }}',
    '{{ name_project }}',
]

# Service-specific configuration
SERVICE_CONFIG = {
    'name': '{{ name_project }}',
    'display_name': '{{ display_name }}',
    'description': '{{ description }}',
    'version': '1.0.0',
}
```

```yaml
# In YAML templates (.yml files):
version: '3.8'
services:
  {{ name_project }}:
    build: .
    image: {{ registry_domain }}/{{ registry_folder }}/{{ name_project }}:latest
    environment:
      - SERVICE_NAME={{ name_project }}
      - SERVICE_DISPLAY_NAME={{ display_name }}
```

```dockerfile
# In Dockerfile templates:
LABEL maintainer="Buildly Team"
LABEL service.name="{{ name_project }}"
LABEL service.description="{{ description }}"
LABEL service.version="1.0.0"

ENV SERVICE_NAME="{{ name_project }}"
ENV SERVICE_DISPLAY_NAME="{{ display_name }}"
```

### 4. Advanced Customization

#### Custom Template Functions
```python
# Edit: service_builder/utils.py

def get_custom_template_context(name_project, name_app, **kwargs):
    """Generate additional template variables"""
    return {
        'service_class_name': name_project.replace('_', '').title(),
        'api_version': 'v1',
        'current_year': datetime.now().year,
        'author_name': 'Your Organization',
        'license': 'MIT',
        'python_version': '3.11',
        'django_version': '4.2',
    }

def generate_model_templates(model_name, fields):
    """Generate Django model templates dynamically"""
    template_content = f"""
class {model_name}(models.Model):
    \"\"\"Auto-generated model for {model_name}\"\"\"
"""
    
    for field_name, field_type in fields.items():
        template_content += f"    {field_name} = models.{field_type}\n"
        
    return template_content
```

#### Conditional Template Logic
```python  
# In setup_service.py, add conditional template processing:

def _configure_advanced_features(name_project, features):
    """Configure advanced features based on user selection"""
    
    if 'redis' in features:
        # Add Redis configuration
        add_redis_settings(name_project)
        
    if 'celery' in features:
        # Add Celery configuration  
        add_celery_configuration(name_project)
        
    if 'monitoring' in features:
        # Add monitoring and logging
        add_monitoring_configuration(name_project)

def add_redis_settings(name_project):
    """Add Redis caching configuration"""
    redis_template = get_template_content('cache/redis_settings.py')
    settings_file = os.path.join(name_project, name_project, 'settings', 'base.py')
    append_to_file(settings_file, redis_template)
```

## 📊 Template Best Practices

### 1. Maintainable Templates
- **Use Template Variables** - Avoid hardcoded values
- **Modular Design** - Break complex templates into smaller pieces  
- **Comments** - Document template purpose and variables
- **Version Control** - Track template changes carefully

### 2. Security Considerations
```python
# Always use environment variables for secrets
SECRET_KEY = os.environ.get('SECRET_KEY')
DATABASE_PASSWORD = os.environ.get('DATABASE_PASSWORD')

# Never hardcode sensitive information
# ❌ Bad
SECRET_KEY = 'hardcoded-secret-key'

# ✅ Good  
SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-only-key')
```

### 3. Performance Optimization
```python
# Use efficient Django settings
DATABASES = {
    'default': {
        # Connection pooling
        'CONN_MAX_AGE': 60,
        # Query optimization  
        'OPTIONS': {
            'MAX_CONNS': 20,
            'MIN_CONNS': 5,
        }
    }
}

# Efficient caching configuration
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'KEY_PREFIX': '{{ name_project }}',
        'TIMEOUT': 300,  # 5 minutes default
    }
}
```

### 4. Testing Templates
```bash
# Test template generation
docker-compose run --rm django_service_wizard

# Test generated service  
cd test_service
docker-compose build
docker-compose up -d

# Verify service functionality
curl http://localhost:8000/health_check/
curl http://localhost:8000/swagger/
```

## 🔄 Template Update Workflow

### 1. Local Development
```bash
# Make template changes
edit service_builder/templates/your_template.py

# Test changes
docker-compose build
docker-compose run --rm django_service_wizard

# Verify generated service works  
cd generated_service
docker-compose up -d
```

### 2. Version Control
```bash
# Commit template changes
git add service_builder/templates/
git commit -m "Update template: add Redis caching support"

# Tag template versions
git tag -a template-v1.1.0 -m "Template version 1.1.0"
```

### 3. Documentation
```markdown
# Document template changes in CHANGELOG.md
## Template Changes v1.1.0
- Added Redis caching configuration  
- Enhanced Docker multi-stage builds
- Updated Django to 4.2.x
- Added custom middleware templates
```

---

**Need help customizing templates?** Check our [customization examples](./customization.md) or join our [Discord community](https://discord.gg/buildly) for support! 🚀