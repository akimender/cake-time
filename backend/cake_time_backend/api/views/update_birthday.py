from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from api.models import Birthday
from .helpers import validate_birth_date

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
    
    if 'name' in data:
        birthday.name = data['name']
    
    birth_day, birth_month = data.get('birth_day'), data.get('birth_month')
    
    validation_error = validate_birth_date(birth_day, birth_month)
    if validation_error:
        return validation_error
    
    if birth_day is not None:
        birthday.birth_day = birth_day
    
    if birth_month is not None:
        birthday.birth_month = birth_month
    
    if 'birth_year' in data:
        birthday.birth_year = data['birth_year']
    
    if 'notes' in data:
        birthday.notes = data['notes']
    
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
