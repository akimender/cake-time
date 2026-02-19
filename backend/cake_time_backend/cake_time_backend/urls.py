from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/token/', TokenObtainPairView.as_view()), # Authenticates user credentials
    path('api/token/refresh/', TokenRefreshView.as_view()), # Returns access type JWT if refresh valid
    path('api/', include('api.urls')), # Includes all endpoints from api
]
