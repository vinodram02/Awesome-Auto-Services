public class AutomateVehicleMaintenance {
    
    public static void vehiclesWithMaintenanceReading(List<Vehicle__c> updatedVehicleDetails){
        set<Id>maintenenceNeededVehicles=new set<Id>();
        for(Vehicle__c vh:updatedVehicleDetails){
            if(vh.Last_Known_Odometer_Reading__c!=null){
                Integer currentReading=(Integer)vh.Last_Known_Odometer_Reading__c;
                Integer flagValue=math.mod(currentReading,10000);
                if(flagValue==9500){
                    maintenenceNeededVehicles.add(vh.id);
                } 
            }
        }
        
        if(!maintenenceNeededVehicles.isEmpty()){
			createNewMaintenanceRequest(maintenenceNeededVehicles);            
        }
        
    }
    
    public static void createNewMaintenanceRequest(set<id> vIds){
        set<id>vehiclesToNotify=new set<id>();

        List<Maintenance_Request__c>maintenanceRequestList=new List<Maintenance_Request__c>();
        Map<id,Maintenance_Request__c>vehicleWithMaintenanceRequest=new Map<id,Maintenance_Request__c>();
        for(Maintenance_Request__c mr:[select id,Vehicle__c,Status__c from Maintenance_Request__c where Vehicle__c IN:vIds and (Status__c='Not Confirmed' OR Status__c='Confirmed' OR Status__c='In Progress')]){
            vehicleWithMaintenanceRequest.put(mr.Vehicle__c,mr);
        }
        for(id vehicleId:vIds){
            if(!vehicleWithMaintenanceRequest.containsKey(vehicleId)){
                
                Maintenance_Request__c maintenanceRequest= new Maintenance_Request__c();
                maintenanceRequest.Vehicle__c=vehicleId;
                maintenanceRequest.Maintenance_Date__c=Date.today()+30;
                maintenanceRequest.Status__c='Not Confirmed';
                maintenanceRequestList.add(maintenanceRequest);
                vehiclesToNotify.add(vehicleId);
            }
            
            if(!maintenanceRequestList.isEmpty()){
               insert maintenanceRequestList;
               sendMaintenanceNotification(vehiclesToNotify);
            }
        }      
    }
    
    
    
    public static void sendMaintenanceNotification(set<id> vehiclesToNotify){
        
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