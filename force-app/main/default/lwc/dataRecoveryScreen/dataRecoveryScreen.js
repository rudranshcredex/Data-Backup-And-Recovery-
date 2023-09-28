/* eslint-disable @lwc/lwc/no-unknown-wire-adapters */
/* eslint-disable no-undef */
import { LightningElement, track, wire } from "lwc";
import local from "@salesforce/resourceUrl/LocalBackup";
import cloud from "@salesforce/resourceUrl/cloud";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import uploadZipFile from '@salesforce/apex/DataRecovery.uploadZipFile';
import performInsert from '@salesforce/apex/DataRecovery.performInsert';
import performUpsert from '@salesforce/apex/DataRecovery.performUpsert';
import { ShowToastEvent } from "lightning/platformShowToastEvent";



export default class DataRecoveryScreen extends LightningElement {


  currentPageTable1 = 1;
  currentPageTable2 = 1;
  recordsPerPage = 5;

  recoveryAwsText = "Your data recovery from AWS is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";
  lowertext = "You will receive an email notification once the recovery is completed, along with a custom notification .";
  recoveryLocaltext = "Your data recovery is now in the queue and will be processed shortly. We're working diligently to ensure that your requested data is recovered accurately and securely.";
  userEmail;
  selecetdStringData = [];
  selectedObjectDataString = [];
  selectedId;

  currentStep = "1";
  step = 1;

  columns1 = [{ label: 'Names', fieldName: 'objectName', type: "text" }];

  dummyData = [
    { objectName: 'Account', csvData: 'CSV Data 1', externalId: ['id 1', 'id 2', 'id 3', 'id 4'] },
    { objectName: 'Opportunity', csvData: 'CSV Data 2', externalId: ['id 1', 'id 2', 'id 3', 'id 4'] },
    { objectName: 'Contact', csvData: 'CSV Data 3', externalId: ['id 1', 'id 2', 'id 3', 'id 4'] },
    { objectName: 'Case', csvData: 'CSV Data 4', externalId: ['id 1', 'id 2', 'id 3', 'id 4'] }
  ];

  selectedRecords = [];
  objectsWithExternalId = [];
  objectsWithoutExternalId = [];
  RecoveryLocalScreen = false;
  RecoveryAwsScreen = false;

  local = local;
  cloud = cloud;
  date = Date();
  file = null;
  objectScreen = false;
  showScreen1 = true;
  showScreen2 = false;
  isModal = false;
  awsModal = false;
  isRecovery = true;
  retrievalLoading = false;

  tableWithId = true;
  tableWithoutId = true;


  selectedId;
  selectedDataMap = {};

  @track fileName = '';

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD, EMAIL_FIELD]
  })
  wireUser({ error, data }) {
    if (data) {
      this.username = data.fields.Name.value;
      this.userEmail = data.fields.Email.value;
    } else if (error) {
      console.log('error', error);
    }
  }

  // handlePicklistChange(event) {
  //   const selectedId = event.target.value;
  //   const objectIndex = event.target.getAttribute('data-index');
  //   //  const selectedObject = this.objectsWithExternalId[objectIndex];
  //   const selectedObject = this.dummyData[objectIndex];


  //   if (!this.selectedDataMap[selectedObject.objectName]) {
  //     this.selectedDataMap[selectedObject.objectName] = [];
  //   }
  //   const isDuplicate = this.selectedDataMap[selectedObject.objectName].findIndex(item => {
  //     return item.objectName === selectedObject.objectName;
  //   });

  //   if (isDuplicate !== -1) {
  //     this.selectedDataMap[selectedObject.objectName][isDuplicate] = {
  //       externalId: selectedId,
  //       objectName: selectedObject.objectName,
  //       // csvData: selectedObject.CsvData
  //       csvData: selectedObject.csvData
  //     };
  //   } else {
  //     this.selectedDataMap[selectedObject.objectName].push({
  //       externalId: selectedId,
  //       objectName: selectedObject.objectName,
  //       csvData: selectedObject.csvData
  //       // csvData: selectedObject.CsvData
  //     });
  //   }
  //   console.log('selected Obejcts>>>>>', JSON.stringify(this.selectedDataMap));


  //   const selectedString = JSON.stringify(this.selectedDataMap[selectedObject.objectName]);


  //   console.log('selectedString', selectedString);

  //   this.selecetdStringData.push(selectedString);
  //   console.log('this.selecetdStringData', JSON.stringify(this.selecetdStringData));

  //   console.log('selectedObjectDataString', JSON.stringify(selectedObjectDataString));

  //   //console.log('selected objects>>>>>', JSON.parse(JSON.stringify(this.selectedDataMap)));
  // }

  handlePicklistChange(event) {
    //const selectedId = event.target.value;
    this.selectedId = event.target.value;
    const objectIndex = event.target.getAttribute('data-index');
    //const selectedObject = this.dummyData[objectIndex];
    const selectedObject = this.objectsWithExternalId[objectIndex];

    if (!this.selectedDataMap[selectedObject.objectName]) {
      this.selectedDataMap[selectedObject.objectName] = [];
    }

    const isDuplicateIndex = this.selectedDataMap[selectedObject.objectName].findIndex(item => {
      return item.objectName === selectedObject.objectName;
    });

    const newObject = {
      externalId: selectedId,
      objectName: selectedObject.objectName,
      csvData: selectedObject.CsvData
    };

    if (isDuplicateIndex !== -1) {
      this.selectedDataMap[selectedObject.objectName][isDuplicateIndex] = newObject;
    } else {
      this.selectedDataMap[selectedObject.objectName].push(newObject);
    }

    this.selectedObjectDataString = Object.values(this.selectedDataMap).flat();

    console.log('this.selectedObjectDataString', JSON.stringify(this.selectedObjectDataString));
  }

  handleUpload(event) {
    console.log(event);
    console.log(event.detail.files[0]);
    console.log(this.file);

    let selectedFile = event.target.files[0];
    // this.file = event.detail.files[0];
    this.fileName = selectedFile.name;
    const expectedName = 'Salesforce Data';
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
    console.log('handle recovery');
    if (this.file == null) {
      this.showToast('Error', 'Please attach required file to Recover Data', 'error');
      return;
    }
    this.retrievalLoading = true;

    /*testMethods({FileData:'this.file'})
    .then(data=>{
        console.log(data);
    })
    .catch(error=>{
        console.log(error);
    })*/
    const fileReader = new FileReader();
    fileReader.onload = () => {
      const file = fileReader.result.split(',')[1];
      console.log('files');
      console.log(file);

      uploadZipFile({ FileData: file })
        .then(data => {
          this.retrievalLoading = false;
          this.objectScreen = true;
          this.showScreen1 = false;
          this.step = 2;
          this.handleStepUp();
          console.log('data');
          console.log(data);
          console.log(JSON.stringify(data));
          for (var key in data) {

            let objwithoutExternalId = {};
            let objwithExternalId = {};

            console.log(this.objectsWithoutExternalId.length);
            console.log(data[key].objectName);
            if (data[key].ExternalIdField.length > 0) {
              console.log('yes');
              var externalId = data[key].ExternalIdField;

              if (externalId[0] == '') {
                objwithoutExternalId.objectName = data[key].objectName;
                objwithoutExternalId.CsvData = data[key].csvData;
                this.objectsWithoutExternalId.push(objwithoutExternalId);
                console.log('blank');
              }
              else {
                console.log('not blank');
                objwithExternalId.objectName = data[key].objectName;
                objwithExternalId.CsvData = data[key].csvData;
                objwithExternalId.ExternalIds = data[key].ExternalIdField;
                this.objectsWithExternalId.push(objwithExternalId);
              }
            }
            if (this.objectsWithoutExternalId.length === 0) {
              this.tableWithoutId = false;
              console.log('this.objectsWithoutExternalId', this.objectsWithoutExternalId, this.objectsWithoutExternalId.length);

            }
            if (this.objectsWithExternalId.length === 0) {
              console.log('this.objectsWithExternalId', this.objectsWithExternalId, this.objectsWithExternalId.length);
              this.tableWithId = false;
            }
            if (this.objectsWithExternalId.length > 0) {
              console.log('greater than zero');
              this.tableWithId = true;
              console.log(this.tableWithId);
            }
            console.log('after call');


            /* console.log('objwithoutExternalId      ');
             console.log(objwithoutExternalId);
             console.log(objwithoutExternalId.length);
 
             this.objectsWithoutExternalId.push(objwithoutExternalId);
             console.log('without ');
             console.log(this.objectsWithoutExternalId);
             console.log(this.objectsWithoutExternalId.length);
             console.log(objectsWithoutExternalId);*/

            //console.log(JSON.stringify(this.objectsWithExternalId));
            // if (this.objectsWithExternalId.length == 0 ) {
            //   console.log('objectsWithExternalId', this.objectsWithExternalId.length, JSON.stringify(this.objectsWithExternalId) );
            //     this.tableWithId = false;
            // }
            // console.log('without ids');
            // console.log('length', this.objectsWithoutExternalId.length);
            // console.log(JSON.stringify(this.objectsWithoutExternalId));
            // if (this.objectsWithoutExternalId.length == 0 ) {
            //   console.log('objectsWithoutExternalId', this.objectsWithoutExternalId.length, JSON.stringify(this.objectsWithoutExternalId));
            //     this.tableWithoutId = false;
            // }
            console.log(data[key].ExternalIdField);
            console.log(key);
          }
        })
        .catch(error => {
          console.log('inside error');
          console.log('error', error);
        })

    };
    fileReader.readAsDataURL(this.file);
  }

  handleInsert() {
    this.showScreen2 = true;
    this.objectScreen = false;
    this.step = 3;
    this.handleStepUp();

    /*if (buttonId === 'btn-1') {
        this.RecoveryLocalScreen = true;
      }
    else if (buttonId === 'btn-2') {
      this.RecoveryAwsScreen = true;
      }*/

    console.log('inside insert');
    performInsert({ objectsToInsert: JSON.stringify(this.objectsWithoutExternalId) })
      .then(data => {
        console.log('data');
        console.log(data);
      })
      .catch(error => {
        console.log(error);
      })

    this.RecoveryLocalScreen = true;
  }
  awsScreen() {
    this.isModal = true;
    this.awsModal = true;
    this.template.querySelector('c-lightning-Modal').handleIsOpenModal();
  }

  handleAWSCredentials(event) {
    console.log('handle aws creds');
    console.log(event);
    console.log(event.detail.value);
    console.log(JSON.stringify(event.detail));
  }

  handleUpsert() {
    console.log('upsert');

    if (!this.selectedId) {
      this.showToast('Error', 'Please Select External Ids', 'error')
      return;

    }
    else {
      performUpsert({ objectsToUpsert: JSON.stringify(this.selectedObjectDataString) })
        .then(data => {
          console.log('data');
          console.log(data);
          this.showToast('Data Upserted', 'Move to the next Step', 'success');

        })
        .catch(error => {
          console.log(error);
        })
    }
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





  handleNextPageTable1() {
    if (this.currentPageTable1 < this.totalPagesTable1) {
      this.currentPageTable1++;
    }
  }

  handlePreviousPageTable1() {
    if (this.currentPageTable1 > 1) {
      this.currentPageTable1--;
    }
  }

  handleNextPageTable2() {
    if (this.currentPageTable2 < this.totalPagesTable2) {
      this.currentPageTable2++;
    }
  }

  handlePreviousPageTable2() {
    if (this.currentPageTable2 > 1) {
      this.currentPageTable2--;
    }
  }

  get totalPagesTable1() {
    return Math.ceil(this.objectsWithoutExternalId.length / this.recordsPerPage);
  }

  get totalPagesTable2() {
    return Math.ceil(this.objectsWithExternalId.length / this.recordsPerPage);
  }

  get displayedDataTable1() {
    const startIndex = (this.currentPageTable1 - 1) * this.recordsPerPage;
    const endIndex = startIndex + this.recordsPerPage;
    return this.objectsWithoutExternalId.slice(startIndex, endIndex);
  }

  get displayedDataTable2() {
    const startIndex = (this.currentPageTable2 - 1) * this.recordsPerPage;
    const endIndex = startIndex + this.recordsPerPage;
    return this.objectsWithExternalId.slice(startIndex, endIndex);
  }

}