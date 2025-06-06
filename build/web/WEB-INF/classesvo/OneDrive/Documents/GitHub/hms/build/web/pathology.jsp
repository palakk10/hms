<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<head>
    <script>
        function confirmDelete() {
            return confirm("Do you really want to delete this pathology report?");
        }

        // AJAX function to fetch patient name based on patient ID
        function fetchPatientName() {
            var patientId = document.getElementById("patientId").value;
            var patientNameInput = document.getElementById("patientName");
            if (patientId === "") {
                patientNameInput.value = "";
                return;
            }
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    patientNameInput.value = xhr.responseText;
                }
            };
            xhr.open("GET", "get_patient_name.jsp?patientId=" + patientId, true);
            xhr.send();
        }

        // Function to calculate charges based on test counts and results
        function calculateCharges(formId) {
            var xray = document.forms[formId]["xray"].value;
            var xrayCount = parseInt(document.forms[formId]["xray_count"].value || 0);
            var usound = document.forms[formId]["usound"].value;
            var usoundCount = parseInt(document.forms[formId]["usound_count"].value || 0);
            var bt = document.forms[formId]["bt"].value;
            var btCount = parseInt(document.forms[formId]["bt_count"].value || 0);
            var ctscan = document.forms[formId]["ctscan"].value;
            var ctCount = parseInt(document.forms[formId]["ct_count"].value || 0);
            var charges = 0;

            // Assign costs for Positive results: X-Ray: $50 each, Ultrasound: $100 each, Blood Test: $30 each, CT-Scan: $200 each
            if (xray === "Positive") charges += 50 * xrayCount;
            if (usound === "Positive") charges += 100 * usoundCount;
            if (bt === "Positive") charges += 30 * btCount;
            if (ctscan === "Positive") charges += 200 * ctCount;

            // Update charges field
            document.forms[formId]["charges"].value = charges;
        }

        // Function to initialize charges when edit modal opens
        function initializeEditModal(formId) {
            calculateCharges(formId);
        }
    </script>
</head>
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu.jsp"%>
        <!---- Content Area Start -------->
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Manage Pathology</div>
                <div class="panel-body">
                    <ul class="nav nav-tabs doctor">
                        <li role="presentation" class="active"><a href="#doctorlist">Pathology List</a></li>
                        <li role="presentation"><a href="#adddoctor">Add Pathology Info</a></li>
                    </ul>

                    <!---- Display Pathology Data List Start ------>
                    <div id="doctorlist" class="switchgroup">
                        <table class="table table-bordered table-hover">
                            <tr class="active">
                                <td>Patient Id</td>
                                <td>Patient Name</td>
                                <td>XRay (Count)</td>
                                <td>UltraSound (Count)</td>
                                <td>Blood Test (Count)</td>
                                <td>CTScan (Count)</td>
                                <td>Charges</td>
                                <td>Options</td>
                            </tr>
                            <%
                                Connection c = (Connection) application.getAttribute("connection");
                                PreparedStatement ps = c.prepareStatement("SELECT * FROM pathology ORDER BY pathology_id DESC", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                ResultSet rs = ps.executeQuery();
                                while (rs.next()) {
                                    String xray = rs.getString("X_RAYS");
                                    int xrayCount = rs.getInt("xray_count");
                                    String usound = rs.getString("U_SOUND");
                                    int usoundCount = rs.getInt("us_count");
                                    String bt = rs.getString("B_TEST");
                                    int btCount = rs.getInt("bt_count");
                                    String ctscan = rs.getString("CT_SCAN");
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
                                    <a href="#" data-toggle="modal" data-target="#myModal<%= pathologyId %>" onclick="initializeEditModal('editForm<%= pathologyId %>')"><button type="button" class="btn btn-primary"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></button></a>
                                    <a href="delete_patho_validation.jsp?pathologyId=<%= pathologyId %>" onclick="return confirmDelete()" class="btn btn-danger"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
                                </td>
                            </tr>
                            <%
                                }
                                rs.first();
                                rs.previous();
                            %>
                        </table>
                    </div>
                    <!---------------- Display Pathology Data List Ends --------------->
                    
                    <!------ Pathology Edit Info Modal Start Here ---------->
                    <%
                        while (rs.next()) {
                            String xray = rs.getString("X_RAYS");
                            int xrayCount = rs.getInt("xray_count");
                            String usound = rs.getString("U_SOUND");
                            int usoundCount = rs.getInt("us_count");
                            String bt = rs.getString("B_TEST");
                            int btCount = rs.getInt("bt_count");
                            String ctscan = rs.getString("CT_SCAN");
                            int ctCount = rs.getInt("ct_count");
                            String name = rs.getString("PNAME");
                            int id = rs.getInt("ID");
                            int charges = rs.getInt("CHARGES");
                            int pathologyId = rs.getInt("pathology_id");
                    %>
                    <div class="modal fade" id="myModal<%= pathologyId %>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                    <h4 class="modal-title" id="myModalLabel">Edit Pathology Information</h4>
                                </div>
                                <div class="modal-body">
                                    <div class="panel panel-default">
                                        <div class="panel-body">
                                            <form class="form-horizontal" id="editForm<%= pathologyId %>" action="edit_patho_validation.jsp" method="post">
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Patient Id:</label>
                                                    <div class="col-sm-10">
                                                        <input type="number" class="form-control" name="patientid" value="<%= id %>" readonly="readonly">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Patient Name</label>
                                                    <div class="col-sm-10">
                                                        <input type="text" class="form-control" name="patientname" value="<%= name %>" required>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">X-Ray</label>
                                                    <div class="col-sm-5">
                                                        <select class="form-control" name="xray" onchange="calculateCharges('editForm<%= pathologyId %>')">
                                                            <option <%= xray.equals("None") ? "selected" : "" %>>None</option>
                                                            <option <%= xray.equals("Positive") ? "selected" : "" %>>Positive</option>
                                                            <option <%= xray.equals("Negative") ? "selected" : "" %>>Negative</option>
                                                        </select>
                                                    </div>
                                                    <div class="col-sm-5">
                                                        <input type="number" class="form-control" name="xray_count" value="<%= xrayCount %>" min="0" onchange="calculateCharges('editForm<%= pathologyId %>')">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">UltraSound</label>
                                                    <div class="col-sm-5">
                                                        <select class="form-control" name="usound" onchange="calculateCharges('editForm<%= pathologyId %>')">
                                                            <option <%= usound.equals("None") ? "selected" : "" %>>None</option>
                                                            <option <%= usound.equals("Positive") ? "selected" : "" %>>Positive</option>
                                                            <option <%= usound.equals("Negative") ? "selected" : "" %>>Negative</option>
                                                        </select>
                                                    </div>
                                                    <div class="col-sm-5">
                                                        <input type="number" class="form-control" name="usound_count" value="<%= usoundCount %>" min="0" onchange="calculateCharges('editForm<%= pathologyId %>')">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Blood Test</label>
                                                    <div class="col-sm-5">
                                                        <select class="form-control" name="bt" onchange="calculateCharges('editForm<%= pathologyId %>')">
                                                            <option <%= bt.equals("None") ? "selected" : "" %>>None</option>
                                                            <option <%= bt.equals("Positive") ? "selected" : "" %>>Positive</option>
                                                            <option <%= bt.equals("Negative") ? "selected" : "" %>>Negative</option>
                                                        </select>
                                                    </div>
                                                    <div class="col-sm-5">
                                                        <input type="number" class="form-control" name="bt_count" value="<%= btCount %>" min="0" onchange="calculateCharges('editForm<%= pathologyId %>')">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">CT-Scan</label>
                                                    <div class="col-sm-5">
                                                        <select class="form-control" name="ctscan" onchange="calculateCharges('editForm<%= pathologyId %>')">
                                                            <option <%= ctscan.equals("None") ? "selected" : "" %>>None</option>
                                                            <option <%= ctscan.equals("Positive") ? "selected" : "" %>>Positive</option>
                                                            <option <%= ctscan.equals("Negative") ? "selected" : "" %>>Negative</option>
                                                        </select>
                                                    </div>
                                                    <div class="col-sm-5">
                                                        <input type="number" class="form-control" name="ct_count" value="<%= ctCount %>" min="0" onchange="calculateCharges('editForm<%= pathologyId %>')">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Charges</label>
                                                    <div class="col-sm-10">
                                                        <input type="number" class="form-control" name="charges" value="<%= charges %>" readonly>
                                                    </div>
                                                </div>
                                                <input type="hidden" name="pathologyId" value="<%= pathologyId %>">
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                                    <input type="submit" class="btn btn-primary" value="Update">
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                        rs.close();
                        ps.close();
                    %>
                    <!---------------- Modal ends here --------------->
                    
                    <!---------------- Add Pathology Info Start --------------->
                    <div id="adddoctor" class="switchgroup">
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
                                                <option selected="selected">None</option>
                                                <option>Positive</option>
                                                <option>Negative</option>
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
                                                <option selected="selected">None</option>
                                                <option>Positive</option>
                                                <option>Negative</option>
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
                                                <option selected="selected">None</option>
                                                <option>Positive</option>
                                                <option>Negative</option>
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
                                                <option selected="selected">None</option>
                                                <option>Positive</option>
                                                <option>Negative</option>
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
                    <!---------------- Add Pathology Ends --------------->
                </div>
                <!---------------- Panel body Ends --------------->
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>