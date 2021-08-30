@isTest
public class AutomateVehicleMaintenance_Test {
    
    public static Account createAccount(){
        
        Account ac=new Account();
        
        ac.Name='Awesome service Automate-Mumbai';
        insert ac;
        return ac;
    }  
    public static Contact createContact(Account acc){

        contact con=new contact();
        con.AccountId=acc.Id;
        con.LastName='Ram';
        con.Email='vinodram.sfdc02@gmail.com';
        insert con;
        return con;
    }  
    public static List<Vehicle__c> createVehicle(contact cont){

        Vehicle__c vh1=new Vehicle__c();
        vh1.Name='Tata';
        vh1.Model__c='Safari';
        vh1.Customer__c=cont.Id;
        vh1.Last_Known_Odometer_Reading__c=29500;
        insert vh1;
        Vehicle__c vh2=new Vehicle__c();
        vh2.Name='Toyota';
        vh2.Model__c='Innova';
        vh2.Customer__c=cont.Id;
        vh2.Last_Known_Odometer_Reading__c=19200;
        insert vh2;
        List<Vehicle__c>vehicleList=new List<Vehicle__c>();
        vehicleList.add(vh1);
        vehicleList.add(vh2);
        return vehicleList;
        
    }
    
    public static testmethod void vehicleMaintenanceTest(){
    
        Account ac=createAccount();
        contact con=createContact(ac);
        
        test.startTest();
          AutomateVehicleMaintenance.vehiclesWithMaintenanceReading(createVehicle(con));
        test.stopTest();
        List<Vehicle__c>vhList=new List<Vehicle__c>();
        vhList.addAll(createVehicle(con));
        Vehicle__c vh=vhList[0];
        System.AssertEquals(
           database.countquery('SELECT COUNT()'
              +' FROM Maintenance_Request__c WHERE Vehicle__c =\'' + vh.Id + '\''),
           0); 
        
    }    

}