@RestResource(urlMapping = '/Account2/*')
global with sharing class Account2RestResource {

/*
//GET request code for unit testing the credentials and basic call only, not used for production.
@HttpGet
global static Account doGetPatient() {
RestRequest req = RestContext.request;
RestResponse res = RestContext.response;
String patientMRN = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
Account result = [SELECT Id, MRN__c, Name FROM Account WHERE MRN__c = :patientMRN];
return result;
}
*/

@HttpPut
global static String doPutPatient() {

RestRequest req = RestContext.request;
Blob body = req.requestBody;
String requestJSON = body.toString();


System.Debug('The RequestJSON was: ' + requestJSON);

if (String.isBlank(requestJSON) || requestJSON == '{}')
return 'EMPTY_JSON_REQUEST';

AccountRequestWrapper request;
try {
request = (AccountRequestWrapper) System.JSON.deserialize(requestJSON, AccountRequestWrapper.class);
} catch (Exception ex) {
return 'JSON_REQUEST_DESERIALIZATION_ERROR';
}

String mrn = request.mrn;
if (String.isBlank(mrn))
return 'MISSING_MRN';

String LastName = request.LastName;
if (String.isBlank(LastName))
return 'MISSING_LAST_NAME';
/*
Integer cpuTime = Limits.getCpuTime();
System.Debug(cpuTime);
*/
processRequest(requestJSON);
return 'Success';


}

private static Boolean validateEmail(String email) {
if (email.trim().length() > 80)
return false;

Boolean result = true;

String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
Pattern MyPattern = Pattern.compile(emailRegex);
Matcher MyMatcher = MyPattern.matcher(email);

if (!MyMatcher.matches())
result = false;

return result;
}

@future
private static void processRequest(String requestJSON) {

System.Debug('Entering Future');
AccountRequestWrapper request;
request = (AccountRequestWrapper) System.JSON.deserialize(requestJSON, AccountRequestWrapper.class);
String mrn = request.mrn;

List<Account> accounts = [SELECT Id, MRN__c, FirstName, MiddleName, LastName, PersonBirthdate, Phone, PersonOtherPhone, PersonHomePhone, PersonEmail, CommunicationConsentStatus__pc,
CommunicationConsentExpirationDate__pc, CommunicationConsentReceived_Date__pc, WPR_Status__pc, MyChartStatusDSC__pc, Last_HL7_Event_DTS__c
FROM Account WHERE MRN__c = :mrn];

// Create a new patient in Salesforce
if (accounts.size() == 0) {
Id recordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Account' AND Name='Person Account'].Id;

Account account = new Account();
account.MRN__c = request.mrn;
account.RecordTypeId = recordTypeId;
try {

populateAccountRecord(account, request);
insert account;
} catch (Exception ex) { System.Debug(ex);}
}
// Update the existing patient in Salesforce only when the messageDtTm in Epic EMR is greater than the Account's Last_HL7_Event_DTS__c.
else {
Account account = accounts[0];

/* System.Debug(request.messageDtTm);
System.Debug(account.Last_HL7_Event_DTS__c);

if (request.messageDtTm > account.Last_HL7_Event_DTS__c) {
System.Debug('was greater');
} else {
System.Debug('was less');
}
*/
try {
if (request.messageDtTm > account.Last_HL7_Event_DTS__c) {
populateAccountRecord(account, request);
update account;
}
} catch (Exception ex) { System.Debug(ex);}
}
}






private static void populateAccountRecord(Account account, AccountRequestWrapper request) {

if (request.FirstName != null){
account.FirstName = request.FirstName;
}

if (request.MiddleName != null)
account.MiddleName = request.MiddleName;

account.LastName = request.LastName;

if (request.dateOfBirth != null) {
if (String.isBlank(request.dateOfBirth))
account.PersonBirthdate = null;
else
account.PersonBirthdate = date.parse(request.dateOfBirth); // MM/DD/YYYY format
}

if (request.primaryPhone != null)
account.Phone = request.primaryPhone.replaceAll('[^0-9]', '');

if (request.mobilePhone != null)
account.PersonMobilePhone = request.mobilePhone.replaceAll('[^0-9]', '');

if (request.homePhone != null)
account.PersonHomePhone = request.homePhone.replaceAll('[^0-9]', '');

//if (!validateEmail(request.primaryEmail))
// throw new DmlException('INVALID_EMAIL_ADDRESS');
if ((!String.isBlank(request.primaryEmail) && validateEmail(request.primaryEmail)) || request.primaryEmail == '')
account.PersonEmail = request.primaryEmail;

if (request.communicationConsentStatus != null)
account.CommunicationConsentStatus__pc = request.communicationConsentStatus;

if (request.communicationConsentExpirationDate != null) {
if (String.isBlank(request.communicationConsentExpirationDate))
account.CommunicationConsentExpirationDate__pc = null;
else
account.CommunicationConsentExpirationDate__pc = date.parse(request.communicationConsentExpirationDate); // MM/DD/YYYY format
}

if (request.communicationConsentReceivedDate != null) {
if (String.isBlank(request.communicationConsentReceivedDate))
account.CommunicationConsentReceived_Date__pc = null;
else
account.CommunicationConsentReceived_Date__pc = date.parse(request.communicationConsentReceivedDate); // MM/DD/YYYY format
}

if (request.wprStatus != null)
account.WPR_Status__pc = (request.wprStatus.toUpperCase() == 'YES' ? true : false);

if (request.myChartStatus != null)
account.MyChartStatusDSC__pc = request.myChartStatus;

if (request.messageDtTm != null)
account.Last_HL7_Event_DTS__c = request.messageDtTm;
}
}