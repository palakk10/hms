<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
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

    System.out.println("Edit Patient Parameters: patientid=" + pid + ", name=" + name + 
                       ", email=" + email + ", pwd=[PROTECTED], street=" + street + 
                       ", area=" + area + ", city=" + city + ", state=" + state + 
                       ", pincode=" + pincode + ", country=" + country + ", phone=" + phone + 
                       ", rov=" + rov + ", roomNo=" + roomNo + ", bedNo=" + bedNo + 
                       ", doctId=" + doctId + ", gender=" + gender + ", joindate=" + joindate + 
                       ", age=" + age + ", bgroup=" + bgroup);

    Connection con = (Connection) application.getAttribute("connection");
    try {
        if (con == null) {
            System.out.println("Error: Database connection is null");
            session.setAttribute("error-message", "Error: Database connection not established.");
            response.sendRedirect("patients.jsp");
            return;
        }

        // Server-side validation
        if (pid == null || pid.trim().isEmpty() || !pid.matches("\\d+")) {
            System.out.println("Error: Invalid Patient ID");
            session.setAttribute("error-message", "Error: Invalid Patient ID.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (pname == null || pname.trim().isEmpty()) {
            System.out.println("Error: Patient name is empty");
            session.setAttribute("error-message", "Error: Patient name cannot be empty.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            System.out.println("Error: Email is empty");
            session.setAttribute("error-message", "Error: Email cannot be empty.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (pwd == null || pwd.trim().length() < 8) {
            System.out.println("Error: Password less than 8 characters");
            session.setAttribute("error-message", "Error: Password must be at least 8 characters.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (street == null || street.trim().isEmpty()) {
            System.out.println("Error: Street is empty");
            session.setAttribute("error-message", "Error: Street cannot be empty.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (area == null || area.trim().isEmpty()) {
            System.out.println("Error: Area is empty");
            session.setAttribute("error-message", "Error: Area cannot be empty.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (city == null || city.trim().isEmpty()) {
            System.out.println("Error: City is empty");
            session.setAttribute("error-message", "Error: City cannot be empty.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (state == null || state.trim().isEmpty()) {
            System.out.println("Error: State is empty");
            session.setAttribute("error-message", "Error: State cannot be empty.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (pincode == null || !pincode.matches("\\d{6}")) {
            System.out.println("Error: Invalid pincode");
            session.setAttribute("error-message", "Error: Pincode must be exactly 6 digits.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (phone == null || !phone.matches("\\d{10}")) {
            System.out.println("Error: Invalid phone");
            session.setAttribute("error-message", "Error: Phone must be exactly 10 digits.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (rov == null || rov.trim().isEmpty()) {
            System.out.println("Error: Reason of visit is empty");
            session.setAttribute("error-message", "Error: Reason of visit cannot be empty.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (roomNo == null || roomNo.trim().isEmpty()) {
            System.out.println("Error: Room number is empty");
            session.setAttribute("error-message", "Error: Room number is required.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (bedNo == null || bedNo.trim().isEmpty()) {
            System.out.println("Error: Bed number is empty");
            session.setAttribute("error-message", "Error: Bed number is required.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (doctId == null || doctId.trim().isEmpty()) {
            System.out.println("Error: Doctor selection is empty");
            session.setAttribute("error-message", "Error: Doctor selection is required.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (gender == null || gender.trim().isEmpty()) {
            System.out.println("Error: Gender is empty");
            session.setAttribute("error-message", "Error: Gender is required.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (joindate == null || joindate.trim().isEmpty()) {
            System.out.println("Error: Admission date is empty");
            session.setAttribute("error-message", "Error: Admission date is required.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (age == null || age.trim().isEmpty()) {
            System.out.println("Error: Age is empty");
            session.setAttribute("error-message", "Error: Age is required.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (bgroup == null || bgroup.trim().isEmpty()) {
            System.out.println("Error: Blood group is empty");
            session.setAttribute("error-message", "Error: Blood group is required.");
            response.sendRedirect("patients.jsp");
            return;
        }

        // Verify doctor exists
        int doctorId = Integer.parseInt(doctId);
        PreparedStatement ps = con.prepareStatement("SELECT ID FROM doctor_info WHERE ID = ?");
        ps.setInt(1, doctorId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            System.out.println("Error: Doctor not found");
            session.setAttribute("error-message", "Error: Doctor not found.");
            response.sendRedirect("patients.jsp");
            rs.close();
            ps.close();
            return;
        }
        rs.close();
        ps.close();

        // Check if room and bed combination exists and is available (if changed)
        PreparedStatement psCheck = con.prepareStatement("SELECT room_no, bed_no FROM patient_info WHERE id = ?");
        psCheck.setInt(1, Integer.parseInt(pid));
        ResultSet rsCheck = psCheck.executeQuery();
        int currentRoomNo = 0, currentBedNo = 0;
        if (rsCheck.next()) {
            currentRoomNo = rsCheck.getInt("room_no");
            currentBedNo = rsCheck.getInt("bed_no");
        }
        rsCheck.close();
        psCheck.close();

        int newRoomNo = Integer.parseInt(roomNo);
        int newBedNo = Integer.parseInt(bedNo);
        if (newRoomNo != currentRoomNo || newBedNo != currentBedNo) {
            ps = con.prepareStatement("SELECT status FROM room_info WHERE room_no = ? AND bed_no = ?");
            ps.setInt(1, newRoomNo);
            ps.setInt(2, newBedNo);
            rs = ps.executeQuery();
            if (!rs.next()) {
                System.out.println("Error: Invalid Room or Bed");
                session.setAttribute("error-message", "Error: Invalid Room or Bed combination.");
                response.sendRedirect("patients.jsp");
                rs.close();
                ps.close();
                return;
            } else if (rs.getString("status").equals("busy")) {
                System.out.println("Error: Room and bed are already occupied");
                session.setAttribute("error-message", "Error: Selected room and bed are already occupied.");
                response.sendRedirect("patients.jsp");
                rs.close();
                ps.close();
                return;
            }
            rs.close();
            ps.close();
        }

        // Simulate password hashing (replace with bcrypt in production)
        String hashedPassword = pwd != null && !pwd.isEmpty() ? pwd : null;

        // Update patient
        ps = con.prepareStatement(
            "UPDATE patient_info SET PNAME = ?, GENDER = ?, AGE = ?, BGROUP = ?, PHONE = ?, STREET = ?, AREA = ?, CITY = ?, STATE = ?, PINCODE = ?, COUNTRY = ?, REA_OF_VISIT = ?, ROOM_NO = ?, BED_NO = ?, DOCTOR_ID = ?, DATE_AD = ?, EMAIL = ?, PASSWORD = ? WHERE ID = ?"
        );
        ps.setString(1, pname);
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
        ps.setInt(15, doctorId);
        ps.setString(16, joindate);
        ps.setString(17, email);
        ps.setString(18, hashedPassword);
        ps.setInt(19, Integer.parseInt(pid));

        int i = ps.executeUpdate();

        if (i > 0) {
            // Update room status if room/bed changed
            if (newRoomNo != currentRoomNo || newBedNo != currentBedNo) {
                // Mark new room/bed as busy
                ps = con.prepareStatement("UPDATE room_info SET status = ? WHERE room_no = ? AND bed_no = ?");
                ps.setString(1, "busy");
                ps.setInt(2, newRoomNo);
                ps.setInt(3, newBedNo);
                ps.executeUpdate();
                ps.close();

                // Mark old room/bed as available
                ps = con.prepareStatement("UPDATE room_info SET status = ? WHERE room_no = ? AND bed_no = ?");
                ps.setString(1, "available");
                ps.setInt(2, currentRoomNo);
                ps.setInt(3, currentBedNo);
                ps.executeUpdate();
                ps.close();
            }
%>
            <div style="text-align: center; margin-top: 25%;">
                <font color="green">
                    <script type="text/javascript">
                        function Redirect() {
                            window.location = "patients.jsp";
                        }
                        document.write("<h2>Patient Details Updated Successfully</h2><br><br>");
                        document.write("<h3>Redirecting to home page...</h3>");
                        setTimeout('Redirect()', 3000);
                    </script>
                </font>
            </div>
<%
        } else {
            session.setAttribute("error-message", "Error: Failed to update patient.");
            response.sendRedirect("patients.jsp");
        }

        ps.close();
        con.commit();
    } catch (SQLException e) {
        System.out.println("SQLException in edit_patient_validation.jsp: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("error-message", "Error: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    } catch (Exception e) {
        System.out.println("Unexpected error in edit_patient_validation.jsp: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("error-message", "Unexpected error: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    }
%>
</body>
</html>