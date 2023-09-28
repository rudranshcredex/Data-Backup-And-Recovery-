@isTest
private class TestObjectHelper {
    @isTest
    public static void TestGetObjectsMethod(){
        ObjectHelper instance = new ObjectHelper();
        List<string> tempList = instance.getObjects();
        system.assertNotEquals(0, templist.size(), 'Expected non empty');
    }
    @isTest
    public static void TestObjectList(){
        ObjectHelper instance = new ObjectHelper();
        List<String> newList = instance.getObjects();
       	boolean result;
        result = newList.contains('account');
        system.assertNotEquals(result, true);
    }

}