from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from api.models import Birthday
from .helpers import update_birthday_object

@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_birthday(request, birthday_id):
    user = request.user
    
    try:
        birthday = Birthday.objects.get(id=birthday_id, user=user)
    except Birthday.DoesNotExist:
        return Response(
            {'error': 'Birthday not found or you do not have permission to edit it'}, 
            status=status.HTTP_404_NOT_FOUND
        )
    
    data = request.data

    update_birthday_error = update_birthday_object(birthday, data)
    if update_birthday_error:
        return update_birthday_error
    
    try:
        birthday.save()
        
        return Response({
            'id': birthday.id,
            'name': birthday.name,
            'birth_day': birthday.birth_day,
            'birth_month': birthday.birth_month,
            'birth_year': birthday.birth_year,
            'notes': birthday.notes,
            'message': 'Birthday updated successfully'
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response(
            {'error': f'Failed to update birthday: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
