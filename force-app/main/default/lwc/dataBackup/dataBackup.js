/* eslint-disable no-alert */
/* eslint-disable vars-on-top */
import { LightningElement, wire, track } from "lwc";
import local from "@salesforce/resourceUrl/LocalBackup";
import cloud from "@salesforce/resourceUrl/AwsLogo";
import getObjectsApiNames from '@salesforce/apex/dataBackup2.getObjectsApiNames';
import getRecordsByObject from '@salesforce/apex/dataBackup2.getRecordsByObject';
import getObjectsApiNamesBySearch from '@salesforce/apex/dataBackup2.getObjectsApiNamesBySearch';
import filePUT from '@salesforce/apex/AwsS3Integration.filePUT';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getObjects from '@salesforce/apex/dataBackup2.getObjects';
import createDataBackup from '@salesforce/apex/DataBackup.createDataBackup';

export default class dataBackup extends LightningElement {
  objectList;
  objectNames = [];

  //showLocalScreen = true;
  //showScheduleExport = false;
  showCloudScreen = false;
  currentStep = 1;
  step = 1;
  columns = [
    { label: "Name", fieldName: "objectName" }
  ];
  columns1 = [{ label: "Name", fieldName: "objectName", type: "text" }];
  selectedObjects = [];
  localImage = local;
  cloudImage = cloud;



  @track objectNames = [];
  @track objectApiNames = [];
  @track selectedObjectNames = [];

  ObjectNames = [];
  items = [];
  objectsWithoutData;
  Screen2 = false;
  Screen1 = true;
  isModal = false;
  searchKey;
  awsAccessKey;
  awsSecretKey;
  awsRegion;
  awsBucket;
  selectedRows;
  fromDate;
  toDate;
  isbackupToS3 = false;
  SfDataFileName;
  maxDate;
  isLoading = true;

  vfRoot = "https://credextechnology13-dev-ed--c.develop.vf.force.com/";

  connectedCallback() {

    const today = new Date();
    this.maxDate = today.toISOString().split('T')[0];
    console.log(this.maxDate);
    if (this.isLoading) {
      this.showToast('Please Wait', 'Please wait while we are fetching your object Details', 'success');
    }

    getObjectsApiNames()
      .then(data => {
        this.objectNames = [];
        for (var i = 0; i < data.length; i++) {
          var item = {
            id: i,
            objectName: data[i]
          };
          this.objectNames.push(item);
        }
        if (this.objectNames != null) {
          this.isLoading = false;
        }
      })
      .catch(error => {
        console.log(error);
      })

    window.addEventListener('message', (event) => this.handleMessage(event));
  }

  disconnectedCallback() {
    // Remove the event listener when the component is removed
    window.removeEventListener('message', this.handleMessage);
  }

  handleMessage(event) {
    console.log('inside handlemssg');

    // Check if the message contains the ZIP file data
    if (event.data && event.data.name === 'ZipFileData') {

      this.zipFileData = event.data.payload;
      console.log('zip inside handle message>>>>>>', this.zipFileData);
      console.log(typeof this.zipFileData);
      console.log('before s3');
      const date = new Date().toJSON();
      this.SfDataFileName = 'SF Data(' + date + ')' + '.zip';

      if (this.isbackupToS3) {
        this.backupTos3('zipFileName');
      }
      else {
        this.downloadZipFile(this.zipFileData);
      }
    }
  }

  downloadZipFile(zipFileData) {
    // Create a Blob object from the ZIP file data
    console.log('inside download zip');
    const blob = new Blob([zipFileData], { type: 'application/zip' });
    console.log(blob);
    // Create an anchor element to initiate the download
    const downloadLink = document.createElement('a');
    downloadLink.href = URL.createObjectURL(blob);
    downloadLink.download = this.SfDataFileName;
    console.log('link');
    console.log(downloadLink);
    // Trigger the download
    downloadLink.click();

    // Release the allocated resources
    URL.revokeObjectURL(downloadLink.href);
    this.showToast('Success', 'Your Salesforce Data Backup File is downloaded on your Local Machine', 'success');
    this.showToast('Review', 'Some objects are not included in backup List as we have not found any data in some objects Total Objects:' + this.objectsWithoutData.length, 'succes');
  }

  handleSearchKey(event) {
    console.log('inside search bar');
    console.log(JSON.parse(JSON.stringify(this.items)));
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



  getSelectedObjects() {
    // console.log('test');
    const selectedRows = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    this.selectedObjects = selectedRows.map((row) => row.objectName);
    for (let i = 0; i < this.selectedObjects.length; i++) {
      console.log(this.selectedObjects[i]);
    }
  }
  handleSteps() {
    if (step === 1) {
      this.Screen1 = true;
      this.screen2 = false;
    }
    else if (step === 2) {
      this.Screen2 = true;
      this.screen1 = false;
    }
    else if (step === 3) {
      //success
    }
    this.currentStep = '' + this.step;
  }

  previousStep() {
    if (this.step != 1)
      this.step--;
    this.handleSteps();

    if (this.Screen2 === false) {
      this.Screen1 = true;
    }
    
  }


  handleNext() {
    this.selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
    console.log(this.selectedRows.length);
    let dates = this.template.querySelectorAll('lightning-input');
    dates.forEach(function (date) {
      if (date.name == 'fromDate') {
        this.fromDate = date.value
      }
      else if (date.name == 'toDate') {
        this.toDate = date.value;
      }
    }, this);

    if (this.selectedRows.length > 0) {
      this.Screen2 = true;
      this.Screen1 = false;
      this.showToast('Kindly Review!', 'You have selected ' + this.selectedRows.length + ' objects to Backup', 'success');
    }
    else if (this.selectedRows.length === 0) {
      this.showToast('Required', 'Kindly select objects To Backup', 'error');

      //this.Screen2 = false;
      
    }
    console.log(this.selectedRows);
    console.log(this.fromDate);
    console.log(this.toDate);
    
    if (this.step != 3) {
      this.step++;
    }
    this.handleSteps();
  }
  
  setAwsCredentials() {
    console.log('inisde set cred');
    this.isModal = true;
  }

  handleAWSCredentials(event) {
    console.log('handle aws creds');
    console.log(event);
    console.log(event.detail.value);
    console.log(JSON.stringify(event.detail));
  }

  localScreenButton() {
    //console.log("inside localScreenButton");
    this.showLocalScreen = true;
  }

  async exportData(event) {

    console.log(event.target.name);
    if (event.target.name == 'backupToS3') {
      this.isbackupToS3 = true;
    }
    else if (event.target.name == 'Local') {
      this.isbackupToS3 = false;
    }
    console.log(this.isbackupToS3);
    console.log('data export');

    //var vfReference = this.template.querySelector('iframe');

    var selectedObjectNames = [];
    selectedObjectNames = JSON.stringify(this.selectedRows);
    //selectedObjectNames = JSON.parse(JSON.stringify(this.selectedRows));
    selectedObjectNames = JSON.parse(selectedObjectNames);
    //  console.log('obj names', selectedObjectNames);
    console.log('length');
    console.log(selectedObjectNames.length);


    //console.log(JSON.stringify(selectedObjectNames));
    /*getObjects({jsonString:JSON.stringify(selectedObjectNames)})
    .then(data=>{
      console.log('data>>>>>',data);
    })
    .catch(error=>{
      console.log('error',error);
    })*/
    /*for (var i = 0; i < selectedObjectNames.length; i++){
        this.objectApiNames.push(selectedObjectNames[i].objectName);
    }*/

   /* console.log('click');
    var iframe = this.template.querySelector('iframe');
    console.log(iframe);
    console.log(iframe.contentWindow);
    var vfWindow = iframe.contentWindow;
    console.log('vfWindow>>>');
    console.log(vfWindow);
    //console.log(this.contentWindow);
    //var vfwin = this.contentWindow;
    vfWindow.postMessage(selectedObjectNames, this.vfRoot);*/
    this.ObjectNames = [];
    try{
      for (var i = 0; i < selectedObjectNames.length; i+=1) {

        this.ObjectNames.push(selectedObjectNames[i].objectName);
       // console.log(selectedObjectNames[i].objectName);
      }
      console.log('after ');
      console.log(JSON.stringify(this.ObjectNames));
      //console.log(this.ObjectNames);
      createDataBackup({ObjectApiNames:this.ObjectNames})
      .then(data=>{
        console.log('data>>>>>>>');
        console.log(data);
      })
      .catch(error=>{
        console.log(error);
        console.log('error');
      })
    }
    catch(err){
      console.log(err);
      console.log('error in 312');
    }
    

    // for (var i = 0; i < selectedObjectNames.length; i += 10) {
    //   this.ObjectNames = [];
    //   for (var j = i; j < i + 10; j++) {
    //     if (j < selectedObjectNames.length) {
    //       //ObjectNames.push(selectedObjectNames[j].objectName);

    //       this.ObjectNames.push(selectedObjectNames[j].objectName);
    //     }
    //   }
    //   console.log(this.objectNames);

    //   await getRecordsByObject({ objectNames: this.ObjectNames, fromDate: this.fromDate, toDate: this.toDate })
    //     .then(data => {
    //       console.log('data>>>>>>>>>>>');
    //       console.log('data>>>>>>>>>>>>>>', data);
    //       //let c = ObjectNames[0];  
    //       for (var i = 0; i < this.ObjectNames.length; i++) {
    //         let objectName = this.ObjectNames[i];
    //         console.log('inside dta ');
    //         var csvData = this.generateCSV(data[objectName], objectName);
    //         console.log('cont>>>>>>');
    //         console.log(csvData);
    //         console.log(typeof csvData);

    //         let obj = {};
    //         var key = objectName;
    //         obj[key] = csvData;
    //         //this.items.push({'Account':csvData});
    //         this.items.push(obj);
    //         console.log('itema>>>>>>>>>>>>>>>>>>>>>>>>');
    //         console.log(JSON.parse(JSON.stringify(this.items)));
    //         // }
    //       }
    //       console.log('map of content')
    //       console.log(this.items);
    //       // console.log(JSON.stringify(this.CsvMap));
    //       console.log(typeof this.items);
    //       console.log(typeof JSON.stringify(this.items));
    //     })
    //     .catch(error => {
    //       console.log(console.log('error', error));
    //     })



    // }

   /* console.log('click');
    var iframe = this.template.querySelector('iframe');
    console.log(iframe);
    console.log(iframe.contentWindow);
    var vfWindow = iframe.contentWindow;
    console.log('vfWindow>>>');
    console.log(vfWindow);
    //console.log(this.contentWindow);
    //var vfwin = this.contentWindow;
    vfWindow.postMessage(JSON.parse(JSON.stringify(this.items)), this.vfRoot);*/
    //this.uploadS3();*/


  }

  generateCSV(recordData, ApiName) {
    console.log('recordsData>>>>>>>>>', recordData);
    console.log('ApiName>>>>>>>>>.', ApiName);
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
    for (let i = 0; i < recordData.length; i++) {
      let colValue = 0;

      // validating keys in data
      for (let key in rowData) {
        if (rowData.hasOwnProperty(key)) {
          // Key value 
          // Ex: Id, Name
          let rowKey = rowData[key];
          // add , after every value except the first.
          if (colValue > 0) {
            csvString += ',';
          }
          // If the column is undefined, it as blank in the CSV file.
          let value = recordData[i][rowKey] === undefined ? '' : recordData[i][rowKey];
          csvString += '"' + value + '"';
          colValue++;
        }
      }
      csvString += rowEnd;
    }
    console.log('csvString', csvString);
    this.csvString = csvString;
    return csvString;

  }

  backupTos3(zipFileName) {
    console.log('s3 backup');
    console.log(this.zipFileData);
    console.log(typeof this.zipFileData);
    if (this.zipFileData instanceof Blob) {
      console.log('zipData is of type Blob');
    }

    const fileReader = new FileReader();
    fileReader.onload = () => {
      const base64String = fileReader.result.split(',')[1];
      console.log('base64String>>>>>>>>>>>');
      console.log('blobData>>>>>>>>');
      console.log(base64String);
      console.log(this.zipFileData);
      // Call the Apex method and pass the base64String as a parameter
      filePUT({ fileName: 'zipFileName2', recordId: '0015i00000oYvsvAAC', accessKey: 'AKIAXBC2OOIM4NKWKX4D', secretKey: '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', awsRegion: 'eu-north-1', bucket: 'createtestbuk', zipData: base64String })
        .then(data => {
          console.log(data);
          console.log('successfully send to csv');
          this.showToast('Success', 'Your files are successfull Backup to S3', 'success');
        })
        .catch(error => {
          console.log('some error');
          this.showToast('Error', 'Some Errors occured', 'error');
          console.log('error', error);
        })
    };
    fileReader.readAsDataURL(this.zipFileData);

  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

}