Welcome to CakeTime!

To run backend,
- make stop
- make build
- make run

To run frontend,
- make stop
- make build
- make run-server

Design pattern:
- Follows a basic CRUD design pattern to maintain a list of birthdays
- URLs
    - '/' : landing page
    - '/login' : login page
    - '/register' : register page
    - '/home' : only accessible by authenticated users. non-authenticated users will be redirected to /
    - 'api/birthdays/create' : API endpoint or new form page to create a birthday
    - 'api/birthdays/update/<int:birthday_id>' : API endpoint to edit birthday, but this will be done in '/home' page
    - 'api/birthdays/delete<int:birthday_id>' : API endpoint to delete birthday, but this will be done in '/home' page

Models (going to use Django and its built-in User auth):

UserProfile:
- user
- notify_days_before

Birthday
- user
- name
- birth_day
- birth_month
- birth_year
- notes

Reach goals:
- link to gcal, so birthdays are automatically created as events
