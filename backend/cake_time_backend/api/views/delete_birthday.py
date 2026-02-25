from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from api.models import Birthday


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_birthday(request, birthday_id):
    user = request.user
    
    try:
        birthday = Birthday.objects.get(id=birthday_id, user=user)
    except Birthday.DoesNotExist:
        return Response(
            {'error': 'Birthday not found or you do not have permission to delete it'}, 
            status=status.HTTP_404_NOT_FOUND
        )
    
    birthday_name = birthday.name # Save birthday name for message
    
    try:
        birthday.delete()
        
        return Response({
            'message': f'Birthday for {birthday_name} deleted successfully'
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response(
            {'error': f'Failed to delete birthday: {str(e)}'}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
