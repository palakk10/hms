```jsp
<%@page import="java.sql.*, java.text.SimpleDateFormat"%>
<!DOCTYPE html>
<html lang="en">
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    String email = (String) session.getAttribute("email");
    String name = (String) session.getAttribute("name");
    if (email == null || name == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    String patientId = request.getParameter("patientId");
    String caseId = request.getParameter("caseId");
    if (patientId == null || caseId == null) {
        response.sendRedirect("patients.jsp");
        return;
    }
%>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="images/logo.png" rel="icon"/>
    <title>Edit Pathology</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <style>
        body {
            padding-top: 50px;
            background: url('https://via.placeholder.com/1920x1080?text=Hospital+Background') no-repeat center center fixed;
            background-size: cover;
            position: relative;
        }
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(255, 255, 255, 0.7);
            z-index: -1;
        }
        .navbar-custom {
            position: fixed;
            top: 0;
            width: 100%;
            z-index: 1000;
            background-color: #337ab7;
            border-color: #2e6da4;
        }
        .navbar-custom .navbar-brand,
        .navbar-custom .navbar-nav > li > a {
            color: #fff;
        }
        .navbar-custom .navbar-nav > li > a:hover,
        .navbar-custom .navbar-nav > li > a:focus {
            background-color: #2e6da4;
        }
        .maincontent {
            margin-left: 16.66%;
            padding: 20px;
            background: rgba(255, 255, 255, 0.9);
            border-radius: 5px;
        }
        .panel-heading {
            background-color: #337ab7 !important;
            color: #fff !important;
            font-size: 18px;
        }
        .alert {
            margin-bottom: 20px;
        }
        @media (max-width: 767px) {
            .maincontent {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-custom navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbarCollapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="#">Hospital Management System</a>
            </div>
            <div class="collapse navbar-collapse" id="navbarCollapse">
                <ul class="nav navbar-nav navbar-right">
                    <li class="dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button"><%=name.toUpperCase()%> <span class="caret"></span></a>
                        <ul class="dropdown-menu">
                            <li><a href="profile.jsp">Change Profile</a></li>
                            <li role="separator" class="divider"></li>
                            <li><a href="logout.jsp">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    <div class="container-fluid">
        <div class="row">
            <%@include file="menu.jsp" %>
            <div class="col-md-10 maincontent">
                <div class="panel panel-default">
                    <div class="panel-heading">Edit Pathology Report</div>
                    <div class="panel-body">
                        <%
                            Connection conn = (Connection) application.getAttribute("connection");
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            try {
                                ps = conn.prepareStatement(
                                    "SELECT p.PATHOLOGY_ID, p.TEST_ID, p.TEST_DATE, p.B_TEST, p.BT_COUNT, p.URINALYSIS, p.URINALYSIS_COUNT, " +
                                    "p.LIVER_FUNCTION_TESTS, p.LIVER_FUNCTION_TESTS_COUNT, p.LIPID_PROFILES, p.LIPID_PROFILES_COUNT, " +
                                    "p.THYROID_FUNCTION_TESTS, p.THYROID_FUNCTION_TESTS_COUNT, p.KIDNEY_FUNCTION_TESTS, p.KIDNEY_FUNCTION_TESTS_COUNT " +
                                    "FROM pathology p WHERE p.CASE_ID = ? AND p.ID = ?"
                                );
                                ps.setInt(1, Integer.parseInt(caseId));
                                ps.setInt(2, Integer.parseInt(patientId));
                                rs = ps.executeQuery();
                                if (rs.next()) {
                                    int pathologyId = rs.getInt("PATHOLOGY_ID");
                                    int testId = rs.getInt("TEST_ID");
                                    String testDate = rs.getString("TEST_DATE");
                                    String bTest = rs.getString("B_TEST");
                                    int btCount = rs.getInt("BT_COUNT");
                                    String urinalysis = rs.getString("URINALYSIS");
                                    int urinalysisCount = rs.getInt("URINALYSIS_COUNT");
                                    String liverFunctionTests = rs.getString("LIVER_FUNCTION_TESTS");
                                    int liverFunctionTestsCount = rs.getInt("LIVER_FUNCTION_TESTS_COUNT");
                                    String lipidProfiles = rs.getString("LIPID_PROFILES");
                                    int lipidProfilesCount = rs.getInt("LIPID_PROFILES_COUNT");
                                    String thyroidFunctionTests = rs.getString("THYROID_FUNCTION_TESTS");
                                    int thyroidFunctionTestsCount = rs.getInt("THYROID_FUNCTION_TESTS_COUNT");
                                    String kidneyFunctionTests = rs.getString("KIDNEY_FUNCTION_TESTS");
                                    int kidneyFunctionTestsCount = rs.getInt("KIDNEY_FUNCTION_TESTS_COUNT");
                                    if ("POST".equalsIgnoreCase(request.getMethod())) {
                                        String newTestId = request.getParameter("test_id");
                                        String newTestDate = request.getParameter("test_date");
                                        String newBTest = request.getParameter("b_test");
                                        String newBtCount = request.getParameter("bt_count");
                                        String newUrinalysis = request.getParameter("urinalysis");
                                        String newUrinalysisCount = request.getParameter("urinalysis_count");
                                        String newLiverFunctionTests = request.getParameter("liver_function_tests");
                                        String newLiverFunctionTestsCount = request.getParameter("liver_function_tests_count");
                                        String newLipidProfiles = request.getParameter("lipid_profiles");
                                        String newLipidProfilesCount = request.getParameter("lipid_profiles_count");
                                        String newThyroidFunctionTests = request.getParameter("thyroid_function_tests");
                                        String newThyroidFunctionTestsCount = request.getParameter("thyroid_function_tests_count");
                                        String newKidneyFunctionTests = request.getParameter("kidney_function_tests");
                                        String newKidneyFunctionTestsCount = request.getParameter("kidney_function_tests_count");
                                        PreparedStatement psUpdate = null;
                                        try {
                                            conn.setAutoCommit(false);
                                            psUpdate = conn.prepareStatement(
                                                "UPDATE pathology SET TEST_ID = ?, TEST_DATE = ?, B_TEST = ?, BT_COUNT = ?, " +
                                                "URINALYSIS = ?, URINALYSIS_COUNT = ?, LIVER_FUNCTION_TESTS = ?, LIVER_FUNCTION_TESTS_COUNT = ?, " +
                                                "LIPID_PROFILES = ?, LIPID_PROFILES_COUNT = ?, THYROID_FUNCTION_TESTS = ?, THYROID_FUNCTION_TESTS_COUNT = ?, " +
                                                "KIDNEY_FUNCTION_TESTS = ?, KIDNEY_FUNCTION_TESTS_COUNT = ? WHERE PATHOLOGY_ID = ?"
                                            );
                                            psUpdate.setInt(1, Integer.parseInt(newTestId));
                                            psUpdate.setDate(2, java.sql.Date.valueOf(newTestDate));
                                            psUpdate.setString(3, newBTest != null && !newBTest.isEmpty() ? newBTest : null);
                                            psUpdate.setInt(4, Integer.parseInt(newBtCount));
                                            psUpdate.setString(5, newUrinalysis != null && !newUrinalysis.isEmpty() ? newUrinalysis : null);
                                            psUpdate.setInt(6, Integer.parseInt(newUrinalysisCount));
                                            psUpdate.setString(7, newLiverFunctionTests != null && !newLiverFunctionTests.isEmpty() ? newLiverFunctionTests : null);
                                            psUpdate.setInt(8, Integer.parseInt(newLiverFunctionTestsCount));
                                            psUpdate.setString(9, newLipidProfiles != null && !newLipidProfiles.isEmpty() ? newLipidProfiles : null);
                                            psUpdate.setInt(10, Integer.parseInt(newLipidProfilesCount));
                                            psUpdate.setString(11, newThyroidFunctionTests != null && !newThyroidFunctionTests.isEmpty() ? newThyroidFunctionTests : null);
                                            psUpdate.setInt(12, Integer.parseInt(newThyroidFunctionTestsCount));
                                            psUpdate.setString(13, newKidneyFunctionTests != null && !newKidneyFunctionTests.isEmpty() ? newKidneyFunctionTests : null);
                                            psUpdate.setInt(14, Integer.parseInt(newKidneyFunctionTestsCount));
                                            psUpdate.setInt(15, pathologyId);
                                            int rows = psUpdate.executeUpdate();
                                            if (rows > 0) {
                                                conn.commit();
                                                session.setAttribute("success-message", "Pathology updated successfully.");
                                                response.sendRedirect("patient_view_cases.jsp?patient_id=" + patientId);
                                            } else {
                                                conn.rollback();
                                                out.println("<div class='alert alert-danger'>Failed to update pathology.</div>");
                                            }
                                        } catch (SQLException | NumberFormatException e) {
                                            conn.rollback();
                                            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                                        } finally {
                                            conn.setAutoCommit(true);
                                            if (psUpdate != null) try { psUpdate.close(); } catch (SQLException e) {}
                                        }
                                    }
                        %>
                        <form class="form-horizontal" action="edit_patient_pathology.jsp?patientId=<%=patientId%>&caseId=<%=caseId%>" method="post">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient ID</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" value="<%=patientId%>" disabled>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case ID</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" value="<%=caseId%>" disabled>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Test Type</label>
                                <div class="col-sm-9">
                                    <select name="test_id" class="form-control" required>
                                        <%
                                            PreparedStatement psTests = null;
                                            ResultSet rsTests = null;
                                            try {
                                                psTests = conn.prepareStatement("SELECT TEST_ID, NAME FROM pathology_test ORDER BY NAME");
                                                rsTests = psTests.executeQuery();
                                                while (rsTests.next()) {
                                                    int tId = rsTests.getInt("TEST_ID");
                                                    String tName = rsTests.getString("NAME");
                                                    out.println("<option value=\"" + tId + "\"" + (tId == testId ? " selected" : "") + ">" + tName + "</option>");
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error loading tests: " + e.getMessage() + "</option>");
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
                                    <input type="date" name="test_date" class="form-control" value="<%=testDate%>" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Blood Test</label>
                                <div class="col-sm-9">
                                    <select name="b_test" class="form-control">
                                        <option value="" <%= bTest == null ? "selected" : "" %>>None</option>
                                        <option value="Positive" <%= "Positive".equals(bTest) ? "selected" : "" %>>Positive</option>
                                        <option value="Negative" <%= "Negative".equals(bTest) ? "selected" : "" %>>Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Blood Test Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="bt_count" class="form-control" value="<%=btCount%>" min="0" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Urinalysis</label>
                                <div class="col-sm-9">
                                    <select name="urinalysis" class="form-control">
                                        <option value="" <%= urinalysis == null ? "selected" : "" %>>None</option>
                                        <option value="Positive" <%= "Positive".equals(urinalysis) ? "selected" : "" %>>Positive</option>
                                        <option value="Negative" <%= "Negative".equals(urinalysis) ? "selected" : "" %>>Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Urinalysis Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="urinalysis_count" class="form-control" value="<%=urinalysisCount%>" min="0" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Liver Function Tests</label>
                                <div class="col-sm-9">
                                    <select name="liver_function_tests" class="form-control">
                                        <option value="" <%= liverFunctionTests == null ? "selected" : "" %>>None</option>
                                        <option value="Positive" <%= "Positive".equals(liverFunctionTests) ? "selected" : "" %>>Positive</option>
                                        <option value="Negative" <%= "Negative".equals(liverFunctionTests) ? "selected" : "" %>>Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Liver Function Tests Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="liver_function_tests_count" class="form-control" value="<%=liverFunctionTestsCount%>" min="0" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Lipid Profiles</label>
                                <div class="col-sm-9">
                                    <select name="lipid_profiles" class="form-control">
                                        <option value="" <%= lipidProfiles == null ? "selected" : "" %>>None</option>
                                        <option value="Positive" <%= "Positive".equals(lipidProfiles) ? "selected" : "" %>>Positive</option>
                                        <option value="Negative" <%= "Negative".equals(lipidProfiles) ? "selected" : "" %>>Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Lipid Profiles Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="lipid_profiles_count" class="form-control" value="<%=lipidProfilesCount%>" min="0" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Thyroid Function Tests</label>
                                <div class="col-sm-9">
                                    <select name="thyroid_function_tests" class="form-control">
                                        <option value="" <%= thyroidFunctionTests == null ? "selected" : "" %>>None</option>
                                        <option value="Positive" <%= "Positive".equals(thyroidFunctionTests) ? "selected" : "" %>>Positive</option>
                                        <option value="Negative" <%= "Negative".equals(thyroidFunctionTests) ? "selected" : "" %>>Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Thyroid Function Tests Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="thyroid_function_tests_count" class="form-control" value="<%=thyroidFunctionTestsCount%>" min="0" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Kidney Function Tests</label>
                                <div class="col-sm-9">
                                    <select name="kidney_function_tests" class="form-control">
                                        <option value="" <%= kidneyFunctionTests == null ? "selected" : "" %>>None</option>
                                        <option value="Positive" <%= "Positive".equals(kidneyFunctionTests) ? "selected" : "" %>>Positive</option>
                                        <option value="Negative" <%= "Negative".equals(kidneyFunctionTests) ? "selected" : "" %>>Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Kidney Function Tests Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="kidney_function_tests_count" class="form-control" value="<%=kidneyFunctionTestsCount%>" min="0" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-9">
                                    <button type="submit" class="btn btn-primary">Update Pathology</button>
                                    <a href="patient_view_cases.jsp?patient_id=<%=patientId%>" class="btn btn-default">Cancel</a>
                                </div>
                            </div>
                        </form>
                        <%
                                } else {
                                    out.println("<div class='alert alert-danger'>No pathology record found for this case.</div>");
                                }
                            } catch (SQLException | NumberFormatException e) {
                                out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
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