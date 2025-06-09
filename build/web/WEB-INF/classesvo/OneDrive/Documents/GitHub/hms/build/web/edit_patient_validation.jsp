<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%!
    private boolean isValidEmail(String email) {
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        return email != null && email.matches(emailRegex);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Patient Validation</title>
</head>
<body>
<% 
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

    System.out.println("Form Parameters: patientid=" + pid + ", name=" + name + ", email=" + email + 
                       ", street=" + street + ", area=" + area + ", city=" + city + ", state=" + state + 
                       ", pincode=" + pincode + ", country=" + country + ", phone=" + phone + 
                       ", rov=" + rov + ", roomNo=" + roomNo + ", bedNo=" + bedNo + 
                       ", doctId=" + doctId + ", gender=" + gender + ", joindate=" + joindate + 
                       ", age=" + age + ", bgroup=" + bgroup);

    Connection con = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        if (con == null) {
            throw new SQLException("Database connection is null");
        }
        con.setAutoCommit(false); // Start transaction

        // Validate inputs
        if (pid == null || pid.trim().isEmpty() || !pid.matches("\\d+")) {
            throw new Exception("Invalid Patient ID.");
        }
        if (name == null || name.trim().isEmpty()) {
            throw new Exception("Patient name is required.");
        }
        if (email == null || !isValidEmail(email)) {
            throw new Exception("Valid email is required.");
        }
        if (roomNo == null || roomNo.trim().isEmpty() || !roomNo.matches("\\d+")) {
            throw new Exception("Room number is required.");
        }
        if (bedNo == null || bedNo.trim().isEmpty() || !bedNo.matches("\\d+")) {
            throw new Exception("Bed number is required.");
        }
        if (doctId == null || doctId.trim().isEmpty() || !doctId.matches("\\d+")) {
            throw new Exception("Doctor selection is required.");
        }
        if (joindate == null || joindate.trim().isEmpty()) {
            throw new Exception("Admission date is required.");
        }
        if (age == null || !age.matches("\\d+")) {
            throw new Exception("Valid age is required.");
        }

        int patientId = Integer.parseInt(pid);
        int newRoomNo = Integer.parseInt(roomNo);
        int newBedNo = Integer.parseInt(bedNo);
        int doctorId = Integer.parseInt(doctId);
        int patientAge = Integer.parseInt(age);

        // Check for duplicate email (excluding current patient)
        ps = con.prepareStatement("SELECT ID FROM patient_info WHERE EMAIL = ? AND ID != ?");
        ps.setString(1, email);
        ps.setInt(2, patientId);
        rs = ps.executeQuery();
        if (rs.next()) {
            throw new Exception("Email already exists.");
        }
        rs.close();
        ps.close();

        // Verify patient exists
        ps = con.prepareStatement("SELECT ID FROM patient_info WHERE ID = ?");
        ps.setInt(1, patientId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Patient not found.");
        }
        rs.close();
        ps.close();

        // Verify doctor exists
        ps = con.prepareStatement("SELECT ID FROM doctor_info WHERE ID = ?");
        ps.setInt(1, doctorId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Doctor not found.");
        }
        rs.close();
        ps.close();

        // Check current room/bed assignment
        ps = con.prepareStatement("SELECT ROOM_NO, BED_NO FROM patient_info WHERE ID = ?");
        ps.setInt(1, patientId);
        rs = ps.executeQuery();
        Integer currentRoomNo = null;
        Integer currentBedNo = null;
        if (rs.next()) {
            currentRoomNo = rs.getInt("ROOM_NO") != 0 ? rs.getInt("ROOM_NO") : null;
            currentBedNo = rs.getInt("BED_NO") != 0 ? rs.getInt("BED_NO") : null;
        }
        rs.close();
        ps.close();

        // Check room/bed availability if changed
        if (currentRoomNo == null || currentBedNo == null || newRoomNo != currentRoomNo || newBedNo != currentBedNo) {
            ps = con.prepareStatement("SELECT STATUS FROM room_info WHERE ROOM_NO = ? AND BED_NO = ?");
            ps.setInt(1, newRoomNo);
            ps.setInt(2, newBedNo);
            rs = ps.executeQuery();
            if (!rs.next()) {
                throw new Exception("Invalid Room or Bed.");
            }
            if (!rs.getString("STATUS").equalsIgnoreCase("Available")) {
                throw new Exception("Room and bed are already occupied.");
            }
            rs.close();
            ps.close();
        }

        // Update patient
        ps = con.prepareStatement(
            "UPDATE patient_info SET PNAME = ?, GENDER = ?, AGE = ?, BGROUP = ?, PHONE = ?, STREET = ?, AREA = ?, CITY = ?, STATE = ?, PINCODE = ?, COUNTRY = ?, REA_OF_VISIT = ?, ROOM_NO = ?, BED_NO = ?, DOCTOR_ID = ?, DATE_AD = ?, EMAIL = ?, PASSWORD = ? WHERE ID = ?"
        );
        ps.setString(1, name.trim());
        ps.setString(2, gender != null && gender.matches("Male|Female|Other") ? gender : null);
        ps.setInt(3, patientAge);
        ps.setString(4, bgroup != null && bgroup.matches("A\\+|A-|B\\+|B-|AB\\+|AB-|O\\+|O-") ? bgroup : null);
        ps.setString(5, phone != null ? phone.trim() : null);
        ps.setString(6, street != null ? street.trim() : null);
        ps.setString(7, area != null ? area.trim() : null);
        ps.setString(8, city != null ? city.trim() : null);
        ps.setString(9, state != null ? state.trim() : null);
        ps.setString(10, pincode != null ? pincode.trim() : null);
        ps.setString(11, country != null ? country.trim() : null);
        ps.setString(12, rov != null ? rov.trim() : null);
        ps.setInt(13, newRoomNo);
        ps.setInt(14, newBedNo);
        ps.setInt(15, doctorId);
        ps.setString(16, joindate.trim());
        ps.setString(17, email.trim());
        ps.setString(18, pwd != null ? pwd.trim() : null);
        ps.setInt(19, patientId);

        int rowsAffected = ps.executeUpdate();
        ps.close();

        if (rowsAffected > 0) {
            // Update room status if changed
            if (currentRoomNo == null || currentBedNo == null || newRoomNo != currentRoomNo || newBedNo != currentBedNo) {
                ps = con.prepareStatement("UPDATE room_info SET STATUS = 'Occupied' WHERE ROOM_NO = ? AND BED_NO = ?");
                ps.setInt(1, newRoomNo);
                ps.setInt(2, newBedNo);
                ps.executeUpdate();
                ps.close();

                if (currentRoomNo != null && currentBedNo != null) {
                    ps = con.prepareStatement("UPDATE room_info SET STATUS = 'Available' WHERE ROOM_NO = ? AND BED_NO = ?");
                    ps.setInt(1, currentRoomNo);
                    ps.setInt(2, currentBedNo);
                    ps.executeUpdate();
                    ps.close();
                }
            }

            con.commit();
%>
<div style="text-align: center; margin-top: 25%;">
    <font color="blue">
        <script>
            function redirect() { window.location = "patients.jsp"; }
            document.write("<h2>Patient Details Updated Successfully</h2><br><br>");
            document.write("<h3>Redirecting...</h3>");
            setTimeout(redirect, 3000);
        </script>
    </font>
</div>
<%
        } else {
            throw new Exception("Failed to update patient.");
        }
    } catch (SQLException e) {
        if (con != null) try { con.rollback(); } catch (SQLException ex) { System.err.println("Rollback failed: " + ex.getMessage()); }
        System.err.println("SQLException: " + e.getMessage());
        session.setAttribute("error-message", "Database error: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (SQLException ex) { System.err.println("Rollback failed: " + ex.getMessage()); }
        System.err.println("Unexpected error: " + e.getMessage());
        session.setAttribute("error-message", "Error: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { System.err.println("Error closing ResultSet: " + e.getMessage()); }
        if (ps != null) try { ps.close(); } catch (SQLException e) { System.err.println("Error closing PreparedStatement: " + e.getMessage()); }
        if (con != null) try { con.setAutoCommit(true); } catch (SQLException e) { System.err.println("Error resetting auto-commit: " + e.getMessage()); }
    }
%>
</body>
</html>