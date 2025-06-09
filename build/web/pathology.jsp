<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Pathology</title>
    <!-- Cache Control -->
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css">
    <!-- External CSS -->
    <link rel="stylesheet" href="css/style.css">
    <!-- Inline CSS -->
    <style>
        #adddoctor .form-group, #doctorlist .form-group { margin-bottom: 15px !important; }
        #adddoctor .panel-body, #doctorlist .panel-body { padding: 15px !important; }
        #adddoctor .control-label, #doctorlist .control-label { padding-right: 0; }
        #adddoctor, #doctorlist { margin: 0 !important; padding: 5px !important; }
        .panel, .tab-content, .row { margin: 0 !important; padding: 0 !important; }
        .maincontent { position: relative !important; min-height: 603px !important; }
        .panel-heading { padding: 10px 15px !important; }
        /* Remove top margin from contentinside to reduce space */
        .contentinside { margin-top: 0 !important; }
        /* Ensure panel-body in adddoctor has no top padding */
        #adddoctor .panel-body { padding-top: 0 !important; }
        /* Tighten form spacing */
        #adddoctor .form-horizontal { margin-top: 0 !important; }
        /* Ensure active tab is visible, inactive tabs are hidden */
        .tab-pane { display: none; opacity: 0; }
        .tab-pane.active.in { display: block !important; opacity: 1 !important; }
        #adddoctor { background-color: #f0f8ff; }
    </style>
    <!-- JavaScript -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script>
        function confirmDelete() {
            return confirm("Do you really want to delete this pathology report?");
        }

        function fetchPatientName() {
            var patientIdInput = document.getElementById("patientId");
            var patientId = patientIdInput.value.trim();
            var patientNameInput = document.getElementById("patientName");
            console.log("fetchPatientName called with Patient ID: " + patientId);
            if (patientId === "") {
                patientNameInput.value = "";
                console.log("Patient ID is empty; cleared Patient Name");
                return;
            }
            var previousId = patientIdInput.getAttribute("data-last-id") || "";
            if (patientId === previousId) {
                console.log("Patient ID unchanged; skipping AJAX");
                return;
            }
            patientIdInput.setAttribute("data-last-id", patientId);
            console.log("Fetching name for Patient ID: " + patientId);
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    var response = xhr.responseText.trim();
                    patientNameInput.value = response;
                    console.log("AJAX response: Name=" + response);
                    if (response === "") {
                        alert("No patient found with ID: " + patientId);
                    }
                } else if (xhr.readyState == 4) {
                    console.error("AJAX error: Status=" + xhr.status);
                    patientNameInput.value = "";
                    alert("Error fetching patient name for ID: " + patientId);
                }
            };
            xhr.open("GET", "get_patient_name.jsp?patientId=" + encodeURIComponent(patientId) + "&t=" + new Date().getTime(), true);
            xhr.send();
        }

        function calculateCharges(formId) {
            console.log("Calculating charges for form: " + formId);
            var xray = document.forms[formId]["xray"].value;
            var xrayCount = parseInt(document.forms[formId]["xray_count"].value || 0);
            var usound = document.forms[formId]["usound"].value;
            var usoundCount = parseInt(document.forms[formId]["usound_count"].value || 0);
            var bt = document.forms[formId]["bt"].value;
            var btCount = parseInt(document.forms[formId]["bt_count"].value || 0);
            var ctscan = document.forms[formId]["ctscan"].value;
            var ctCount = parseInt(document.forms[formId]["ct_count"].value || 0);
            var charges = 0;
            if (xray === "Positive") charges += 50 * xrayCount;
            if (usound === "Positive") charges += 100 * usoundCount;
            if (bt === "Positive") charges += 30 * btCount;
            if (ctscan === "Positive") charges += 200 * ctCount;
            document.forms[formId]["charges"].value = charges;
            console.log("Calculated charges: " + charges);
        }

        $(document).ready(function() {
            console.log("jQuery loaded successfully");
            var urlParams = new URLSearchParams(window.location.search);
            var tab = urlParams.get('tab');
            console.log("URL parameter 'tab': " + tab);
            $('.nav-tabs li').removeClass('active');
            $('.tab-pane').removeClass('active in');
            if (tab === 'adddoctor') {
                console.log("Activating 'Add Pathology Info' tab");
                $('a[href="#adddoctor"]').parent().addClass('active');
                $('#adddoctor').addClass('active in');
                $('a[href="#doctorlist"]').parent().removeClass('active');
                $('#doctorlist').removeClass('active in');
                var patientId = urlParams.get('patientId');
                var patientName = urlParams.get('patientName');
                console.log("URL parameters - patientId: " + patientId + ", name: " + patientName);
                if (patientId && patientName) {
                    var patientIdInput = $('#patientId');
                    var patientNameInput = $('#patientName');
                    patientIdInput.val(patientId);
                    patientNameInput.val(decodeURIComponent(patientName.replace(/\+/g, ' ')));
                    patientIdInput.attr('data-prefilled', 'true');
                    patientIdInput.attr('data-last-id', patientId);
                    console.log("Prefilled fields - ID: " + patientId + ", Name: " + patientNameInput.val());
                }
                setTimeout(function() {
                    console.log("Fallback: Forcing #adddoctor visibility");
                    $('.nav-tabs li').removeClass('active');
                    $('.tab-pane').removeClass('active in');
                    $('a[href="#adddoctor"]').parent().addClass('active');
                    $('#adddoctor').addClass('active in');
                }, 100);
            } else {
                console.log("Defaulting to Pathology List tab");
                $('a[href="#doctorlist"]').parent().addClass('active');
                $('#doctorlist').addClass('active in');
            }
        });
    </script>
</head>
<body>
    <div class="row">
        <%@include file="header.jsp"%>
        <%@ include file="menu.jsp" %>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default">
                <div class="panel-heading">Manage Pathology</div>
                <div class="panel-body">
                    <ul class="nav nav-tabs">
                        <li role="presentation"><a href="#doctorlist" data-toggle="tab">Pathology List</a></li>
                        <li role="presentation"><a href="#adddoctor" data-toggle="tab">Add Pathology Information</a></li>
                    </ul>
                    <div class="tab-content">
                        <!-- Pathology List -->
                        <div id="doctorlist" class="tab-pane fade">
                            <table class="table table-bordered table-hover">
                                <thead>
                                    <tr class="active">
                                        <th>Patient Id</th>
                                        <th>Patient Name</th>
                                        <th>XRay (Count)</th>
                                        <th>UltraSound (Count)</th>
                                        <th>Blood Test (Count)</th>
                                        <th>CTScan (Count)</th>
                                        <th>Charges</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        Connection conn = null;
                                        PreparedStatement pstmt = null;
                                        ResultSet rs = null;
                                        try {
                                            conn = (Connection) application.getAttribute("connection");
                                            pstmt = conn.prepareStatement("SELECT * FROM pathology ORDER BY pathology_id DESC", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                            rs = pstmt.executeQuery();
                                            while (rs.next()) {
                                                String xray = rs.getString("X_RAYS") != null ? rs.getString("X_RAYS") : "None";
                                                int xrayCount = rs.getInt("xray_count");
                                                String usound = rs.getString("U_SOUND") != null ? rs.getString("U_SOUND") : "None";
                                                int usoundCount = rs.getInt("us_count");
                                                String bt = rs.getString("B_TEST") != null ? rs.getString("B_TEST") : "None";
                                                int btCount = rs.getInt("bt_count");
                                                String ctscan = rs.getString("CT_SCAN") != null ? rs.getString("CT_SCAN") : "None";
                                                int ctCount = rs.getInt("ct_count");
                                                String name = rs.getString("PNAME");
                                                int id = rs.getInt("ID");
                                                int charges = rs.getInt("CHARGES");
                                                int pathologyId = rs.getInt("pathology_id");
                                    %>
                                    <tr>
                                        <td><%= id %></td>
                                        <td><%= name %></td>
                                        <td><%= xray %> (<%= xrayCount %>)</td>
                                        <td><%= usound %> (<%= usoundCount %>)</td>
                                        <td><%= bt %> (<%= btCount %>)</td>
                                        <td><%= ctscan %> (<%= ctCount %>)</td>
                                        <td><%= charges %></td>
                                        <td>
                                            <a href="edit_patho_validation.jsp?pathologyId=<%= pathologyId %>" class="btn btn-primary"><span class="glyphicon glyphicon-wrench"></span></a>
                                            <a href="delete_patho_validation.jsp?pathologyId=<%= pathologyId %>" onclick="return confirmDelete()" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span></a>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                            if (rs.first()) {
                                                rs.previous();
                                            }
                                        } catch (SQLException e) {
                                            out.println("<div class='alert alert-danger'>Error loading pathology list: " + e.getMessage() + "</div>");
                                        } finally {
                                            if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                        <!-- Add Pathology Form -->
                        <div id="adddoctor" class="tab-pane fade">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <form class="form-horizontal" id="addForm" action="add_patho_validation.jsp" method="post">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Patient Id:</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" id="patientId" name="patientid" placeholder="Patient ID" required oninput="fetchPatientName()">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Patient Name</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="patientName" name="patientname" placeholder="Patient Name" readonly>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">X-Ray</label>
                                            <div class="col-sm-5">
                                                <select class="form-control" name="xray" onchange="calculateCharges('addForm')">
                                                    <option value="None" selected>None</option>
                                                    <option value="Positive">Positive</option>
                                                    <option value="Negative">Negative</option>
                                                </select>
                                            </div>
                                            <div class="col-sm-5">
                                                <input type="number" class="form-control" name="xray_count" value="0" min="0" onchange="calculateCharges('addForm')">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">UltraSound</label>
                                            <div class="col-sm-5">
                                                <select class="form-control" name="usound" onchange="calculateCharges('addForm')">
                                                    <option value="None" selected>None</option>
                                                    <option value="Positive">Positive</option>
                                                    <option value="Negative">Negative</option>
                                                </select>
                                            </div>
                                            <div class="col-sm-5">
                                                <input type="number" class="form-control" name="usound_count" value="0" min="0" onchange="calculateCharges('addForm')">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Blood Test</label>
                                            <div class="col-sm-5">
                                                <select class="form-control" name="bt" onchange="calculateCharges('addForm')">
                                                    <option value="None" selected>None</option>
                                                    <option value="Positive">Positive</option>
                                                    <option value="Negative">Negative</option>
                                                </select>
                                            </div>
                                            <div class="col-sm-5">
                                                <input type="number" class="form-control" name="bt_count" value="0" min="0" onchange="calculateCharges('addForm')">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">CT-Scan</label>
                                            <div class="col-sm-5">
                                                <select class="form-control" name="ctscan" onchange="calculateCharges('addForm')">
                                                    <option value="None" selected>None</option>
                                                    <option value="Positive">Positive</option>
                                                    <option value="Negative">Negative</option>
                                                </select>
                                            </div>
                                            <div class="col-sm-5">
                                                <input type="number" class="form-control" name="ct_count" value="0" min="0" onchange="calculateCharges('addForm')">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Charges</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" name="charges" value="0" readonly>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-sm-offset-2 col-sm-10">
                                                <button type="submit" class="btn btn-primary">Add Pathology Info</button>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>