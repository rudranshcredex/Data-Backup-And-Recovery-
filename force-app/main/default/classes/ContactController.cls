public with sharing class ContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        return [select Firstname, LastName, Email from Contact WITH SECURITY_ENFORCED ];
    }
}