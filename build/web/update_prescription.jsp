<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Update Prescription - Hospital Management System</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <style>
        .action-buttons { white-space: nowrap; }
        .form-group { margin-bottom: 15px; }
        .panel { margin-top: 20px; }
    </style>
</head>
<%@include file="header_doctor.jsp"%>
<body>
<div class="row">
    <%@include file="menu_doctor.jsp"%>
    <div class="col-md-10 maincontent">
        <div class="panel panel-default contentinside">
            <div class="panel-heading">Update Prescription</div>
            <div class="panel-body">
<%
    if (session.getAttribute("id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Connection con = null;
    PreparedStatement ps = null;
    try {
        String prescIdStr = request.getParameter("prescid");
        String medicine = request.getParameter("medicine");
        String dosage = request.getParameter("dosage");
        String duration = request.getParameter("duration");
        String notes = request.getParameter("notes");

        if (prescIdStr == null || !prescIdStr.matches("\\d+")) {
            throw new Exception("Invalid or missing prescription ID.");
        }
        if (medicine == null || medicine.trim().isEmpty() || dosage == null || dosage.trim().isEmpty() || duration == null || duration.trim().isEmpty()) {
            throw new Exception("Medicine, dosage, and duration are required.");
        }

        int prescId = Integer.parseInt(prescIdStr);

        con = (Connection) application.getAttribute("connection");
        con.setAutoCommit(false); // Start transaction

        ps = con.prepareStatement(
            "UPDATE prescription SET MEDICINE = ?, DOSAGE = ?, DURATION = ?, NOTES = ? WHERE PRESCRIPTION_ID = ?"
        );
        ps.setString(1, medicine);
        ps.setString(2, dosage);
        ps.setString(3, duration);
        ps.setString(4, notes != null ? notes : "");
        ps.setInt(5, prescId);

        int rowsAffected = ps.executeUpdate();
        if (rowsAffected > 0) {
            con.commit();
%>
                <div class="alert alert-success">
                    Prescription updated successfully!
                    <a href="my_patients.jsp" class="btn btn-primary btn-sm pull-right">Back to Patients</a>
                </div>
<%
        } else {
            throw new Exception("Prescription not found or failed to update.");
        }
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ignored) {}
        }
%>
                <div class="alert alert-danger">
                    Error: <%=e.getMessage()%>
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
</body>
</html>