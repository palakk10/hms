
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.net.URLEncoder" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Patients</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        #adddoctor .form-group { margin-bottom: 15px !important; }
        #adddoctor .panel-body { padding: 15px !important; }
        #adddoctor .control-label { padding-right: 0; }
        #adddoctor { margin: 0 !important; padding: 5px !important; background-color: #f0f8ff; }
        .panel, .panel-body, .tab-content, .row { margin: 0 !important; padding: 0 !important; }
        .maincontent { position: relative !important; min-height: 603px !important; }
        .contentinside { margin-top: 10px !important; }
        .header, .navbar, .nav-tabs { margin: 0 !important; padding: 0 !important; }
        .panel-heading { padding: 10px 15px !important; }
        #reasonOfVisit { height: 34px; width: 100%; }
        #problemDescription { resize: vertical; min-height: 100px; }
        #doctorDisplay { background-color: #f5f5f5; cursor: not-allowed; }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script>
        function confirmDelete() {
            return confirm("Do You Really Want to Delete Patient?");
        }
        function retrieveBeds() {
            var roomNo = $('#roomNo').val();
            var bedSelect = $('#bedNo');
            bedSelect.prop('disabled', true).html('<option value="">Loading...</option>');
            if (roomNo) {
                $.ajax({
                    url: 'retrieve_beds_validation.jsp',
                    type: 'POST',
                    data: { roomNo: roomNo },
                    success: function(data) {
                        bedSelect.html(data);
                        bedSelect.prop('disabled', false);
                        if (bedSelect.find('option').length <= 1) {
                            bedSelect.html('<option value="">No available beds</option>');
                        }
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        bedSelect.html('<option value="">Error loading beds</option>');
                        bedSelect.prop('disabled', true);
                        alert('Error fetching beds: ' + textStatus);
                        console.error('AJAX error:', textStatus, errorThrown);
                    },
                    cache: false
                });
            } else {
                bedSelect.html('<option value="">Select Bed</option>');
                bedSelect.prop('disabled', true);
            }
        }
        function retrieveBeds2(modalId) {
            var roomNo = $('#roomNo' + modalId).val();
            var bedSelect = $('#bedNo' + modalId);
            bedSelect.prop('disabled', true).html('<option value="">Loading...</option>');
            if (roomNo) {
                $.ajax({
                    url: 'retrieve_beds_validation.jsp',
                    type: 'POST',
                    data: { roomNo: roomNo },
                    success: function(data) {
                        bedSelect.html(data);
                        bedSelect.prop('disabled', false);
                        if (bedSelect.find('option').length <= 1) {
                            bedSelect.html('<option value="">No available beds</option>');
                        }
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        bedSelect.html('<option value="">Error loading beds</option>');
                        bedSelect.prop('disabled', true);
                        alert('Error fetching beds: ' + textStatus);
                        console.error('AJAX error:', textStatus, errorThrown);
                    },
                    cache: false
                });
            } else {
                bedSelect.html('<option value="">Select Bed</option>');
                bedSelect.prop('disabled', true);
            }
        }
        $(document).ready(function() {
            $('#roomNo').on('change', retrieveBeds);
            $('#addPatientForm').on('submit', function(e) {
                var phone = $('#phone').val().trim();
                var pincode = $('#pincode').val().trim();
                var pwd = $('#pwd').val().trim();
                var roomNo = $('#roomNo').val();
                var bedNo = $('#bedNo').val();
                if (!phone.match(/^\d{10}$/)) {
                    alert("Phone must be exactly 10 digits.");
                    e.preventDefault();
                } else if (!pincode.match(/^\d{6}$/)) {
                    alert("Pincode must be exactly 6 digits.");
                    e.preventDefault();
                } else if (pwd.length < 8) {
                    alert("Password must be at least 8 characters.");
                    e.preventDefault();
                } else if (!roomNo) {
                    alert("Please select a room.");
                    e.preventDefault();
                } else if (!bedNo) {
                    alert("Please select a bed.");
                    e.preventDefault();
                }
            });
            $('#reasonOfVisit').on('change', function() {
                var reason = $(this).val();
                if (reason) {
                    $.ajax({
                        url: 'getDoctorByReason.jsp',
                        type: 'POST',
                        data: { reason: reason },
                        dataType: 'json',
                        success: function(data) {
                            if (data.doctorId && data.doctorName) {
                                $('#doctorDisplay').val(data.doctorName);
                                $('#doct').val(data.doctorId);
                            } else {
                                $('#doctorDisplay').val('No doctor available');
                                $('#doct').val('');
                                alert('No doctor found for this reason.');
                            }
                        },
                        error: function() {
                            $('#doctorDisplay').val('Error');
                            $('#doct').val('');
                            alert('Error fetching doctor.');
                        },
                        cache: false
                    });
                } else {
                    $('#doctorDisplay').val('');
                    $('#doct').val('');
                }
            });
        });
    </script>
</head>
<body>
    <div class="row">
        <%@include file="header.jsp"%>
        <%@include file="menu.jsp"%>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Manage Patient</div>
                <div class="panel-body">
                    <ul class="nav nav-tabs doctor">
                        <li role="presentation" class="active"><a href="#doctorlist" data-toggle="tab">Patient List</a></li>
                        <li role="presentation"><a href="#adddoctor" data-toggle="tab">Add Patient</a></li>
                    </ul>
                    <div class="tab-content">
                        <!-- Patient List -->
                        <div id="doctorlist" class="tab-pane fade in active">
                            <table class="table table-bordered table-hover">
                                <tr class="active">
                                    <td>#</td>
                                    <td>Patient Name</td>
                                    <td>Age</td>
                                    <td>Sex</td>
                                    <td>Phone</td>
                                    <td>Reason Of Visit</td>
                                    <td>Blood Grp</td>
                                    <td>Date Of Admit</td>
                                    <td>Room No</td>
                                    <td>Bed No</td>
                                    <td>Observed By</td>
                                    <td>Address</td>
                                    <td>Options</td>
                                </tr>
                                <%
                                    Connection c = (Connection) application.getAttribute("connection");
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;
                                    try {
                                        ps = c.prepareStatement(
                                            "SELECT p.ID, p.PNAME, p.GENDER, p.AGE, p.BGROUP, p.PHONE, p.REA_OF_VISIT, p.ROOM_NO, p.BED_NO, p.DOCTOR_ID, d.NAME AS DOCTOR_NAME, p.DATE_AD, p.EMAIL, p.STREET, p.AREA, p.CITY, p.STATE, p.PINCODE, p.COUNTRY FROM PATIENT_INFO p LEFT JOIN DOCTOR_INFO d ON p.DOCTOR_ID = d.ID",
                                            ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                                        );
                                        rs = ps.executeQuery();
                                        while (rs.next()) {
                                            int id = rs.getInt("ID");
                                            String name = rs.getString("PNAME");
                                            String gender = rs.getString("GENDER");
                                            int age = rs.getInt("AGE");
                                            String bgroup = rs.getString("BGROUP");
                                            String phone = rs.getString("PHONE");
                                            String rov = rs.getString("REA_OF_VISIT");
                                            Integer room_no = rs.getInt("ROOM_NO") != 0 ? rs.getInt("ROOM_NO") : null;
                                            Integer bed_no = rs.getInt("BED_NO") != 0 ? rs.getInt("BED_NO") : null;
                                            String doc_name = rs.getString("DOCTOR_NAME") != null ? rs.getString("DOCTOR_NAME") : "Not Assigned";
                                            String admit_date = rs.getString("DATE_AD") != null ? rs.getString("DATE_AD") : "";
                                            String street = rs.getString("STREET");
                                            String area = rs.getString("AREA");
                                            String city = rs.getString("CITY");
                                            String state = rs.getString("STATE");
                                            String pincode = rs.getString("PINCODE");
                                            String country = rs.getString("COUNTRY");
                                            StringBuilder address = new StringBuilder();
                                            if (street != null && !street.trim().isEmpty()) address.append(street).append(", ");
                                            if (area != null && !area.trim().isEmpty()) address.append(area).append(", ");
                                            if (city != null && !city.trim().isEmpty()) address.append(city).append(", ");
                                            if (state != null && !state.trim().isEmpty()) address.append(state).append(", ");
                                            if (pincode != null && !pincode.trim().isEmpty()) address.append(pincode).append(", ");
                                            if (country != null && !country.trim().isEmpty()) address.append(country);
                                            String addressStr = address.toString().replaceAll(",\\s*$", "");
                                            pageContext.setAttribute("currentDoctorId", rs.getInt("DOCTOR_ID"));
                                %>
                                <tr>
                                    <td><%=id%></td>
                                    <td><%=name%></td>
                                    <td><%=age%></td>
                                    <td><%=gender%></td>
                                    <td><%=phone%></td>
                                    <td><%=rov%></td>
                                    <td><%=bgroup%></td>
                                    <td><%=admit_date%></td>
                                    <td><%=room_no != null ? room_no : "N/A"%></td>
                                    <td><%=bed_no != null ? bed_no : "N/A"%></td>
                                    <td><%=doc_name%></td>
                                    <td><%=addressStr%></td>
                                    <td>
                                        <a href="#"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal<%=id%>"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></button></a>
                                        <a href="delete_patient_validation.jsp?patientId=<%=id%>&roomNo=<%=room_no != null ? room_no : ""%>&bedNo=<%=bed_no != null ? bed_no : ""%>" onclick="return confirmDelete()" class="btn btn-danger"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
                                        <a href="pathology.jsp?tab=adddoctor&patientId=<%=id%>&patientName=<%=URLEncoder.encode(name, "UTF-8")%>"><button type="button" class="btn btn-success"><span class="glyphicon glyphicon-plus" aria-hidden="true"></span> Add Pathology</button></a>
                                        <a href="billing.jsp?tab=addBilling&patientId=<%=id%>&patientName=<%=URLEncoder.encode(name, "UTF-8")%>&admitDate=<%=URLEncoder.encode(admit_date, "UTF-8")%>"><button type="button" class="btn btn-info"><span class="glyphicon glyphicon-usd" aria-hidden="true"></span> Billing</button></a>
                                    </td>
                                </tr>
                                <%
                                        }
                                        rs.first();
                                        rs.previous();
                                    } catch (SQLException e) {
                                        out.println("<div class='alert alert-danger'>Error loading patient list: " + e.getMessage() + "</div>");
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                    }
                                %>
                            </table>
                        </div>
                        <!-- Edit Patient Modals -->
                        <%
                            PreparedStatement psModal = null;
                            ResultSet rsModal = null;
                            try {
                                psModal = c.prepareStatement(
                                    "SELECT p.ID, p.PNAME, p.GENDER, p.AGE, p.BGROUP, p.PHONE, p.REA_OF_VISIT, p.ROOM_NO, p.BED_NO, p.DOCTOR_ID, d.NAME AS DOCTOR_NAME, p.DATE_AD, p.EMAIL, p.STREET, p.AREA, p.CITY, p.STATE, p.PINCODE, p.COUNTRY, p.PASSWORD FROM PATIENT_INFO p LEFT JOIN DOCTOR_INFO d ON p.DOCTOR_ID = d.ID",
                                    ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                                );
                                rsModal = psModal.executeQuery();
                                while (rsModal.next()) {
                                    int id = rsModal.getInt("ID");
                                    String name = rsModal.getString("PNAME");
                                    String gender = rsModal.getString("GENDER");
                                    int age = rsModal.getInt("AGE");
                                    String bgroup = rsModal.getString("BGROUP");
                                    String phone = rsModal.getString("PHONE");
                                    String rov = rsModal.getString("REA_OF_VISIT");
                                    Integer roomNo = rsModal.getInt("ROOM_NO") != 0 ? rsModal.getInt("ROOM_NO") : null;
                                    Integer bedNo = rsModal.getInt("BED_NO") != 0 ? rsModal.getInt("BED_NO") : null;
                                    int doctorId = rsModal.getInt("DOCTOR_ID");
                                    String admitDate = rsModal.getString("DATE_AD");
                                    String email = rsModal.getString("EMAIL");
                                    String street = rsModal.getString("STREET");
                                    String area = rsModal.getString("AREA");
                                    String city = rsModal.getString("CITY");
                                    String state = rsModal.getString("STATE");
                                    String pincode = rsModal.getString("PINCODE");
                                    String country = rsModal.getString("COUNTRY");
                                    String pwd = rsModal.getString("PASSWORD");
                                    pageContext.setAttribute("currentDoctorId", doctorId);
                        %>
                        <div class="modal fade" id="myModal<%=id%>" tabindex="-1" role="dialog" aria-labelledby="aria-label-<%=id%>">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                        <h4 class="modal-title" id="aria-label">Edit Patient</h4>
                                    </div>
                                    <div class="modal-body">
                                        <div class="panel">
                                            <div class="panel-body">
                                                <form class="form-horizontal" action="edit_patient_validation.jsp" method="post">
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Patient Id:</label>
                                                        <div class="col-sm-10">
                                                            <input type="number" class="form-control" name="patientid" value="<%=id%>" readonly="readonly">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Name</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="patientname" value="<%=name%>" placeholder="Name" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Email</label>
                                                        <div class="col-sm-10">
                                                            <input type="email" class="form-control" name="email" value="<%=email%>" placeholder="Email" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Password</label>
                                                        <div class="col-sm-10">
                                                            <input type="password" class="form-control" name="pwd" value="<%=pwd != null ? pwd : ""%>" placeholder="Password" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Street</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="street" value="<%=street != null ? street : ""%>" placeholder="Street" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Area</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="area" value="<%=area != null ? area : ""%>" placeholder="Area" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">City</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="city" value="<%=city != null ? city : ""%>" placeholder="City" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">State</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="state" value="<%=state != null ? state : ""%>" placeholder="State" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Pincode</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="pincode" value="<%=pincode != null ? pincode : ""%>" placeholder="Pincode" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Country</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="country" value="<%=country != null ? country : ""%>" placeholder="Country">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Phone</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="phone" value="<%=phone%>" placeholder="Phone" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Reason Of Visit</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="rov" value="<%=rov%>" placeholder="Reason Of Visit" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Room Number</label>
                                                        <div class="col-sm-10">
                                                            <select class="form-control" name="roomNo" id="roomNo<%=id%>" onchange="retrieveBeds2('<%=id%>')" required>
                                                                <option value="<%=roomNo != null ? roomNo : ""%>" selected><%=roomNo != null ? roomNo : "Select Room"%></option>
                                                                <%
                                                                    PreparedStatement ps1 = null;
                                                                    ResultSet rs1 = null;
                                                                    try {
                                                                        ps1 = c.prepareStatement("SELECT DISTINCT room_no FROM room_info WHERE STATUS = 'Available' ORDER BY room_no", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                                        rs1 = ps1.executeQuery();
                                                                        while (rs1.next()) {
                                                                            int roomNo1 = rs1.getInt(1);
                                                                            if (roomNo == null || roomNo1 != roomNo) {
                                                                %>
                                                                <option value="<%=roomNo1%>"><%=roomNo1%></option>
                                                                <%
                                                                            }
                                                                        }
                                                                    } finally {
                                                                        if (rs1 != null) try { rs1.close(); } catch (SQLException e) {}
                                                                        if (ps1 != null) try { ps1.close(); } catch (SQLException e) {}
                                                                    }
                                                                %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Bed No.</label>
                                                        <div class="col-sm-10">
                                                            <select class="form-control" name="bed_no" id="bedNo<%=id%>" required>
                                                                <option value="<%=bedNo != null ? bedNo : ""%>" selected><%=bedNo != null ? bedNo : "Select Bed"%></option>
                                                                <%
                                                                    PreparedStatement psBeds = null;
                                                                    ResultSet rsBeds = null;
                                                                    try {
                                                                        psBeds = c.prepareStatement("SELECT BED_NO FROM room_info WHERE ROOM_NO = ? AND STATUS = 'Available' ORDER BY BED_NO", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                                        psBeds.setInt(1, roomNo != null ? roomNo : 0);
                                                                        rsBeds = psBeds.executeQuery();
                                                                        while (rsBeds.next()) {
                                                                            int bedNo1 = rsBeds.getInt("BED_NO");
                                                                            if (bedNo == null || bedNo1 != bedNo) {
                                                                %>
                                                                <option value="<%=bedNo1%>"><%=bedNo1%></option>
                                                                <%
                                                                            }
                                                                        }
                                                                    } finally {
                                                                        if (rsBeds != null) try { rsBeds.close(); } catch (SQLException e) {}
                                                                        if (psBeds != null) try { psBeds.close(); } catch (SQLException e) {}
                                                                    }
                                                                %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Referred To</label>
                                                        <div class="col-sm-10">
                                                            <select class="form-control" name="doct" required>
                                                                <%
                                                                    PreparedStatement ps2 = null;
                                                                    ResultSet rs2 = null;
                                                                    try {
                                                                        ps2 = c.prepareStatement("SELECT ID, NAME FROM DOCTOR_INFO", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                                        rs2 = ps2.executeQuery();
                                                                        while (rs2.next()) {
                                                                            int doctId = rs2.getInt("ID");
                                                                            String doctName = rs2.getString("NAME");
                                                                            String selected = (doctId == doctorId) ? "selected" : "";
                                                                %>
                                                                <option value="<%=doctId%>" <%=selected%>><%=doctName%> (<%=doctId%>)</option>
                                                                <%
                                                                        }
                                                                    } finally {
                                                                        if (rs2 != null) try { rs2.close(); } catch (SQLException e) {}
                                                                        if (ps2 != null) try { ps2.close(); } catch (SQLException e) {}
                                                                    }
                                                                %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Gender</label>
                                                        <div class="col-sm-10">
                                                            <select class="form-control" name="gender" required>
                                                                <option value="Male" <%=gender.equals("Male") ? "selected" : ""%>>Male</option>
                                                                <option value="Female" <%=gender.equals("Female") ? "selected" : ""%>>Female</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Admission Date</label>
                                                        <div class="col-sm-10">
                                                            <input type="date" class="form-control" name="admit_date" value="<%=admitDate%>" placeholder="Admission Date" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Age</label>
                                                        <div class="col-sm-10">
                                                            <input type="number" class="form-control" name="age" value="<%=age%>" placeholder="Age" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Blood Group</label>
                                                        <div class="col-sm-10">
                                                            <select class="form-control" name="bgroup" required>
                                                                <option value="A+" <%=bgroup.equals("A+") ? "selected" : ""%>>A+</option>
                                                                <option value="A-" <%=bgroup.equals("A-") ? "selected" : ""%>>A-</option>
                                                                <option value="B+" <%=bgroup.equals("B+") ? "selected" : ""%>>B+</option>
                                                                <option value="B-" <%=bgroup.equals("B-") ? "selected" : ""%>>B-</option>
                                                                <option value="AB+" <%=bgroup.equals("AB+") ? "selected" : ""%>>AB+</option>
                                                                <option value="AB-" <%=bgroup.equals("AB-") ? "selected" : ""%>>AB-</option>
                                                                <option value="O+" <%=bgroup.equals("O+") ? "selected" : ""%>>O+</option>
                                                                <option value="O-" <%=bgroup.equals("O-") ? "selected" : ""%>>O-</option>
                                                            </select>
                                                        </div>
                                                    </div>
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
                            } catch (SQLException e) {
                        %>
                        <div class="alert alert-danger">Error loading patient modals: <%=e.getMessage()%></div>
                        <%
                            } finally {
                                if (rsModal != null) try { rsModal.close(); } catch (SQLException e) {}
                                if (psModal != null) try { psModal.close(); } catch (SQLException e) {}
                            }
                        %>
                        <!-- Add Patient Form -->
                        <div id="adddoctor" class="tab-pane fade">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <form class="form-horizontal" action="add_patient_validation.jsp" method="post" id="addPatientForm">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Patient Id:</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" name="patientid" placeholder="unique_id auto generated" readonly>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Name</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="patientname" placeholder="Name" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Email</label>
                                            <div class="col-sm-10">
                                                <input type="email" class="form-control" name="email" placeholder="Email" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Password</label>
                                            <div class="col-sm-10">
                                                <input type="password" class="form-control" name="pwd" id="pwd" placeholder="Password" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Street</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="street" id="street" placeholder="Street" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Area</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="area" id="area" placeholder="Area" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">City</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="city" id="city" placeholder="City" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">State</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="state" id="state" placeholder="State" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Pincode</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="pincode" id="pincode" placeholder="Pincode" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Country</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="country" placeholder="Country">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Phone</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="phone" id="phone" placeholder="Phone No." required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Reason Of Visit</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="rov" id="reasonOfVisit" required>
                                                    <option value="">-- Select Reason --</option>
                                                    <option value="Fever">Fever</option>
                                                    <option value="Cold / Cough">Cold / Cough</option>
                                                    <option value="Headache / Migraine">Headache / Migraine</option>
                                                    <option value="Chest Pain">Chest Pain</option>
                                                    <option value="Shortness of Breath / Difficulty Breathing">Shortness of Breath / Difficulty Breathing</option>
                                                    <option value="Abdominal Pain / Stomach Pain">Abdominal Pain / Stomach Pain</option>
                                                    <option value="Back Pain">Back Pain</option>
                                                    <option value="Joint Pain / Arthritis">Joint Pain / Arthritis</option>
                                                    <option value="Skin Rash / Allergies">Skin Rash / Allergies</option>
                                                    <option value="Diarrhea / Vomiting">Diarrhea / Vomiting</option>
                                                    <option value="Fatigue">Fatigue</option>
                                                    <option value="High Blood Pressure (Hypertension)">High Blood Pressure (Hypertension)</option>
                                                    <option value="Diabetes Checkup">Diabetes Checkup</option>
                                                    <option value="Infection">Infection</option>
                                                    <option value="Injury / Trauma">Injury / Trauma</option>
                                                    <option value="Pregnancy Checkup / Antenatal Care">Pregnancy Checkup / Antenatal Care</option>
                                                    <option value="Mental Health Issues (Anxiety, Depression)">Mental Health Issues (Anxiety, Depression)</option>
                                                    <option value="Vision Problems / Eye Pain">Vision Problems / Eye Pain</option>
                                                    <option value="Earache / Hearing Problems">Earache / Hearing Problems</option>
                                                    <option value="Dental Pain">Dental Pain</option>
                                                    <option value="Follow-up / Routine Checkup">Follow-up / Routine Checkup</option>
                                                    <option value="Medication Refill">Medication Refill</option>
                                                    <option value="Allergy Reaction">Allergy Reaction</option>
                                                    <option value="Asthma Attack">Asthma Attack</option>
                                                    <option value="Skin Infection / Boils">Skin Infection / Boils</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Describe Patient's Problem</label>
                                            <div class="col-sm-10">
                                                <textarea class="form-control" name="prob_desc" id="problemDescription" placeholder="Describe Your Problem" rows="4"></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Room No</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="roomNo" id="roomNo" required>
                                                    <option value="">Select Room</option>
                                                    <%
                                                        PreparedStatement ps3 = null;
                                                        ResultSet rs3 = null;
                                                        try {
                                                            ps3 = c.prepareStatement(
                                                                "SELECT DISTINCT ROOM_NO FROM room_info WHERE ROOM_NO IN (SELECT ROOM_NO FROM room_info WHERE LOWER(status) = 'available') ORDER BY ROOM_NO",
                                                                ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                                                            );
                                                            rs3 = ps3.executeQuery();
                                                            if (!rs3.next()) {
                                                                %>
                                                                <option value="" disabled>No available rooms</option>
                                                                <%
                                                            } else {
                                                                rs3.beforeFirst();
                                                                while (rs3.next()) {
                                                                    int roomNo = rs3.getInt("ROOM_NO");
                                                                    %>
                                                                    <option value="<%=roomNo%>"><%=roomNo%></option>
                                                                    <%
                                                                }
                                                            }
                                                        } finally {
                                                            if (rs3 != null) try { rs3.close(); } catch (SQLException e) {}
                                                            if (ps3 != null) try { ps3.close(); } catch (SQLException e) {}
                                                        }
                                                    %>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Bed No</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="bed_no" id="bedNo" required disabled>
                                                    <option value="">Select Room First</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Doctor</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" id="doctorDisplay" readonly placeholder="Doctor will be assigned based on Reason">
                                                <input type="hidden" name="doct" id="doct">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Sex</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="gender" required>
                                                    <option value="Male">Male</option>
                                                    <option value="Female">Female</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Admit Date</label>
                                            <div class="col-sm-10">
                                                <input type="date" class="form-control" name="joindate" placeholder="Admission date" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Age</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" name="age" placeholder="Age" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Blood Group</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="bgroup" required>
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
                                            <div class="col-sm-offset-2 col-sm-10">
                                                <button type="submit" class="btn btn-primary">Add Patient</button>
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
```