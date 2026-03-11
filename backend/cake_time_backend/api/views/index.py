from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status


@api_view(['GET'])
def index():
    """Return OK response for calling GET to this endpoint -- tests the prod server"""
    return Response(status=status.HTTP_200_OK)
