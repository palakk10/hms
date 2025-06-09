<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Patient Validation</title>
</head>
<body>
<% 
    // Retrieve form parameters
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

    // Log form parameters
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
        // Check database connection
        if (con == null) {
            System.out.println("ERROR: Database connection is null");
            session.setAttribute("error-message", "Database connection failed.");
            response.sendRedirect("patients.jsp");
            return;
        }
        System.out.println("Database connection established");

        // Validate critical fields
        if (pid == null || pid.trim().isEmpty() || !pid.matches("\\d+")) {
            System.out.println("ERROR: Invalid Patient ID: " + pid);
            session.setAttribute("error-message", "Invalid Patient ID.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (roomNo == null || roomNo.trim().isEmpty() || !roomNo.matches("\\d+")) {
            System.out.println("ERROR: Invalid Room Number: " + roomNo);
            session.setAttribute("error-message", "Room number is required.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (bedNo == null || bedNo.trim().isEmpty() || !bedNo.matches("\\d+")) {
            System.out.println("ERROR: Invalid Bed Number: " + bedNo);
            session.setAttribute("error-message", "Bed number is required.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (doctId == null || doctId.trim().isEmpty() || !doctId.matches("\\d+")) {
            System.out.println("ERROR: Invalid Doctor ID: " + doctId);
            session.setAttribute("error-message", "Doctor selection is required.");
            response.sendRedirect("patients.jsp");
            return;
        }

        // Parse integers
        int patientId = Integer.parseInt(pid);
        int newRoomNo = Integer.parseInt(roomNo);
        int newBedNo = Integer.parseInt(bedNo);
        int doctorId = Integer.parseInt(doctId);
        int patientAge = (age != null && age.matches("\\d+")) ? Integer.parseInt(age) : 0;

        // Verify patient exists
        ps = con.prepareStatement("SELECT ID FROM patient_info WHERE ID = ?");
        ps.setInt(1, patientId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            System.out.println("ERROR: Patient ID not found: " + patientId);
            session.setAttribute("error-message", "Patient not found.");
            response.sendRedirect("patients.jsp");
            rs.close();
            ps.close();
            return;
        }
        rs.close();
        ps.close();

        // Verify doctor exists
        ps = con.prepareStatement("SELECT ID FROM doctor_info WHERE ID = ?");
        ps.setInt(1, doctorId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            System.out.println("ERROR: Doctor ID not found: " + doctorId);
            session.setAttribute("error-message", "Doctor not found.");
            response.sendRedirect("patients.jsp");
            rs.close();
            ps.close();
            return;
        }
        rs.close();
        ps.close();

        // Check current room/bed assignment
        ps = con.prepareStatement("SELECT ROOM_NO, BED_NO FROM patient_info WHERE ID = ?");
        ps.setInt(1, patientId);
        rs = ps.executeQuery();
        int currentRoomNo = 0, currentBedNo = 0;
        if (rs.next()) {
            currentRoomNo = rs.getInt("ROOM_NO");
            currentBedNo = rs.getInt("BED_NO");
        }
        rs.close();
        ps.close();
        System.out.println("Current assignment: ROOM_NO=" + currentRoomNo + ", BED_NO=" + currentBedNo);
        System.out.println("New assignment: ROOM_NO=" + newRoomNo + ", BED_NO=" + newBedNo);

        // Check room/bed availability if changed
        if (newRoomNo != currentRoomNo || newBedNo != currentBedNo) {
            System.out.println("Checking availability for ROOM_NO=" + newRoomNo + ", BED_NO=" + newBedNo);
            ps = con.prepareStatement("SELECT STATUS FROM room_info WHERE ROOM_NO = ? AND BED_NO = ?");
            ps.setInt(1, newRoomNo);
            ps.setInt(2, newBedNo);
            rs = ps.executeQuery();
            if (!rs.next()) {
                System.out.println("ERROR: Room/Bed not found: ROOM_NO=" + newRoomNo + ", BED_NO=" + newBedNo);
                session.setAttribute("error-message", "Invalid Room or Bed.");
                response.sendRedirect("patients.jsp");
                rs.close();
                ps.close();
                return;
            }
            String status = rs.getString("STATUS");
            if (!status.equalsIgnoreCase("Available")) {
                System.out.println("ERROR: Room/Bed occupied: ROOM_NO=" + newRoomNo + ", BED_NO=" + newBedNo + ", STATUS=" + status);
                session.setAttribute("error-message", "Room and bed are already occupied.");
                response.sendRedirect("patients.jsp");
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
        }

        // Prepare update query
        System.out.println("Updating patient_info for ID=" + patientId);
        ps = con.prepareStatement(
            "UPDATE patient_info SET PNAME = ?, GENDER = ?, AGE = ?, BGROUP = ?, PHONE = ?, STREET = ?, AREA = ?, CITY = ?, STATE = ?, PINCODE = ?, COUNTRY = ?, REA_OF_VISIT = ?, ROOM_NO = ?, BED_NO = ?, DOCTOR_ID = ?, DATE_AD = ?, EMAIL = ?, PASSWORD = ? WHERE ID = ?"
        );
        ps.setString(1, name != null ? name.trim() : null);
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
        ps.setString(16, joindate != null ? joindate.trim() : null);
        ps.setString(17, email != null ? email.trim() : null);
        ps.setString(18, pwd != null ? pwd.trim() : null); // Replace with bcrypt in production
        ps.setInt(19, patientId);

        // Execute update
        int rowsAffected = ps.executeUpdate();
        System.out.println("Rows affected by patient_info update: " + rowsAffected);
        ps.close();

        if (rowsAffected > 0) {
            // Update room status if changed
            if (newRoomNo != currentRoomNo || newBedNo != currentBedNo) {
                System.out.println("Updating room_info: ROOM_NO=" + newRoomNo + ", BED_NO=" + newBedNo + " to Occupied");
                ps = con.prepareStatement("UPDATE room_info SET STATUS = 'Occupied' WHERE ROOM_NO = ? AND BED_NO = ?");
                ps.setInt(1, newRoomNo);
                ps.setInt(2, newBedNo);
                int roomRows = ps.executeUpdate();
                System.out.println("Rows affected by room_info update (new bed): " + roomRows);
                ps.close();

                if (currentRoomNo != 0 && currentBedNo != 0) {
                    System.out.println("Updating old room_info: ROOM_NO=" + currentRoomNo + ", BED_NO=" + currentBedNo + " to Available");
                    ps = con.prepareStatement("UPDATE room_info SET STATUS = 'Available' WHERE ROOM_NO = ? AND BED_NO = ?");
                    ps.setInt(1, currentRoomNo);
                    ps.setInt(2, currentBedNo);
                    int oldRoomRows = ps.executeUpdate();
                    System.out.println("Rows affected by room_info update (old bed): " + oldRoomRows);
                    ps.close();
                }
            }

            System.out.println("Committing transaction");
            con.commit();
%>
            <div style="text-align:center;margin-top:25%">
                <font color="blue">
                    <script type="text/javascript">
                        function Redirect() {
                            window.location = "patients.jsp";
                        }
                        document.write("<h2>Patient Details Updated Successfully</h2><br><br>");
                        document.write("<h3>Redirecting you to home page....</h3>");
                        setTimeout('Redirect()', 3000);
                    </script>
                </font>
            </div>
<%
        } else {
            System.out.println("ERROR: Update failed for patient ID=" + patientId);
            session.setAttribute("error-message", "Failed to update patient. No matching record found.");
            response.sendRedirect("patients.jsp");
        }
    } catch (SQLException e) {
        System.out.println("SQLException: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("error-message", "Database error: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    } catch (Exception e) {
        System.out.println("Unexpected error: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("error-message", "Unexpected error: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { System.out.println("Error closing ResultSet: " + e.getMessage()); }
        if (ps != null) try { ps.close(); } catch (SQLException e) { System.out.println("Error closing PreparedStatement: " + e.getMessage()); }
    }
%>
</body>
</html>