import { LightningElement, api } from "lwc";
import LOGO_URL from "@salesforce/resourceUrl/logo";
export default class HomeScreen extends LightningElement {
  @api
  logoUrl = LOGO_URL;

  DataBackup = false;
  DataRecovery = false;
  MetaDataBackup = false;
  MetaDataRecovery = false;

  handleMouseOver(event) {
    event.target.style.backgroundColor = "black";
    //this.DataBackup = true;
  }
  handleMouseOut(event) {
    // Remove the hover effect when the mouse leaves the element
    event.target.style.backgroundColor = "";
  }

  handleDataBackup() {
    console.log('daata',this.DataBackup);
    this.DataBackup = true;
    this.DataRecovery = false;
    this.MetaDataBackup = false;
    this.MetaDataRecovery = false;
    console.log(this.DataBackup);
  }
  handleDataRecovery() {
    console.log('recovery');
    this.DataRecovery = true;
    this.DataBackup = false;
    this.MetaDataBackup = false;
    this.MetaDataRecovery = false;

  }

  handleMetaDataBackup() {
    console.log('Metadaata');
    this.MetaDataBackup = true;
    this.MetaDataRecovery = false;
    this.DataBackup = false;
    this.DataRecovery = false;
  }
  handleMetaDataRecovery() {
    console.log('MetaRecovery');
    this.MetaDataRecovery = true;
    this.MetaDataBackup = false;
    this.DataBackup = false;
    this.DataRecovery = false;
  }
}