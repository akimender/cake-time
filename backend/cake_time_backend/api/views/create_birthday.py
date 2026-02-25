from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from api.models import Birthday
from .helpers import validate_birth_date, validate_required_fields, birthday_created_response


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_birthday(request):
    user, data = request.user, request.data
    
    # Validate if required fields are there
    required_fields_error = validate_required_fields(data)
    if required_fields_error:
        return required_fields_error
    
    birth_day, birth_month = data.get('birth_day'), data.get('birth_month')
    
    # Validate birth date within time ranges
    validation_error = validate_birth_date(birth_day, birth_month)
    if validation_error:
        return validation_error
    
    try:
        birthday = Birthday.objects.create(
            user=user,
            name=data.get('name'),
            birth_day=birth_day,
            birth_month=birth_month,
            birth_year=data.get('birth_year'),
            notes=data.get('notes', '')
        )
        
        return birthday_created_response(birthday, status)
        
    except Exception as e:
        return Response(
            {'error': f'Failed to create birthday: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
