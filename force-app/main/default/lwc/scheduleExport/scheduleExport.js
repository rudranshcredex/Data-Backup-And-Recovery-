import { LightningElement, track } from 'lwc';
import LightningModal from 'lightning/modal';

export default class ScheduleExportService extends LightningElement {
  @track exportFrequency = 1;
  @track exportTime = '';
  @track exportDate = '';

  handleFrequencyChange(event) {
    this.exportFrequency = parseInt(event.target.value, 10);
  }

  handleTimeChange(event) {
    this.exportTime = event.target.value;
  }

  handleOkay() {
    this.close('okay');
  }

  scheduleExport() {
    /*scheduleExport({ frequency: this.exportFrequency, time: this.exportTime })
      .then(() => {
        // Success message or further actions
        console.log('Export service scheduled successfully');
      })
      .catch((error) => {
        // Error handling
        console.error('Error scheduling export service', error);
      });*/
      console.log('this.exportFrequency'+this.exportFrequency);
      console.log('this.exportTime'+this.exportTime);
      console.log('Date'+this.exportDate);
  }
}