```jsp
<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<%
    response.setHeader("cache-control", "no-cache, no-store, must-revalidate");
    String emaill = (String) session.getAttribute("email");
    String namee = (String) session.getAttribute("name");
    if (emaill == null || namee == null) {
        response.sendRedirect("index.jsp");
    } else {
%>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="images/logo.png" rel="icon"/>
    <title>Receptionist Dashboard</title>
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
        }
        .btn-primary, .btn-info, .btn-warning, .btn-success { 
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
        .content { margin-left: 16.66%; float: left; }
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
                <!-- Patient Management -->
                <div class="panel panel-default">
                    <div class="panel-heading logintitle">Manage Patients</div>
                    <div class="panel-body">
                        <%
                            String status = request.getParameter("status");
                            if ("success".equals(status)) {
                                out.println("<div class='alert alert-success'>Action performed successfully!</div>");
                            } else if ("error".equals(status)) {
                                out.println("<div class='alert alert-danger'>Error performing action.</div>");
                            }
                        %>
                        <div class="row">
                            <div class="col-md-2">
                                <button class="btn btn-primary btn-block btn-lg" data-toggle="modal" data-target="#addPatientModal">Add Patient</button>
                            </div>
                            <div class="col-md-10">
                                <%
                                    Connection c = (Connection) application.getAttribute("connection");
                                    if (c == null) {
                                        out.println("<div class='alert alert-danger'>Error: Database connection is null.</div>");
                                    } else {
                                %>
                                <table class="table table-bordered">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Patient Name</th>
                                            <th>Age</th>
                                            <th>Sex</th>
                                            <th>Phone</th>
                                            <th>Reason Of Visit</th>
                                            <th>Blood Grp</th>
                                            <th>Address</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            PreparedStatement ps = null;
                                            ResultSet rs = null;
                                            try {
                                                ps = c.prepareStatement(
                                                    "SELECT p.ID, p.PNAME, p.AGE, p.GENDER, p.PHONE, " +
                                                    "(SELECT c.REASON FROM case_master c WHERE c.PATIENT_ID = p.ID ORDER BY c.CASE_DATE DESC LIMIT 1) AS REASON, " +
                                                    "p.BGROUP, CONCAT(p.STREET, ', ', p.AREA, ', ', p.CITY, ', ', p.STATE, ', ', p.COUNTRY, ', ', p.PINCODE) AS ADDRESS " +
                                                    "FROM patient_info p"
                                                );
                                                rs = ps.executeQuery();
                                                if (!rs.isBeforeFirst()) {
                                                    out.println("<tr><td colspan='9'>No patients found.</td></tr>");
                                                } else {
                                                    while (rs.next()) {
                                                        int patientId = rs.getInt("ID");
                                                        out.println("<tr>");
                                                        out.println("<td>" + patientId + "</td>");
                                                        out.println("<td>" + (rs.getString("PNAME") != null ? rs.getString("PNAME") : "-") + "</td>");
                                                        out.println("<td>" + rs.getInt("AGE") + "</td>");
                                                        out.println("<td>" + (rs.getString("GENDER") != null ? rs.getString("GENDER") : "-") + "</td>");
                                                        out.println("<td>" + (rs.getString("PHONE") != null ? rs.getString("PHONE") : "-") + "</td>");
                                                        out.println("<td>" + (rs.getString("REASON") != null ? rs.getString("REASON") : "-") + "</td>");
                                                        out.println("<td>" + (rs.getString("BGROUP") != null ? rs.getString("BGROUP") : "-") + "</td>");
                                                        out.println("<td>" + (rs.getString("ADDRESS") != null ? rs.getString("ADDRESS") : "-") + "</td>");
                                                        out.println("<td>");
                                                        out.println("<button class='btn btn-info btn-sm' data-toggle='modal' data-target='#addCaseModal' data-patient-id='" + patientId + "'>Add Case</button> ");
                                                        out.println("<a href='view_cases.jsp?patient_id=" + patientId + "' class='btn btn-primary btn-sm'>View Cases</a> ");
                                                        out.println("<button class='btn btn-success btn-sm' data-toggle='modal' data-target='#addPathologyModal' data-patient-id='" + patientId + "'>Add Pathology</button> ");
                                                        out.println("<button class='btn btn-warning btn-sm' data-toggle='modal' data-target='#editPathologyModal' data-patient-id='" + patientId + "'>Update Pathology</button>");
                                                        out.println("</td>");
                                                        out.println("</tr>");
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                out.println("<tr><td colspan='9'>Error loading patients: " + e.getMessage() + "</td></tr>");
                                            } finally {
                                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </tbody>
                                </table>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Pathology Management -->
                <div class="panel panel-default">
                    <div class="panel-heading logintitle">Manage Pathology</div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-2">
                                <button class="btn btn-primary btn-block btn-lg" data-toggle="modal" data-target="#addPathologyModal">Add Pathology</button>
                            </div>
                            <div class="col-md-10">
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
                                            <th>Charges</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            PreparedStatement ps = null;
                                            ResultSet rs = null;
                                            try {
                                                ps = c.prepareStatement(
                                                    "SELECT p.PATHOLOGY_ID, p.ID, pi.PNAME, p.CASE_ID, pt.NAME AS TEST_NAME, p.TEST_DATE, " +
                                                    "p.B_TEST, p.BT_COUNT, p.URINALYSIS, pt.PRICE " +
                                                    "FROM pathology p " +
                                                    "JOIN patient_info pi ON p.ID = pi.ID " +
                                                    "JOIN pathology_test pt ON p.TEST_ID = pt.TEST_ID " +
                                                    "ORDER BY p.TEST_DATE DESC"
                                                );
                                                rs = ps.executeQuery();
                                                if (!rs.isBeforeFirst()) {
                                                    out.println("<tr><td colspan='11'>No pathology records found.</td></tr>");
                                                } else {
                                                    while (rs.next()) {
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
                                                        out.println("<td>" + String.format("%.2f", rs.getDouble("PRICE")) + "</td>");
                                                        out.println("<td>");
                                                        out.println("<button class='btn btn-warning btn-sm' data-toggle='modal' data-target='#editPathologyModal' " +
                                                                    "data-pathology-id='" + rs.getInt("PATHOLOGY_ID") + "' " +
                                                                    "data-patient-id='" + rs.getInt("ID") + "' " +
                                                                    "data-case-id='" + rs.getInt("CASE_ID") + "' " +
                                                                    "data-test-name='" + rs.getString("TEST_NAME") + "' " +
                                                                    "data-test-date='" + rs.getDate("TEST_DATE") + "' " +
                                                                    "data-b-test='" + (rs.getString("B_TEST") != null ? rs.getString("B_TEST") : "") + "' " +
                                                                    "data-bt-count='" + rs.getInt("BT_COUNT") + "' " +
                                                                    "data-urinalysis='" + (rs.getString("URINALYSIS") != null ? rs.getString("URINALYSIS") : "") + "'>Edit</button>");
                                                        out.println("</td>");
                                                        out.println("</tr>");
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                out.println("<tr><td colspan='11'>Error loading pathology: " + e.getMessage() + "</td></tr>");
                                            } finally {
                                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Add Patient Modal -->
        <div class="modal fade" id="addPatientModal" tabindex="-1" role="dialog">
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title">Add Patient</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="add_patient_receptionist.jsp" method="post">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient Name</label>
                                <div class="col-sm-9">
                                    <input type="text" name="pname" class="form-control" placeholder="Patient Name" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Email</label>
                                <div class="col-sm-9">
                                    <input type="email" name="email" class="form-control" placeholder="example@gmail.com" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Phone</label>
                                <div class="col-sm-9">
                                    <input type="text" name="phone" class="form-control" placeholder="Phone" required pattern="[0-9]{10}" title="Enter a 10-digit phone number">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Gender</label>
                                <div class="col-sm-9">
                                    <select name="gender" class="form-control" required>
                                        <option value="Male">Male</option>
                                        <option value="Female">Female</option>
                                        <option value="Other">Other</option>
                                    </select>
                                </div>
                            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Age</label>
                <div class="col-sm-9">
                    <input type="number" name="age" class="form-control" placeholder="Age" required min="0" max="150">
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Date of Birth</label>
                <div class="col-sm-9">
                    <input type="date" name="dob" class="form-control" required>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Blood Group</label>
                <div class="col-sm-9">
                    <select name="bgroup" class="form-control" required>
                        <option value="A+">A+</option>
                        <option value="A-">A-</option>
                        <option value="B+">B+</option>
                        <option value="B-">B-</option>
                        <option value="AB+">AB+</option>
                        <option value="AB-">AB-</option>
                        <option value="O+">O+</option>
                        <option value="O-">O-</option>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Street</label>
                <div class="col-sm-9">
                    <input type="text" name="street" class="form-control" placeholder="Street" required>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Area</label>
                <div class="col-sm-9">
                    <input type="text" name="area" class="form-control" placeholder="Area" required>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">City</label>
                <div class="col-sm-9">
                    <input type="text" name="city" class="form-control" placeholder="City" required>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">State</label>
                <div class="col-sm-9">
                    <input type="text" name="state" class="form-control" placeholder="State" required>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Country</label>
                <div class="col-sm-9">
                    <input type="text" name="country" class="form-control" placeholder="Country" value="India">
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Pincode</label>
                <div class="col-sm-9">
                    <input type="text" name="pincode" class="form-control" placeholder="Pincode" required pattern="[0-9]{6}" title="Enter a 6-digit pincode">
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Medical History</label>
                <div class="col-sm-9">
                    <textarea name="medical_history" class="form-control" placeholder="Enter any medical history" rows="4" maxlength="1000"></textarea>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Reason Of Visit</label>
                <div class="col-sm-9">
                    <select name="reason" class="form-control" required>
                        <%
                            PreparedStatement psReason = null;
                            ResultSet rsReason = null;
                            try {
                                psReason = c.prepareStatement("SELECT REASON FROM reason_department_mapping");
                                rsReason = psReason.executeQuery();
                                if (!rsReason.isBeforeFirst()) {
                                    out.println("<option value=\"\">No reasons available</option>");
                                } else {
                                    while (rsReason.next()) {
                                        out.println("<option value=\"" + rsReason.getString("REASON") + "\">" + rsReason.getString("REASON") + "</option>");
                                    }
                                }
                            } catch (SQLException e) {
                                out.println("<option value=\"\">Error: " + e.getMessage() + "</option>");
                            } finally {
                                if (rsReason != null) try { rsReason.close(); } catch (SQLException e) {}
                                if (psReason != null) try { psReason.close(); } catch (SQLException e) {}
                            }
                        %>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Condition Details</label>
                <div class="col-sm-9">
                    <textarea name="condition_details" class="form-control" placeholder="Describe the patient's condition" rows="4" maxlength="1000"></textarea>
                </div>
            </div>
            <div class="form-group">
                <label class="col-sm-3 control-label">Referred To</label>
                <div class="col-sm-9">
                    <select name="doctor_id" class="form-control" required>
                        <%
                            PreparedStatement psDoctor = null;
                            ResultSet rsDoctor = null;
                            try {
                                psDoctor = c.prepareStatement("SELECT ID, NAME FROM doctor_info");
                                rsDoctor = psDoctor.executeQuery();
                                if (!rsDoctor.isBeforeFirst()) {
                                    out.println("<option value=\"\">No doctors available</option>");
                                } else {
                                    while (rsDoctor.next()) {
                                        out.println("<option value=\"" + rsDoctor.getInt("ID") + "\">" + rsDoctor.getString("NAME") + "</option>");
                                    }
                                }
                            } catch (SQLException e) {
                                out.println("<option value=\"\">Error: " + e.getMessage() + "</option>");
                            } finally {
                                if (rsDoctor != null) try { rsDoctor.close(); } catch (SQLException e) {}
                                if (psDoctor != null) try { psDoctor.close(); } catch (SQLException e) {}
                            }
                        %>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <div class="col-sm-offset-3 col-sm-9">
                    <button type="submit" class="btn btn-primary">Add Patient</button>
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                </div>
            </div>
        </form>
    </div>
</div>
</div>
</div>
<!-- Add Case Modal -->
<div class="modal fade" id="addCaseModal" tabindex="-1" role="dialog">
<div class="modal-dialog" role="document">
    <div class="modal-content">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
            <h4 class="modal-title">Add Case</h4>
        </div>
        <div class="modal-body">
            <form class="form-horizontal" action="add_case_receptionist.jsp" method="post">
                <input type="hidden" name="patient_id" id="patient_id">
                <div class="form-group">
                    <label class="col-sm-3 control-label">Reason Of Visit</label>
                    <div class="col-sm-9">
                        <select name="reason" class="form-control" required>
                            <%
                                psReason = null;
                                rsReason = null;
                                try {
                                    psReason = c.prepareStatement("SELECT REASON FROM reason_department_mapping");
                                    rsReason = psReason.executeQuery();
                                    if (!rsReason.isBeforeFirst()) {
                                        out.println("<option value=\"\">No reasons available</option>");
                                    } else {
                                        while (rsReason.next()) {
                                            out.println("<option value=\"" + rsReason.getString("REASON") + "\">" + rsReason.getString("REASON") + "</option>");
                                        }
                                    }
                                } catch (SQLException e) {
                                    out.println("<option value=\"\">Error: " + e.getMessage() + "</option>");
                                } finally {
                                    if (rsReason != null) try { rsReason.close(); } catch (SQLException e) {}
                                    if (psReason != null) try { psReason.close(); } catch (SQLException e) {}
                                }
                            %>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-sm-3 control-label">Condition Details</label>
                    <div class="col-sm-9">
                        <textarea name="condition_details" class="form-control" placeholder="Describe the patient's condition" rows="4" maxlength="1000"></textarea>
                    </div>
                </div>
                <div class="form-group">
                    <label class="col-sm-3 control-label">Referred To</label>
                    <div class="col-sm-9">
                        <select name="doctor_id" class="form-control" required>
                            <%
                                psDoctor = null;
                                rsDoctor = null;
                                try {
                                    psDoctor = c.prepareStatement("SELECT ID, NAME FROM doctor_info");
                                    rsDoctor = psDoctor.executeQuery();
                                    if (!rsDoctor.isBeforeFirst()) {
                                        out.println("<option value=\"\">No doctors available</option>");
                                    } else {
                                        while (rsDoctor.next()) {
                                            out.println("<option value=\"" + rsDoctor.getInt("ID") + "\">" + rsDoctor.getString("NAME") + "</option>");
                                        }
                                    }
                                } catch (SQLException e) {
                                    out.println("<option value=\"\">Error: " + e.getMessage() + "</option>");
                                } finally {
                                    if (rsDoctor != null) try { rsDoctor.close(); } catch (SQLException e) {}
                                    if (psDoctor != null) try { psDoctor.close(); } catch (SQLException e) {}
                                }
                            %>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-sm-offset-3 col-sm-9">
                        <button type="submit" class="btn btn-primary">Add Case</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </form>
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
                        <input type="number" name="patient_id" id="add_patient_id" class="form-control" placeholder="Patient ID" required min="1">
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
                                    psTests = c.prepareStatement("SELECT TEST_ID, NAME FROM pathology_test");
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
                        <input type="number" name="case_id" id="edit_case_id" class="form-control" required min="1">
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
                                    psEditTests = c.prepareStatement("SELECT TEST_ID, NAME FROM pathology_test");
                                    rsEditTests = psEditTests.executeQuery();
                                    if (!rsEditTests.isBeforeFirst()) {
                                        out.println("<option value=\"\">No tests available</option>");
                                    } else {
                                        while (rsEditTests.next()) {
                                            out.println("<option value=\"" + rsEditTests.getInt("TEST_ID") + "\">" + rsEditTests.getString("NAME") + "</option>");
                                        }
                                    }
                                } catch (SQLException e) {
                                    out.println("<option value=\"\">Error: " + e.getMessage() + "</option>");
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
<div class="row marginreset"></div>
</div>
<script>
    $('#addCaseModal').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget);
        var patientId = button.data('patient-id');
        var modal = $(this);
        modal.find('#patient_id').val(patientId);
    });
    $('#addPathologyModal').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget);
        var patientId = button.data('patient-id');
        var modal = $(this);
        if (patientId) {
            modal.find('#add_patient_id').val(patientId).prop('readonly', true);
        } else {
            modal.find('#add_patient_id').val('').prop('readonly', false);
        }
    });
    $('#editPathologyModal').on('show.bs.modal', function (event) {
        var button = $(event.relatedTarget);
        var modal = $(this);
        var patientId = button.data('patient-id');
        var pathologyId = button.data('pathology-id');
        if (patientId) {
            modal.find('#edit_patient_id').val(patientId).prop('readonly', true);
        } else {
            modal.find('#edit_patient_id').val('').prop('readonly', false);
        }
        if (pathologyId) {
            modal.find('#edit_pathology_id').val(pathologyId);
            modal.find('#edit_case_id').val(button.data('case-id'));
            modal.find('#edit_test_date').val(button.data('test-date'));
            modal.find('#edit_b_test').val(button.data('b-test'));
            modal.find('#edit_bt_count').val(button.data('bt-count'));
            modal.find('#edit_urinalysis').val(button.data('urinalysis'));
            // Note: test_id requires mapping from test-name or separate query
            var testName = button.data('test-name');
        } else {
            modal.find('#edit_pathology_id').val('');
            modal.find('#edit_case_id').val('');
            modal.find('#edit_test_date').val('');
            modal.find('#edit_b_test').val('');
            modal.find('#edit_bt_count').val('');
            modal.find('#edit_urinalysis').val('');
        }
    });
</script>
</body>
</html>
<% } %>
```