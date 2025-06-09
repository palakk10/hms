<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Patient Validation</title>
    <style>
        .success-message {
            text-align: center;
            margin-top: 25%;
            color: green;
        }
    </style>
</head>
<body>
<% 
    // Get all parameters from the request
    String pid = request.getParameter("patientid");
    String name = request.getParameter("patientname");
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
    String joindate = request.getParameter("admit_date");
    String age = request.getParameter("age");
    String bgroup = request.getParameter("bgroup");

    // Debug logging
    System.out.println("Edit Patient Parameters: patientid=" + pid + ", name=" + name + 
                       ", email=" + email + ", street=" + street + ", area=" + area + 
                       ", city=" + city + ", state=" + state + ", pincode=" + pincode + 
                       ", country=" + country + ", phone=" + phone + ", rov=" + rov + 
                       ", roomNo=" + roomNo + ", bedNo=" + bedNo + ", doctId=" + doctId + 
                       ", gender=" + gender + ", joindate=" + joindate + ", age=" + age + 
                       ", bgroup=" + bgroup);

    Connection con = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        // Validate connection
        if (con == null || con.isClosed()) {
            System.out.println("Error: Database connection is not available");
            session.setAttribute("error-message", "Database connection error. Please try again.");
            response.sendRedirect("patients.jsp");
            return;
        }

        // Start transaction
        con.setAutoCommit(false);

        // Server-side validation
        if (pid == null || pid.trim().isEmpty() || !pid.matches("\\d+")) {
            throw new Exception("Invalid Patient ID");
        }
        if (name == null || name.trim().isEmpty()) {
            throw new Exception("Patient name cannot be empty");
        }
        if (email == null || email.trim().isEmpty() || !email.contains("@")) {
            throw new Exception("Valid email is required");
        }
        if (pwd == null || pwd.trim().length() < 8) {
            throw new Exception("Password must be at least 8 characters");
        }
        // [Add all other validations as needed]

        // Verify patient exists
        ps = con.prepareStatement("SELECT room_no, bed_no FROM patient_info WHERE id = ?");
        ps.setInt(1, Integer.parseInt(pid));
        rs = ps.executeQuery();
        
        if (!rs.next()) {
            throw new Exception("Patient not found with ID: " + pid);
        }
        
        int currentRoomNo = rs.getInt("room_no");
        int currentBedNo = rs.getInt("bed_no");
        rs.close();
        ps.close();

        // Check if room/bed changed
        int newRoomNo = Integer.parseInt(roomNo);
        int newBedNo = Integer.parseInt(bedNo);
        boolean roomChanged = (newRoomNo != currentRoomNo) || (newBedNo != currentBedNo);

        if (roomChanged) {
            // Check new room/bed availability
            ps = con.prepareStatement(
                "SELECT status FROM room_info WHERE room_no = ? AND bed_no = ? FOR UPDATE");
            ps.setInt(1, newRoomNo);
            ps.setInt(2, newBedNo);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                throw new Exception("Invalid Room/Bed combination");
            } else if ("busy".equalsIgnoreCase(rs.getString("status"))) {
                throw new Exception("Selected Room/Bed is already occupied");
            }
            rs.close();
            ps.close();
        }

        // Update patient info
        String updateSql = "UPDATE patient_info SET " +
            "PNAME=?, GENDER=?, AGE=?, BGROUP=?, PHONE=?, " +
            "STREET=?, AREA=?, CITY=?, STATE=?, PINCODE=?, COUNTRY=?, " +
            "REA_OF_VISIT=?, ROOM_NO=?, BED_NO=?, DOCTOR_ID=?, DATE_AD=?, " +
            "EMAIL=?, PASSWORD=? WHERE ID=?";
        
        ps = con.prepareStatement(updateSql);
        ps.setString(1, name);
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
        ps.setInt(13, newRoomNo);
        ps.setInt(14, newBedNo);
        ps.setInt(15, Integer.parseInt(doctId));
        ps.setString(16, joindate);
        ps.setString(17, email);
        ps.setString(18, pwd); // Note: Should be hashed in production
        ps.setInt(19, Integer.parseInt(pid));

        int rowsAffected = ps.executeUpdate();
        System.out.println("Patient update rows affected: " + rowsAffected);

        if (rowsAffected == 0) {
            throw new Exception("No patient record updated - ID may not exist");
        }

        if (roomChanged) {
            // Update new room status
            ps = con.prepareStatement(
                "UPDATE room_info SET status='busy' WHERE room_no=? AND bed_no=?");
            ps.setInt(1, newRoomNo);
            ps.setInt(2, newBedNo);
            int updated = ps.executeUpdate();
            System.out.println("New room update rows: " + updated);
            ps.close();

            // Update old room status
            ps = con.prepareStatement(
                "UPDATE room_info SET status='available' WHERE room_no=? AND bed_no=?");
            ps.setInt(1, currentRoomNo);
            ps.setInt(2, currentBedNo);
            updated = ps.executeUpdate();
            System.out.println("Old room update rows: " + updated);
            ps.close();
        }

        // Commit transaction
        con.commit();
        System.out.println("Transaction committed successfully");
        
        // Set success message
        session.setAttribute("success-message", "Patient details updated successfully!");
%>
        <div class="success-message">
            <h2>Patient Details Updated Successfully</h2>
            <p>Redirecting to patients list...</p>
            <script>
                setTimeout(function() {
                    window.location.href = "patients.jsp";
                }, 3000);
            </script>
        </div>
<%
    } catch (Exception e) {
        try {
            if (con != null) con.rollback();
        } catch (SQLException ex) {
            System.out.println("Error rolling back transaction: " + ex.getMessage());
        }
        
        System.out.println("Error updating patient: " + e.getMessage());
        e.printStackTrace();
        
        session.setAttribute("error-message", "Error: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    } finally {
        try { 
            if (rs != null) rs.close(); 
            if (ps != null) ps.close();
            if (con != null) con.setAutoCommit(true); 
        } catch (SQLException e) {
            System.out.println("Error cleaning up resources: " + e.getMessage());
        }
    }
%>
</body>
</html>