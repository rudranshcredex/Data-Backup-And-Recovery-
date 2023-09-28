import { LightningElement, track } from 'lwc';
//import uploadCSVFile from '@salesforce/apex/UploadCSVFileController.uploadCSVFile';
import getObjectsApiNames from '@salesforce/apex/dataBackup2.getObjectsApiNames';
import getObjectsApiNamesBySearch from '@salesforce/apex/dataBackup2.getObjectsApiNamesBySearch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processCSVFile from '@salesforce/apex/UploadCSVFileController.processCSVFile';
import uploadZipFile from '@salesforce/apex/DataRecovery.uploadZipFile';
import performInsert from '@salesforce/apex/DataRecovery.performInsert';
import testMethods from '@salesforce/apex/DataRecovery.testMethods';
//import uploadZipFile from '@salesforce/apex/BulkApiQueryExample.uploadZipFile';
export default class DataRecovery extends LightningElement {

  @track csvFile;
  fileName = 'No files selected';
  searchKey
  @track objectNames = [];
  totalRecords;
  insertedRecords;
  updatedRecords;
  recordsNotProcessed;
  showRecordDetails = false;
  isLoading = false;
  result = false;
  screen2 = true;
  screen1 = false;
 
  columns = [
        { label: 'Names', fieldName: 'objectName', type: 'text' },
        {
            label: 'External Ids',
            type: 'dropdown',
            typeAttributes: {
                options: [
                    { label: 'External ID 1', value: 'externalId1' },
                    { label: 'External ID 2', value: 'externalId2' },
                    { label: 'External ID 3', value: 'externalId3' }
                ]
            }
        }
    ];

    data = [
        { objectName: 'Account',csvData: 'CSV Data 1' },
        { objectName: 'Opportunity',csvData: 'CSV Data 2' },
    ];
  

  columns1 = [{ label: 'Names', fieldName: 'objectName', type: "text" }];

  selectedRecords = [];
  objectsWithExternalId = [];
  objectsWithoutExternalId = [];

  vfRoot = "https://credextechnology13-dev-ed--c.develop.vf.force.com/";

    objectsWithoutExternalId = [
        {
            objectName: 'Opportunity',
            CsvData: 'Sample CSV Data for Opportunity without External ID'
        },
        {
            objectName: 'Lead',
            CsvData: 'Sample CSV Data for Lead without External ID'
        }
        
    ];


  
  connectedCallback() {
    console.log('inside connected callback');
    /* getObjectsApiNames()
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
     })*/

    /*window.addEventListener("message", (message) => {
      console.log('inside window.origin>>>>>>>.');
      console.log('origin',message.origin);
      
       console.log('message>>>>>>');
       console.log(message);
       //handle the message
       if (message.data.name === "SampleVFToLWCMessage") {
         console.log('message from vf >>>>>>>>.');
         console.log(message.data.payload);
         this.messageFromVF = message.data.payload;
       }
       console.log('messageFromVF>>>>>>>>>>>>');
       console.log(this.messageFromVF[0]);
       //console.log(this.messageFromVF[0].filename);
       //console.log(typeof this.messageFromVF[0].filename);
     });*/

    /* uploadZipFile()
     .then(data=>{
      console.log('data');
      console.log(data);
      console.log(JSON.parse(data));
      let parsedData = JSON.parse(data);
      console.log(JSON.stringify(parsedData));
      console.log(JSON.stringify(JSON.parse(data)));
     })*/
  }

  handleSearchKey(event) {
    // console.log('search key',event.target.value);
    this.searchKey = event.target.value;
    //console.log(this.searchKey.length);
    if (this.searchKey.length >= 3) {
      getObjectsApiNamesBySearch({ textKey: this.searchKey })
        .then(data => {
          // console.log('data',data);
          this.objectNames = [];
          for (var i = 0; i < data.length; i++) {
            var item = {
              id: i,
              objectName: data[i]
            };
            this.objectNames.push(item);
          }
        })
        .catch(error => {
          console.log('error', error);
        })
    }
  }


  handleFileChange(event) {
    this.csvFile = event.target.files[0];
    this.fileName = event.target.files[0].name;

    this.showToast('Files Uploaded Sucessfully', this.fileName + '  Uploaded Successully', 'success');
    console.log('name' + this.fileName);
    console.log(this.csvFile);

    var vfWindow = this.template.querySelector("iframe").contentWindow;
    console.log('vfWindow>>>');
    console.log(vfWindow);
    vfWindow.postMessage(this.csvFile, this.vfRoot);


  }

  handleUpload2() {
    const fileReader = new FileReader();
    fileReader.onload = () => {
      const fileData = fileReader.result.split(',')[1]; // Extract base64 encoded data
      //this.callApexMethod(fileData);
      testMethods({ FileData: fileData })
        .then(data => {
          console.log('data');
        })
        .catch(error => {
          console.log('error');
          console.log(error);
        })
    };
    fileReader.readAsDataURL(this.csvFile);
  }
  handleUpload() {
    /*var vfWindow = this.template.querySelector("iframe").contentWindow;
      console.log('vfWindow>>>');
      console.log(vfWindow);
      vfWindow.postMessage(this.csvFile,this.vfRoot);*/

    if (this.csvFile == null) {
      this.showToast('Required', 'Please upload file for Recovery', 'error');
    }
    else {
      console.log('mssage>>>>>>', this.messageFromVF);
      console.log(typeof this.messageFromVF);
      this.isLoading = true;
      console.log('loading ' + this.isLoading);
      this.showRecordDetails = true;
      if (this.csvFile) {
        console.log('vf message>>>>>>>>');
        console.log('type>>>>>>>>>>>>>');
        console.log(typeof this.messageFromVF);
        processCSVFile({ csvContent: JSON.stringify(this.messageFromVF) })
          .then((result) => {
            // Handle success
            if (result) {
              this.isLoading = false;
            }
            this.result = true;
            this.totalRecords = result['totalRecords'];
            this.updatedRecords = result['updatedRecords'];
            this.insertedRecords = result['createdRecords'];
            this.recordsNotProcessed = result['recordsNotProcessed'];
            console.log(result);
            // refreshApex()
          })
          .catch((error) => {
            // Handle error
          });

        /* const reader = new FileReader();
         reader.onload = (event) => {
           const fileContent = event.target.result;
           // Pass file content to Apex method
          // console.log('file content>>>>>>>>>>'+fileContent);

           
           
         };
         reader.readAsText(this.csvFile);*/
      }
    }
  }

  showToast(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }

  // handleClick() {
  //   console.log('inside click');

  //   uploadZipFile()
  //     .then(data => {
  //       console.log('data');
  //       console.log(data);
  //       console.log(JSON.stringify(data));
  //       for (var key in data) {

  //         let objwithoutExternalId = {};
  //         let objwithExternalId = {};

  //         console.log(data[key].objectName);
  //         if (data[key]?.ExternalIdField.length > 0) {
  //           console.log('yes');
  //           var externalId = data[key].ExternalIdField;

  //           if (externalId[0] == '') {
  //             objwithoutExternalId.objectName = data[key].objectName;
  //             objwithoutExternalId.CsvData = data[key].csvData;

  //             /*   const blob = new Blob([data[key].csvData]);
  //                const reader = new FileReader();
  //                reader.onload = () => {
  //                  // Read the Blob data and store it in the object property
  //                  objwithoutExternalId.CsvData = reader.result;
  //                 };
 
  //                reader.readAsDataURL(blob);
  //                 console.log('bolb result');
  //                 console.log(blob);
  //                 console.log(objwithoutExternalId.CsvData);
  //                 console.log(typeof objwithoutExternalId.CsvData);*/

  //             console.log('blank');
  //           }
  //           else {
  //             console.log('not blank');
  //             objwithExternalId.objectName = data[key].objectName;
  //             objwithExternalId.CsvData = data[key].csvData;
  //             objwithExternalId.ExternalIds = data[key].ExternalIdField;
  //           }
  //         }

  //         this.objectsWithoutExternalId.push(objwithoutExternalId);
  //         this.objectsWithExternalId.push(objwithExternalId);
  //         console.log(data[key].ExternalIdField);
  //         console.log(key);
  //       }
  //     })
  //     .catch(error => {
  //       console.log('inside error');
  //       console.log('error', error);
  //     })
  // }

  // handleInsert() {
  //   console.log('insert op');
  //   performInsert({ objectsToInsert: JSON.stringify(this.objectsWithoutExternalId) })
  //     .then(data => {
  //       console.log('data');
  //       console.log(data);
  //     })
  //     .catch(error => {
  //       console.log('error', error);
  //     })
  // }
  handleExternalIdChange(event) {
    const selectedValue = event.detail.value;
    const selectedObject = this.objwithExternalId.find(item => item.dropdownValue === selectedValue);
    
    if (selectedObject) {
        const selectedRecord = {
            objectName: selectedObject.objectName,
            externalId: selectedValue,
            csvData: selectedObject.CsvData
        };
        
        this.selectedRecords.push(selectedRecord); // Add to the selected records array
        
        console.log('Selected Records:', this.selectedRecords);
    }
}
}