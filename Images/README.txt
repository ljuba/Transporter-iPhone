Transporter is a free public transit app designed for the San Francisco Bay Area. 

It was designed and built by me, Ljuba Miljkovic, while I was a master's student at the UC Berkeley School of Information.

The design and development of this app was my thesis project and represents many months worth of work. Learn more about the intentions of this app and design principles that underlie it here: www.transporterapp.net/blog

**config.plist**
This file has values that you'll need to provide in order to use some of the functionality in the app.

1. checkForUpdateURL: the API endpoint for checking the current version of the static transit data on your instance of the Transporter server (e.g. www.example.com/check.php)

2. flurryKey: the key given to you by Flurry Analytics for monitoring events in the app.

The app will run with these values blanks, but the app won't be able to check for static data updates or report analytics data to Flurry.


