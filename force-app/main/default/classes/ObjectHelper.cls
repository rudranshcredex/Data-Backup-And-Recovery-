public with sharing class ObjectHelper {
    @AuraEnabled(cacheable=true)
  //  public static List<String> getObjects() {
     public  List<String> getObjects() {
        List<Schema.SObjectType> objectTypes = Schema.getGlobalDescribe().values();
        List<String> objectNames = new List<String>();

        for (Schema.SObjectType objectType : objectTypes) {
            objectNames.add(objectType.getDescribe().getName());
        }
        return objectNames;
    }
}