from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status


@api_view(['GET'])
@permission_classes([AllowAny])
def index(request):
    """Return OK response for calling GET to this endpoint -- tests the prod server"""
    return Response(status=status.HTTP_200_OK)
