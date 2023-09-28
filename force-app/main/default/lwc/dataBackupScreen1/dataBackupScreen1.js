/* eslint-disable array-callback-return */
/* eslint-disable no-await-in-loop */
/* eslint-disable no-unused-vars */
import { LightningElement, wire, track } from "lwc";
import getObjects from "@salesforce/apex/ObjectHelper.getObjects";
//import local from "@salesforce/resourceUrl/backup";
//import cloud from "@salesforce/resourceUrl/cloud";

export default class DataBackupScreen1 extends LightningElement {
  @track objectList;
  @track objectNames = [];
  @track searchKeyword = "";
  //@track selectedObjectNameRows = ["1", "2"];
  selectedObjects = [];
  selectedObjectsNames = [];
  showScreen2 = false;
  showScreen1 = true;
  showLocalScreen = true;
  showScheduleExport = false;
  showCloudScreen = false;
  currentStep = 1;
  selectedIds = new Set();
  selectedRowIds = new Set();
  originalObjectList = [];
  step = 1;

  columns = [
    { label: "Name", fieldName: "objectName" },
    { label: "Object Data", fieldName: "objectData" },
    { label: "Download", fieldName: "download" }
  ];
  columns1 = [{ label: "Name", fieldName: "objectName"}];
  localImage = local;
  cloudImage = cloud;

  @wire(getObjects)
  wiredObjectList({ error, data }) {
    if (data) {
      this.objectNames = data;
      this.originalObjectList = [...data];

      this.initializeObjectNames();
      this.filterObjectNames();
    } else if (error) {
      console.log("Error retrieving object list:", error);
    }
  }
  async filterObjectNames() {
    this.objectNames = this.objectList
      .map((objectName, index) => ({ id: index, objectName }))
      .filter((item) =>
        item.objectName.toLowerCase().includes(this.searchKeyword.toLowerCase())
      );
    console.log("inside filter objectss>>>>>>>.");

    this.objectNames.forEach((item) => {
      if (this.selectedIds.has(item.id)) {
        item.selected = true;
      } else {
        item.selected = false;
      }
    });
  }

  async handleRowSelection(event) {
    // const selectedRows = this.template
    //   .querySelector("lightning-datatable")
    //   .getSelectedRows();
    // const checkboxStatus = event.target.checked;

    // this.selectedObjects = selectedRows.map((row) => row.objectName);

    // this.selectedObjects.forEach((data, i) => {
    //   let dataToInsert = data;
    //   console.log("Data to insert", dataToInsert);
    //   this.selectedObjectsNames.push(dataToInsert.toString());
    // });

    // console.log("this.selectedObjectsNames--->", this.selectedObjectsNames);
    // console.log(
    //   "Set this.selectedObjectsNames--->",
    //   new Set(this.selectedObjectsNames)
    // );
    const checkboxStatus = event.target.checked;
    console.log("checkboxStatus: ", checkboxStatus);
    console.log("event: ", event);

    const selectedRows = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    console.log("selectedRows: ", selectedRows);
    for (const row of selectedRows) {
      const recordId = row.objectId;
      console.log("record id>>>", recordId);
      this.selectedIds.add(recordId);
    }
    console.log("selectedIds>>>>", this.selectedIds);
    for (const row of selectedRows) {
      if (!checkboxStatus) {
        this.selectedIds.delete(row.id);
      }
    }

    //console.log("selected obejcts id>>>>>", this.selectedObjects);
    // console.log(
    //   "this.selectedObjectsNames--->",
    //   JSON.stringify(new Set(this.selectedObjectsNames))
    // );
    // console.log("Array of set ");
  }

  initializeObjectNames() {
    this.objectNames = this.objectList.map((objectName, index) => ({
      id: index,
      objectName
    }));
  }

  handleSearchChange(event) {
    this.searchKeyword = event.target.value;
    if (this.searchKeyword === "") {
      this.initializeObjectNames();
    } else {
      this.filterObjectNames();
    }

    if (event.detail.selectedRows) {
      let updatedItemsSet = new Set();
      event.detail.selectedRows.map((ele) => {
        updatedItemsSet.add(ele.Id);
      });

      // Add any new items to the selectedRows list
      updatedItemsSet.forEach((id) => {
        if (!this.selectedIds.has(id)) {
          this.selectedIds.add(id);
        }
      });
    }
  }

  nextButton() {
    this.showScreen2 = true;
    this.showScreen1 = false;
  }

  localScreenButton() {
    this.showLocalScreen = true;
  }

  previousButton() {
    this.showScreen2 = false;
    this.showScreen1 = true;
    this.showLocalScreen = true;
  }
}