
STATIC_ROOT = os.getenv('STATIC_ROOT', 'static/')


# Rest Framework

REST_FRAMEWORK = {
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',),
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.SessionAuthentication',
        'rest_framework.authentication.TokenAuthentication',
        'oauth2_provider_jwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        '{{ name_project }}.permissions.AllowOptionsAuthentication',
    )
}

# JWT Configuration

JWT_AUTH_DISABLED = True
JWT_ALLOWED_ISSUER = 'buildly'
JWT_PUBLIC_KEY_RSA_BUILDLY = os.getenv('JWT_PUBLIC_KEY_RSA_BUILDLY')
