<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Patient Validation</title>
</head>
<body>
<%
    String pid = request.getParameter("patientid");
    String pname = request.getParameter("patientname");
    String email = request.getParameter("email");
    String pwd = request.getParameter("pwd");
    String street = request.getParameter("street");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String pincode = request.getParameter("pincode");
    String country = request.getParameter("country");
    String phone = request.getParameter("phone");
    String rov = request.getParameter("rov");
    String roomNo = request.getParameter("roomNo");
    String bedNo = request.getParameter("bed_no");
    String doctId = request.getParameter("doct");
    String gender = request.getParameter("gender");
    String joindate = request.getParameter("joindate");
    String age = request.getParameter("age");
    String bgroup = request.getParameter("bgroup");

    System.out.println("Add Patient Parameters: patientname=" + pname + ", email=" + email + 
                       ", pwd=[PROTECTED], street=" + street + ", area=" + area + 
                       ", city=" + city + ", state=" + state + ", pincode=" + pincode + 
                       ", country=" + country + ", phone=" + phone + ", rov=" + rov + 
                       ", roomNo=" + roomNo + ", bedNo=" + bedNo + ", doctId=" + doctId + 
                       ", gender=" + gender + ", joindate=" + joindate + ", age=" + age + 
                       ", bgroup=" + bgroup);

    Connection con = (Connection) application.getAttribute("connection");
    try {
        if (con == null) {
            System.out.println("Error: Database connection is null");
            out.println("<h3 style='color:red;'>Error: Database connection not established.</h3>");
            return;
        }

        // Server-side validation
        if (pname == null || pname.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Patient name cannot be empty.</h3>");
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Email cannot be empty.</h3>");
            return;
        }
        if (pwd == null || pwd.trim().length() < 8) {
            out.println("<h3 style='color:red;'>Error: Password must be at least 8 characters.</h3>");
            return;
        }
        if (street == null || street.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Street cannot be empty.</h3>");
            return;
        }
        if (area == null || area.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Area cannot be empty.</h3>");
            return;
        }
        if (city == null || city.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: City cannot be empty.</h3>");
            return;
        }
        if (state == null || state.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: State cannot be empty.</h3>");
            return;
        }
        if (pincode == null || !pincode.matches("\\d{6}")) {
            out.println("<h3 style='color:red;'>Error: Pincode must be exactly 6 digits.</h3>");
            return;
        }
        if (phone == null || !phone.matches("\\d{10}")) {
            out.println("<h3 style='color:red;'>Error: Phone must be exactly 10 digits.</h3>");
            return;
        }
        if (rov == null || rov.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Reason of visit cannot be empty.</h3>");
            return;
        }
        if (roomNo == null || roomNo.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Room number is required.</h3>");
            return;
        }
        if (bedNo == null || bedNo.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Bed number is required.</h3>");
            return;
        }
        if (doctId == null || doctId.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Doctor selection is required.</h3>");
            return;
        }
        if (gender == null || gender.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Gender is required.</h3>");
            return;
        }
        if (joindate == null || joindate.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Admission date is required.</h3>");
            return;
        }
        if (age == null || age.trim().isEmpty()) {
            out.println("<h3 style='color:red;'>Error: Age is required.</h3>");
            return;
        }
        // Step 1: Get doctor ID
        int doctorId = Integer.parseInt(doctId);
        PreparedStatement ps = con.prepareStatement("SELECT ID FROM doctor_info WHERE ID = ?");
        ps.setInt(1, doctorId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            out.println("<h3 style='color:red;'>Doctor not found in the system. Please add the doctor first.</h3>");
            rs.close();
            ps.close();
            return;
        }
        rs.close();
        // Step 2: Check if Room + Bed combination exists and is available
        ps = con.prepareStatement("SELECT status FROM room_info WHERE room_no = ? AND bed_no = ?");
        ps.setInt(1, Integer.parseInt(roomNo));
        ps.setInt(2, Integer.parseInt(bedNo));
        rs = ps.executeQuery();
        if (!rs.next()) {
            out.println("<h3 style='color:red;'>Invalid Room or Bed. Please add this Room/Bed first.</h3>");
            rs.close();
            ps.close();
            return;
        } else if (rs.getString("status").equals("busy")) {
            out.println("<h3 style='color:red;'>Error: Selected room and bed are already occupied.</h3>");
            rs.close();
            ps.close();
            return;
    }
        rs.close();
        // Simulate password hashing (replace with bcrypt in production)
        String hashedPassword = pwd != null && !pwd.isEmpty() ? pwd : null;

        // Step 3: Insert patient
        ps = con.prepareStatement(
            "INSERT INTO patient_info (PNAME, GENDER, AGE, BGROUP, PHONE, STREET, AREA, CITY, STATE, PINCODE, COUNTRY, REA_OF_VISIT, ROOM_NUMBER, BED_NO, DOCTOR_ID, DATE_ADDED, EMAIL, PASSWORD) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        );
        ps.setString(1, pName);
        ps.setString(2, gender);
        ps.setInt(3, Integer.parseInt(age));
        ps.setString(4, bgroup);
        ps.setString(5, phone);
        ps.setString(6, street);
        ps.setString(7, area);
        ps.setString(8, city);
        ps.setString(9, state);
        ps.setString(10, pincode);
        ps.setString(11, country);
        ps.setString(12, rov);
        ps.setInt(13, Integer.parseInt(roomNo));
        ps.setInt(14, Integer.parseInt(bedNo));
        ps.setInt(15, doctorId);
        ps.setString(16, joindate);
        ps.setString(17, email);
        ps.setString(18, hashedPassword);

        int i = ps.executeUpdate();

        if (i > 0) {
            // Update room status to busy
            ps = con.prepareStatement("UPDATE room_info SET status = ? WHERE room_no = ? AND bed_no = ?");
            ps.setString(1, "busy");
            ps.setInt(2, Integer.parseInt(roomNo));
            ps.setInt(3, Integer.parseInt(bedNo));
            ps.executeUpdate();
%>
            <div style="text-align: center; margin-top: 25%;">
                <font color="green">
                    <script type="text/javascript">
                        function Redirect() {
                            window.location = "patients.jsp";
                        }
                        document.write("<h2>Patient Added Successfully</h2><br><br>");
                        document.write("<h3>Redirecting to home page...</h3>");
                        setTimeout('Redirect()', 3000);
                    </script>
                </font>
            </div>
<%
        } else {
            out.println("<h3 style='color:red;'>Error: Failed to add patient.</h3>");
        }

        ps.close();
        con.commit();
    } catch (SQLException e) {
        System.out.println("SQLException in add_patient_validation.jsp: " + e.getMessage());
        e.printStackTrace();
        out.println("<h3 style='color:red;'>Error: " + e.getMessage() + "</h3>");
    } catch (Exception e) {
        System.out.println("Unexpected error in add_patient_validation.jsp: " + e.getMessage());
        e.printStackTrace();
        out.println("<h3 style='color:red;'>Unexpected error: " + e.getMessage() + "</h3>");
    } finally {
        try {
            if (con != null) {
                rs.close();
            }
            if (ps != null) ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
%>
</body>
</html>