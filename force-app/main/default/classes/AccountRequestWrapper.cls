public class AccountRequestWrapper {
public String mrn;
public String firstName;
public String middleName;
public String lastName;
public String dateOfBirth;
public String primaryPhone;
public String mobilePhone;
public String homePhone;
public String primaryEmail;
public String communicationConsentStatus;
public String communicationConsentExpirationDate;
public String communicationConsentReceivedDate;
public String wprStatus;
public String myChartStatus;
public DateTime messageDtTm;

public static AccountRequestWrapper parse(String json) {
return (AccountRequestWrapper) System.JSON.deserialize(json, AccountRequestWrapper.class);
}
}