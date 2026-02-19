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
    - '/home' : only accessible by authenticated users. non-authenticated users will be redirected to '/'
    - '/birthdays/create' : API endpoint or new form page to create a birthday
    - '/birthdays/update' : API endpoint to edit birthday, but this will be done in '/home' page
    - '/birthdays/delete' : API endpoint to delete birthday, but this will be done in '/home' page

Models:
User
- username
- password

Birthday
- name (string)
- birth_date (datetime)

Reach goals:
- link to gcal, so birthdays are automatically created as events
