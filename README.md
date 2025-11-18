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


On the CakeTime website, users will see the following opt-in message when registering their phone numbers: “Sign up to receive birthday reminders from CakeTime! Text START to [Twilio number] to subscribe. By subscribing, you agree to receive recurring SMS reminders. Message & data rates may apply. Reply STOP to unsubscribe or HELP for help.” After texting START, users receive: “You’re subscribed to CakeTime Birthday Reminders! You’ll receive up to 4 reminders per month (frequency may vary depending on your birthday list). Message & data rates may apply. Reply STOP to unsubscribe or HELP for help.”