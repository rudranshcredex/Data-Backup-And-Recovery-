import { LightningElement, wire } from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import Email_FIELD from "@salesforce/schema/User.Email";

export default class ActivityLogs extends LightningElement {

    username;

    @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD,Email_FIELD]
  })
  wireUser({ error, data }) {
    if (data) {
      this.username = data.fields.Name.value;
    } else if (error) {
      console.error(error);
    }
  }
}