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
    String city = request.getParameter("city");
    String pincode = request.getParameter("pincode");
    String phone = request.getParameter("phone");
    String dept = request.getParameter("dept");

    System.out.println("Edit Doctor Parameters: doctid=" + doctid + ", doctname=" + doctname + 
                       ", email=" + email + ", pwd=[PROTECTED], city=" + city + 
                       ", pincode=" + pincode + ", phone=" + phone + ", dept=" + dept);

    Connection con = (Connection) application.getAttribute("connection");
    try {
        if (con == null) {
            System.out.println("Error: Database connection is null");
            session.setAttribute("error-message", "Error: Database connection is not established.");
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

        // Simulate password hashing (replace with bcrypt in production)
        String hashedPwd = pwd != null && !pwd.isEmpty() ? pwd : null; // TODO: Use bcrypt
        System.out.println("Hashed password: " + (hashedPwd != null ? "[PROTECTED]" : "null"));

        // Update doctor_info
        PreparedStatement ps = con.prepareStatement(
            "UPDATE doctor_info SET NAME = ?, EMAIL = ?, PASSWORD = ?, CITY = ?, PINCODE = ?, PHONE = ?, DEPT_ID = ?, STREET = NULL, AREA = NULL, STATE = NULL, COUNTRY = NULL WHERE ID = ?"
        );
        ps.setString(1, doctname);
        ps.setString(2, email);
        ps.setString(3, hashedPwd);
        ps.setString(4, city);
        ps.setString(5, pincode);
        ps.setString(6, phone);
        ps.setInt(7, deptId);
        ps.setString(8, doctid);

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