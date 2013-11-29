public class Tq_TwilioResponseBuilder {

	public static string INIT_KNOWN_CALLER = 'init_knowncaller';
	public static string INIT_UNKNOWN_CALLER = 'init_unknowncaller';
	public static string OPTION_KNOWN_CALLER = 'opt_known_caller';
	public static string OPTION_UNKNOWN_CALLER = 'opt_unknown_caller';
	public static string OPTION_CONFIRM_IDENTITY = 'option_confirm_identity';	
	public static string OPTION_SAVE_IDENTITY = 'option_save_identity';
	public static string INPUT_IDENTIFY_USER = 'input_idenitfy_user';
	
	public static string BASE_URL = getHttpsSalesforceBaseURL();
	public static string STATUS = '?status=';



	public static String initKnownCaller(TwilioTwiML.Response r, Twilio_call__c twiCall) {
		
		r.append(new TwilioTwiML.Say('Hello ' + twiCall.User_First_Name__c));
		TwilioTwiML.Redirect redirect = new TwilioTwiML.Redirect(BASE_URL+STATUS+INIT_KNOWN_CALLER);
		r.append(redirect);
		return r.toXML();
	}


	public static String initUnknownCaller(TwilioTwiML.Response r) {
		
		TwilioTwiML.Gather g = new TwilioTwiML.Gather();
		g.setNumDigits(1);
		g.setAction(BASE_URL+STATUS+OPTION_UNKNOWN_CALLER);
		g.append(new TwilioTwiML.Say('I do not recognise the number you are calling from. Press 1 to try and identify yourself, otherwise please hang up.'));
		r.append(g);
		return r.toXML();	
	}


	public static String optionKnownCaller(TwilioTwiML.Response r) {
		
		TwilioTwiML.Gather g = new TwilioTwiML.Gather();
		g.setNumDigits(1);
		g.setAction(BASE_URL+STATUS+OPTION_KNOWN_CALLER);
		g.append(new TwilioTwiML.Say('Press 1 to record a voice note. Press 2 to hear your meetings for today, or press 3 to hear a story.'));
		r.append(g);
		return r.toXML();
	}


	public static String manualUserIdentify(TwilioTwiML.Response r) {
		
		TwilioTwiML.Gather g = new TwilioTwiML.Gather();
		g.setFinishOnKey('#');
		g.setAction(BASE_URL+STATUS+INPUT_IDENTIFY_USER);
		g.append(new TwilioTwiML.Say('Ok, lets do this! Please type in your name on the numeric keypad, in the same way you would type an SMS message. Press the hash key when you are finished.'));
		r.append(g);
		return r.toXML();

	}


	public static String confirmIdentity(TwilioTwiML.Response r, Twilio_Call__c twiCall) {

		TwilioTwiML.Gather g = new TwilioTwiML.Gather();
		g.setNumDigits(1);
		g.setAction(BASE_URL+STATUS+OPTION_CONFIRM_IDENTITY);
		g.append(new TwilioTwiML.Say('I have identified you as ' + twiCall.User_Name__c +'. If this is correct, press 1, otherwise, please press 2'));
		r.append(g);

		return r.toXML();

	}

	public static String optionSaveIdentity(TwilioTwiML.Response r) {

		TwilioTwiML.Gather g = new TwilioTwiML.Gather();
		g.setNumDigits(1);
		g.setAction(BASE_URL+STATUS+OPTION_SAVE_IDENTITY);
		g.append(new TwilioTwiML.Say('If you would like to have this number saved so you are automatically recognised next time you call, press 1, otherwise, press 2'));
		r.append(g);

		return r.toXML();


	}


	public static String taskVoiceNote(TwilioTwiML.Response r) {

		TwilioTwiML.Record rec = new TwilioTwiML.Record();
		rec.setMaxLength(120); // sets to 120 seconds - the maximum length for transcription
		rec.setTranscribe(true);
		rec.setTranscribeCallback(BASE_URL+'/services/apexrest/transcriptionhandler');
		rec.setMethod('POST');

		r.append(new TwilioTwiML.Say('Please leave a message after the beep. When finished, you may hang up.'));
		r.append(rec);
		return r.toXML();

	}


	public static String todaysDiary(TwilioTwiML.Response r, Twilio_Call__c twiCall) {
		
		List<String> meetingLi = getDiary(twiCall);

		for(String meeting : meetingLi) {
			r.append(new TwilioTwiML.Say(meeting));
		}

		//TwilioTwiML.Pause paws = new TwilioTwiML.Pause();
		//paws.setLength(1);
		//r.append(paws);
		r.append(new TwilioTwiML.Say('I hope you have a great day, goodbye.'));
		return r.toXML();

	}

	public static String storyTime(TwilioTwiML.Response r, Twilio_Call__c twiCall) {
		
		r.append(new TwilioTwiML.Say(twiCall.User_First_Name__c + ', I don\'t have time to tell a story right now. Don\'t you have better things to be doing? Goodbye'));
		return r.toXML();

	}


	public static String optionError(TwilioTwiML.Response r, Twilio_Call__c twiCall){

		r.append(new TwilioTwiML.Say(twiCall.Input__c + ' was not an option. Returning you to the previous menu.'));

		if(twiCall.Status__c == OPTION_KNOWN_CALLER) {
			return optionKnownCaller(r);
		} else if (twiCall.Status__c == OPTION_UNKNOWN_CALLER) {
			//tbd
			return initUnknownCaller(r);
		} else {
			return null;
		}
	}


	public static String unableToIdentifyError(TwilioTwiML.Response r) {
		r.append(new TwilioTwiML.Say('Sorry, I am unable to identify you. Please hang up'));
		return r.toXML();
	}





/*** Helpers ***/

private static List<String> getDiary(Twilio_Call__c twiCall) {


	List<Event> eventLi = [SELECT Subject, Who.Name, What.Name, What.Type, Location, StartDateTime, EndDateTime
							FROM Event 
							WHERE OwnerId = :twiCall.User__c
							AND StartDateTime = TODAY];  //filter by today

	List<String> responseLi = new List<String>();

	String meeting;

	if(!eventLi.isEmpty()) {
		if(eventLi.size() == 1) {
			meeting = 'meeting';
		} else {
			meeting = 'meetings';
		}

		responseLi.add('Today you have ' + eventLi.size() + meeting);
		for(Event e : eventLi) {
			responseLi.add('From ' + e.StartDateTime.format('hh:mm') + ' ... until ' + e.EndDateTime.format('hh:mm') + ' ... with ' + e.Who.Name + ' ... regarding ' + e.What.Name + ' ... the meeting location is ' + e.Location);
		}
	} else {
		responseLi.add('You have no meetings today.');

	}

	return responseLi;

}



  //by default the url is returned with http not https. twilio only accepts https.
   private static String getHttpsSalesforceBaseURL(){
      String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
      if (baseURL.startsWith('http:')){
        baseURL = baseURL.replaceFirst('http:', 'https:');
      } 
      return baseURL;
    }

}