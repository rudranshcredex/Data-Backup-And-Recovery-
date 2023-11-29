import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBuckets from '@salesforce/apex/AwsS3Integration.getBuckets';
import getFiles from '@salesforce/apex/AwsS3Integration.getFiles';
import getFile from '@salesforce/apex/AwsS3Integration.getFile';
import saveCred from '@salesforce/apex/AwsCredentials.saveCred';
import getCredentails from '@salesforce/apex/AwsCredentials.getCredentails';
import getCredentailsOnName from '@salesforce/apex/AwsCredentials.getCredentailsOnName';
import awsS3Logo from '@salesforce/resourceUrl/awsS3Logo';


export default class LightningModal extends LightningElement {
    @api ismodalopen = false;
    @api isbackup = false;
    @api ismetadatabackup = false;
    @api isrecovery = false;
    @track awsCredentials = [];
    @track credentialAlias = [];
    accessKey = null;
    secretKey = null;
    region = null;
    Buckets = null;
    files = null;
    fileData = null;
    selectedFile = null;
    BucketSelected = null;
    isBucketsLoading = false;
    isFilesLoading = false;
    haveCreds = false;
    isOpenCredsModal = false;
    selectedCredentials;
    credsName = null;
    credAlias;
    addcreds = false;
    isLoading = true;
    forBucketsButton = true;
    awsS3Logo=awsS3Logo;
    showCredsSpinner = true;



    @api
    handleIsOpenModal() {
        this.ismodalopen = true;
    }

    async connectedCallback() {
        console.log('recovery');
        console.log(this.isrecovery);
        console.log(this.ismodalopen);
        await getCredentails()
            .then(data => {
                console.log(data);
                this.awsCredentials = data;
                this.showCredsSpinner = false;

                if (this.awsCredentials.length ==0) {
                   this.showToast('No Credentials','No Credentials found Please Enter Credentials','error');
                }

                if (this.awsCredentials.length > 0) {
                    this.haveCreds = true; 
                }
                console.log(this.awsCredentials);
                console.log(data.length);
                console.log('cred length', this.awsCredentials.length);
            })
            .catch(error => {
                console.log('error');
                console.log(error);
                console.log(JSON.stringify(error));
            })
        for (const element of this.awsCredentials) {
            this.credentialAlias.push(element.DeveloperName);
        }
        console.log('alias');
        console.log(this.credentialAlias);

    }


    async closeModal() {
        if (this.accessKey === null && this.secretKey === null && this.region === null) {
            this.ismodalopen = false;
            return;
        }

        if (this.isbackup || this.ismetadatabackup) {
            if (this.BucketSelected === null && this.accessKey === null && this.secretKey === null && this.region === null) {
                this.showToast('Required', ' Please Select Atleast 1 Bucket to Backup', 'error');
            }
            else {
                this.showToast('Success', 'credentials saved successfully go for Backup', 'success');
            }
        }

        if (this.isrecovery) {
            if (this.BucketSelected === null && this.accessKey === null && this.secretKey === null && this.region === null && this.selectedFile === null) {
                this.showToast('Kindly Review', 'Select creds/Files for recovery', 'error');
            }
            else {
                this.showToast('Success', 'credentials saved successfully go for recovery', 'success');
            }
        }

        console.log('close modal');

        console.log(this.BucketSelected);
        if (this.BucketSelected === null) {
            this.dispatchEvent(new CustomEvent('awscredentials', {
                bubbles: true,
                composed: true,
                detail: null
            }));
        }
        else if (this.BucketSelected != null && this.isbackup) {
            this.dispatchEvent(new CustomEvent('awscredentials', {
                bubbles: true,
                composed: true,
                detail: {
                    accessKey: this.accessKey,
                    secretKey: this.secretKey,
                    regionName: this.region,
                    bucketName: this.BucketSelected
                }
            }));
        }
        else if (this.BucketSelected != null && this.ismetadatabackup) {
            this.dispatchEvent(new CustomEvent('awscredentials', {
                bubbles: true,
                composed: true,
                detail: {
                    accessKey: this.accessKey,
                    secretKey: this.secretKey,
                    regionName: this.region,
                    bucketName: this.BucketSelected
                }
            }));

        }

        else if (this.isrecovery && this.selectedFile != null) {
            await getFile({ accessKey: this.accessKey, secretKey: this.secretKey, awsRegion: this.region, bucket: this.BucketSelected, FileKey: this.selectedFile })
                .then(data => {
                    console.log(data);
                    this.fileData = data;
                })
                .catch(error => {
                    console.log(error);
                })
            this.dispatchEvent(new CustomEvent('awscredentials', {
                bubbles: true,
                composed: true,
                detail: {
                    accessKey: this.accessKey,
                    secretKey: this.secretKey,
                    regionName: this.region,
                    bucketName: this.BucketSelected,
                    fileData: this.fileData
                }
            }));
        }
        else if (this.isrecovery && this.selectedFile == null) {
            this.dispatchEvent(new CustomEvent('awscredentials', {
                bubbles: true,
                composed: true,
                detail: {
                    accessKey: this.accessKey,
                    secretKey: this.secretKey,
                    regionName: this.region,
                    bucketName: this.BucketSelected
                }
            }));
        }
        this.ismodalopen = false;
    }

    handleCreds(event) {
        console.log('event');
        console.log(event);
        console.log(event.target.value)
        this.credsName = event.target.value;
        this.forBucketsButton = true;
    }
    async getBuckets() {
        this.Buckets = null;
        if (this.credsName == null || this.credsName == 'Select') {
            this.showToast('Required', 'Kindly select name of credentials to get Buckets', 'error');
            return;
        }

        this.isBucketsLoading = true;
        await getCredentailsOnName({ name: this.credsName })
        
            .then(data => {
                console.log('data---->',data);
                this.accessKey = data.CTBR__AccessKey__c;
                this.secretKey = data.CTBR__SecretKey__c;
                this.region = data.CTBR__Region_Name__c;
            })
            .catch(error => {
                console.log('error');
                console.log(error);
                console.log(JSON.stringify(error));
            })

        if (this.accessKey === null && this.secretKey === null && this.region === null && this.credAlias == null) {
            this.isBucketsLoading = false;
            this.showToast('Required', 'Please enter your Credentials to fetch Buckets', 'error');
            return;
        }

        console.log('after if ');
        console.log(this.accessKey);
        console.log(this.secretKey);
        console.log(this.region);

        getBuckets({ accessKey: this.accessKey, secretKey: this.secretKey, awsRegion: this.region })
            .then(data => {
                console.log(data);
                this.Buckets = data;
                this.isBucketsLoading = false;
                this.forBucketsButton = false;
            })
            .catch(error => {
                console.log('error');
                console.log(error);
                const errorBody = error.body;
                console.log(errorBody.message);
                this.isBucketsLoading = false;
                if (errorBody.message == 'InvalidAccessKeyId') {
                    this.isBucketsLoading = false;
                    this.showToast('Invalid AccessKey', 'Please Provide valid Access key to fetch Buckets', 'error');
                }
                else if (errorBody.message == 'SignatureDoesNotMatch') {
                    this.isBucketsLoading = false;
                    this.showToast('Invalid Secret Key', 'Please Provide valid Secret key to fetch Buckets', 'error');
                }
                else if (errorBody.message == 'Exception') {
                    this.isBucketsLoading = false;
                    this.showToast('Invalid Region', 'Please Provide valid Aws Region to fetch Buckets', 'error');
                }
            })
    }


    async saveCreds() {
        if (!this.haveCreds) {
            console.log('have creds');
            console.log(this.haveCreds);
            let credentials = this.template.querySelectorAll('lightning-input');
            console.log('creds');
            console.log(credentials);
            credentials.forEach((cred) => {

                if (cred.name == 'AccessKey') {
                    console.log('access key');
                    console.log(cred.value);
                    if (cred.value) {
                        console.log('yes access');
                        this.accessKey = cred.value;
                    }
                }
                if (cred.name == 'credName') {
                    console.log('credName');
                    console.log(cred.value);
                    if (cred.value) {
                        console.log('yes access');
                        this.credAlias = cred.value;
                    }
                }

                if (cred.name == 'SecretKey') {
                    console.log('access key');
                    console.log(cred.value);
                    if (cred.value) {
                        console.log('yes secret');
                        this.secretKey = cred.value;
                    }
                }
                if (cred.name == 'Region') {
                    console.log('access key');
                    console.log(cred.value);
                    if (cred.value) {
                        console.log('yes region');
                        this.region = cred.value;
                    }
                }
            });

                this.showCredsSpinner = false;
        }
        if (this.haveCreds) {

            let credentials = this.template.querySelectorAll('lightning-input');
            console.log('havecreds');
            console.log(credentials);
            credentials.forEach((cred) => {

                if (cred.name == 'AccessKey2') {
                    console.log('access key');
                    console.log(cred.value);
                    if (cred.value) {
                        console.log('yes access');
                        this.accessKey = cred.value;
                    }
                }
                if (cred.name == 'credName2') {
                    console.log('credName');
                    console.log(cred.value);
                    if (cred.value) {
                        console.log('yes access');
                        this.credAlias = cred.value;
                    }
                }

                if (cred.name == 'SecretKey2') {
                    console.log('access key');
                    console.log(cred.value);
                    if (cred.value) {
                        console.log('yes secret');
                        this.secretKey = cred.value;
                    }
                }
                if (cred.name == 'Region2') {
                    console.log('access key');
                    console.log(cred.value);
                    if (cred.value) {
                        console.log('yes region');
                        this.region = cred.value;
                    }
                }
            });
            this.showCredsSpinner = false;
        }

        if (this.accessKey == null) {
            this.showToast('Required', 'Please enter AccessKey value', 'error');
            return;
        }
        if (this.secretKey == null) {
            this.showToast('Required', 'Please enter SecretKey value', 'error');
            return;
        }
        if (this.region == null) {
            this.showToast('Required', 'Please enter Region', 'error');
            return;
        }
        if (this.credAlias == null) {
            this.showToast('Required', 'Please enter name of Creds to Store ', 'error');
            return;
        }

        if (this.credentialAlias.includes(this.credAlias)) {
            this.showToast('Duplicate Found', 'credential Alias Already used', 'error');
            return;
        }

        await saveCred({ AccessKey: this.accessKey, SecretKey: this.secretKey, RegionName: this.region, credName: this.credAlias })
            .then(data => {
                console.log('data saved to sf');
                console.log(data);
                this.haveCreds = true;

            })
            .catch(error => {
                console.log('error');
                console.log(error);
            })
                
         
        getCredentails()
            .then(data => {
                console.log('get creds');
                console.log(data);
                this.awsCredentials = data;
                console.log(this.awsCredentials);
                console.log(data.length);
            })
            .catch(error => {
                console.log('error');
                console.log(error);
                console.log(JSON.stringify(error));
            })
            console.log('loading');
            console.log(this.isLoading);
            //this.isLoading = false;
            console.log('after');
            console.log(this.isLoading);
        
            this.isOpenCredsModal = false;
    }
    AddCreds() {
        this.isOpenCredsModal = true;
        addcreds = true;
    }
    closeCredsModal() {
        this.isOpenCredsModal = false;
    }
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    handlBucketSelect(event) {

        console.log(event);
        console.log(event.target.value);
        this.BucketSelected = event.target.value;
        //this.isrecovery = true;
        if (this.isrecovery && this.BucketSelected != null) {
            this.isFilesLoading = true;
            getFiles({ accessKey: this.accessKey, secretKey: this.secretKey, awsRegion: this.region, bucket: this.BucketSelected })
                .then(data => {
                    this.isFilesLoading = false;
                    this.files = data;
                    console.log('data');
                    console.log(data);

                })
                .catch(error => {
                    this.showToast('No Files', 'No Files appear in the bucket you have selected', 'error');
                    this.isFilesLoading = false;
                    console.log('error');
                    console.log(error);
                })
        }


    }

    getFile(event) {
        console.log('inside get file');
        console.log(event.target.value);
        this.selectedFile = event.target.value;


    }
    isSpinnerLoading(isLoading) {
        window.setTimeout(() => {
            this.isLoading = isLoading;
        }, 1000);

    }
}