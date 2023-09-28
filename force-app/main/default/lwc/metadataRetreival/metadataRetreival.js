import { LightningElement, wire, track } from "lwc";
import Id from '@salesforce/user/Id';
import UserNameFIELD from '@salesforce/schema/User.Name';
import { getRecord } from 'lightning/uiRecordApi';
import local from "@salesforce/resourceUrl/LocalBackup";
import cloud from "@salesforce/resourceUrl/AwsLogo";
import getObjectsApiNames from '@salesforce/apex/dataBackup2.getObjectsApiNames';
import getRecordsByObject from '@salesforce/apex/dataBackup2.getRecordsByObject';
import getObjectsApiNamesBySearch from '@salesforce/apex/dataBackup2.getObjectsApiNamesBySearch';
import filePUT from '@salesforce/apex/AwsS3Integration.filePUT';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMetaDataTypes from '@salesforce/apex/MetadataRetriever.getMetaDataTypes';
import retreive from '@salesforce/apex/MetadataRetriever.retreive';
//import checkRetrieveStatus from '@salesforce/apex/MetadataRetriever.checkRetrieveStatus';
import getSessionId from '@salesforce/apex/MetadataRetriever.getSessionId';
export default class MetadataRetreival extends LightningElement {
  objectList;
  objectNames = [];
  textVariable = 'Your export has been queued. You will receive an email and custom notification when it is completed.';
  showLocalScreen = true;
  showScheduleExport = false;
  showCloudScreen = false;
 
  step = 1;
  date = Date();
  columns = [
    { label: "Name", fieldName: "metadataType" }
  ];
  //columns1 = [{ label: "Name", fieldName: "objectName", type: "text" }];
  selectedObjects = [];
  localImage = local;
  cloudImage = cloud;

  isModalOpen = false;
  isModalOpen1 = false;

  @track metadataTypes = [];
  @track objectApiNames = [];
  @track selectedObjectNames = [];

  ObjectNames = [];
  items = [];
  objectsWithoutData;
  Screen2 = false;
  Screen1 = true;
  isModal = false;
  searchKey;
  awsAccessKey = null;
  awsSecretKey = null;
  awsRegion = null;
  awsBucket = null;
  backupTo = 'Local';
  selectedRows;
  Screen3 = false;

  isbackupToS3 = false;
  isbackupToLocal = false;
  SfDataFileName;

  isLoading = false;
  myInterval;
  asyncresultId;
  sessionId;
  currentUserName;
  currentStep = 2;


  @wire(getRecord, { recordId: Id, fields: [UserNameFIELD] })
  currentUserInfo({ error, data }) {
    if (data) {
      console.log('user data');
      console.log(data);
      this.currentUserName = data.fields.Name.value;
      console.log(this.currentUserName);
    }
    if (error) {
      console.log('error');
      console.log(error);
    }
  };
  async connectedCallback() {


    if (this.isLoading) {
      this.showToast('Please Wait', 'Please wait while we are fetching Metadata Types', 'success');
    }

    /*await getSessionId()
      .then(data => {
        console.log('sessionId>>>>>');
        console.log(data);
        this.sessionId = data;
    })*/
    getMetaDataTypes()
      .then(data => {
        console.log('data>>>>>');
        console.log(data);

        this.metadataTypes = [];
        for (var i = 0; i < data.length; i++) {
          var item = {
            id: i,
            metadataType: data[i]
          };
          this.metadataTypes.push(item);
        }
        if (this.metadataTypes != null) {
          this.isLoading = false;
        }
      })
      .catch(error => {
        console.log(error);
      })

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


  handleNext() {
    this.selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();

    if (this.selectedRows.length > 0) {
      this.Screen2 = true;
      this.Screen1 = false;
      this.currentStep = 2;
      this.showToast('Kindly Review!', 'You have selected ' + this.selectedRows.length + ' Metdata Types to Backup', 'success');
    }
    else {
      this.showToast('Required', 'Kindly select Metdata Types To Backup', 'error');
    }
    console.log(this.selectedRows);

    //this.handleStepUps();
    //this.currentStep = 2;

   
  }

  handlePrevious() {
    this.Screen2 = false;
    this.Screen1 = true;
    //this.currentStep = 1;
  }

  setAwsCredentials() {
    console.log('inisde set cred');
    this.isModal = true;
  }

  handleAWSCredentials(event) {
    console.log('handle aws creds');
    console.log(event);
    console.log(event.detail.value);
  }

  localScreenButton() {
    //console.log("inside localScreenButton");
    this.showLocalScreen = true;
  }

  exportData(event) {

    this.showToast('In Progress', "Please wait while we are Prcocessing Your request  \n Thanks!", 'success');
    /*console.log(event.target.id);
    console.log(event.target.name);
    if(event.target.id =='backupToS3'){
      this.isbackupToS3 = true;
      this.isbackupToLocal = false;
    } 
    else if(event.target.id =='Local'){
      this.isbackupToS3 = false;
      this.isbackupToLocal = true;
    }*/
    console.log(this.isbackupToS3);
    console.log('data export');

    var selectedObjectNames = [];
    selectedObjectNames = JSON.stringify(this.selectedRows);
    //selectedObjectNames = JSON.parse(JSON.stringify(this.selectedRows));
    selectedObjectNames = JSON.parse(selectedObjectNames);

    console.log('length');
    console.log(selectedObjectNames.length);

    this.ObjectNames = [];
    for (var i = 0; i < selectedObjectNames.length; i++) {
      this.ObjectNames.push(selectedObjectNames[i].metadataType);
    }
    console.log('object names>>>>');

    var credential = { "accessKey": this.awsAccessKey, "SecretKey": this.awsSecretKey, "Bucket": this.awsBucket, "awsRegion": this.awsRegion, "backupTos3": this.isbackupToS3, "backupToLocal": this.isbackupToLocal };

    retreive({ metadataTypes: this.ObjectNames, credentials: JSON.stringify(credential) })
      .then(data => {
        console.log('data>>>');
        console.log(data);
        if (data) {
          this.showToast('In Progress', "we are processing your request  \nWe will send you an Email and Custom Notification once it gets completed \n Thanks!", 'success');
         this.Screen3 = true;
          this.Screen2 = false;
          this.currentStep = 3;

        }
        //this.myInterval = setInterval(() => this.checkRetrieveStatusfunc(data), 10000);
      })
      .catch(error => {

        console.log(console.log('error', error));
      })

  }

  /*checkRetrieveStatusfunc(asyncId) {
      console.log('call ibn check status');
      checkRetrieveStatus({ asyncResultId: asyncId })
        .then(data => {
          console.log(data);
          if (data == 'success' || data=='error') {
            //clearInterval(this.myInterval);
            this.backupTos3('test');
          }
      })
    }*/



  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  openModal() {
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
  }
  openModal1() {
    this.isModalOpen1 = true;
  }
  closeModal1() {
    this.isModalOpen1 = false;
  }
  
}