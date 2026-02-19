from django.db import models
from django.contrib.auth.models import User

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    notify_days_before = models.IntegerField(default=14)

    def __str__(self):
        return f"{self.user.username} UserProfile"

class Birthday(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    birth_day = models.IntegerField()
    birth_month = models.IntegerField()
    birth_year = models.IntegerField(null=True, blank=True) # Year is optional
    notes = models.TextField(blank=True)

    def __str__(self):
        return f"name: {self.name}, birth_day: {self.birth_day}, birth_month: {self.birth_month}"