import { LightningElement, wire } from "lwc";
import local from "@salesforce/resourceUrl/LocalBackup";
import cloud from "@salesforce/resourceUrl/cloud";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import deployMetadata from '@salesforce/apex/MetadataRecovery.deployMetadata';
export default class MetadataRecoveryScreen extends LightningElement {
  
  
  recoveryAwsText = "Your metadata recovery from AWS is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";
  lowertext = "You will receive an email notification once the recovery is completed, along with a custom notification .";
  recoveryLocaltext = "Your metadata recovery is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";

  userEmail;
  local = local;
  cloud = cloud;
  date = Date();
  file;
  objectScreen = false;
  showScreen1 = true;
  showScreen2 = false;
  isModal = false;
  awsModal = false;
  isRecovery = true;
  retrievalLoading = false;
  RecoveryLocalScreen = false;
  RecoveryAwsScreen = false;
  isModal = false;
  awsModal = false;
  awsAccessKey = null;
  awsSecretKey = null;
  awsRegion = null;
  awsBucket = null;
  fileData = null;

  currentStep = "1";
  step = 1;

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD, EMAIL_FIELD]
  })
  wireUser({ error, data }) {
    if (data) {
      this.username = data.fields.Name.value;
      this.userEmail = data.fields.Email.value;
    } else if (error) {
      console.error(error);
    }
  }

  awsScreen() {
    this.isModal = true;
    this.awsModal = true;
    //this.template.querySelector('c-lightning-Modal').handleIsOpenModal();
    let recoveryScreenElement = this.template.querySelector('c-lightning-modal');
    if (recoveryScreenElement) {
      recoveryScreenElement.handleIsOpenModal();
    } else {
      console.error("c-lightning-modal element not found");
    }
  }

  handleUpload(event) {
    console.log(event);
    console.log(event.detail.files[0]);

    let selectedFile = event.target.files[0];
    this.fileName = selectedFile.name;
    const expectedName = 'salesforcemetadata';
    if (!this.fileName.includes(expectedName)) {
      console.log('not uploaded')
      this.showToast('Error', 'Please Upload Files which includes name ' + expectedName, 'error');
      return;
    }
    else {
      console.log("inside file change function");
      this.file = event.detail.files[0];
      this.showToast('Success', 'File Uploaded Successfully ' + this.fileName, 'success');
    }
  }
  handleRecovery() {
    if (this.file == null) {
      this.showToast('Error', 'Please attach required file to Recover Data', 'error');
      return;
    }
    this.retrievalLoading = true;
    const fileReader = new FileReader();
    fileReader.onload = () => {
      const file = fileReader.result.split(',')[1];
      console.log('files');
      console.log(file);
      deployMetadata({ zipContent: file })
        .then(data => {
          this.showScreen1=false;
          this.RecoveryLocalScreen=true;
      this.handleStepUp();
          this.retrievalLoading = false;
          console.log('data');
          console.log(data);
          
        })
        .catch(error => {
          this.retrievalLoading = false;
          console.log('error');
          console.log(error);
        })
    };
    fileReader.readAsDataURL(this.file);
    this.step=2;
    this.handleStepUp();
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

  handleAWSCredentials(event) {
    console.log('handle aws creds');
    console.log(event);
    console.log(event.detail.value);
    console.log(JSON.stringify(event.detail));
    const parsedData = JSON.parse(JSON.stringify(event.detail));
    this.awsAccessKey = parsedData.accessKey;
    this.awsSecretKey = parsedData.secretKey;
    this.awsRegion = parsedData.regionName;
    this.awsBucket = parsedData.bucketName;
    this.fileData = parsedData.fileData;
  }

  recoverAwsFiles() {
    console.log('inside recover file');
    console.log('test');
    console.log(this.awsAccessKey);
    //this.retrievalLoading = true;


    
    if (this.awsAccessKey == null && this.awsSecretKey == null && this.awsRegion == null && this.awsBucket == null && this.fileData == null) {
      console.log('yes null');
      this.showToast('Required', 'Please select atleast 1 file to recover', 'error');
      return;
    }
    console.log('after if');
    const expectedName = 'salesforcemetadata';
    deployMetadata({ zipContent: this.fileData })
      .then(data => {
        console.log('data inside');
      
        console.log('data');
        console.log(data);
      })
      .catch(error => {
       
        console.log('error');
        console.log(error);
      })

      this.showScreen1=false;
      this.RecoveryAwsScreen=true;
      this.RecoveryLocalScreen=false;
      this.step=2;
      this.handleStepUp();
  }

  handleStepUp() {
    this.showScreen1 = this.step == 1;
    this.currentStep = "" + this.step;
  }
}