// Landing page to try and identify the caller.

public class Tq_TwilioLandingController {
	
	public static Map<String, String> params;
	public static Twilio_Call__c twiCall;


	public Tq_TwilioLandingController() {
		params = System.ApexPages.CurrentPage().getParameters();
	}


	/* 
	initTwiml()
	Called by apex:page action. Creates a updates/creates a Twilio_Call__c record. 
	*/
	public static void initTwiml() {
		//get call log
		if(params.containsKey('CallSid')) {
			List<Twilio_Call__c> callLi = [SELECT Id, Caller__c, CallSid__c, Input__c, Status__c, User__c, User_First_Name__c, User_Last_Name__c
											FROM Twilio_Call__c
											WHERE CallSid__c = :params.get('CallSid')];

			if(callLi.isEmpty()) {
				twiCall = initTwilioCall(params);

			} else if (callLi.size() == 1) {
				twiCall = callLi[0];
				// make sure it has latest info...
				updateTwilioCall(params);
			}
		}

		if(params.get('status') == Tq_TwilioResponseBuilder.OPTION_SAVE_IDENTITY && twiCall.Input__c == '1') {
			saveIdentity();
		}

	}



	/* 
	getTwiml()
	Renders XML document on page, based on supplier 'status' parameter (passed as query param in url) 
	*/	
	public string getTwiml() {

		TwilioTwiML.Response r = new TwilioTwiML.Response();
		

		/****** Initial Greeting ********/

		if(!params.keySet().contains('status')) {
			if(twiCall.User__c != null) {
				return Tq_TwilioResponseBuilder.initKnownCaller(r, twiCall);
			} else {
				return Tq_TwilioResponseBuilder.initUnknownCaller(r);
			}
		}


		/****** Known Caller Actions: ********/

		if (params.get('status') == Tq_TwilioResponseBuilder.INIT_KNOWN_CALLER) {
			return Tq_TwilioResponseBuilder.optionKnownCaller(r);
		} 

		if(params.get('status') == Tq_TwilioResponseBuilder.OPTION_KNOWN_CALLER) {
			
			if(twiCall.Input__c == '1') {
				return Tq_TwilioResponseBuilder.taskVoiceNote(r);
			} else if (twiCall.Input__c == '2') {
				return Tq_TwilioResponseBuilder.todaysDiary(r, twiCall);
			} else if (twiCall.Input__c == '3') {
				return Tq_TwilioResponseBuilder.storyTime(r, twiCall);
			} else {
				return Tq_TwilioResponseBuilder.optionError(r, twiCall);
			}

		} 


		/****** Uknown Caller Actions: ********/

		if(params.get('status') == Tq_TwilioResponseBuilder.OPTION_UNKNOWN_CALLER) {
			if(twiCall.Input__c == '1') {
				return Tq_TwilioResponseBuilder.manualUserIdentify(r);
			} else {
				return Tq_TwilioResponseBuilder.optionError(r, twiCall);

			}

		} 

		if(params.get('status') == Tq_TwilioResponseBuilder.INPUT_IDENTIFY_USER){

			if(twiCall.User__c != null) {
				//found user, ask them to confirm
				return Tq_TwilioResponseBuilder.confirmIdentity(r, twiCall);
			} else {
				return Tq_TwilioResponseBuilder.unableToIdentifyError(r);
			}

		} 

		if(params.get('status') == Tq_TwilioResponseBuilder.OPTION_CONFIRM_IDENTITY) {

			if(twiCall.Input__c == '1') {
				return Tq_TwilioResponseBuilder.optionSaveIdentity(r);
			} else  if (twiCall.Input__c == '2') {
				return Tq_TwilioResponseBuilder.unableToIdentifyError(r);
			} else {
				return Tq_TwilioResponseBuilder.optionError(r, twiCall);
			}

		} 

		if(params.get('status') == Tq_TwilioResponseBuilder.OPTION_SAVE_IDENTITY) {
			if(twiCall.Input__c == '1' || twiCall.Input__c == '2') {
				// if input == 1, user has been updated in initTwiml()
				return Tq_TwilioResponseBuilder.optionKnownCaller(r);
			} else {
				return Tq_TwilioResponseBuilder.optionError(r, twiCall);
			}

		}


		else {
			return null;
		}		

	}



	/****** Helpers ********/

	private static Twilio_Call__c initTwilioCall(Map<String,String> incParams) {
		
		Twilio_Call__c newTwiCall = new Twilio_Call__c();		
		newTwiCall.CallSid__c = incParams.get('CallSid');
		newTwiCall.Status__c = 'initial';
		if(incParams.containsKey('Caller')) { 
			newTwiCall.Caller__c = incParams.get('Caller');
			// try and link to User
			List<User> userLi = [SELECT Id, Name, FirstName, LastName, Phone 
								 FROM User 
								 WHERE Phone = :params.get('Caller') 
								 OR Alt_Phone__c = :params.get('Caller')];

			if(!userLi.isEmpty() && userLi.size() == 1) {
				newTwiCall.User_Name__c = userLi[0].Name;
				newTwiCall.User_First_Name__c = userLi[0].FirstName;
				newTwiCall.User_Last_Name__c = userLi[0].LastName;
				newTwiCall.User__c = userLi[0].Id;
			}
		}

		try { 
			insert newTwiCall;
			return newTwiCall;
		} catch (Exception e) {
			System.debug('Error inserting Twilio_Call__c from initTwilioCall: ' + e);
			return null;
		}
	}


	private static Twilio_Call__c updateTwilioCall(Map<String, String> incParams) {

		if(params.containsKey('Digits')) { twiCall.Input__c = params.get('Digits'); }

		if(params.containsKey('status')) { 
			twiCall.Status__c = params.get('status'); 
			if(twiCall.Status__c == Tq_TwilioResponseBuilder.INPUT_IDENTIFY_USER) {
				// try and link to user
				linkToUserFromInput();
			}
		}

		//tbd make more intelligent so only updates if there has been change.
		update twiCall;
		return twiCall;

	}

	private static void saveIdentity() {

		// get user
		List<User> userLi = [SELECT Id, Phone, Alt_Phone__c FROM User WHERE Id = :twiCall.User__c];
		
		if(!userLi.isEmpty() && userLi.size() == 1) {
			if (userLi[0].Phone == null) {
				userLi[0].Phone = twiCall.Caller__c;
			} else {
				userLi[0].Alt_Phone__c = twiCall.Caller__c;
			}
		}
		try {
			update userLi[0];
		} catch (Exception e) {
			System.debug('Error updating user with phone number: ' + e);
		}
	}



	private static Twilio_Call__c linkToUserFromInput() {

		List<User> userLi = [SELECT Id, Name, FirstName, LastName 
							 FROM User 
							 WHERE NameToKeypad__c = :twiCall.Input__c]; //rework
		if(!userLi.isEmpty() && userLi.size() == 1) {
			twiCall.User_Name__c = userLi[0].Name;
			twiCall.User_First_Name__c = userLi[0].FirstName;
			twiCall.User_Last_Name__c = userLi[0].LastName;
			twiCall.User__c = userLi[0].Id;
		}

		return twiCall;

	}


}