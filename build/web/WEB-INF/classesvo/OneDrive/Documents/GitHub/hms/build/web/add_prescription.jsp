<%@page import="java.sql.*, java.util.Date"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Add Prescription - Hospital Management System</title>
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
            <div class="panel-heading">Add Prescription</div>
            <div class="panel-body">
<%
    if (session.getAttribute("id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    Connection con = null;
    PreparedStatement ps = null;
    try {
        // Validate parameters
        String caseIdStr = request.getParameter("caseid");
        String doctorIdStr = request.getParameter("doctorid");
        String medicine = request.getParameter("medicine");
        String dosage = request.getParameter("dosage");
        String duration = request.getParameter("duration");
        String notes = request.getParameter("notes");

        if (caseIdStr == null || !caseIdStr.matches("\\d+")) {
            throw new Exception("Invalid or missing case ID.");
        }
        if (doctorIdStr == null || !doctorIdStr.matches("\\d+")) {
            throw new Exception("Invalid or missing doctor ID.");
        }
        if (medicine == null || medicine.trim().isEmpty() || dosage == null || dosage.trim().isEmpty() || duration == null || duration.trim().isEmpty()) {
            throw new Exception("Medicine, dosage, and duration are required.");
        }

        int caseId = Integer.parseInt(caseIdStr);
        int doctorId = Integer.parseInt(doctorIdStr);

        // Get database connection
        con = (Connection) application.getAttribute("connection");
        con.setAutoCommit(false); // Start transaction

        // Insert prescription
        ps = con.prepareStatement(
            "INSERT INTO prescription (CASE_ID, DOCTOR_ID, MEDICINE, DOSAGE, DURATION, DATE_ISSUED, NOTES) VALUES (?, ?, ?, ?, ?, ?, ?)"
        );
        ps.setInt(1, caseId);
        ps.setInt(2, doctorId);
        ps.setString(3, medicine);
        ps.setString(4, dosage);
        ps.setString(5, duration);
        ps.setDate(6, new java.sql.Date(new Date().getTime()));
        ps.setString(7, notes != null ? notes : "");

        int rowsAffected = ps.executeUpdate();
        if (rowsAffected > 0) {
            con.commit();
%>
                <div class="alert alert-success">
                    Prescription added successfully!
                    <a href="my_patients.jsp" class="btn btn-primary btn-sm pull-right">Back to Patients</a>
                </div>
<%
        } else {
            throw new Exception("Failed to add prescription.");
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