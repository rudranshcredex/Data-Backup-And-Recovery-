/* eslint-disable @lwc/lwc/no-api-reassignments */
import { LightningElement, api, track } from "lwc";
import dataImage from "@salesforce/resourceUrl/dataImageForBackup";
import recoveryImage from "@salesforce/resourceUrl/recoveryImage";

export default class BackupScreen extends LightningElement {
  dataImage = dataImage;
  recoveryImage = recoveryImage;
  isBackup = true;
  dataBackupScreen = false;
  metadataBackupScreen = false;

  //  renderedCallback() {
  //   if (this.sendValueToBackup) {
  //     console.log('sendValueToBackup', this.sendValueToBackup);
  //     this.isBackup = true;
  //     this.dataBackupScreen = false;
  //   }
  // }
  @api
  handleReturnBackup() {
    console.log("inside return backup");
    this.isBackup = true;
    this.dataBackupScreen = false;
    this.metadataBackupScreen = false;
    
  }
  
  handleDataBackupScreen() {
    console.log("isBackup: ", this.isBackup);
    this.dataBackupScreen = true;
    this.metadataBackupScreen =false;
    this.isBackup = false;
  }
  handleMetaDataBackupScreen(){
    this.metadataBackupScreen =true;
    this.dataBackupScreen = false;
    this.isBackup = false;
  }
}