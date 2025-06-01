```jsp
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Doctor Validation</title>
</head>
<body>
<%
    String doctid = request.getParameter("doctid");
    String doctname = request.getParameter("doctname");
    String email = request.getParameter("email");
    String pwd = request.getParameter("pwd");
    String street = request.getParameter("street");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String pincode = request.getParameter("pincode");
    String phone = request.getParameter("phone");
    String dept = request.getParameter("dept");

    System.out.println("Edit Doctor Parameters: doctid=" + doctid + ", doctname=" + doctname + 
                       ", email=" + email + ", pwd=[PROTECTED], street=" + street + 
                       ", area=" + area + ", city=" + city + ", state=" + state + 
                       ", pincode=" + pincode + ", phone=" + phone + ", dept=" + dept);

    Connection con = (Connection) application.getAttribute("connection");
    try {
        if (con == null) {
            System.out.println("Error: Database connection is null");
            session.setAttribute("error-message", "Error: Database connection is not established.");
            response.sendRedirect("doctor.jsp");
            return;
        }

        // Server-side validation
        if (doctid == null || doctid.trim().isEmpty() || !doctid.matches("\\d+")) {
            System.out.println("Error: Invalid Doctor ID");
            session.setAttribute("error-message", "Error: Invalid Doctor ID.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        if (doctname == null || doctname.trim().isEmpty()) {
            System.out.println("Error: Doctor name is empty");
            session.setAttribute("error-message", "Error: Doctor name cannot be empty.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            System.out.println("Error: Email is empty");
            session.setAttribute("error-message", "Error: Email cannot be empty.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        if (pwd == null || pwd.trim().length() < 8) {
            System.out.println("Error: Password less than 8 characters");
            session.setAttribute("error-message", "Error: Password must be at least 8 characters.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        if (street == null || street.trim().isEmpty()) {
            System.out.println("Error: Street is empty");
            session.setAttribute("error-message", "Error: Street cannot be empty.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        if (area == null || area.trim().isEmpty()) {
            System.out.println("Error: Area is empty");
            session.setAttribute("error-message", "Error: Area cannot be empty.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        if (city == null || city.trim().isEmpty()) {
            System.out.println("Error: City is empty");
            session.setAttribute("error-message", "Error: City cannot be empty.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        if (state == null || state.trim().isEmpty()) {
            System.out.println("Error: State is empty");
            session.setAttribute("error-message", "Error: State cannot be empty.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        if (pincode == null || !pincode.matches("\\d{6}")) {
            System.out.println("Error: Invalid pincode");
            session.setAttribute("error-message", "Error: Pincode must be exactly 6 digits.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        if (phone == null || !phone.matches("\\d{10}")) {
            System.out.println("Error: Invalid phone");
            session.setAttribute("error-message", "Error: Phone must be exactly 10 digits.");
            response.sendRedirect("doctor.jsp");
            return;
        }

        // Get DEPT_ID from department name
        PreparedStatement psDept = con.prepareStatement("SELECT ID FROM department WHERE NAME = ?");
        psDept.setString(1, dept);
        ResultSet rsDept = psDept.executeQuery();
        int deptId = 0;
        if (rsDept.next()) {
            deptId = rsDept.getInt("ID");
            System.out.println("Found DEPT_ID: " + deptId + " for dept: " + dept);
        } else {
            System.out.println("Error: Department '" + dept + "' not found");
            session.setAttribute("error-message", "Error: Department '" + dept + "' not found.");
            response.sendRedirect("doctor.jsp");
            return;
        }
        rsDept.close();
        psDept.close();

        // Simulate password hashing (replace with bcrypt in production)
        String hashedPwd = pwd != null && !pwd.isEmpty() ? pwd : null;
        System.out.println("Hashed password: " + (hashedPwd != null ? "[PROTECTED]" : "null"));

        // Update doctor_info
        PreparedStatement ps = con.prepareStatement(
            "UPDATE doctor_info SET NAME = ?, EMAIL = ?, PASSWORD = ?, STREET = ?, AREA = ?, CITY = ?, STATE = ?, PINCODE = ?, PHONE = ?, DEPT_ID = ?, COUNTRY = NULL WHERE ID = ?"
        );
        ps.setString(1, doctname);
        ps.setString(2, email);
        ps.setString(3, hashedPwd);
        ps.setString(4, street);
        ps.setString(5, area);
        ps.setString(6, city);
        ps.setString(7, state);
        ps.setString(8, pincode);
        ps.setString(9, phone);
        ps.setInt(10, deptId);
        ps.setString(11, doctid);

        int i = ps.executeUpdate();
        System.out.println("Update result: " + i + " rows affected");

        if (i > 0) {
            session.setAttribute("success-message", "Doctor updated successfully!");
        } else {
            session.setAttribute("error-message", "Error: Failed to update doctor!");
        }
        response.sendRedirect("doctor.jsp");
    } catch (SQLException e) {
        System.out.println("SQLException in edit_doct_validation.jsp: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("error-message", "Error: " + e.getMessage());
        response.sendRedirect("doctor.jsp");
    } catch (Exception e) {
        System.out.println("Unexpected error in edit_doct_validation.jsp: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("error-message", "Unexpected error: " + e.getMessage());
        response.sendRedirect("doctor.jsp");
    } finally {
        try {
            if (con != null) con.commit();
        } catch (SQLException e) {
            System.out.println("Error committing transaction: " + e.getMessage());
            e.printStackTrace();
        }
    }
%>
</body>
</html>
```