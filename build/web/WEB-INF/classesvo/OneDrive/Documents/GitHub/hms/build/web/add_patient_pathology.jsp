<%@page import="java.sql.*, java.text.SimpleDateFormat, javax.servlet.http.HttpSession"%>
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
    int patientId;
    int caseId;
    try {
        patientId = Integer.parseInt(request.getParameter("patientId"));
        caseId = Integer.parseInt(request.getParameter("caseId"));
    } catch (NumberFormatException e) {
        out.println("<script>alert('Invalid patient or case ID.'); window.location='manage_patients.jsp';</script>");
        return;
    }
%>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="images/logo.png" rel="icon"/>
    <title>Add Pathology Report</title>
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
            position: relative;
            z-index: 1001;
        }
        @media (max-width: 767px) {
            .maincontent {
                margin-left: 0;
            }
        }
    </style>
    <script>
        $(document).ready(function() {
            setTimeout(function() {
                $('.alert').fadeOut('slow', function() {
                    $(this).remove();
                });
            }, 5000);

            $('#addPathologyForm').submit(function(e) {
                var caseId = $('select[name="case_id"]').val();
                var testId = $('select[name="test_id"]').val();
                var testDate = $('input[name="test_date"]').val();
                var btCount = $('input[name="bt_count"]').val();
                var urinalysisCount = $('input[name="urinalysis_count"]').val();
                var liverCount = $('input[name="liver_function_tests_count"]').val();
                var lipidCount = $('input[name="lipid_profiles_count"]').val();
                var thyroidCount = $('input[name="thyroid_function_tests_count"]').val();
                var kidneyCount = $('input[name="kidney_function_tests_count"]').val();

                if (!caseId) {
                    alert('Please select a case.');
                    e.preventDefault();
                    return false;
                }
                if (!testId) {
                    alert('Please select a test.');
                    e.preventDefault();
                    return false;
                }
                if (!testDate || new Date(testDate) > new Date()) {
                    alert('Please select a valid test date (not in the future).');
                    e.preventDefault();
                    return false;
                }
                if (btCount && (btCount < 0 || isNaN(btCount))) {
                    alert('Please enter a valid blood test count (non-negative number).');
                    e.preventDefault();
                    return false;
                }
                if (urinalysisCount && (urinalysisCount < 0 || isNaN(urinalysisCount))) {
                    alert('Please enter a valid urinalysis count (non-negative number).');
                    e.preventDefault();
                    return false;
                }
                if (liverCount && (liverCount < 0 || isNaN(liverCount))) {
                    alert('Please enter a valid liver function test count (non-negative number).');
                    e.preventDefault();
                    return false;
                }
                if (lipidCount && (lipidCount < 0 || isNaN(lipidCount))) {
                    alert('Please enter a valid lipid profile count (non-negative number).');
                    e.preventDefault();
                    return false;
                }
                if (thyroidCount && (thyroidCount < 0 || isNaN(thyroidCount))) {
                    alert('Please enter a valid thyroid function test count (non-negative number).');
                    e.preventDefault();
                    return false;
                }
                if (kidneyCount && (kidneyCount < 0 || isNaN(kidneyCount))) {
                    alert('Please enter a valid kidney function test count (non-negative number).');
                    e.preventDefault();
                    return false;
                }
                return true;
            });
        });
    </script>
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
                    <div class="panel-heading">Add Pathology Report</div>
                    <div class="panel-body">
                        <%
                            String pathologyMessage = (String) session.getAttribute("pathologyMessage");
                            if (pathologyMessage != null) {
                                String alertClass = pathologyMessage.contains("successfully") ? "alert-success" : "alert-danger";
                        %>
                        <div class="alert <%=alertClass%> alert-dismissible">
                            <button type="button" class="close" data-dismiss="alert">×</button>
                            <%=pathologyMessage%>
                        </div>
                        <%
                                session.removeAttribute("pathologyMessage");
                            }
                            Connection conn = (Connection) application.getAttribute("connection");
                            if (conn == null || conn.isClosed()) {
                                out.println("<div class='alert alert-danger'>Database connection is null or closed!</div>");
                                return;
                            }
                        %>
                        <form id="addPathologyForm" class="form-horizontal" action="add_pathology.jsp" method="post">
                            <input type="hidden" name="patient_id" value="<%=patientId%>">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient ID</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" value="<%=patientId%>" disabled>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient Name</label>
                                <div class="col-sm-9">
                                    <%
                                        PreparedStatement psPatient = null;
                                        ResultSet rsPatient = null;
                                        try {
                                            psPatient = conn.prepareStatement("SELECT PNAME FROM patient_info WHERE ID = ?");
                                            psPatient.setInt(1, patientId);
                                            rsPatient = psPatient.executeQuery();
                                            if (rsPatient.next()) {
                                                out.println("<input type='text' class='form-control' value='" + rsPatient.getString("PNAME") + "' readonly>");
                                            } else {
                                                out.println("<input type='text' class='form-control' value='Patient not found' readonly>");
                                            }
                                        } catch (SQLException e) {
                                            out.println("<input type='text' class='form-control' value='Error loading name' readonly>");
                                        } finally {
                                            if (rsPatient != null) try { rsPatient.close(); } catch (SQLException ignore) {}
                                            if (psPatient != null) try { psPatient.close(); } catch (SQLException ignore) {}
                                        }
                                    %>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case ID</label>
                                <div class="col-sm-9">
                                    <select name="case_id" class="form-control" required>
                                        <option value="">Select Case</option>
                                        <%
                                            PreparedStatement psCase = null;
                                            ResultSet rsCase = null;
                                            try {
                                                psCase = conn.prepareStatement(
                                                    "SELECT CASE_ID, REASON, CASE_DATE FROM case_master WHERE PATIENT_ID = ? ORDER BY CASE_DATE DESC"
                                                );
                                                psCase.setInt(1, patientId);
                                                rsCase = psCase.executeQuery();
                                                if (!rsCase.isBeforeFirst()) {
                                                    out.println("<option value=\"\">No cases found</option>");
                                                } else {
                                                    while (rsCase.next()) {
                                                        int caseIdOption = rsCase.getInt("CASE_ID");
                                                        String reason = rsCase.getString("REASON");
                                                        String caseDate = rsCase.getString("CASE_DATE");
                                                        String selected = (caseIdOption == caseId && caseId != 0) ? "selected" : "";
                                                        out.println("<option value=\"" + caseIdOption + "\" " + selected + ">" + caseIdOption + " - " + reason + " (" + caseDate + ")</option>");
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error: " + e.getMessage() + "</option>");
                                            } finally {
                                                if (rsCase != null) try { rsCase.close(); } catch (SQLException ignore) {}
                                                if (psCase != null) try { psCase.close(); } catch (SQLException ignore) {}
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Test Type</label>
                                <div class="col-sm-9">
                                    <select name="test_id" class="form-control" required>
                                        <option value="">Select Test</option>
                                        <%
                                            PreparedStatement psTests = null;
                                            ResultSet rsTests = null;
                                            try {
                                                psTests = conn.prepareStatement("SELECT TEST_ID, NAME FROM pathology_test ORDER BY NAME");
                                                rsTests = psTests.executeQuery();
                                                while (rsTests.next()) {
                                                    out.println("<option value=\"" + rsTests.getInt("TEST_ID") + "\">" + rsTests.getString("NAME") + "</option>");
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error: " + e.getMessage() + "</option>");
                                            } finally {
                                                if (rsTests != null) try { rsTests.close(); } catch (SQLException ignore) {}
                                                if (psTests != null) try { psTests.close(); } catch (SQLException ignore) {}
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Test Date</label>
                                <div class="col-sm-9">
                                    <input type="date" name="test_date" class="form-control" value="2025-06-16" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Blood Test Result</label>
                                <div class="col-sm-9">
                                    <label class="radio-inline"><input type="radio" name="b_test" value="" checked>None</input></label>
                                    <label class="radio-inline"><input type="radio" name="b_test" value="Positive">Positive</input></label>
                                    <label class="radio-inline"><input type="radio" name="b_test" value="Negative">Negative</input></label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Blood Test Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="bt_count" class="form-control" min="0" value="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Urinalysis Result</label>
                                <div class="col-sm-9">
                                    <label class="radio-inline"><input type="radio" name="urinalysis" value="" checked>None</input></label>
                                    <label class="radio-inline"><input type="radio" name="urinalysis" value="Positive">Positive</input></label>
                                    <label class="radio-inline"><input type="radio" name="urinalysis" value="Negative">Negative</input></label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Urinalysis Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="urinalysis_count" class="form-control" min="0" value="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Liver Function Test Result</label>
                                <div class="col-sm-9">
                                    <label class="radio-inline"><input type="radio" name="liver_function_tests" value="" checked>None</input></label>
                                    <label class="radio-inline"><input type="radio" name="liver_function_tests" value="Positive">Positive</input></label>
                                    <label class="radio-inline"><input type="radio" name="liver_function_tests" value="Negative">Negative</input></label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Liver Function Test Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="liver_function_tests_count" class="form-control" min="0" value="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Lipid Profile Result</label>
                                <div class="col-sm-9">
                                    <label class="radio-inline"><input type="radio" name="lipid_profiles" value="" checked>None</input></label>
                                    <label class="radio-inline"><input type="radio" name="lipid_profiles" value="Positive">Positive</input></label>
                                    <label class="radio-inline"><input type="radio" name="lipid_profiles" value="Negative">Negative</input></label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Lipid Profile Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="lipid_profiles_count" class="form-control" min="0" value="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Thyroid Function Test Result</label>
                                <div class="col-sm-9">
                                    <label class="radio-inline"><input type="radio" name="thyroid_function_tests" value="" checked>None</input></label>
                                    <label class="radio-inline"><input type="radio" name="thyroid_function_tests" value="Positive">Positive</input></label>
                                    <label class="radio-inline"><input type="radio" name="thyroid_function_tests" value="Negative">Negative</input></label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Thyroid Function Test Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="thyroid_function_tests_count" class="form-control" min="0" value="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Kidney Function Test Result</label>
                                <div class="col-sm-9">
                                    <label class="radio-inline"><input type="radio" name="kidney_function_tests" value="" checked>None</input></label>
                                    <label class="radio-inline"><input type="radio" name="kidney_function_tests" value="Positive">Positive</input></label>
                                    <label class="radio-inline"><input type="radio" name="kidney_function_tests" value="Negative">Negative</input></label>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Kidney Function Test Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="kidney_function_tests_count" class="form-control" min="0" value="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-9">
                                    <button type="submit" class="btn btn-primary">Add Pathology</button>
                                    <a href="patient_view_cases.jsp?patient_id=<%=patientId%>" class="btn btn-default">Cancel</a>
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