public class VehicleMaintenanceBatch implements Database.Batchable<sObject>,Database.Stateful {
    
    public set<id>vehiclesToNotify=new set<id>();
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        return Database.getQueryLocator('select id,name,Last_Service_Date__c,'+ 
                                       'Last_Known_Odometer_Reading__c,Customer__c from Vehicle__c');
        
    }
    
    public void execute(Database.BatchableContext bc,List<Vehicle__c> scope){
        set<ID> vehicleIds=new set<ID>();
        for(Vehicle__c vh:scope){
            Date notificationDate=vh.Last_Service_Date__c.addYears(1)-30;
            system.debug('notificationDate...'+notificationDate);
            system.debug('Date.today()...'+Date.today());
            if(Date.today()==notificationDate){
                vehicleIds.add(vh.Id);    
            }  
        }
        
        if(!vehicleIds.isEmpty()){    
            
            List<Maintenance_Request__c>maintenanceRequestList=new List<Maintenance_Request__c>();
            Map<id,Maintenance_Request__c>vehicleWithMaintenanceRequest=new Map<id,Maintenance_Request__c>();
            
            for(Maintenance_Request__c mr:[select id,Vehicle__c,Status__c from Maintenance_Request__c where Vehicle__c IN:vehicleIds and (Status__c='Not Confirmed' OR Status__c='Confirmed' OR Status__c='In Progress')]){
                 vehicleWithMaintenanceRequest.put(mr.Vehicle__c,mr);
                system.debug('vehicleWithMaintenanceRequest==='+vehicleWithMaintenanceRequest);
                system.debug('vehicleIds***'+vehicleIds);
            }
            
            for(id vehicleId:vehicleIds){
                system.debug('vehicleWithMaintenanceRequest==='+vehicleWithMaintenanceRequest);
                system.debug('vehicleIds***'+vehicleIds);
               if(!vehicleWithMaintenanceRequest.containsKey(vehicleId)){
                    Maintenance_Request__c maintenanceRequest= new Maintenance_Request__c();
                    maintenanceRequest.Vehicle__c=vehicleId;
                    maintenanceRequest.Maintenance_Date__c=Date.today()+30;
                    maintenanceRequest.Status__c='Not Confirmed';
                    maintenanceRequestList.add(maintenanceRequest);
                   vehiclesToNotify.add(vehicleId);
                   system.debug('maintenanceRequestList....'+maintenanceRequestList);
                } 
            } 
            
            if(!maintenanceRequestList.isEmpty()){
                   insert maintenanceRequestList;
            }
        }  
     }
    
    public void finish(Database.BatchableContext bc){
        List<ID>contactListToSendNotification=new List<ID>();
        for(Vehicle__c vh:[select Id,Customer__c from Vehicle__c where id IN:vehiclesToNotify]){
            contactListToSendNotification.add(vh.Customer__c);
        }
        for(Contact c:[select Id,Email from contact where id IN:contactListToSendNotification]){
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{c.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Your Vehicle due to Maintenance in 30 days');
            mail.setPlainTextBody('Best Regards from Awesome Auto services');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
    }
}