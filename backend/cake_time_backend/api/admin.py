from django.contrib import admin
from .models import UserProfile, Birthday

# Register your models here.
admin.site.register(UserProfile)
admin.site.register(Birthday)