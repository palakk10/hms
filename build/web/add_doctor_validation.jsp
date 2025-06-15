<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add Doctor - Hospital Management System</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <style>
        .action-buttons { white-space: nowrap; }
        .form-group { margin-bottom: 15px; }
        .panel { margin-top: 20px; }
    </style>
</head>
<body>
<div class="row">
    <div class="col-md-12 maincontent">
        <div class="panel panel-default contentinside">
            <div class="panel-heading">Add Doctor</div>
            <div class="panel-body">
<%
    // Assuming admin session validation
    if (session.getAttribute("admin_id") == null) { // Adjust "admin_id" based on your login mechanism
        response.sendRedirect("admin_login.jsp"); // Adjust redirect to your admin login page
        return;
    }
    Connection con = null;
    PreparedStatement ps = null;
    try {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String dept = request.getParameter("dept");
        String status = request.getParameter("status");
        String qual = request.getParameter("qual");
        String exp = request.getParameter("exp");
        String fees = request.getParameter("fees");

        // Validate inputs
        if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() || phone == null || phone.trim().isEmpty() ||
            dept == null || dept.trim().isEmpty() || status == null || status.trim().isEmpty() ||
            qual == null || qual.trim().isEmpty() || exp == null || !exp.matches("\\d+") ||
            fees == null || !fees.matches("\\d+")) {
            throw new Exception("All fields are required and must be valid.");
        }

        int experience = Integer.parseInt(exp);
        int consultationFees = Integer.parseInt(fees);

        con = (Connection) application.getAttribute("connection");
        con.setAutoCommit(false); // Start transaction

        ps = con.prepareStatement(
            "INSERT INTO doctor_info (NAME, EMAIL, PASSWORD, PHONE, DEPT, STATUS, QUAL, EXP, FEES) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
        );
        ps.setString(1, name);
        ps.setString(2, email);
        ps.setString(3, password);
        ps.setString(4, phone);
        ps.setString(5, dept);
        ps.setString(6, status);
        ps.setString(7, qual);
        ps.setInt(8, experience);
        ps.setInt(9, consultationFees);

        int rowsAffected = ps.executeUpdate();
        if (rowsAffected > 0) {
            con.commit();
%>
                <div class="alert alert-success">
                    Doctor added successfully!
                    <a href="manage_doctors.jsp" class="btn btn-primary btn-sm pull-right">Back to Manage Doctors</a>
                </div>
<%
        } else {
            throw new Exception("Failed to add doctor.");
        }
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ignored) {}
        }
%>
                <div class="alert alert-danger">
                    Error: <%=e.getMessage()%>
                    <a href="manage_doctors.jsp" class="btn btn-primary btn-sm pull-right">Back to Manage Doctors</a>
                </div>
<%
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
        if (con != null) try { con.setAutoCommit(true); } catch (SQLException ignored) {}
    }
%>
            </div>
        </div>
    </div>
</div>
</body>
</html>