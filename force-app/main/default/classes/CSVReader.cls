public class CSVReader {
    public static final String ParserCOMMA = String.fromCharArray(new List<Integer>{44});
    public static final String ParserCR = '\r';
    public static final String ParserDQUOTE = '\"';
    public static final String ParserLF = '\n';
    public static final String ParserCRLF = ParserCR + ParserLF;
    public static final String ParserLFCR = ParserLF + ParserCR;
    public static final String ParserDQUOTEDQUOTE = ParserDQUOTE + ParserDQUOTE;

    
     public static List<List<String>> doParse(Blob file)
     {
        String fileString = file.toString();        
        if (!fileString.endsWith(ParserCRLF))
        {
            fileString = fileString + ParserCRLF;
        }        
        List<List<String>> fileValues = new List<List<String>>();
        List<String> rowValues = new List<String>();
        CSVValue csvValue = new CSVValue();        
        Boolean eod = false; 
        while (!eod) 
        {
            System.debug(fileString);
            csvValue = ParseStringValue(fileString);            
            rowValues.add(csvValue.value);            
            if (csvValue.delimiter == ParserCRLF) {
                fileValues.add(rowValues);                
                System.debug('rowvalues'+rowValues);                
                /*if (fileValues.size() > 0) {
                    System.assertEquals(fileValues.get(0).size(),rowValues.size());
                } */               
                rowValues = new List<String>();
            }
            
            if (csvValue.biteSize() == fileString.length()) {
                eod = true;
            }
            else {
                fileString = fileString.substring(csvValue.biteSize());
            }
        }        
        return fileValues;
    } 
   
    public static CSVValue ParseStringValue(String data)
    {
        System.assert(data.endsWith(ParserCRLF));        
        CSVValue csvValue = new CSVValue();        
        if (data.startsWith(ParserDQUOTE)){
            csvValue.enclosed = true;            
            Integer searchIndex = 1;     
            Integer dquoteIndex = -1;    
            Integer dquotesIndex = -1;             
            Boolean closerFound = false;            
            while (!closerFound) {
                dquoteIndex = data.indexOf(ParserDQUOTE, searchIndex);                
                dquotesIndex = data.indexOf(ParserDQUOTEDQUOTE,searchIndex);                
              //  System.assert(dquoteIndex != -1);                
                if (dquoteIndex == dquotesIndex) {
                    searchIndex = dquotesIndex+ParserDQUOTEDQUOTE.length();
                }
                else {
                    closerFound = true;
                }
            }            
            csvValue.value = data.substring(ParserDQUOTE.length(), dquoteIndex).replaceAll(ParserDQUOTEDQUOTE, ParserDQUOTE);            
            Integer commaIndex = data.indexOf(ParserCOMMA, dquoteIndex);
             Integer crlfIndex = data.indexOf(ParserCRLF, dquoteIndex);            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.delimiter = ParserCOMMA;
            }
            else {
                csvValue.delimiter = ParserCRLF;
            }
        }
        else {
            csvValue.enclosed = false;            
            Integer commaIndex = data.indexOf(ParserCOMMA);
            Integer crlfIndex = data.indexOf(ParserCRLF);            
            if (commaIndex != -1 && commaIndex < crlfIndex) {
                csvValue.value = data.substring(0, commaIndex);
                csvValue.delimiter = ParserCOMMA;
            }
            else {
                csvValue.value = data.substring(0, crlfIndex);
                csvValue.delimiter = ParserCRLF;
            }
        }        
        System.debug('Returning: ' + csvValue);        
        return csvValue;
    }       
    
    private class CSVValue {        
        public String value;       
        public Boolean enclosed;      
        public String delimiter;
        
        public CSVValue() {
            this(null, null, null);
        }
        
        public CSVValue(String value, Boolean enclosed, String delimiter) {
            this.value = value;
            this.enclosed = enclosed;
            this.delimiter = delimiter;
        }        
        
        public Integer biteSize() {
            Integer biteSize = value.replaceAll(ParserDQUOTE, ParserDQUOTEDQUOTE).length()+delimiter.length();            
            if (enclosed) {
                biteSize += ParserDQUOTE.length() * 2;
            }            
            System.debug('biteSize: ' + biteSize);            
            return biteSize;
        }        
        
        public Boolean equals(CSVValue compCSVValue) {
            return this.value.equals(compCSVValue.value)
                && this.enclosed == compCSVValue.enclosed
                && this.delimiter == compCSVValue.delimiter;
        }
        
        public void assertEquals(CSVValue compCSVValue) {
            System.assertEquals(value, compCSVValue.value);
            System.assertEquals(enclosed, compCSVValue.enclosed);
            System.assertEquals(delimiter, compCSVValue.delimiter);
        }
    } 
 }