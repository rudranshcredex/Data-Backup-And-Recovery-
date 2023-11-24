import { LightningElement, api } from 'lwc';
import GoogleCloudIcon from '@salesforce/resourceUrl/GoogleCloudIcon'

export default class GCPCloudComponent extends LightningElement {
    GoogleCloudIcon = GoogleCloudIcon;
    @api
    isGCPopen = false;
    //temp variables
    abc=true;
    xyz=false;
   
    @api
    handleGCPopen(){
        this.isGCPopen=true;
    }
}