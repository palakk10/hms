<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Delete Prescription - Hospital Management System</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <style>
        .action-buttons {
            white-space: nowrap;
        }
        .panel {
            margin-top: 20px;
        }
    </style>
</head>
<%@include file="header_doctor.jsp"%>
<body>
<div class="row">
    <%@include file="menu_doctor.jsp"%>
    <div class="col-md-10 maincontent">
        <div class="panel panel-default contentinside">
            <div class="panel-heading">Delete Prescription</div>
            <div class="panel-body">
<%
    Connection con = null;
    PreparedStatement ps = null;
    try {
        // Retrieve prescription ID
        int prescId = Integer.parseInt(request.getParameter("prescId"));
        
        // Get database connection
        con = (Connection)application.getAttribute("connection");
        con.setAutoCommit(false); // Start transaction
        
        // Prepare SQL statement
        ps = con.prepareStatement("DELETE FROM prescription WHERE PRESCRIPTION_ID = ?");
        ps.setInt(1, prescId);
        
        // Execute update
        int rowsAffected = ps.executeUpdate();
        if (rowsAffected > 0) {
            con.commit();
%>
                <div class="alert alert-success">
                    Prescription deleted successfully!
                    <a href="my_patients.jsp" class="btn btn-primary btn-sm pull-right">Back to Patients</a>
                </div>
<%
        } else {
            throw new Exception("Prescription not found.");
        }
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ignored) {}
        }
%>
                <div class="alert alert-danger">
                    Error: <%= e.getMessage() %>
                    <a href="my_patients.jsp" class="btn btn-primary btn-sm pull-right">Back to Patients</a>
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
<script src="js/bootstrap.min.js"></script>
</body>
</html>