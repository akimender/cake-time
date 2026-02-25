from rest_framework.response import Response
from rest_framework import status

def update_birthday_object(birthday: Birthday, data: dict):
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

    return None

def birthday_created_response(birthday: dict, status: status):
        return Response({
        'id': birthday.id,
        'name': birthday.name,
        'birth_day': birthday.birth_day,
        'birth_month': birthday.birth_month,
        'birth_year': birthday.birth_year,
        'notes': birthday.notes,
    }, status=status.HTTP_201_CREATED)

def validate_required_fields(data: dict):
    """
    Checks if all required fields are present in the input data dict.
    Returns a Response with an error and 400 status if a required field is missing, otherwise None.
    """
    required_fields = ['name', 'birth_day', 'birth_month']
    for field in required_fields:
        if field not in data:
            return Response(
                {'error': f'Missing required field: {field}'}, 
                status=status.HTTP_400_BAD_REQUEST
            )

def validate_birth_date(birth_day: int, birth_month: int):
    """
    Validates birth_day and birth_month values.
    Returns a Response object with error if validation fails, None if valid.
    """
    if birth_day is not None and not (1 <= birth_day <= 31):
        return Response(
            {'error': 'birth_day must be between 1 and 31'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if birth_month is not None and not (1 <= birth_month <= 12):
        return Response(
            {'error': 'birth_month must be between 1 and 12'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
    
    return None