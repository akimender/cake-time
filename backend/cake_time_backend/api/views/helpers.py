from django.http import JsonResponse
from django.contrib.auth import get_user_model
from rest_framework.response import Response
from rest_framework import status

User = get_user_model()

def check_register_credentials(username, password, email):
    errors = {}

    if not username:
        errors["username"] = "This field is required."
    elif User.objects.filter(username=username).exists():
        errors["username"] = "A user with that username already exists."

    if not password:
        errors["password"] = "This field is required."
    else:
        from django.contrib.auth.password_validation import validate_password
        try:
            validate_password(password)
        except Exception as e:
            errors["password"] = " ".join(getattr(e, "messages", [str(e)]))

    if errors:
        return JsonResponse({"error": "Validation failed.", "details": errors}, status=400)
    
    return None

def update_birthday_object(birthday: dict, data: dict):
    """
    Updates the fields of a Birthday object based on the provided data dictionary.

    Fields updated (if present in data): name, birth_day, birth_month, birth_year, notes.
    Validates birth_day and birth_month using validate_birth_date().
    Returns:
        - None if all fields are valid and birthday object has been updated.
        - Response object with validation error if birth_day or birth_month are invalid.
    """
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
    """
    Returns a Response object indicating that a Birthday object was successfully created.

    Args:
        birthday (dict): The birthday object (likely a model instance) with relevant attributes.
        status (status): The DRF status module or object, to obtain HTTP response codes.

    Returns:
        Response: DRF Response containing the created birthday's data with HTTP_201_CREATED status.
    """
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