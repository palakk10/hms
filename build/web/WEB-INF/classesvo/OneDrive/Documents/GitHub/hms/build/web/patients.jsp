
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Patients</title>
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css">
    <!-- External CSS -->
    <link rel="stylesheet" href="css/style.css">
    <!-- Inline CSS -->
    <style>
        /* Form spacing to match doctor.jsp */
        #adddoctor .form-group {
            margin-bottom: 15px !important; /* Match Bootstrap default */
        }
        #adddoctor .panel-body {
            padding: 15px !important; /* Match Bootstrap default panel-body padding */
        }
        #adddoctor .control-label {
            padding-right: 0; /* Remove custom padding to align with doctor.jsp */
        }
        /* Updated #adddoctor styling (remove absolute positioning) */
        #adddoctor {
            margin: 0 !important;
            padding: 5px !important;
            background-color: #f0f8ff;
        }
        /* Adjusted spacing overrides */
        .panel, .panel-body, .tab-content, .row {
            margin: 0 !important;
            padding: 0 !important;
        }
        .maincontent {
            position: relative !important;
            min-height: 603px !important; /* Match style.css height */
        }
        .contentinside {
            margin-top: 10px !important; /* Restore style.css margin */
        }
        .header, .navbar, .nav-tabs {
            margin: 0 !important;
            padding: 0 !important;
        }
        .panel-heading {
            padding: 10px 15px !important; /* Restore Bootstrap default */
        }
    </style>
    <!-- JavaScript -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script>
        function confirmDelete() {
            return confirm("Do You Really Want to Delete Patient?");
        }

        document.addEventListener('DOMContentLoaded', function() {
            const addPatientForm = document.querySelector('#addPatientForm');
            if (addPatientForm) {
                addPatientForm.addEventListener('submit', function(e) {
                    const phone = document.getElementById('phone').value.trim();
                    const pincode = document.getElementById('pincode').value.trim();
                    const pwd = document.getElementById('pwd').value.trim();
                    const street = document.getElementById('street').value.trim();
                    const area = document.getElementById('area').value.trim();
                    const city = document.getElementById('city').value.trim();
                    const state = document.getElementById('state').value.trim();
                    if (!phone.match(/^\d{10}$/)) {
                        alert("Phone must be exactly 10 digits.");
                        e.preventDefault();
                    } else if (!pincode.match(/^\d{6}$/)) {
                        alert("Pincode must be exactly 6 digits.");
                        e.preventDefault();
                    } else if (!pwd || pwd.length < 8) {
                        alert("Password must be at least 8 characters.");
                        e.preventDefault();
                    } else if (!street) {
                        alert("Street cannot be empty.");
                        e.preventDefault();
                    } else if (!area) {
                        alert("Area cannot be empty.");
                        e.preventDefault();
                    } else if (!city) {
                        alert("City cannot be empty.");
                        e.preventDefault();
                    } else if (!state) {
                        alert("State cannot be empty.");
                        e.preventDefault();
                    }
                });
            }
        });
    </script>
    <script src="validation.js"></script>
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
                                    <td>Street</td>
                                    <td>Area</td>
                                    <td>City</td>
                                    <td>State</td>
                                    <td>Pincode</td>
                                    <td>Country</td>
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
                                            int room_no = rs.getInt("ROOM_NO");
                                            int bed_no = rs.getInt("BED_NO");
                                            String doc_name = rs.getString("DOCTOR_NAME") != null ? rs.getString("DOCTOR_NAME") : "Not Assigned";
                                            String admit_date = rs.getString("DATE_AD");
                                            String street = rs.getString("STREET");
                                            String area = rs.getString("AREA");
                                            String city = rs.getString("CITY");
                                            String state = rs.getString("STATE");
                                            String pincode = rs.getString("PINCODE");
                                            String country = rs.getString("COUNTRY");
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
                                    <td><%=room_no%></td>
                                    <td><%=bed_no%></td>
                                    <td><%=doc_name%></td>
                                    <td><%=street != null ? street : ""%></td>
                                    <td><%=area != null ? area : ""%></td>
                                    <td><%=city != null ? city : ""%></td>
                                    <td><%=state != null ? state : ""%></td>
                                    <td><%=pincode != null ? pincode : ""%></td>
                                    <td><%=country != null ? country : ""%></td>
                                    <td>
                                        <a href="#"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal<%=id%>"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></button></a>
                                        <a href="delete_patient_validation.jsp?patientId=<%=id%>&roomNo=<%=room_no%>&bedNo=<%=bed_no%>" onclick="return confirmDelete()" class="btn btn-danger"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
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
                                    int room_no = rsModal.getInt("ROOM_NO");
                                    int bed_no = rsModal.getInt("BED_NO");
                                    int doctorId = rsModal.getInt("DOCTOR_ID");
                                    String admit_date = rsModal.getString("DATE_AD");
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
                        <div class="modal fade" id="myModal<%=id%>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                        <h4 class="modal-title" id="myModalLabel">Edit Patient Information</h4>
                                    </div>
                                    <div class="modal-body">
                                        <div class="panel panel-default">
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
                                                                <option selected="selected"><%=room_no%></option>
                                                                <%
                                                                    PreparedStatement ps1 = null;
                                                                    ResultSet rs1 = null;
                                                                    try {
                                                                        ps1 = c.prepareStatement("SELECT DISTINCT room_no FROM room_info", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                                        rs1 = ps1.executeQuery();
                                                                        while (rs1.next()) {
                                                                            int roomNo1 = rs1.getInt(1);
                                                                %>
                                                                <option value="<%=roomNo1%>"><%=roomNo1%></option>
                                                                <%
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
                                                            <select class="form-control" name="bed_no" required>
                                                                <option selected="selected"><%=bed_no%></option>
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
                                                            <input type="date" class="form-control" name="admit_date" value="<%=admit_date%>" placeholder="Admission Date" required>
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
                                out.println("<div class='alert alert-danger'>Error loading patient modals: " + e.getMessage() + "</div>");
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
                                            <label class="col-sm-2 control-label">Reason</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="rov" placeholder="Reason Of Visit" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Room No</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="roomNo" id="roomNo" onchange="retrieveBeds()" required>
                                                    <option value="">Select Room</option>
                                                    <%
                                                        PreparedStatement ps3 = null;
                                                        ResultSet rs3 = null;
                                                        try {
                                                            ps3 = c.prepareStatement("SELECT DISTINCT room_no FROM room_info", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                            rs3 = ps3.executeQuery();
                                                            while (rs3.next()) {
                                                                int roomNo = rs3.getInt(1);
                                                    %>
                                                    <option value="<%=roomNo%>"><%=roomNo%></option>
                                                    <%
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
                                            <label class="col-sm-2 control-label">Bed No.</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="bed_no" required>
                                                    <option value="">Select Bed</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Doctor</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="doct" required>
                                                    <option value="">Select Doctor</option>
                                                    <%
                                                        PreparedStatement ps4 = null;
                                                        ResultSet rs4 = null;
                                                        try {
                                                            ps4 = c.prepareStatement("SELECT ID, NAME FROM DOCTOR_INFO", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                            rs4 = ps4.executeQuery();
                                                            while (rs4.next()) {
                                                                int doctId = rs4.getInt("ID");
                                                                String doctName = rs4.getString("NAME");
                                                    %>
                                                    <option value="<%=doctId%>"><%=doctName%> (<%=doctId%>)</option>
                                                    <%
                                                            }
                                                        } finally {
                                                            if (rs4 != null) try { rs4.close(); } catch (SQLException e) {}
                                                            if (ps4 != null) try { ps4.close(); } catch (SQLException e) {}
                                                        }
                                                    %>
                                                </select>
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