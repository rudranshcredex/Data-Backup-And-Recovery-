@RestResource(urlMapping='/accounts/*')
global class REST_AccountController {
    @HttpGet
    global static List<Account> getAccount(){
        List<Account> accounts = [select name , id from Account];
        return accounts;
    }

}