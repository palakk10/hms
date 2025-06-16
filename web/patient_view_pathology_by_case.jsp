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
    <title>View Pathology by Case</title>
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
        .btn-primary, .btn-default, .btn-success, .btn-warning, .btn-info { 
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
        .total-charges {
            margin-top: 20px;
            font-weight: bold;
        }
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
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><%= namee.toUpperCase() %> <span class="caret"></span></a>
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
             
            <%@include file="menu.jsp" %>
            <div class="col-md-10 content">
                <div class="panel panel-default">
                    <div class="panel-heading logintitle">Pathology Records for Case</div>
                    <div class="panel-body">
                        <%
                            Connection conn = (Connection) application.getAttribute("connection");
                            String patientId = request.getParameter("patient_id");
                            String caseId = request.getParameter("case_id");
                            if (conn == null || patientId == null || caseId == null || patientId.trim().isEmpty() || caseId.trim().isEmpty()) {
                                out.println("<div class='alert alert-danger'>Error: Invalid request or database connection.</div>");
                                return;
                            }
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            PreparedStatement psPrice = null;
                            ResultSet rsPrice = null;
                            double totalCharges = 0.0;
                            try {
                                ps = conn.prepareStatement(
                                    "SELECT p.PATHOLOGY_ID, p.TEST_ID, pt.NAME AS TEST_NAME, p.TEST_DATE, " +
                                    "p.B_TEST, p.BT_COUNT, p.URINALYSIS, p.URINALYSIS_COUNT, " +
                                    "p.LIVER_FUNCTION_TESTS, p.LIVER_FUNCTION_TESTS_COUNT, " +
                                    "p.LIPID_PROFILES, p.LIPID_PROFILES_COUNT, " +
                                    "p.THYROID_FUNCTION_TESTS, p.THYROID_FUNCTION_TESTS_COUNT, " +
                                    "p.KIDNEY_FUNCTION_TESTS, p.KIDNEY_FUNCTION_TESTS_COUNT " +
                                    "FROM pathology p " +
                                    "JOIN pathology_test pt ON p.TEST_ID = pt.TEST_ID " +
                                    "WHERE p.ID = ? AND p.CASE_ID = ? " +
                                    "ORDER BY p.TEST_DATE DESC"
                                );
                                ps.setInt(1, Integer.parseInt(patientId));
                                ps.setInt(2, Integer.parseInt(caseId));
                                rs = ps.executeQuery();
                        %>
                        <table class="table table-bordered table-striped">
                            <thead>
                                <tr>
                                    <th>Pathology ID</th>
                                    <th>Test Name</th>
                                    <th>Test Date</th>
                                    <th>Blood Test</th>
                                    <th>Blood Count</th>
                                    <th>Urinalysis</th>
                                    <th>Urinalysis Count</th>
                                    <th>Liver Function</th>
                                    <th>Liver Count</th>
                                    <th>Lipid Profiles</th>
                                    <th>Lipid Count</th>
                                    <th>Thyroid Function</th>
                                    <th>Thyroid Count</th>
                                    <th>Kidney Function</th>
                                    <th>Kidney Count</th>
                                    <th>Charges (?)</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (!rs.isBeforeFirst()) {
                                        out.println("<tr><td colspan='16'>No pathology records found for this case.</td></tr>");
                                    } else {
                                        while (rs.next()) {
                                            int testId = rs.getInt("TEST_ID");
                                            double recordCharges = 0.0;
                                            try {
                                                psPrice = conn.prepareStatement("SELECT PRICE FROM pathology_test WHERE TEST_ID = ?");
                                                psPrice.setInt(1, testId);
                                                rsPrice = psPrice.executeQuery();
                                                if (rsPrice.next()) {
                                                    double price = rsPrice.getDouble("PRICE");
                                                    if ("Positive".equals(rs.getString("B_TEST")) ||
                                                        "Positive".equals(rs.getString("URINALYSIS")) ||
                                                        "Positive".equals(rs.getString("LIVER_FUNCTION_TESTS")) ||
                                                        "Positive".equals(rs.getString("LIPID_PROFILES")) ||
                                                        "Positive".equals(rs.getString("THYROID_FUNCTION_TESTS")) ||
                                                        "Positive".equals(rs.getString("KIDNEY_FUNCTION_TESTS"))) {
                                                        recordCharges = price;
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                out.println("<div class='alert alert-warning'>Error fetching price: " + e.getMessage() + "</div>");
                                                recordCharges = 0.0;
                                            } finally {
                                                if (rsPrice != null) try { rsPrice.close(); } catch (SQLException e) {}
                                                if (psPrice != null) try { psPrice.close(); } catch (SQLException e) {}
                                            }
                                            totalCharges += recordCharges;
                                            out.println("<tr>");
                                            out.println("<td>" + rs.getInt("PATHOLOGY_ID") + "</td>");
                                            out.println("<td>" + rs.getString("TEST_NAME") + "</td>");
                                            out.println("<td>" + rs.getDate("TEST_DATE") + "</td>");
                                            out.println("<td>" + (rs.getString("B_TEST") != null ? rs.getString("B_TEST") : "-") + "</td>");
                                            out.println("<td>" + rs.getInt("BT_COUNT") + "</td>");
                                            out.println("<td>" + (rs.getString("URINALYSIS") != null ? rs.getString("URINALYSIS") : "-") + "</td>");
                                            out.println("<td>" + rs.getInt("URINALYSIS_COUNT") + "</td>");
                                            out.println("<td>" + (rs.getString("LIVER_FUNCTION_TESTS") != null ? rs.getString("LIVER_FUNCTION_TESTS") : "-") + "</td>");
                                            out.println("<td>" + rs.getInt("LIVER_FUNCTION_TESTS_COUNT") + "</td>");
                                            out.println("<td>" + (rs.getString("LIPID_PROFILES") != null ? rs.getString("LIPID_PROFILES") : "-") + "</td>");
                                            out.println("<td>" + rs.getInt("LIPID_PROFILES_COUNT") + "</td>");
                                            out.println("<td>" + (rs.getString("THYROID_FUNCTION_TESTS") != null ? rs.getString("THYROID_FUNCTION_TESTS") : "-") + "</td>");
                                            out.println("<td>" + rs.getInt("THYROID_FUNCTION_TESTS_COUNT") + "</td>");
                                            out.println("<td>" + (rs.getString("KIDNEY_FUNCTION_TESTS") != null ? rs.getString("KIDNEY_FUNCTION_TESTS") : "-") + "</td>");
                                            out.println("<td>" + rs.getInt("KIDNEY_FUNCTION_TESTS_COUNT") + "</td>");
                                            out.println("<td>" + String.format("%.2f", recordCharges) + "</td>");
                                            out.println("</tr>");
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                        <div class="total-charges">
                            Total Charges: <%= String.format("%.2f", totalCharges) %>
                        </div>
                        <a href="patient_view_cases.jsp?patient_id=<%= patientId %>" class="btn btn-default">Back to Cases</a>
                        <%
                            } catch (SQLException e) {
                                out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                            } catch (NumberFormatException e) {
                                out.println("<div class='alert alert-danger'>Error: Invalid patient or case ID.</div>");
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