import { LightningElement,wire,track } from 'lwc';
import getObjectsApiNames from '@salesforce/apex/dataBackup2.getObjectsApiNames';
import getRecordsByObject from '@salesforce/apex/dataBackup2.getRecordsByObject';
import getObjectsApiNamesBySearch from '@salesforce/apex/dataBackup2.getObjectsApiNamesBySearch';
import uploadCSV from '@salesforce/apex/AWSFileService.uploadCSV';
import getcsvContent from '@salesforce/apex/ZipDataController.getcsvContent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import method from '@salesforce/apex/TestClass.method';
//let items=[{n:'name'}];
//let items={name:'n'};
export default class BackupToS3 extends LightningElement {

    @track objectNames = [];
    @track objectApiNames = [];
    @track selectedObjectNames=[];

    vfRoot = "https://credextechnology13-dev-ed--c.develop.vf.force.com/";

    test='fejf';
    fromDate=null;
    toDate=null;
    scheduleDate;
    scheduleTime;
    hasSchedule=false;


    items=[];
    isModal=true;
    
    currentStep='1';
    searchKey;
    csvString='';
    service=false;
    local=false;
    aws = false;
    value='';
    dataRows;
    objectSelected;
    iframe;
    minDate;
    contentWindow;

    screen1=true;
    screen2=false;

    zipFileData=null;
    
    
    CsvMap=new Map();

    columns = [{ label: 'Names', fieldName: 'objectName', type: "text" }];

    get options(){
        return [{label:'Local Storage',value:'Local'},
        {label:'AWS S3',value:'S3'}];

    }

    handleClick(){
        console.log('click');
        var ifk=this.template.querySelector("iframe");
        var vfWindow = ifk.contentWindow;
        console.log('vfWindow>>>');
        console.log(vfWindow);
        vfWindow.postMessage('test string', this.vfRoot);
    }
    connectedCallback(){
        /*console.log('array>>>>>>>>>>');
        console.log(thisitems);*/

        // window.addEventListener('message', this.handleMessage);
        window.addEventListener('message', (event) => this.handleMessage(event));
        console.log('after window');

        const today = new Date();
        today.setHours(0, 0, 0, 0); // Set time to midnight
        this.minDate = today.toISOString().slice(0, -1); // Convert to ISO string
        
        getObjectsApiNames()
        .then(data=>{
            this.objectNames = [];
            for (var i = 0; i < data.length; i++){
                    var item={
                    id:i,
                    objectName:data[i]
                    };
                this.objectNames.push(item);
                }
        })
        .catch(error=>{
            console.log(error);
        })
    }

    disconnectedCallback() {
        // Remove the event listener when the component is removed
        window.removeEventListener('message', this.handleMessage);
      }

      handleMessage(event) {
        console.log('inside handlemssg');
        // Check if the message is from the expected VF page
       /* if (event.origin !== 'https://your-vf-page-url.com') {
          return;
        }*/
    
        // Check if the message contains the ZIP file data
        if (event.data && event.data.name === 'ZipFileData') {
            console.log('zip file data');
          // Extract the ZIP file data from the event data
          this.zipFileData = event.data.payload;
          console.log('zip inside handle message>>>>>>',this.zipFileData);
          console.log(typeof this.zipFileData);
          /*setTimeout(() => {
            this.uploadS3();
            }, 7000)*/
          this.uploadS3();
          // Trigger the download of the ZIP file in the LWC
        //  this.downloadZipFile(this.zipFileData); //if Export Now call this line from this function. 
        }
      }

      downloadZipFile(zipFileData) {
        // Create a Blob object from the ZIP file data
        const blob = new Blob([this.zipFileData], { type: 'application/zip' });
    
        // Create an anchor element to initiate the download
        const downloadLink = document.createElement('a');
        downloadLink.href = URL.createObjectURL(blob);
        downloadLink.download = 'SF Data.zip';
    
        // Trigger the download
        downloadLink.click();
    
        // Release the allocated resources
        URL.revokeObjectURL(downloadLink.href);
      }

      

    handleSearchKey(event){
        console.log('array>>>>>>>>>>');
        console.log(JSON.parse(JSON.stringify(this.items)));
       // console.log('search key',event.target.value);
        this.searchKey=event.target.value;
        //console.log(this.searchKey.length);
        if(this.searchKey.length>=3){
            getObjectsApiNamesBySearch({textKey:this.searchKey})
                .then(data=>{
                   // console.log('data',data);
                    this.objectNames = [];
                    for (var i = 0; i < data.length; i++){
                            var item={
                            id:i,
                            objectName:data[i]
                            };
                        this.objectNames.push(item);
                        }
                })
                .catch(error=>{
                    console.log('error',error);
                })
        }
    }

    handleRadio(event){
        if (event.target.value =='Local') {
            console.log('array>>>>>>>>>>');
            console.log(this.items);
            this.local = true;
            this.aws = false;
        }
        if (event.target.value =='S3') {
            this.aws = true;
            this.local = false;
        }
        if(this.aws == true){

        }
    }

     /*handleClick() {
        console.log('in modal');
        const result =  MyModal.open({
            label:'test',
            // `label` is not included here in this example.
            // it is set on lightning-modal-header instead
            size: 'large',
            description: 'Accessible description of modal\'s purpose',
            //content: 'Passed into content api',
        })
        .then((data)=>{
            console.log('success');
        }).catch((error)=>{
            console.log('error');
        })
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
        console.log(result);
    }*/

    handleNext(){
        this.screen2=true;
        this.screen1=false;
        this.currentStep='2';
        this.service=true;
        this.previous=false;
        let scheduleDateTime;

        this.dataRows=this.template.querySelector('lightning-datatable').getSelectedRows();
        /*console.log('selectedRows.getSelectedRows()',selectedRows.getSelectedRows());
        console.log('after data');
        console.log('selectedRows ', selectedRows);
        console.log('rows'+selectedRows);*/
       // this.dataRows=selectedRows;
        console.log(this.dataRows);
        console.log(this.dataRows.length);
        if(this.dataRows.length>0){
            this.objectSelected=true;
        }
        else{
            this.objectSelected=false;
        }
       // exportData(selectedRows.getSelectedRows());
       this.iframe = this.template.querySelector("iframe");
       console.log('iframe');
       console.log(this.iframe);
       console.log(this.iframe.contentWindow);
       this.contentWindow=this.iframe.contentWindow;
       console.log('content window>>>>>>>>>>>>');
       console.log(this.contentWindow);
       
       let dates=this.template.querySelectorAll('lightning-input');
        dates.forEach(function(date){
            if(date.name=='fromDate'){
                this.fromDate=date.value 
            }
            else if(date.name=='toDate'){
                this.toDate=date.value;
            }
            else if(date.name=='scheduleDate'){
                scheduleDateTime=date.value;
            }
        },this);
        console.log('from date',this.fromDate);
        console.log('to date',this.toDate); 
        console.log('scheduleDate>>>>>>>>>>',this.scheduleDate);

        const dateTime = new Date(scheduleDateTime);
        this.scheduleDate = dateTime.toISOString().slice(0, 10);
        this.scheduleTime = dateTime.toTimeString().slice(0, 8);
        console.log('Date:', this.scheduleDate); // Output: Date: 2023-07-22
        console.log('Time:', this.scheduleTime); //

        
    }
    handlePrevious(){
        this.currentStep='1';
        this.previous=true;
        this.service=false;

    }

    // this func will use to schedule jobs at given time
    scheduleFunction() {
        // Set the target date and time when you want the function to execute
        this.hasSchedule=true;
        const timeArray = this.scheduleTime.split(":");
        const hours = parseInt(timeArray[0], 10);
        const minutes = parseInt(timeArray[1], 10);
        const seconds= parseInt(timeArray[2], 10);


        console.log('schedule function');
        const targetDate = new Date(this.scheduleDate); // Example date: August 1, 2023
        const targetTimeHours = parseInt(hours, 10);; // 12 PM
        const targetTimeMinutes = parseInt(minutes, 10);
        const targetTimeSeconds = parseInt(seconds, 10);

        // Combine the target date and time
        targetDate.setHours(targetTimeHours);
        targetDate.setMinutes(targetTimeMinutes);
        targetDate.setSeconds(targetTimeSeconds);
    
        // Get the current date and time
        const now = new Date();

        // Calculate the delay in milliseconds from the current time to the target time
        const delay = targetDate - now;
    
        // Use setTimeout to schedule the function after the calculated delay
        setTimeout(() => {
          // Call the function you want to execute here
          this.exportData();
        }, delay);

      }
    
    async exportData(){
        console.log('data export');
        // fetching Dates selected by user
        /*let dates=this.template.querySelectorAll('lightning-input');
        dates.forEach(function(date){
            if(date.name=='fromDate'){
                this.fromDate=date.value
            }
            else if(date.name=='toDate'){
                this.toDate=date.value;
            }
        },this);
        console.log('from date',this.fromDate);
        console.log('to date',this.toDate);  */
       
       /* var selectedRows=this.template.querySelector('lightning-datatable');
        console.log('after data');
        console.log('selectedRows ', selectedRows);
        console.log('rows'+selectedRows)*/
        var selectedObjectNames=[];
        selectedObjectNames=JSON.stringify(this.dataRows);//rows
        selectedObjectNames = JSON.parse(selectedObjectNames);
      //  console.log('obj names', selectedObjectNames);
        for (var i = 0; i < selectedObjectNames.length; i++){
            this.objectApiNames.push(selectedObjectNames[i].objectName);
        }
        
        /*for(var i=0;i<data.length;i++){
            const objectsNames=[];
            for(j=i;j<i+50;j++){
                objectsNames.push(data[i]);
            }
            await getRecordsByObject({objectNames:this.objectApiNames,fromDate:this.fromDate,toDate:this.toDate})
            .then(data=>{
                this.objectData.push(data);
            })
            .catch(data=>{

            })
        }*/
      /*
            @description : Implicitly fetching data of objects selected by the user
            */
        await getRecordsByObject({objectNames:this.objectApiNames,fromDate:this.fromDate,toDate:this.toDate})
        .then(data=>{
            let c = this.objectApiNames[0];  
            for(var i=0;i<this.objectApiNames.length;i++){
                let c = this.objectApiNames[i]
              //  this.downloadCSV(data[c],c);
               // this.CsvMap.set(c,this.downloadCSV(data[c],c));
               var cont=this.downloadCSV(data[c],c);
               console.log('cont>>>>>>');
               console.log(cont);
               console.log(typeof cont);
                this.items.push({'Account':cont});
                console.log('itema>>>>>>>>>>>>>>>>>>>>>>>>');
                console.log(JSON.parse(JSON.stringify(this.items)));
            }
            console.log('map of content')
            console.log(this.items);
            console.log(JSON.stringify(this.CsvMap));
            console.log(typeof this.items);
            console.log(typeof JSON.stringify(this.items));
            //if(!this.CsvMap){
               /* getcsvContent({csvContents:JSON.stringify(this.items)})
                .then(data=>{
                    console.log('yes');
                })
                .catch(error=>{
                    console.log('error');
                })*/
           // }
        })
        .catch(error=>{
            console.log(console.log('error',error));
        })

        //window.postMessage({ type: 'FROM_LWC', data: JSON.stringify(this.items) }, window.location.origin);

        console.log('click');
        console.log(this.iframe);
        console.log(this.iframe.contentWindow);
        var vfWindow = this.iframe.contentWindow;
        console.log('vfWindow>>>');
        console.log(vfWindow);
        console.log(this.contentWindow);
        var vfwin = this.contentWindow;
        vfwin.postMessage(JSON.parse(JSON.stringify(this.items)),this.vfRoot);
        //this.uploadS3();
        
            
    }

    /* 
        @description : This function is used to convert our data to CSV Format and User can download the file.
    */
    downloadCSV(recordData,ApiName){
        // console.log('recordsData>>>>>>>>>',recordData);
        // console.log('ApiName>>>>>>>>>.',ApiName);
            let rowEnd = '\n';
            let csvString = '';
            // this set elminates the duplicates if have any duplicate keys
            let rowData = new Set();
     
            // getting keys from data
            recordData.forEach(function (record) {
                Object.keys(record).forEach(function (key) {
                    rowData.add(key);
                });
            });
     
            // Array.from() method returns an Array object from any object with a length property or an iterable object.
            rowData = Array.from(rowData);
             
            // splitting using ','
            csvString += rowData.join(',');
            csvString += rowEnd;
     //this.recordsData
            // main for loop to get the data based on key value
            for(let i=0; i < recordData.length; i++){
                let colValue = 0;
     
                // validating keys in data
                for(let key in rowData) {
                    if(rowData.hasOwnProperty(key)) {
                        // Key value 
                        // Ex: Id, Name
                        let rowKey = rowData[key];
                        // add , after every value except the first.
                        if(colValue > 0){
                            csvString += ',';
                        }
                        // If the column is undefined, it as blank in the CSV file.
                        let value = recordData[i][rowKey] === undefined ? '' : recordData[i][rowKey];
                        csvString += '"'+ value +'"';
                        colValue++;
                    }
                }
                csvString += rowEnd;
            }
            console.log('csvString',csvString);
            this.csvString=csvString;
            return csvString;
           // this.uploadS3(csvString,ApiName);
           
            // Creating anchor element to download
           /* let downloadElement = document.createElement('a');
     
            // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
            downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
            downloadElement.target = '_self';
            
            // CSV File Name
            downloadElement.download = ApiName+' Data.csv';
            console.log(downloadElement);
            // below statement is required if you are using firefox browser
            document.body.appendChild(downloadElement);
            console.log(document.body);
            // click() Javascript function to download CSV file
            console.log(document);
            downloadElement.click(); */
    }
//csvString,ApiName
    //uploadS3(){
    uploadS3 = () => {
        console.log('inside upload');
        console.log('zip Data>>>>>>>>>>>>>>>>>>>>');
        console.log(this.zipFileData);
        console.log(typeof this.zipFileData);
        if(this.zipFileData instanceof Blob){
            console.log('zipData is of type Blob');
        }

        //const base64String= window.btoa(unescape(encodeURIComponent(blobData)));
       /* console.log('inside upload');
        console.log(typeof this.csvString);*/
        //const blob = new Blob([csvString], { type: 'text/csv;charset=utf-8;' });
        const blobData = new Blob(['sfsfsff'], { type: 'application/json' });
        console.log('blob>>>>>>>>>>>',blobData);
        console.log(typeof blobData);


        const fileReader = new FileReader();
        fileReader.onload = () => {
            const base64String = fileReader.result.split(',')[1];
                console.log('base64String>>>>>>>>>>>');
                console.log('blobData>>>>>>>>');
                console.log(blobData);
                console.log(base64String);
                console.log(this.zipFileData);
            // Call the Apex method and pass the base64String as a parameter
            uploadCSV({ZipData:base64String})
            .then(data=>{
                console.log(data);
                console.log('successfully send to csv');
                this.showToast('Your files are successfull Backup to S3','success');
            })
            .catch(error=>{
                console.log('some error');
                this.showToast('Some Errors occured','error');
                console.log('error',error);
            })
        };

        if(blobData instanceof Blob){
            console.log('yes its a type of blob');
        }
        // uploading to s3
        //uploadCSV({csvString:'bd',apiName:'ndsn'})
      /*  let zipDataaaa=JSON.stringify(this.zipFileData);
        const blobData2 = new Blob([this.zipFileData]);
        console.log('typeof', typeof blobData2);

        if(blobData2 instanceof Blob){
            console.log('yes');
        }

        console.log(JSON.stringify(blobData2));*/
        //console.log(blobData2.size());

        /*uploadCSV({ZipData:base64String})
        .then(data=>{
            console.log('successfully send to csv');
            this.showToast('Your files are successfull Backup to S3','success');
        })
        .catch(error=>{
            console.log('some error');
            this.showToast('Some Errors occured','error');
            console.log('error',error);
        })*/

       /* console.log('blob object'+blob);
        console.log(typeof blob);
        console.log(navigator.msSaveBlob(blob, 'Account File'));*/

        
        // Create a new FormData object and append the Blob data
       /* let formData = new FormData();
        formData.append('ZipData', this.zipFileData, 'file.zip');*/

        // Make the HTTP callout to the Apex method using the fetch API
       /* fetch('AWSFileService.uploadCSV', {
            method: 'POST',
            body: formData
        })
            .then((response) => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then((data) => {
                console.log('Success:', data);
            })
            .catch((error) => {
                console.error('Error:', error);
            });*/
            fileReader.readAsDataURL(this.zipFileData);

 
    }

    showToast(message,variant){
        const event = new ShowToastEvent({
            title:'Sucess',
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}