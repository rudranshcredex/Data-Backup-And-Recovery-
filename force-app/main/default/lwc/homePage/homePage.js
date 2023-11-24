/* eslint-disable no-dupe-class-members */
import { LightningElement, wire } from "lwc";
import logo from "@salesforce/resourceUrl/logo";
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id";
import NAME_FIELD from "@salesforce/schema/User.Name";
import arrowRotateSolid from "@salesforce/resourceUrl/arrowRotateSolid";
import salesforce from "@salesforce/resourceUrl/salesforceIcon";
import computer from "@salesforce/resourceUrl/computer";
import dataIconForHome from "@salesforce/resourceUrl/dataIconForHome";
import recoveryIconForHome from "@salesforce/resourceUrl/recoveryIconForHome";

export default class HomePage extends LightningElement {
  logo = logo;
  recoveryIcon = arrowRotateSolid;
  salesforce = salesforce;
  computer = computer;
  dataIcon = dataIconForHome;
  recoveryIcon = recoveryIconForHome;

  username;
  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD]
  })
  wireUser({ error, data }) {
    if (data) {
      this.username = data.fields.Name.value;
    } else if (error) {
      console.error(error);
    }
  }
}