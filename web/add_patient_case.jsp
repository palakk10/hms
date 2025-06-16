<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu.jsp"%>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Add Patient Case</div>
                <div class="panel-body">
                    <%
                        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                        String email = (String) session.getAttribute("email");
                        String name = (String) session.getAttribute("name");
                        if (email == null || name == null) {
                            out.println("<div class='alert alert-danger'>Please log in to continue.</div>");
                            response.sendRedirect("index.jsp");
                            return;
                        }
                        Connection conn = (Connection) application.getAttribute("connection");
                        String patientId = request.getParameter("patient_id");
                        String caseDate = request.getParameter("case_date");
                        String reason = request.getParameter("reason");
                        String doctorId = request.getParameter("doctor_id");
                        String conditionDetails = request.getParameter("condition_details");

                        System.out.println("add_patient_case.jsp - Parameters: patientId=[" + patientId + "], doctorId=[" + doctorId + "], caseDate=[" + caseDate + "], reason=[" + reason + "]");

                        String errorMessage = "";
                        String successMessage = "";
                        String redirectPatientId = (patientId != null && !patientId.equals("null") && !patientId.trim().isEmpty() ? patientId : "");

                        if (conn == null || conn.isClosed()) {
                            errorMessage = "Database connection unavailable.";
                        } else if (patientId == null || patientId.equals("null") || patientId.trim().isEmpty()) {
                            errorMessage = "Patient ID is missing or invalid.";
                        } else {
                            int patientIdInt;
                            try {
                                patientIdInt = Integer.parseInt(patientId);
                                if (patientIdInt <= 0) {
                                    errorMessage = "Patient ID must be a positive number.";
                                }
                            } catch (NumberFormatException e) {
                                errorMessage = "Patient ID is not a valid number: " + patientId;
                            }
                            if (errorMessage.isEmpty()) {
                                if (doctorId == null || doctorId.trim().isEmpty() || doctorId.equals("null")) {
                                    errorMessage = "Doctor ID is missing or invalid.";
                                } else {
                                    int doctorIdInt;
                                    try {
                                        doctorIdInt = Integer.parseInt(doctorId);
                                        if (doctorIdInt <= 0) {
                                            errorMessage = "Doctor ID must be a positive number.";
                                        }
                                    } catch (NumberFormatException e) {
                                        errorMessage = "Doctor ID is not a valid number: " + doctorId;
                                    }
                                }
                                if (caseDate == null || caseDate.trim().isEmpty()) {
                                    errorMessage = "Case date is required.";
                                }
                                if (reason == null || reason.trim().isEmpty() || reason.equals("null")) {
                                    errorMessage = "Reason is required.";
                                }
                                if (errorMessage.isEmpty()) {
                                    PreparedStatement ps = null;
                                    try {
                                        ps = conn.prepareStatement(
                                            "INSERT INTO case_master (PATIENT_ID, CASE_DATE, REASON, DOCTOR_ID, CONDITION_DETAILS) VALUES (?, ?, ?, ?, ?)"
                                        );
                                        ps.setInt(1, Integer.parseInt(patientId));
                                        ps.setDate(2, java.sql.Date.valueOf(caseDate));
                                        ps.setString(3, reason);
                                        ps.setInt(4, Integer.parseInt(doctorId));
                                        ps.setString(5, conditionDetails != null && !conditionDetails.trim().isEmpty() ? conditionDetails : null);
                                        int rows = ps.executeUpdate();
                                        if (rows > 0) {
                                            successMessage = "Case added successfully.";
                                        } else {
                                            errorMessage = "Failed to add case.";
                                        }
                                    } catch (SQLException e) {
                                        errorMessage = "Database Error: " + e.getMessage();
                                    } finally {
                                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                    }
                                }
                            }
                        }
                        if (!successMessage.isEmpty()) {
                    %>
                    <div class="alert alert-success text-center">
                        <h2><%=successMessage%></h2>
                        <h3>Redirecting to patient cases...</h3>
                        <script>
                            setTimeout(function() { window.location="patient_view_cases.jsp?patient_id=<%=redirectPatientId%>"; }, 3000);
                        </script>
                    </div>
                    <%
                        } else if (!errorMessage.isEmpty()) {
                    %>
                    <div class="alert alert-danger text-center">
                        <h2>Error: <%=errorMessage%></h2>
                        <h3>Redirecting back...</h3>
                        <script>
                            setTimeout(function() { window.location="patient_view_cases.jsp?patient_id=<%=redirectPatientId%>"; }, 3000);
                        </script>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>