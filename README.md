Tquilio
=======

Integrating Twilio with Salesforce

## Setup Guide

### Step 0 - Get a Salesforce Org

Use an existing Salesforce sandbox or get a free [Developer Org](https://events.developerforce.com/signup?d=70130000000EjHb, "Developer Org")

### Step 1 - Get the twilio-salesforce library

There are two options to install:
+ Salesforce [unmanaged package](https://login.salesforce.com/packaging/installPackage.apexp?p0=04ti0000000XkE0"Twilio for Salesforce") (login required)
+ Via GitHub: https://github.com/twilio/twilio-salesforce


### Step 2 - Install Tquilio

+ Fork this repo
+ Clone it locally
+ Deploy to your Salesforce org


### Step 3 - Set up a Force.com Site

This will act as the endpoint which you direct your Twilio account to.

+ **Setup** > **Develop** > **Sites** 
+ Choose a domain
+ Create a new site
  + Choose a label / site name
  + Set the 'Active Site Hope Page' as **'Twilio Landing'** visualforce page
  + Save

+ Configure the Public Access settings for the Site User
  + From the Site Details page, click **Pulic Access Settings**
  + Give the profile the following access:
    + Visualforce Page Access: 'TwilioLanding'
    + Apex Class Access: 'TranscriptionHandler'
    + Object Access: 'Twilio_Calls__c' (CRUD)


### Step 4 - Set up a Twilio Trial account

+ Get a Twilip sandbox number - this is the number you will call TO
+ Add your number as a verified caller ID - this is the number you will call FROM (note: this step is only required when using a trial account)

+ Create a Twilio TwiML App from the Twilio.com dashboard
  + **Dev Tools** > **Create TwiML App**
    + Give the app a name
    + Set the app Voice Request URL to the URL of your Force.com site - eg. http://yourdomain-developer-edition.xxx.force.com/
