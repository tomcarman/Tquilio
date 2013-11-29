Tquilio
=======

Integrating Twilio with Salesforce

## Setup Guide

#### Step 0 - Get a Salesforce Org

Use an existing Salesforce sandbox or get a free [Developer Org](https://events.developerforce.com/signup?d=70130000000EjHb, "Developer Org")

#### Step 1 - Get the twilio-salesforce library

There are two options to install:
+ Salesforce [unmanaged package](https://login.salesforce.com/packaging/installPackage.apexp?p0=04ti0000000XkE0"Twilio for Salesforce") (login required)
+ Via GitHub: https://github.com/twilio/twilio-salesforce


#### Step 2 - Install Tquilio

+ Fork this repo
+ Clone it locally
+ Deploy to your Salesforce org


#### Step 3 - Create a Force.com Site

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


#### Step 4 - Create a Twilio Trial account

+ Get a Twilip sandbox number - this is the number you will call TO
+ Add your number as a verified caller ID - this is the number you will call FROM (note: this step is only required when using a trial account)

+ Create a Twilio TwiML App from the Twilio.com dashboard
  + **Dev Tools** > **Create TwiML App**
    + Give the app a name
    + Set the app Voice Request URL to the URL of your Force.com site - eg. http://yourdomain-developer-edition.xxx.force.com/


# Examples

## Voicenote (calling from an unknown number)

In this example, the user:
+ Rings Twilio from an unknown number (eg. it is not stored against a User record in Salesforce)
+ Types their name into the keypad
+ Salesforce queries for the user based on the input
+ User is prompted to save the number they are ringing from against there User record
+ User leaves a voicenote, which is transcribed and stored as a Task assigned to their User account in Salesforce - via calling a public REST service.


**Recording** 

[Click here to listen/download (mp3)](https://dl.dropboxusercontent.com/u/23217397/Projects/Twilio/Example%20Calls/Voicenote_unidentified.mp3 "call")

**Screenshot** 

Task Created in Salesforce: 

![Screenshot](https://dl.dropboxusercontent.com/u/23217397/Projects/Twilio/Example%20Calls/Voicenote_screenshot.png)



## Today's Diary (from known caller)

In this example, the User:
+ Calls from a known phone number (eg. it is stored agains their User record in Salesforce)
+ Requests to hear their diary for the day

**Recording**

[Click here to listen/download (mp3)](https://dl.dropboxusercontent.com/u/23217397/Projects/Twilio/Example%20Calls/Get%20Diary_identified.mp3 "call")

**Screenshot**

Existing Event in Salesforce:
![Screenshot](https://dl.dropboxusercontent.com/u/23217397/Projects/Twilio/Example%20Calls/Task_screenshot.png)





