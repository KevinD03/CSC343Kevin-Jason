import java.sql.*;
// You should use this class so that you can represent SQL points as
// Java PGpoint objects.
import org.postgresql.geometric.PGpoint;

public class Assignment2 {

   // A connection to the database
   Connection connection;

   Assignment2() throws SQLException {
      try {
         Class.forName("org.postgresql.Driver");
      } catch (ClassNotFoundException e) {
         e.printStackTrace();
      }
   }

  /**
   * Connects and sets the search path.
   *
   * Establishes a connection to be used for this session, assigning it to
   * the instance variable 'connection'.  In addition, sets the search
   * path to uber, public.
   *
   * @param  url       the url for the database
   * @param  username  the username to connect to the database
   * @param  password  the password to connect to the database
   * @return           true if connecting is successful, false otherwise
   */
   public boolean connectDB(String URL, String username, String password) {
      // Implement this method!
      try { 
      	connection = DriverManager.getConnection(URL, username, password);
      	PreparedStatement setPath = 
      	        connection.prepareStatement("SET SEARCH_PATH TO uber, public");
      	setPath.execute();
      	return true;
      } catch (SQLException se) {
      	System.err.println("SQL Exception. " + "<Message>: " + se.getMessage());
      }
      return false;
   }

  /**
   * Closes the database connection.
   *
   * @return true if the closing was successful, false otherwise
   */
   public boolean disconnectDB() {
      // Implement this method!
      try {
      	connection.close();
      	return true;
      } catch (SQLException se) {
      	System.err.println("SQL Exception. " + "<Message>: " + se.getMessage());
      }
      return false;
   }
   
   /* ======================= Driver-related methods ======================= */

   /**
    * Records the fact that a driver has declared that he or she is available 
    * to pick up a client.  
    *
    * Does so by inserting a row into the Available table.
    * 
    * @param  driverID  id of the driver
    * @param  when      the date and time when the driver became available
    * @param  location  the coordinates of the driver at the time when 
    *                   the driver became available
    * @return           true if the insertion was successful, false otherwise. 
    */
   public boolean available(int driverID, Timestamp when, PGpoint location) {
      // Implement this method!
      try {
      	String queryString = "INSERT INTO Available " + 
      		"(driver_id, datetime, location) " + 
      		"VALUES (?, ?, ?);";
      	PreparedStatement ps = connection.prepareStatement(queryString);
      	ps.setInt(1, driverID);
      	ps.setTimestamp(2, when);
      	ps.setObject(3, location);
      	ps.execute();
      } catch (SQLException se){
      	System.err.println("SQL Exception. " + "<Message>: " + se.getMessage());
      	return false;
      }
      return true;
   }

   /**
    * Records the fact that a driver has picked up a client.
    *
    * If the driver was dispatched to pick up the client and the corresponding
    * pick-up has not been recorded, records it by adding a row to the
    * Pickup table, and returns true.  Otherwise, returns false.
    * 
    * @param  driverID  id of the driver
    * @param  clientID  id of the client
    * @param  when      the date and time when the pick-up occurred
    * @return           true if the operation was successful, false otherwise
    */
   public boolean picked_up(int driverID, int clientID, Timestamp when) {
      // Implement this method!
      try {
      	String queryString = "Select Request.request_id " + 
      		"From Request, Dispatch, Pickup" + 
      		"Where Request.request_id = Dispatch.request_id and "
      		+ "Dispatch.request_id = Requset.request_id and "
      		+ "Dispatch.driver_id = ? and "
      		+ "Request.client_id = ? and "
      		+ "Pickup.datetime = ?;";
      	PreparedStatement ps = connection.prepareStatement(queryString);
      	ps.setInt(1, driverID);
      	ps.setInt(2, clientID);
      	ps.setTimestamp(3, when);
      	ResultSet rs = ps.executeQuery();
      	while (rs.next()) {
      	    int request_id = rs.getInt("request_id");
      	    String insertString = "INSERT INTO Pickup " + 
          		"(requset_id, datetime) " + 
          		"VALUES (?, ?);";
      	    PreparedStatement is = connection.prepareStatement(insertString);
      	    is.setInt(1, request_id);
      	    is.setTimestamp(2, when);
      	    is.executeUpdate();
      	    rs = is.executeQuery();
      	}
      } catch (SQLException se){
      	System.err.println("SQL Exception. " + "<Message>: " + se.getMessage());
      	return false;
      }
      return true;
   }
   
   /* ===================== Dispatcher-related methods ===================== */

   /**
    * Dispatches drivers to the clients who've requested rides in the area
    * bounded by NW and SE.
    * 
    * For all clients who have requested rides in this area (i.e., whose 
    * request has a source location in this area), dispatches drivers to them
    * one at a time, from the client with the highest total billings down
    * to the client with the lowest total billings, or until there are no
    * more drivers available.
    *
    * Only drivers who (a) have declared that they are available and have 
    * not since then been dispatched, and (b) whose location is in the area
    * bounded by NW and SE, are dispatched.  If there are several to choose
    * from, the one closest to the client's source location is chosen.
    * In the case of ties, any one of the tied drivers may be dispatched.
    *
    * Area boundaries are inclusive.  For example, the point (4.0, 10.0) 
    * is considered within the area defined by 
    *         NW = (1.0, 10.0) and SE = (25.0, 2.0) 
    * even though it is right at the upper boundary of the area.
    *
    * Dispatching a driver is accomplished by adding a row to the
    * Dispatch table.  All dispatching that results from a call to this
    * method is recorded to have happened at the same time, which is
    * passed through parameter 'when'.
    * 
    * @param  NW    x, y coordinates in the northwest corner of this area.
    * @param  SE    x, y coordinates in the southeast corner of this area.
    * @param  when  the date and time when the dispatching occurred
    */
   public void dispatch(PGpoint NW, PGpoint SE, Timestamp when) {
      // Implement this method!
    
      try {
	      Double SEx = SE.x;
	      Double SEy = SE.y;
	      Double NWx = NW.x;
	      Double NWy = NW.y;
	      
	      // Drivers who are really available
	      String query0 =
	      	"CREATE VIEW AvailableDrivers AS " +
	      	"SELECT Driver.driver_id as driver_id, Available.location as location " + 
	      	"FROM Driver, Available " +
	      	"WHERE Driver.driver_id = Available.driver_id AND " +
	      	"NOT EXISTS( " +
	      	"SELECT * " +
	      	"FROM Dispatch " +
	      	"WHERE Dispatch.driver_id = Driver.driver_id AND " +
	      	"Dispatch.datetime > Available.datetime) AND " +
	      	"Available.location[0] < SEx AND Available.location[0] > NWx " +
	      	"AND Available.location[1] < NWy AND Available.location[1] > " +
	      	"SEy;";
	      PreparedStatement stat = connection.prepareStatement(query0);     
	      ResultSet worths0 = stat.executeQuery();
	      System.out.println("Truly available drivers");
	      	
	      // Clients who have not been picked up yet
	      String query1 = 
	      	"CREATE VIEW ClientNotPickedUp AS " +
	      	"(SELECT request_id " +
	      	"FROM Request) " +
	      	"EXCEPT " +
	      	"(SELECT request_id " +
	      	"FROM Pickup);";	
	      stat = connection.prepareStatement(query1);     
	      stat.execute();
	      System.out.println("CLients who have not been picked up yet");
	      
	      // Client total billings
	      String query2 =
	      	"CREATE VIEW ClientBillings AS " +
	      	"SELECT client_id, sum(amount) as billings " +
	      	"FROM billed JOIN Request ON billed.request_id = Request.request_id " +
	      	"GROUP BY client_id " +
	      	"ORDER BY billings DESC;";
	      stat = connection.prepareStatement(query2);
	      stat.execute();
	      System.out.println("Total Billing");
	      
	      ArrayList<Integer> driverid = new ArrayList<Integer>();
	      ArrayList<PGpoint> driverlocation = new ArrayList<PGpoint>();
	      
	      while (worths0.next()) {
	      	driverid.add(worths.getInt("driver_id"));
	      	PGpoint pg = (PGpoint)worths.getObject("location");
	      	driverlocation.add(pg);
	      }
	      
	      // Client location
	      String query3 =
	      	"SELECT ClientNotPickedUp.request_id as request_id, " +
	      	"ClientBillings.client_id as client_id, Place.location as " +
	      	"location " +
	      	"FROM ClientNotPickedUp, ClientBillings, Request, Place " +
	      	"WHERE ClientNotPickedUP.request_id = Request.id AND " +
	      	"Request.client_id = ClientBillings.client_id AND " +
	      	"Request.source = Place.name AND " +
	      	"PLace.location[0] < SEx AND Place.location[0] > NWx " +
	      	"AND Available.Place[1] < NWy AND Place.location[1] > " +
	      	"SEy" +
	      	"ORDER BY billings DESC;";
	      PreparedStatement stat = connection.prepareStatement(query3);     
	      ResultSet worths3 = stat.executeQuery();
	      System.out.println("Client location");
	      
	      ArrayList<Integer> requestid = new ArrayList<Integer>();
	      ArrayList<Integer> clientid = new ArrayList<Integer>();
	      ArrayList<PGpoint> clientlocation = new ArrayList<PGpoint>();
	      
	      while (worths3) {
	      	PGpoint pg = (PGpoint) worths3.getObject("location");
	      	clientlocation.add(pg);
	      	requestid.add(worths3.getInt("request_id"));
	      	clientid.add(worths3.getInt("client_id"));
	      }
	      
	      ArrayList<Integer> dprequestid = new ArrayList<Integer>();
	      ArrayList<Integer> dpdriverid = new ArrayList<Integer>();
	      ArrayList<PGpoint> dpcarlocation = new ArrayList<PGpoint>();
	      
	      for (int i = 0; i < requestid.size(); i++) {
	      	if (driverid.size()) == 0){
	      		break;
	      	}
	      	int distance = Integer.MAX_VALUE;
	      	int index = 0;
	      	for (int j = 0; j < driverid.size(); j++) {
	      		double distancecad = Math.sqrt(
	      		(clientlocation.get(i).x - driverlocation.get(j).x) 
	      		* (clientlocation.get(i).x - driverlocation.get(j).x
	      		+ (clientlocation.get(i).y - driverlocation.get(j).y) *
	      		(clientlocation.get(i).y - driverlocation.get(j).y));
	      		if (distancecad < distance) {
	      			distance = distancecad;
	      			index = j;
	      		}
	      	}
	      	dprequestid.add(requestid.get(i));
	      	dpdriverid.add(driverid.get(index));
	      	dpcarlocation.add(driverlocation.get(index));
	      	
	      }
	      for (int k = 0; k < dprequestid.size(); k++) {
	      	query4 = "INSERT INTO Dispatch (request_id, driver_id, " + 
	      	"car_location, datetime) " +
	      	"VALUES(?, ?, ?, ?);";
	      	stat = connection.prepareStatement(query4);
	      	stat.setInt(1, dprequestid.get(k));
	      	stat.setInt(2, dpdriverid.get(k));
	      	stat.setObject(3, dpcarlocation.get(k));
	      	stat.setTimestamp(4, when);
	      	stat.execute;
	      }
      
      
      } catch (SQLException se) {
      	System.err.println("SQL Exception." + "<Message>:" + se.getMessage());
      }
   }
   
   public void Print() {
        try {
            String queryString = "Select * From Request"; 		
          	PreparedStatement ps = connection.prepareStatement(queryString);
          	ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int request = rs.getInt("request_id");
                System.out.println(request);
            }
      } catch (SQLException se){
      	    System.err.println("SQL Exception. " + 
                "<Message>: " + se.getMessage());
      }
   }

   public static void main(String[] args) {
      // You can put testing code in here. It will not affect our autotester.
      String url;
      try {
        Assignment2 test = new Assignment2();
        url = "jdbc:postgresql://localhost:5432/csc343h-dingxuya";
        System.out.println("connection: " + test.connectDB(url, "dingxuya", ""));
        test.Print();
        test.disconnectDB();
      } catch (SQLException se){
      	    System.err.println("SQL Exception. " + 
                "<Message>: " + se.getMessage());
      }
      System.out.println("Boo!");
   }
}
