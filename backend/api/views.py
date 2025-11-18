from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from datetime import datetime, timedelta
from .models import Birthday
from .serializers import BirthdaySerializer


class BirthdayViewSet(viewsets.ModelViewSet):
    serializer_class = BirthdaySerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return Birthday.objects.filter(belonging_user=self.request.user).order_by('birth_date')

    def perform_create(self, serializer):
        serializer.save(belonging_user=self.request.user)

    @action(detail=False, methods=['get'])
    def upcoming(self, request):
        """Get birthdays coming up in the next 30 days"""
        today = timezone.now().date()
        thirty_days_later = today + timedelta(days=30)
        
        birthdays = self.get_queryset()
        upcoming = []
        
        for birthday in birthdays:
            # Calculate next birthday occurrence
            next_birthday = birthday.birth_date.replace(year=today.year)
            if next_birthday < today:
                next_birthday = next_birthday.replace(year=today.year + 1)
            
            if today <= next_birthday <= thirty_days_later:
                upcoming.append({
                    'id': birthday.id,
                    'name': birthday.name,
                    'birth_date': birthday.birth_date,
                    'next_occurrence': next_birthday,
                    'days_until': (next_birthday - today).days
                })
        
        return Response(upcoming)
