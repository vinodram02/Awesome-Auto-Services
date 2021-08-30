@isTest
public class VehicleMaintenanceBatch_Test {

    static TestMethod void vehicleMaintenanceBatch(){
        
        Account ac=new Account();
        ac.Name='Awesome service Automate-Mumbai';
        insert ac;
        
        contact con=new contact();
        con.AccountId=ac.Id;
        con.LastName='Ram';
        con.Email='vinodram.sfdc02@gmail.com';
        insert con;
        
        Vehicle__c vh1=new Vehicle__c();
        vh1.Name='Tata';
        vh1.Model__c='Safari';
        vh1.Customer__c=con.Id;
        vh1.Last_Known_Odometer_Reading__c=29500;
        Date lastserviceDate=Date.newInstance(2020, 9, 28);
        vh1.Last_Service_Date__c=lastserviceDate;
        insert vh1;
        Vehicle__c vh2=new Vehicle__c();
        vh2.Name='Toyota';
        vh2.Model__c='Innova';
        vh2.Customer__c=con.Id;
        vh2.Last_Known_Odometer_Reading__c=19200;
        Date lastserviceDate1=Date.newInstance(2020, 9, 29);
        vh2.Last_Service_Date__c=lastserviceDate1;
        insert vh2;
        List<Vehicle__c>vehicleList=new List<Vehicle__c>();
        vehicleList.add(vh1);
        vehicleList.add(vh2);
        
     
        Test.startTest();
        VehicleMaintenanceBatch vm=new VehicleMaintenanceBatch();
        ID batchprocessid = Database.executeBatch(vm);
        Test.stopTest();

        System.AssertEquals(
           database.countquery('SELECT COUNT()'
              +' FROM Maintenance_Request__c WHERE Vehicle__c=\'' + vh1.Id + '\''),
           1);   
        
    }
}