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
        .modal { z-index: 1050 !important; }
        .modal:not(.in) {
            display: none !important;
            visibility: hidden !important;
        }
        .modal.in .modal-dialog, .modal.in .modal-content, .modal.in .modal-body {
            display: block !important;
            visibility: visible !important;
            opacity: 1 !important;
        }
        select.form-control[name="test_id"] {
            height: auto !important;
            max-height: none !important;
            overflow-y: visible !important;
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
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (!rs.isBeforeFirst()) {
                                        out.println("<tr><td colspan='6'>No cases found for this patient.</td></tr>");
                                    } else {
                                        while (rs.next()) {
                                            int caseId = rs.getInt("CASE_ID");
                                            out.println("<tr>");
                                            out.println("<td>" + caseId + "</td>");
                                            out.println("<td>" + rs.getDate("CASE_DATE") + "</td>");
                                            out.println("<td>" + rs.getString("REASON") + "</td>");
                                            out.println("<td>" + (rs.getString("CONDITION_DETAILS") != null ? rs.getString("CONDITION_DETAILS") : "-") + "</td>");
                                            out.println("<td>" + rs.getString("DOCTOR_NAME") + "</td>");
                                            out.println("<td>");
                                            out.println("<button class='btn btn-success btn-sm' data-toggle='modal' data-target='#addPathologyModal' " +
                                                        "data-patient-id='" + patientId + "' data-case-id='" + caseId + "' onclick='console.log(\"Add Pathology button clicked for case ID: " + caseId + "\");'>Add Pathology</button> ");
                                            out.println("<button class='btn btn-warning btn-sm' data-toggle='modal' data-target='#editPathologyModal' " +
                                                        "data-patient-id='" + patientId + "' data-case-id='" + caseId + "'>Update Pathology</button> ");
                                            out.println("<a href='view_pathology_by_case.jsp?patient_id=" + patientId + "&case_id=" + caseId + "' class='btn btn-info btn-sm'>View Pathology</a>");
                                            out.println("</td>");
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
                                    <input type="number" name="patient_id" id="add_patient_id" class="form-control" placeholder="Patient ID" required min="1" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="case_id" id="add_case_id" class="form-control" placeholder="Case ID" required min="1" readonly>
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
                                                psTests = c.prepareStatement("SELECT TEST_ID, NAME FROM pathology_test ORDER BY NAME");
                                                rsTests = psTests.executeQuery();
                                                if (!rsTests.isBeforeFirst()) {
                                                    out.println("<option value=\"\">No tests available</option>");
                                                } else {
                                                    while (rsTests.next()) {
                                                        out.println("<option value=\"" + rsTests.getInt("TEST_ID") + "\">" + rsTests.getString("NAME") + "</option>");
                                                    }
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
        <!-- Edit Pathology Modal -->
        <div class="modal fade" id="editPathologyModal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title">Edit Pathology Record</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="edit_pathology.jsp" method="post">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Pathology ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="pathology_id" id="edit_pathology_id" class="form-control" placeholder="Enter Pathology ID" required min="1">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="patient_id" id="edit_patient_id" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="case_id" id="edit_case_id" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Test</label>
                                <div class="col-sm-9">
                                    <select name="test_id" id="edit_test_id" class="form-control" required>
                                        <%
                                            PreparedStatement psEditTests = null;
                                            ResultSet rsEditTests = null;
                                            try {
                                                psEditTests = c.prepareStatement("SELECT TEST_ID, NAME FROM pathology_test ORDER BY NAME");
                                                rsEditTests = psEditTests.executeQuery();
                                                if (!rsEditTests.isBeforeFirst()) {
                                                    out.println("<option value=\"\">No tests available</option>");
                                                } else {
                                                    while (rsEditTests.next()) {
                                                        out.println("<option value=\"" + rsEditTests.getInt("TEST_ID") + "\">" + rsEditTests.getString("NAME") + "</option>");
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error loading tests: " + e.getMessage() + "</option>");
                                            } finally {
                                                if (rsEditTests != null) try { rsEditTests.close(); } catch (SQLException e) {}
                                                if (psEditTests != null) try { psEditTests.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Test Date</label>
                                <div class="col-sm-9">
                                    <input type="date" name="test_date" id="edit_test_date" class="form-control" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Blood Test Result</label>
                                <div class="col-sm-9">
                                    <select name="b_test" id="edit_b_test" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Blood Test Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="bt_count" id="edit_bt_count" class="form-control" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Urinalysis Result</label>
                                <div class="col-sm-9">
                                    <select name="urinalysis" id="edit_urinalysis" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Urinalysis Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="urinalysis_count" id="edit_urinalysis_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Liver Function Tests Result</label>
                                <div class="col-sm-9">
                                    <select name="liver_function_tests" id="edit_liver_function_tests" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Liver Function Tests Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="liver_function_tests_count" id="edit_liver_function_tests_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Lipid Profiles Result</label>
                                <div class="col-sm-9">
                                    <select name="lipid_profiles" id="edit_lipid_profiles" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Lipid Profiles Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="lipid_profiles_count" id="edit_lipid_profiles_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Thyroid Function Tests Result</label>
                                <div class="col-sm-9">
                                    <select name="thyroid_function_tests" id="edit_thyroid_function_tests" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Thyroid Function Tests Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="thyroid_function_tests_count" id="edit_thyroid_function_tests_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Kidney Function Tests Result</label>
                                <div class="col-sm-9">
                                    <select name="kidney_function_tests" id="edit_kidney_function_tests" class="form-control">
                                        <option value="">None</option>
                                        <option value="Positive">Positive</option>
                                        <option value="Negative">Negative</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Kidney Function Tests Count</label>
                                <div class="col-sm-9">
                                    <input type="number" name="kidney_function_tests_count" id="edit_kidney_function_tests_count" class="form-control" value="0" min="0">
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-9">
                                    <button type="submit" class="btn btn-primary">Update Pathology</button>
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script>
        $(document).ready(function() {
            console.log('Page loaded. Checking modal state...');
            if ($('#addPathologyModal').hasClass('in')) {
                console.log('Add Pathology modal is unexpectedly open on page load!');
            } else {
                console.log('Add Pathology modal is correctly hidden on page load.');
            }
        });
        $('#addPathologyModal').on('show.bs.modal', function (event) {
            console.log('Add Pathology modal is being opened.');
            var button = $(event.relatedTarget);
            var patientId = button.data('patient-id');
            var caseId = button.data('case-id');
            var modal = $(this);
            modal.find('#add_patient_id').val(patientId);
            modal.find('#add_case_id').val(caseId);
        });
        $('#addPathologyModal').on('shown.bs.modal', function () {
            console.log('Add Pathology modal is fully shown.');
            var optionsCount = $('#addPathologyModal select[name="test_id"] option').length;
            console.log('Test dropdown options count: ' + optionsCount);
        });
        $('#editPathologyModal').on('show.bs.modal', function (event) {
            console.log('Edit Pathology modal is being opened.');
            var button = $(event.relatedTarget);
            var patientId = button.data('patient-id');
            var caseId = button.data('case-id');
            var modal = $(this);
            modal.find('#edit_patient_id').val(patientId);
            modal.find('#edit_case_id').val(caseId);
            modal.find('#edit_pathology_id').val('');
            modal.find('#edit_test_id').val('');
            modal.find('#edit_test_date').val('');
            modal.find('#edit_b_test').val('');
            modal.find('#edit_bt_count').val('');
            modal.find('#edit_urinalysis').val('');
            modal.find('#edit_urinalysis_count').val('');
            modal.find('#edit_liver_function_tests').val('');
            modal.find('#edit_liver_function_tests_count').val('');
            modal.find('#edit_lipid_profiles').val('');
            modal.find('#edit_lipid_profiles_count').val('');
            modal.find('#edit_thyroid_function_tests').val('');
            modal.find('#edit_thyroid_function_tests_count').val('');
            modal.find('#edit_kidney_function_tests').val('');
            modal.find('#edit_kidney_function_tests_count').val('');
        });
    </script>
</body>
</html>