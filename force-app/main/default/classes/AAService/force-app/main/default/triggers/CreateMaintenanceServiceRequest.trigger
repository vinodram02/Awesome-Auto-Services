trigger CreateMaintenanceServiceRequest on Vehicle__c (before insert,after insert, before update, after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate ){
        
        AutomateVehicleMaintenance.vehiclesWithMaintenanceReading(Trigger.new);
        
    }

}