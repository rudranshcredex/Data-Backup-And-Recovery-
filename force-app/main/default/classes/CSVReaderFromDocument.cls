public class CSVReaderFromDocument {
    public static void readCSVFromDocument(Id documentId) {
        List<List<String>> csvRecords = new List<List<String>>();

        // Retrieve the Document record
        Document doc = [SELECT Body FROM Document WHERE Id = :documentId];

        if (doc != null) {
            String fileContent = doc.Body.toString();

            // Split the file content into lines
            List<String> lines = fileContent.split('\n');

            // Process each line and split into CSV values
            for (String line : lines) {
                List<String> values = line.split(',');
                csvRecords.add(values);
            }
        }

        // Check if there are any CSV records to insert
        if (!csvRecords.isEmpty()) {
            // Specify the API name of the target object
            String objectName = 'Account';

            // Call the insertCSVRecords method from CSVDataImporter class
            CSVDataImporter.insertCSVRecords(csvRecords, objectName);
        }
    }
}