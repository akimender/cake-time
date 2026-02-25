import json
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.http import JsonResponse
from django.contrib.auth import get_user_model
from .helpers import check_register_credentials

from api.models import UserProfile

User = get_user_model()

@csrf_exempt # Exposing endpoint to separate frontend service
@require_http_methods(["POST"])
def register(request) -> JsonResponse:
    """
    Create a new user and UserProfile. Expects JSON: username, password, email (optional).
    """
    try:
        data = json.loads(request.body) if request.body else {}
    except json.JSONDecodeError:
        return JsonResponse(
            {"error": "Invalid JSON"},
            status=400,
        )

    username = (data.get("username") or "").strip()
    password = data.get("password") or ""
    email = (data.get("email") or "").strip()

    register_error = check_register_credentials(username, password, email)
    if register_error:
        return register_error

    user = User.objects.create_user(
        username=username,
        password=password,
        email=email or "",
    )
    UserProfile.objects.get_or_create(user=user, defaults={"notify_days_before": 14})

    return JsonResponse(
        {"message": "Account created successfully.", "username": user.username},
        status=201,
    )
