<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    String pname = request.getParameter("patientname");
    String email = request.getParameter("email");
    String pwd = request.getParameter("pwd");

    String phone = request.getParameter("phone");
    String rov = request.getParameter("rov");
    String gender = request.getParameter("gender");
    String age = request.getParameter("age");
    String bgroup = request.getParameter("bgroup");
    String street = request.getParameter("street");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String country = request.getParameter("country");
    String pincode = request.getParameter("pincode");

    // Room, Bed, and Doctor will be assigned by admin later, so set as NULL
    Integer roomNo = null;
    Integer bedNo = null;

    // Current date for DATE_AD
    java.util.Date currentDate = new java.util.Date();
    java.sql.Date sqlDate = new java.sql.Date(currentDate.getTime());

    Connection con = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "Naman@123");

        String sql = "INSERT INTO PATIENT_INFO (PNAME, GENDER, AGE, BGROUP, PHONE, REA_OF_VISIT, ROOM_NO, BED_NO, DOCTOR_ID, DATE_AD, EMAIL, PASSWORD, STREET, AREA, CITY, STATE, COUNTRY, PINCODE) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        ps = con.prepareStatement(sql);

        ps.setString(1, pname);
        ps.setString(2, gender);
        ps.setInt(3, Integer.parseInt(age));
        ps.setString(4, bgroup);
        ps.setString(5, phone);
        ps.setString(6, rov);

        // Set ROOM_NO and BED_NO as NULL because admin assigns them later
        ps.setNull(7, java.sql.Types.INTEGER);
        ps.setNull(8, java.sql.Types.INTEGER);

        // Set DOCTOR_ID as NULL because admin assigns doctor later
        ps.setNull(9, java.sql.Types.INTEGER);

        ps.setDate(10, sqlDate);
        ps.setString(11, email);
        ps.setString(12, pwd);
        ps.setString(13, street);
        ps.setString(14, area);
        ps.setString(15, city);
        ps.setString(16, state);
        ps.setString(17, country);
        ps.setString(18, pincode);

        int i = ps.executeUpdate();

        if (i > 0) {
%>
            <script>
                alert("Patient Registered Successfully! Admin will assign room and doctor details.");
                window.location.href = "index.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("Registration Failed!");
                window.history.back();
            </script>
<%
        }
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (ps != null) try { ps.close(); } catch(Exception e) {}
        if (con != null) try { con.close(); } catch(Exception e) {}
    }
%>
