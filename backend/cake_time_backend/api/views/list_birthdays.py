from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from api.models import Birthday


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_birthdays(request):
    """Return all birthdays for the authenticated user, ordered by month then day."""
    birthdays = Birthday.objects.filter(user=request.user).order_by('birth_month', 'birth_day')
    data = [
        {
            'id': b.id,
            'name': b.name,
            'birth_day': b.birth_day,
            'birth_month': b.birth_month,
            'birth_year': b.birth_year,
            'notes': b.notes or '',
        }
        for b in birthdays
    ]
    return Response(data, status=status.HTTP_200_OK)
