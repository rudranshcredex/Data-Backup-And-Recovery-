import { LightningElement } from 'lwc';
import local from '@salesforce/resourceUrl/LocalBackup';
import cloud from '@salesforce/resourceUrl/cloud';

    
export default class CloudComponent extends LightningElement {
    local = local;
    cloud = cloud;
    
}