import { LightningElement,track,wire } from 'lwc';
import getObjectsApiNames from '@salesforce/apex/dataBackup2.getObjectsApiNames';
export default class Sfobjects extends LightningElement {

    @track objectNames=[];
    columns=[{label:'Names',fieldName:'objectName',type:"text"}];


    @wire(getObjectsApiNames)
    result({data,error}){
        if(data){
            //this.objectNames=data;
            
            for(var i=0;i<data.length;i++){
                var item={
                    id:i,
                    objectName:data[i]
                };
                this.objectNames.push(item);
            }
            console.log(this.objectNames);
        }
        if(error){
            console.log('error');
        }
    }

    
    getObjectNames(){
        getObjectsApiNames()
        .then(data=>{          
            console.log(data); 
            this.objectNames=[];
            for(var i=0;i<data.length;i++){
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