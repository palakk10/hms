```jsp
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<%
    response.setHeader("cache-control", "no-cache, no-store, must-revalidate");
    String emaill = (String) session.getAttribute("email");
    String namee = (String) session.getAttribute("name");
    if (emaill == null || namee == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="images/logo.png" rel="icon"/>
    <title>View Patient Cases</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/bootstrap-theme.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <style>
        body { padding-top: 60px; }
        .header { 
            display: block !important; 
            visibility: visible !important; 
            position: fixed !important; 
            top: 0; 
            width: 100%; 
            z-index: 1000 !important; 
            background-color: #fff; 
            border-bottom: 1px solid #ddd;
        }
        .btn-primary, .btn-default { 
            display: inline-block !important; 
            visibility: visible !important; 
            margin: 2px; 
        }
        .table { display: table !important; visibility: visible !important; }
        .sidebar { 
            position: static; 
            width: 16.66%; 
            float: left; 
            margin-top: 60px; 
        }
        .content { 
            margin-left: 16.66%; 
            float: left; 
            padding: 20px; 
        }
        .panel { position: relative !important; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Header Start -->
        <div class="row header">
            <div class="col-md-10">
                <h2>Hospital Management System</h2>
            </div>
            <div class="col-md-2">
                <ul class="nav nav-pills">
                    <li class="dropdown dmenu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><%=namee.toUpperCase()%> <span class="caret"></span></a>
                        <ul class="dropdown-menu">
                            <li><a href="profile_receptionist.jsp">Change Profile</a></li>
                            <li role="separator" class="divider"></li>
                            <li><a href="logout.jsp">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
        <!-- Header Ends -->
        <div class="row">
            <%@include file="receptionist_menu.jsp" %>
            <div class="col-md-10 content">
                <div class="panel panel-default">
                    <div class="panel-heading logintitle">Patient Case History</div>
                    <div class="panel-body">
                        <%
                            Connection c = (Connection) application.getAttribute("connection");
                            String patientId = request.getParameter("patient_id");
                            if (c == null || patientId == null || patientId.trim().isEmpty()) {
                                out.println("<div class='alert alert-danger'>Error: Invalid request or database connection.</div>");
                                return;
                            }

                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            try {
                                ps = c.prepareStatement(
                                    "SELECT c.CASE_ID, c.CASE_DATE, c.REASON, c.CONDITION_DETAILS, d.NAME AS DOCTOR_NAME " +
                                    "FROM case_master c " +
                                    "JOIN doctor_info d ON c.DOCTOR_ID = d.ID " +
                                    "WHERE c.PATIENT_ID = ? ORDER BY c.CASE_DATE DESC"
                                );
                                ps.setInt(1, Integer.parseInt(patientId));
                                rs = ps.executeQuery();
                        %>
                        <table class="table table-bordered table-striped">
                            <thead>
                                <tr>
                                    <th>Case ID</th>
                                    <th>Date</th>
                                    <th>Reason</th>
                                    <th>Condition Details</th>
                                    <th>Doctor</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (!rs.isBeforeFirst()) {
                                        out.println("<tr><td colspan='5'>No cases found for this patient.</td></tr>");
                                    } else {
                                        while (rs.next()) {
                                            out.println("<tr>");
                                            out.println("<td>" + rs.getInt("CASE_ID") + "</td>");
                                            out.println("<td>" + rs.getDate("CASE_DATE") + "</td>");
                                            out.println("<td>" + rs.getString("REASON") + "</td>");
                                            out.println("<td>" + (rs.getString("CONDITION_DETAILS") != null ? rs.getString("CONDITION_DETAILS") : "-") + "</td>");
                                            out.println("<td>" + rs.getString("DOCTOR_NAME") + "</td>");
                                            out.println("</tr>");
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                        <a href="receptionist.jsp" class="btn btn-default">Back to Dashboard</a>
                        <%
                            } catch (SQLException e) {
                                out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                            } catch (NumberFormatException e) {
                                out.println("<div class='alert alert-danger'>Error: Invalid patient ID.</div>");
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
```