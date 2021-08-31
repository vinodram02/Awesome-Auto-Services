public class ScheduleVehicleMaintenance implements Schedulable {
    
    public void execute(SchedulableContext sc){

        Database.executeBatch(new VehicleMaintenanceBatch(), 10);       

    }
    
}
