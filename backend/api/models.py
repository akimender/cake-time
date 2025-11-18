from django.db import models
from django.contrib.auth.models import User

class Birthday(models.Model):
    belonging_user = models.ForeignKey(User, on_delete=models.CASCADE)
    next_birthday = models.ForeignKey('self', on_delete=models.RESTRICT, null=True, blank=True) # need to clarify between RESTRICT and PROTECT
    name = models.CharField(max_length=100)
    birth_date = models.DateField()

    def __str__(self):
        return self.name