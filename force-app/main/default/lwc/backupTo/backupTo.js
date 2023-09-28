import { LightningElement } from 'lwc';

export default class BackupTo extends LightningElement {
    local=false;
    aws=false;
    handleSelect(event){
        console.log(event.target.value);
        this.serviceToBackup=event.target.value;
        if(event.target.value='Local Storage'){
            this.local=true;
        }
        if(event.target.value='AWS s3'){
            this.aws=true;
        }
    }
}