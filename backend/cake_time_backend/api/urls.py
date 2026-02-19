from django.urls import path
from .views import create_birthday, update_birthday, delete_birthday

urlpatterns = [
    path('birthdays/create/', create_birthday, name='create_birthday'),
    path('birthdays/update/<int:birthday_id>/', update_birthday, name='update_birthday'),
    path('birthdays/delete/<int:birthday_id>/', delete_birthday, name='delete_birthday'),
]