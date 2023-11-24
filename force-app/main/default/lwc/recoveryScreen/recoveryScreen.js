import { LightningElement, api } from "lwc";
import dataImage from "@salesforce/resourceUrl/dataImageForBackup";
import recoveryImage from "@salesforce/resourceUrl/recoveryImage";

export default class RecoveryScreen extends LightningElement {
  dataImage = dataImage;
  recoveryImage = recoveryImage;
  dataRecoveryScreen = false;
  isrecovery = true;
  metadataRecoveryScreen = false;

  @api
  handleReturnRecovery() {
    console.log("inside return backup");
    this.isrecovery = true;
    this.dataRecoveryScreen = false;
    this.metadataRecoveryScreen = false;
  }
  
  handleDataRecoveryScreen() {
    this.dataRecoveryScreen = true;
    this.isrecovery = false;
    this.metadataRecoveryScreen = false;
  }
  handleMetadataRecoveryScreen() {
    this.metadataRecoveryScreen = true;
    this.dataRecoveryScreen = false;
    this.isrecovery = false;

  }
  
}