public class JSONtoXMLConverter {
    public static String jsonToXML(String jsonString) {
        // Parse the JSON string to a Map<String, Object>
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        // Create a new XML Document
        Dom.Document xmlDocument = new Dom.Document();
        Dom.XmlNode rootElement = xmlDocument.createRootElement('root', null, null);

        // Convert JSON to XML and set the root element
        createXMLElement(rootElement, jsonMap);

        // Convert the XML Document to a String
        return xmlDocument.toXmlString();
    }

    private static void createXMLElement(Dom.XmlNode parentNode, Map<String, Object> jsonMap) {
        // Loop through each key-value pair in the JSON map
        for (String key : jsonMap.keySet()) {
            Object value = jsonMap.get(key);
            if (value instanceof Map<String, Object>) {
                // If the value is a nested map, create a new XML element recursively
                Dom.XmlNode childElement = parentNode.addChildElement(key, null, null);
                createXMLElement(childElement, (Map<String, Object>) value);
            } else {
                // If the value is a primitive type, create a new XML element with the value as text content
                String stringValue = String.valueOf(value);
                Dom.XmlNode childElement = parentNode.addChildElement(key, null, null);
                childElement.addTextNode(stringValue);
            }
        }
    }
}