# Getting Started with Django Service Wizard

Welcome to the Django Service Wizard! This comprehensive guide will walk you through creating your first Django microservice for Buildly Core, from installation to deployment.

## What You'll Build

By the end of this tutorial, you'll have:
- A complete Django microservice with REST API
- Docker containerization for easy deployment
- Swagger/OpenAPI documentation
- Integration with Buildly Core authentication
- Ready-to-deploy production configuration

**Time Required:** 15-30 minutes

## Prerequisites

Before we begin, ensure you have:

- **Docker** 20.10+ installed ([Get Docker](https://docs.docker.com/get-docker/))
- **docker-compose** 1.29+ installed 
- **Basic Django knowledge** (models, views, serializers)
- **2GB+ free disk space** for Docker images
- **Text editor** (VS Code, PyCharm, etc.)

### Verify Prerequisites

```bash
# Check Docker version
docker --version
# Should show: Docker version 20.10.x or higher

# Check docker-compose version  
docker-compose --version
# Should show: docker-compose version 1.29.x or higher

# Test Docker is running
docker ps
# Should show container list (may be empty)
```

## Step 1: Get the Django Service Wizard

### Option A: Within Buildly CLI (Recommended)

If you're using the Buildly CLI ecosystem:

```bash
# The django-service-wizard is already included
cd buildly-cli/django-service-wizard
```

### Option B: Standalone Installation

```bash
# Clone the repository
git clone https://github.com/buildlyio/django-service-wizard.git
cd django-service-wizard

# Verify files are present
ls -la
# Should see: README.md, docker-compose.yml, service_builder/, etc.
```

## Step 2: Build the Wizard

```bash
# Build the Docker image (first time only)
docker-compose build

# This downloads Python, Django, and dependencies (~5 minutes)
```

**Expected Output:**
```
Successfully built django-service-wizard
Successfully tagged django-service-wizard_django_service_wizard:latest
```

## Step 3: Create Your First Service

Let's create a customer management service as an example.

### Launch the Interactive Wizard

```bash
docker-compose run --rm django_service_wizard
```

You'll see the welcome screen:
```
Welcome to the Buildly Core (Micro)Service wizard!
 _           _ _     _ _
| |__  _   _(_) | __| | |_   _  
| '_ \| | | | | |/ _` | | | | |
| |_) | |_| | | | (_| | | |_| |
|_.__/ \__,_|_|_|\__,_|_|\__, |
                         |___/

We will help you to set up a Micro or Right Size Service :)
```

### Follow the Interactive Prompts

#### 1. Service Name
```
Type in the name of your service (e.g.: appointments_service): customer_service
```
**Enter:** `customer_service`

#### 2. Application Name  
```
Type in the name of your application (e.g.: appointment): customer
```
**Enter:** `customer`

#### 3. Docker Support
```
Add Docker support? (y/N): y
```
**Enter:** `y` (Yes - we want containerization)

#### 4. Travis CI Support
```
Add travis CI test support? (y/N): n  
```
**Enter:** `n` (No - we'll skip CI for now)

#### 5. Swagger Documentation
```
Add Swagger docs? (Y/n): y
```
**Enter:** `y` (Yes - we want API documentation)

#### 6. Service Display Name
```
Type in the displayed Name of your service (e.g.: Appointment Service): Customer Management Service
```
**Enter:** `Customer Management Service`

#### 7. Service Description
```
Type in the description of your service (e.g.: A microservice for saving and retrieving appointments.): A microservice for managing customer profiles, contact information, and preferences
```
**Enter:** `A microservice for managing customer profiles, contact information, and preferences`

### Generation Complete! 🎉

You should see:
```
✅ The Django project "customer_service" was successfully created
✅ Django application "customer" was successfully created  
✅ Docker support added successfully
✅ Swagger documentation configured
✅ Great! Now you can find your new project inside the current's wizard folder with name "customer_service"
```

## Step 4: Explore Your Generated Service

### Project Structure

```bash
# List your new service
ls -la customer_service/

# You should see:
customer_service/
├── 📄 README.md                   # Project documentation
├── 🐳 Dockerfile                  # Production container
├── 🐳 docker-compose.yml         # Development setup
├── ⚙️ manage.py                   # Django management  
├── 📋 requirements/               # Python dependencies
├── 📂 customer/                   # Your Django app
└── 📂 customer_service/           # Django project config
```

### Key Generated Files

**Django Application (`customer/`):**
```python
# customer/models.py - Add your data models
# customer/views.py - API viewsets  
# customer/serializers.py - API serializers
# customer/urls.py - URL routing
# customer/admin.py - Django admin config
```

**Project Configuration (`customer_service/`):**
```python  
# settings/base.py - Development settings
# settings/production.py - Production settings
# permissions.py - Custom permission classes
# gunicorn_conf.py - Production server config
```

## Step 5: Start Your Service

### Navigate to Your Service

```bash
cd customer_service
```

### Start the Development Server

```bash
# Start all services (Django + PostgreSQL)
docker-compose up -d

# Check that containers are running
docker-compose ps
```

**Expected Output:**
```
Name                    Command               State           Ports
------------------------------------------------------------------------
customer_service_db_1   docker-entrypoint.sh postgres   Up      5432/tcp
customer_service_web_1  ./wait-for-it.sh db:5432 ...    Up      0.0.0.0:8000->8000/tcp
```

### Access Your Service

Open your browser to explore your new service:

**🏠 Service Homepage**
- URL: http://localhost:8000/
- Should show: Django welcome page

**📊 API Documentation (Swagger)**
- URL: http://localhost:8000/swagger/
- Interactive API documentation

**📖 Alternative Docs (ReDoc)**  
- URL: http://localhost:8000/redoc/
- Clean documentation view

**🔧 Django Admin**
- URL: http://localhost:8000/admin/
- Django administration interface

**⚡ Health Check**
- URL: http://localhost:8000/health_check/
- Service health monitoring

## Step 6: Add Your First Model

Let's add a Customer model to demonstrate the full workflow.

### Edit the Models File

```bash
# Open the models file in your editor
code customer_service/customer/models.py
# Or use: nano customer_service/customer/models.py
```

### Add the Customer Model

```python
# customer_service/customer/models.py
from django.db import models

class Customer(models.Model):
    """Customer model for storing customer information"""
    
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50) 
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        ordering = ['-created_at']
        
    def __str__(self):
        return f"{self.first_name} {self.last_name}"
    
    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}"

class CustomerProfile(models.Model):
    """Extended customer profile information"""
    
    customer = models.OneToOneField(
        Customer, 
        on_delete=models.CASCADE, 
        related_name='profile'
    )
    date_of_birth = models.DateField(null=True, blank=True)
    address = models.TextField(blank=True)
    preferences = models.JSONField(default=dict, blank=True)
    
    def __str__(self):
        return f"Profile for {self.customer.full_name}"
```

### Create API Serializers

```bash
# Edit the serializers file
code customer_service/customer/serializers.py
```

```python
# customer_service/customer/serializers.py
from rest_framework import serializers
from .models import Customer, CustomerProfile

class CustomerProfileSerializer(serializers.ModelSerializer):
    """Serializer for customer profile data"""
    
    class Meta:
        model = CustomerProfile
        fields = ['date_of_birth', 'address', 'preferences']

class CustomerSerializer(serializers.ModelSerializer):
    """Serializer for customer data with profile"""
    
    profile = CustomerProfileSerializer(read_only=True)
    full_name = serializers.ReadOnlyField()
    
    class Meta:
        model = Customer
        fields = [
            'id', 'first_name', 'last_name', 'full_name',
            'email', 'phone', 'is_active', 'created_at', 
            'updated_at', 'profile'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate_email(self, value):
        """Ensure email is lowercase"""
        return value.lower()

class CustomerCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating new customers"""
    
    class Meta:
        model = Customer  
        fields = ['first_name', 'last_name', 'email', 'phone']
        
    def create(self, validated_data):
        customer = Customer.objects.create(**validated_data)
        # Create empty profile
        CustomerProfile.objects.create(customer=customer)
        return customer
```

### Create API Views

```bash
# Edit the views file
code customer_service/customer/views.py
```

```python
# customer_service/customer/views.py
from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Customer, CustomerProfile
from .serializers import (
    CustomerSerializer, 
    CustomerCreateSerializer,
    CustomerProfileSerializer
)

class CustomerViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Customer model
    Provides CRUD operations for customers
    """
    queryset = Customer.objects.all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['is_active', 'created_at']
    search_fields = ['first_name', 'last_name', 'email']
    ordering_fields = ['created_at', 'last_name', 'first_name']
    ordering = ['-created_at']
    
    def get_serializer_class(self):
        """Return appropriate serializer based on action"""
        if self.action == 'create':
            return CustomerCreateSerializer
        return CustomerSerializer
    
    @action(detail=True, methods=['get', 'put', 'patch'])
    def profile(self, request, pk=None):
        """Manage customer profile"""
        customer = self.get_object()
        profile, created = CustomerProfile.objects.get_or_create(
            customer=customer
        )
        
        if request.method == 'GET':
            serializer = CustomerProfileSerializer(profile)
            return Response(serializer.data)
        
        elif request.method in ['PUT', 'PATCH']:
            partial = request.method == 'PATCH'
            serializer = CustomerProfileSerializer(
                profile, 
                data=request.data, 
                partial=partial
            )
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(
                serializer.errors, 
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=False, methods=['get'])
    def active(self, request):
        """Get only active customers"""
        active_customers = self.get_queryset().filter(is_active=True)
        serializer = self.get_serializer(active_customers, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'])
    def deactivate(self, request, pk=None):
        """Deactivate a customer"""
        customer = self.get_object()
        customer.is_active = False
        customer.save()
        return Response({'status': 'customer deactivated'})
```

### Update URLs

```bash
# Edit the URLs file  
code customer_service/customer/urls.py
```

```python
# customer_service/customer/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CustomerViewSet

router = DefaultRouter()
router.register(r'customers', CustomerViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
]
```

### Run Database Migration

```bash
# Create and apply migrations
docker-compose exec web python manage.py makemigrations
docker-compose exec web python manage.py migrate

# Create a superuser (optional)
docker-compose exec web python manage.py createsuperuser
```

## Step 7: Test Your API

### Using Swagger UI

1. **Open Swagger:** http://localhost:8000/swagger/
2. **Explore endpoints:** You should see:
   - `GET /api/customers/` - List customers
   - `POST /api/customers/` - Create customer  
   - `GET /api/customers/{id}/` - Get customer details
   - `PUT /api/customers/{id}/` - Update customer
   - `DELETE /api/customers/{id}/` - Delete customer
   - `GET /api/customers/active/` - Get active customers
   - `POST /api/customers/{id}/deactivate/` - Deactivate customer
   - `GET /api/customers/{id}/profile/` - Get customer profile

### Using curl

```bash
# Create a new customer
curl -X POST http://localhost:8000/api/customers/ \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "John",
    "last_name": "Doe", 
    "email": "john.doe@example.com",
    "phone": "+1-555-123-4567"
  }'

# List all customers
curl http://localhost:8000/api/customers/

# Search customers  
curl "http://localhost:8000/api/customers/?search=john"

# Get active customers only
curl http://localhost:8000/api/customers/active/
```

### Using Django Admin

1. **Access Admin:** http://localhost:8000/admin/
2. **Login** with your superuser credentials  
3. **Add Customer models** to admin (edit `customer/admin.py`):

```python  
# customer_service/customer/admin.py
from django.contrib import admin
from .models import Customer, CustomerProfile

@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ['full_name', 'email', 'phone', 'is_active', 'created_at']
    list_filter = ['is_active', 'created_at']
    search_fields = ['first_name', 'last_name', 'email']
    readonly_fields = ['created_at', 'updated_at']

@admin.register(CustomerProfile)  
class CustomerProfileAdmin(admin.ModelAdmin):
    list_display = ['customer', 'date_of_birth']
    list_select_related = ['customer']
```

## Step 8: Integration with Buildly Core

Your service is already pre-configured for Buildly Core integration. Here's how to connect it:

### Environment Configuration

```bash
# Create environment file
cat > customer_service/.env << 'EOF'
# Buildly Core Integration
BUILDLY_CORE_URL=http://buildly-core:8080
JWT_SECRET_KEY=your-jwt-secret-key

# Database Configuration  
DATABASE_ENGINE=django.db.backends.postgresql
DATABASE_NAME=customer_service_db
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_HOST=db
DATABASE_PORT=5432

# Django Configuration
DEBUG=True
SECRET_KEY=your-django-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1,buildly-core
EOF
```

### Service Registration  

When using with Buildly Core, your service will be automatically discoverable at:
```
http://buildly-core:8080/api/customer-service/customers/
```

## Step 9: Production Deployment

### Build Production Image

```bash
# Build production Docker image
docker build -t customer-service:latest .

# Or with specific tag
docker build -t your-registry.com/customer-service:v1.0.0 .
```

### Deploy to Kubernetes

```yaml  
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: customer-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: customer-service
  template:
    metadata:
      labels:
        app: customer-service
    spec:
      containers:
      - name: web
        image: customer-service:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          value: "postgresql://user:pass@postgres:5432/db"
        - name: BUILDLY_CORE_URL  
          value: "http://buildly-core:8080"
```

```bash
kubectl apply -f k8s-deployment.yaml
```

## Next Steps

Congratulations! You've successfully created a Django microservice with the wizard. Here are some next steps:

### 🚀 Immediate Next Steps

1. **Add More Models** - Extend your service with additional models
2. **Custom Endpoints** - Add business logic specific endpoints  
3. **Tests** - Write unit and integration tests
4. **Documentation** - Enhance your service documentation

### 📈 Advanced Features

1. **Caching** - Add Redis caching for better performance
2. **Celery Tasks** - Background job processing
3. **File Uploads** - Handle file uploads with cloud storage
4. **Monitoring** - Add logging, metrics, and alerting

### 🔧 Integration

1. **More Services** - Create additional microservices
2. **Message Queues** - Service-to-service communication
3. **API Gateway** - Use Buildly Core for routing and auth
4. **Frontend** - Connect React/Vue.js frontend

### 📚 Learn More

- **[Django REST Framework](https://www.django-rest-framework.org/)** - API development  
- **[Buildly Core Documentation](https://docs.buildly.io/)** - Microservices gateway
- **[Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)** - Container optimization
- **[Kubernetes Guide](https://kubernetes.io/docs/home/)** - Container orchestration

## Troubleshooting

### Common Issues

**Service won't start:**
```bash
# Check logs
docker-compose logs web
docker-compose logs db

# Restart services
docker-compose down
docker-compose up -d
```

**Database connection errors:**
```bash
# Wait for database to be ready
docker-compose exec web ./scripts/wait-for-it.sh db:5432

# Check database status
docker-compose exec db psql -U postgres -l
```

**Migration issues:**
```bash
# Reset migrations (development only!)
docker-compose exec web rm -rf customer/migrations/*
docker-compose exec web python manage.py makemigrations customer
docker-compose exec web python manage.py migrate
```

**Port conflicts:**
```bash  
# Check what's using port 8000
lsof -i :8000

# Use different port
docker-compose -f docker-compose.yml -p 8001:8000 up
```

### Getting Help

- **GitHub Issues** - Report bugs and get community help
- **Buildly Discord** - Real-time community support  
- **Documentation** - Check our comprehensive guides
- **Stack Overflow** - Tag questions with `buildly` and `django`

---

**🎉 Congratulations!** You've successfully created your first Django microservice with the wizard. Happy coding! 🚀