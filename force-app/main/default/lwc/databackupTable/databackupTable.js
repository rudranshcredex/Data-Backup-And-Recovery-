import { LightningElement,track } from 'lwc';
import getObjectsApiNames from '@salesforce/apex/dataBackup2.getObjectsApiNames';
import getRecords from '@salesforce/apex/dataBackup2.getRecords';

export default class DatabackupTable extends LightningElement {

    dataSection=false;
    objectApiName;
    columnHeader = ['ID', 'Name'];
    recordsData;
    fromDate;
    toDate;
    @track objectNames=[];

    columns=[{label:'Names',fieldName:'objectName',type:"text"}];

    getObjectNames(){
        this.dataSection=true;
       
        getObjectsApiNames()
        .then(data=>{
           // this.sfobjects=data;
            this.objectNames=[];
            var i;
            for(i=0;i<data.length;i++){
                var item={
                    id:i,
                    objectName:data[i]
                };
                this.objectNames.push(item);
            }
        })
        .catch(error=>{
            console.log(error);
        })
    }
}