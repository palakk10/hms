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
    <title>My Pathology Info</title>
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
        .modal { z-index: 1050 !important; }
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
                    <div class="panel-heading logintitle">Pathology List</div>
                    <div class="panel-body">
                        <%
                            String status = request.getParameter("status");
                            if ("success".equals(status)) {
                                out.println("<div class='alert alert-success'>Pathology record added successfully!</div>");
                            } else if ("error".equals(status)) {
                                out.println("<div class='alert alert-danger'>Error adding pathology record.</div>");
                            }
                        %>
                        <div class="row">
                            <div class="col-md-2">
                                <button class="btn btn-primary btn-block btn-lg" data-toggle="modal" data-target="#addPathologyModal">Add Pathology</button>
                            </div>
                        </div>
                        <br>
                        <table class="table table-bordered table-striped">
                            <thead>
                                <tr>
                                    <th>Pathology ID</th>
                                    <th>Patient ID</th>
                                    <th>Patient Name</th>
                                    <th>Case ID</th>
                                    <th>Test Name</th>
                                    <th>Test Date</th>
                                    <th>Blood Test</th>
                                    <th>Blood Test Count</th>
                                    <th>Urinalysis</th>
                                    <th>Urinalysis Count</th>
                                    <th>Liver Tests</th>
                                    <th>Liver Tests Count</th>
                                    <th>Lipid Profiles</th>
                                    <th>Lipid Profiles Count</th>
                                    <th>Thyroid Tests</th>
                                    <th>Thyroid Tests Count</th>
                                    <th>Kidney Tests</th>
                                    <th>Kidney Tests Count</th>
                                    <th>Charges</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    Connection conn = (Connection) application.getAttribute("connection");
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;
                                    double totalCharges = 0.0;
                                    try {
                                        ps = conn.prepareStatement(
                                            "SELECT p.PATHOLOGY_ID, p.ID, pi.PNAME, p.CASE_ID, pt.NAME AS TEST_NAME, p.TEST_DATE, " +
                                            "p.B_TEST, p.BT_COUNT, p.URINALYSIS, p.URINALYSIS_COUNT, p.LIVER_FUNCTION_TESTS, " +
                                            "p.LIVER_FUNCTION_TESTS_COUNT, p.LIPID_PROFILES, p.LIPID_PROFILES_COUNT, " +
                                            "p.THYROID_FUNCTION_TESTS, p.THYROID_FUNCTION_TESTS_COUNT, p.KIDNEY_FUNCTION_TESTS, " +
                                            "p.KIDNEY_FUNCTION_TESTS_COUNT, pt.PRICE " +
                                            "FROM pathology p " +
                                            "JOIN patient_info pi ON p.ID = pi.ID " +
                                            "JOIN pathology_test pt ON p.TEST_ID = pt.TEST_ID " +
                                            "ORDER BY p.TEST_DATE DESC"
                                        );
                                        rs = ps.executeQuery();
                                        if (!rs.isBeforeFirst()) {
                                            out.println("<tr><td colspan='19'>No pathology records found.</td></tr>");
                                        } else {
                                            while (rs.next()) {
                                                double charges = rs.getDouble("PRICE");
                                                totalCharges += charges;
                                                out.println("<tr>");
                                                out.println("<td>" + rs.getInt("PATHOLOGY_ID") + "</td>");
                                                out.println("<td>" + rs.getInt("ID") + "</td>");
                                                out.println("<td>" + rs.getString("PNAME") + "</td>");
                                                out.println("<td>" + rs.getInt("CASE_ID") + "</td>");
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
                                                out.println("<td>" + String.format("%.2f", charges) + "</td>");
                                                out.println("</tr>");
                                            }
                                        }
                                    } catch (SQLException e) {
                                        out.println("<tr><td colspan='19'>Error: " + e.getMessage() + "</td></tr>");
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                    }
                                %>
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="18" style="text-align: right;"><strong>Total Charges:</strong></td>
                                    <td><%= String.format("%.2f", totalCharges) %></td>
                                </tr>
                            </tfoot>
                        </table>
                        <a href="receptionist.jsp" class="btn btn-default">Back to Dashboard</a>
                    </div>
                </div>
            </div>
        </div>
        <!-- Add Pathology Modal -->
        <div class="modal fade" id="addPathologyModal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title">Add Pathology Record</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="add_pathology.jsp" method="post">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="patient_id" class="form-control" placeholder="Patient ID" required min="1">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="case_id" class="form-control" placeholder="Case ID" required min="1">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Test</label>
                                <div class="col-sm-9">
                                    <select name="test_id" class="form-control" required>
                                        <%
                                            PreparedStatement psTests = null;
                                            ResultSet rsTests = null;
                                            try {
                                                psTests = conn.prepareStatement("SELECT TEST_ID, NAME FROM pathology_test");
                                                rsTests = psTests.executeQuery();
                                                if (!rsTests.isBeforeFirst()) {
                                                    out.println("<option value=\"\">No tests available</option>");
                                                } else {
                                                    while (rsTests.next()) {
                                                        out.println("<option value=\"" + rsTests.getInt("TEST_ID") + "\">" + rsTests.getString("NAME") + "</option>");
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error: " + e.getMessage() + "</option>");
                                            } finally {
                                                if (rsTests != null) try { rsTests.close(); } catch (SQLException e) {}
                                                if (psTests != null) try { psTests.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Test Date</label>
                                <div class="col-sm-9">
                                    <input type="date" name="test_date" class="form-control" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Blood Test Result</label>
                                <div class="col-sm-9">
                                    <select name="b_test" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Blood Test Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="bt_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Urinalysis Result</label>
                                <div class="col-sm-9">
                                    <select name="urinalysis" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Urinalysis Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="urinalysis_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Liver Function Tests Result</label>
                                <div class="col-sm-9">
                                    <select name="liver_function_tests" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Liver Function Tests Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="liver_function_tests_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Lipid Profiles Result</label>
                                <div class="col-sm-9">
                                    <select name="lipid_profiles" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Lipid Profiles Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="lipid_profiles_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Thyroid Function Tests Result</label>
                                <div class="col-sm-9">
                                    <select name="thyroid_function_tests" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Thyroid Function Tests Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="thyroid_function_tests_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Kidney Function Tests Result</label>
                                <div class="col-sm-9">
                                    <select name="kidney_function_tests" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Kidney Function Tests Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="kidney_function_tests_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-9">
                                    <button type="submit" class="btn btn-primary">Add Pathology</button>
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
```