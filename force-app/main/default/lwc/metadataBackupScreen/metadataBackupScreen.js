/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable eqeqeq */
import { LightningElement, wire, track } from "lwc";
import local from "@salesforce/resourceUrl/LocalBackup";
import cloud from "@salesforce/resourceUrl/cloud";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import getMetaDataTypes from '@salesforce/apex/MetadataBackup.getMetaDataTypes';
import retrieveMetadata from '@salesforce/apex/MetadataBackup.retrieveMetadata';
import ScheduleMetaDataBackup from '@salesforce/apex/MetadataBackup.ScheduleMetaDataBackup';
export default class MetadataBackupScreen extends LightningElement {
  @track metadataList;
  @track metadataTypes = [];
  @track numberOfMetadataSelected = 0;
  @track schDate;


  dataExportText1 = "Your metadata export is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is exported accurately and securely.";
  lowerText = "You will receive an email notification once the export is completed, along with a custom notification.";
  dataScheduleText = "Your export is now scheduled and will be processed shortly. We're working diligently to ensure that your requested metadata is exported accurately and on time.";
  dataAwsText = "Your data backup to AWS is now in the queue and will be uploaded shortly. We're working diligently to ensure that your requested metadata is uploaded accurately and securely.";
  dataAwsScheduleText = "Your data backup to AWS is now scheduled and will be uploaded shortly. We're working diligently to ensure that your requested metadata is uploaded accurately and securely.";


  exportNowScreen = false;
  exportScheduleScreen = false;
  AwsNowScreen = false;
  AwsScheduleScreen = false;


  selectedMetadataTypes =[];
  showScreen1 = true;
  showScreen2 = false;
  showScreen3 = false;
  showCloudScreen = false;
  currentStep = "1";
  step = 1;
  isLoading = true;
  date = Date();
  columns1 = [{ label: "Name", fieldName: "metadataType", type: "text" }];
  local = local;
  cloud = cloud;
  homepage = false;
  username;
  userEmail;
  openModal = false;
  openModal1 = false;
  awsModal = false;
  isModal =false;
  isMetadataBackup = true;
  awsAccessKey = null;
  awsSecretKey = null;
  awsRegion = null;
  awsBucket = null;
  isbackupToS3 = false;
  isbackupToLocal = false;
  retrievalLoading = false;
  ScheduleDateLocal =null;
  ScheduleDateAws = null;

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD,EMAIL_FIELD]
  })
  wireUser({ error, data }) {
    if (data) {
      this.username = data.fields.Name.value;
      this.userEmail = data.fields.Email.value;
    } else if (error) {
      // Handle error
      console.error(error);
    }
  }

  connectedCallback() {
    getMetaDataTypes({})
      .then((result) => {
        console.log('result');
        console.log(result);
        this.metadataList = structuredClone(result);
        this.isSpinnerLoading(false);
        this.metadataTypes = this.metadataList;
      })
      .catch((error) => {
        this.showToast("Error fetching objects", error.message.body, "error");
      });
  }

  handleSearchChange(event) {
    if (this.metadataList && event.target.value.length >= 2) {
      this.filterObjectNames(event.target.value);
    } else {
      this.isSpinnerLoading(true);
      this.metadataList = this.metadataTypes;
      this.isSpinnerLoading(false);
    }
  }

  async filterObjectNames(searchKeyword) {
    let newMetadataList = [];
    this.isSpinnerLoading(true);
    for (let i = 0; i < this.metadataList.length; i++) {
      if (
        this.metadataList[i].metadataType
          .toLowerCase()
          .substring(0, searchKeyword.length)
          .localeCompare(searchKeyword.toLowerCase()) == 0
      ) {
        newMetadataList.push(this.metadataList[i]);
      }
    }
    this.metadataList = newMetadataList;
    this.isSpinnerLoading(false);
  }

  nextButton() {
    if (this.step === 1) {
      const selectedMetadataTypes = this.metadataList.filter((metadata) => metadata.isSelected);
      if (selectedMetadataTypes.length === 0) {
        this.showToast(
          "Required",
          "Please select at least one object.",
          "error"
        );
        return;
      }
      if (selectedMetadataTypes.length>0) {
        this.showToast(
          "Kindly Review!",
          "You have selected "+ selectedMetadataTypes.length +" Components to backup",
          "success"
        );
      }
      console.log('selected Objects');
     // console.log(selectedMetadataTypes);
      console.log(JSON.stringify(selectedMetadataTypes));
      //console.log(JSON.stringify(JSON.parse(selectedMetadataTypes)));
      console.log(selectedMetadataTypes.length);
      
      let MetadataArray = selectedMetadataTypes;
      console.log('obj Array');
      console.log(JSON.stringify(MetadataArray));
      for(var i=0;i<MetadataArray.length;i++){
          console.log(MetadataArray[i]);
          console.log('stringify');
          console.log(JSON.stringify(MetadataArray[i]));
          console.log(MetadataArray[i].metadataType);
          this.selectedMetadataTypes.push(MetadataArray[i].metadataType);
      }
      console.log(JSON.stringify(this.selectedMetadataTypes));
    }

    if (this.step !== 3) {
      this.step++;
    }
    this.handleStepUp();

  }

  ExportData(event){
    console.log('export data');
    //console.log(event.target);
    let divId =event.currentTarget.getAttribute('data-id');;
   // console.log(dib.dataset.id);
   // console.log(event.id);
    this.retrievalLoading =true;
    if(divId=='LocalNow'){
      console.log('local');
      this.isbackupToLocal = true;
      this.isbackupToS3 = false;
      this.exportNowScreen = true;
    }
    if(divId=='AwsNow'){
        this.isbackupToS3 = true;
      this.isbackupToLocal = false;
      this.AwsNowScreen = true;
    }
    if(this.isbackupToS3 &&(this.awsAccessKey===null && this.awsSecretKey===null && this.awsRegion===null && this.awsBucket===null)){
        this.showToast('Required','To Backup Data to S3 Kindly select Credentials','error');
        this.retrievalLoading =false;
        return;
    }
    
    console.log('data export');
    var credential = { "accessKey": this.awsAccessKey, "SecretKey": this.awsSecretKey, "Bucket": this.awsBucket, "awsRegion": this.awsRegion, "backupTos3": this.isbackupToS3, "backupToLocal": this.isbackupToLocal };
    retrieveMetadata({ metadataTypes: this.selectedMetadataTypes, credentials: JSON.stringify(credential) })
    .then(data=>{
        this.showScreen3 = true;
        console.log('data>>>>>>>');
        console.log(data);
        //if(data=='Success'){

            this.retrievalLoading =false
            this.showScreen3 = true;
            this.showScreen1 = false;
            this.showScreen2 = false;
      })
      .catch(error=>{
        this.showScreen3 = true;
        console.log(error);
        console.log('error');
      })
      this.step = 3;
      this.handleStepUp();
  }


  previousButton() {
    this.showScreen2 = false;
    this.showScreen1 = true;
    this.step = 1;
    this.handleStepUp();
    this.isLoading = true;
    this.isSpinnerLoading(false);
    this.metadataList = this.metadataTypes;
  }

  handlecheckboxChange(event) {
    this.changeObjectSelectionNumber(event);
    for (let i = 0; i < this.metadataList.length; i++) {
      if (this.metadataList[i].objectId == event.target.dataset.id) {
        this.metadataList[i].isSelected = event.detail.checked;
        break;
      }
    }
  }
  changeObjectSelectionNumber(event) {
    if (event.detail.checked) {
      this.numberOfMetadataSelected++;
    } else {
      this.numberOfMetadataSelected--;
    }
  }
  handleAllCheckboxChange(event) {
    if (event.detail.checked) {
      this.processObjectList(event);
      this.numberOfMetadataSelected = this.metadataTypes.length;
    } else {
      this.processObjectList(event);
      this.numberOfMetadataSelected = 0;
    }
  }

  processObjectList(event) {
    for (let i = 0; i < this.metadataList.length; i++) {
      this.metadataList[i].isSelected = event.detail.checked;
    }
  }
  isSpinnerLoading(isLoading) {
    window.setTimeout(() => {
      this.isLoading = isLoading;
    }, 1000);
  }
  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant
      })
    );
  }
  handleStepUp() {
    this.showScreen1 = this.step == 1;
    this.showScreen2 = this.step == 2;
    this.showScreen3 = this.step == 3;
    this.currentStep = "" + this.step;
  }
  handleHomepage() {
    console.log("handle home");
    this.homepage = true;
    this.showScreen3 = false;
    this.showScreen1 = false;
    this.showScreen2 = false;
    console.log(this.homepage);
  }

  handleOpenModal() {
    this.openModal = true;
  }
  handleOpenModal1() {
    this.openModal1 = true;
  }
  handleCloseModal() {
    this.openModal = false;
  }
  handleCloseModal1() {
    this.openModal1 = false;
  }
  handleAwsModal() {
    console.log("inside credentals");
    this.awsModal = true;
  }


  ScheduleBackup(event) {
    let buttonName = event.target.name;
    this.isscheduleSpinner = true;
    const currDate = new Date();

    if(event.target.name=='ScheduleLocal'){
      this.isbackupToLocal =true;
      this.isbackupToS3 =false;
  }
  if(event.target.name=='ScheduleAws'){
      this.isbackupToLocal =false;
      this.isbackupToS3 =true;
  }
  if(this.isbackupToS3 ||(this.awsAccessKey===null && this.awsSecretKey===null && this.awsRegion===null && this.awsBucket)){
      this.showToast('Required','To Backup Data to S3 Kindly select Credentials','error');
      this.isscheduleSpinner =false;
      return;
   }

    let scheduleDates = this.template.querySelectorAll('lightning-input');
    scheduleDates.forEach(function(date){
      if (date.name === 'ScheduleDateLocal') {
        if (date.value) {
          this.ScheduleDateLocal=date.value;
        }
          
      }
      if (date.name === 'ScheduleDateAws') {
        if (date.value) {
          this.ScheduleDateAws=date.value;
        }
      }
  },this);
    let awsDate=null;
    let localDate=null;
    
    if (this.ScheduleDateAws!=null) {
     awsDate =  new Date(this.ScheduleDateAws);
    }
    if (this.ScheduleDateLocal!=null) {
     localDate = new Date(this.ScheduleDateLocal);
    }
    console.log('dates');
    console.log(currDate);
    console.log(this.ScheduleDateLocal);
    console.log(this.ScheduleDateAws);
    
    if (this.isbackupToLocal && this.ScheduleDateLocal === null) {
      this.showToast('Required', 'Please Select Date to schedule the Backup Process', 'error');
      this.isscheduleSpinner = false;
      return;
    }
    else if (this.isbackupToLocal && localDate < currDate) {
      this.showToast('Validation', 'You can\'t select previous Date than today to schedule the Backup Process', 'error');
     this.isscheduleSpinner = false;
      return;
    }
    else if (this.isbackupToS3 && this.ScheduleDateAws === null) {
      this.showToast('Required', 'Please Select Date to schedule the Backup Process', 'error');
      this.isscheduleSpinner = false;
      return;
    }
    else if (this.isbackupToS3 &&  awsDate < currDate) {
      this.showToast('Validation', 'You can\'t select previous Date than today to schedule the Backup Process', 'error');
      this.isscheduleSpinner = false;
      return;
    }
    else {
      let scheduleDate = null;
      if (this.isbackupToLocal) {
          scheduleDate = this.ScheduleDateLocal;
        }
        if (this.isbackupToS3) {
          scheduleDate = this.ScheduleDateAws;
        }
      console.log('schedule date');
      console.log(scheduleDate);
    var credential = { "accessKey": this.awsAccessKey, "SecretKey": this.awsSecretKey, "Bucket": this.awsBucket, "awsRegion": this.awsRegion, "backupTos3": this.isbackupToS3, "backupToLocal": this.isbackupToLocal };
    ScheduleMetaDataBackup({metadataTypes:this.selectedMetadataTypes,credentials:JSON.stringify(credential),scheduleDate:scheduleDate})
    .then(data=>{
      this.isscheduleSpinner =false;
      console.log('data');
      console.log(data);
      if (buttonName === 'ScheduleLocal') {
        console.log('yes');
        this.exportScheduleScreen = true;
      }
      else if (buttonName === 'ScheduleAws') {
        this.AwsScheduleScreen = true;
       }
      console.log('spins');
      console.log(this.exportScheduleScreen);
      console.log(this.isscheduleSpinner);
      this.showScreen2 = false;
      this.showScreen1 = false;
      this.openModal = false;
      this.openModal1 = false;
    })
    .catch(error=>{
      this.openModal = false;
      this.openModal1 = false;
      this.isscheduleSpinner =false;
      console.log('error in schedule');
       this.showToast('Error', 'some error occuring Please check or contact support', 'error');
      console.log(error);
    })

    
    this.step = 3;
    this.handleStepUp();
  }
    
    
     
  }

  
  awsScreen(){
    this.isModal =true;
    this.awsModal = true;
    this.template.querySelector('c-lightning-Modal').handleIsOpenModal();
  }

  handleAWSCredentials(event) {
    console.log('handle aws creds');
    console.log(event);
    console.log(event.detail.value);
    console.log(JSON.stringify(event.detail));
    console.log('yes');
    const parsedData = JSON.parse(JSON.stringify(event.detail));
    this.awsAccessKey = parsedData.accessKey;
    this.awsSecretKey = parsedData.secretKey;
    this.awsRegion = parsedData.regionName;
    this.awsBucket = parsedData.bucketName;
    console.log(this.awsBucket);
    console.log( this.accessKey);
    console.log(parsedData.accessKey);
  }
  handleScheduleDate(event) {
    this.schDate = event.target.value;
    this.validateSchDate();
  }

  validateSchDate() {
    const currentDate = new Date();
    const enterDate = new Date(this.schDate);
    if (enterDate < currentDate) {
       this.showToast("Warning", "Scheduled Date cannot be greater than today's date", "error");
    }
  }
}