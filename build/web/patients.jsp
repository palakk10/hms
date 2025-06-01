<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        /* Compact spacing for Add Patient form fields */
        #adddoctor .form-group {
            margin-bottom: 2px !important;
        }
        #adddoctor .panel-body {
            padding: 5px !important;
        }
        #adddoctor .control-label {
            padding-right: 5px;
        }
        /* Position Add Patient tab dynamically */
        #adddoctor {
            position: absolute !important;
            left: 0;
            right: 0;
            margin: 0 !important;
            padding: 5px !important;
            background-color: #f0f8ff;
            z-index: 1000;
        }
        /* Minimize all top spacing */
        .panel, .panel-body, .tab-content, .maincontent, .contentinside, .row {
            margin: 0 !important;
            padding: 0 !important;
        }
        /* Override maincontent */
        .maincontent {
            position: relative !important;
            height: auto !important;
            min-height: 100vh !important;
            border: 1px solid red !important;
        }
        /* Override contentinside */
        .contentinside {
            border: 1px solid green !important;
        }
        /* Counter potential header/menu offsets */
        .header, .navbar, .nav-tabs, .panel-heading {
            margin: 0 !important;
            padding: 0 !important;
        }
    </style>
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
            const addDoctorSection = document.querySelector('#adddoctor');
            const header = document.querySelector('.header');
            const navbar = document.querySelector('.navbar');
            const panelHeading = document.querySelector('.panel-heading');
            const navTabs = document.querySelector('.nav-tabs');
            let totalOffset = 0;
            if (header) totalOffset += header.offsetHeight;
            if (navbar) totalOffset += navbar.offsetHeight;
            if (panelHeading) totalOffset += panelHeading.offsetHeight;
            if (navTabs) totalOffset += navTabs.offsetHeight;
            totalOffset += 5;
            if (addDoctorSection) {
                addDoctorSection.style.top = totalOffset + 'px';
            }
            console.log('Header height:', header?.offsetHeight, 
                       'Navbar height:', navbar?.offsetHeight, 
                       'Panel-heading height:', panelHeading?.offsetHeight, 
                       'Nav-tabs height:', navTabs?.offsetHeight, 
                       'Total offset:', totalOffset);
            const addPatientTab = document.querySelector('a[href="#adddoctor"]');
            if (addPatientTab) {
                addPatientTab.addEventListener('shown.bs.tab', function() {
                    const scrollPosition = addDoctorSection.getBoundingClientRect().top + window.pageYOffset - totalOffset;
                    window.scrollTo({
                        top: scrollPosition,
                        behavior: 'smooth'
                    });
                    console.log('Scrolling to:', scrollPosition, 
                               'AddDoctor top:', addDoctorSection.getBoundingClientRect().top, 
                               'Page Y offset:', window.pageYOffset);
                });
            }
        });
    </script>
    <script src="validation.js"></script>
</head>
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu.jsp"%>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Manage Patient</div>
                <div class="panel-body">
                    <ul class="nav nav-tabs doctor">
                        <li role="presentation" class="active"><a href="#doctorlist" data-toggle="tab">Patient List</a></li>
                        <li role="presentation"><a href="#adddoctor" data-toggle="tab">Add Patient</a></li>
                    </ul>
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
                                PreparedStatement ps = c.prepareStatement(
                                    "SELECT p.ID, p.PNAME, p.GENDER, p.AGE, p.BGROUP, p.PHONE, p.REA_OF_VISIT, p.ROOM_NO, p.BED_NO, p.DOCTOR_ID, d.NAME AS DOCTOR_NAME, p.DATE_AD, p.EMAIL, p.STREET, p.AREA, p.CITY, p.STATE, p.PINCODE, p.COUNTRY FROM PATIENT_INFO p LEFT JOIN DOCTOR_INFO d ON p.DOCTOR_ID = d.ID",
                                    ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                                );
                                ResultSet rs = ps.executeQuery();
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
                            %>
                        </table>
                    </div>
                    <%
                        PreparedStatement psModal = c.prepareStatement(
                            "SELECT p.ID, p.PNAME, p.GENDER, p.AGE, p.BGROUP, p.PHONE, p.REA_OF_VISIT, p.ROOM_NO, p.BED_NO, p.DOCTOR_ID, d.NAME AS DOCTOR_NAME, p.DATE_AD, p.EMAIL, p.STREET, p.AREA, p.CITY, p.STATE, p.PINCODE, p.COUNTRY, p.PASSWORD FROM PATIENT_INFO p LEFT JOIN DOCTOR_INFO d ON p.DOCTOR_ID = d.ID",
                            ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                        );
                        ResultSet rsModal = psModal.executeQuery();
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
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
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
                                                                PreparedStatement ps1 = c.prepareStatement("SELECT DISTINCT room_no FROM room_info", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                                ResultSet rs1 = ps1.executeQuery();
                                                                while (rs1.next()) {
                                                                    int roomNo1 = rs1.getInt(1);
                                                            %>
                                                            <option value="<%=roomNo1%>"><%=roomNo1%></option>
                                                            <%
                                                                }
                                                                ps1.close();
                                                                rs1.close();
                                                            %>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Bed No.</label>
                                                    <div class="col-sm-10" id="beds<%=id%>">
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
                                                                PreparedStatement ps2 = c.prepareStatement("SELECT ID, NAME FROM DOCTOR_INFO", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                                ResultSet rs2 = ps2.executeQuery();
                                                                while (rs2.next()) {
                                                                    int doctId = rs2.getInt("ID");
                                                                    String doctName = rs2.getString("NAME");
                                                                    String selected = (doctId == doctorId) ? "selected" : "";
                                                            %>
                                                            <option value="<%=doctId%>" <%=selected%>><%=doctName%> (<%=doctId%>)</option>
                                                            <%
                                                                }
                                                                ps2.close();
                                                                rs2.close();
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
                        psModal.close();
                        rsModal.close();
                    %>
                    <div id="adddoctor" class="tab-pane fade">
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <form class="form-horizontal" action="add_patient_validation.jsp" method="post" id="addPatientForm">
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Patient Id:</label>
                                        <div class="col-sm-9">
                                            <input type="number" class="form-control" name="patientid" placeholder="unique_id auto generated" readonly>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Name</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="patientname" placeholder="Name" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Email</label>
                                        <div class="col-sm-9">
                                            <input type="email" class="form-control" name="email" placeholder="Email" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Password</label>
                                        <div class="col-sm-9">
                                            <input type="password" class="form-control" name="pwd" id="pwd" placeholder="Password" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Street</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="street" id="street" placeholder="Street" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Area</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="area" id="area" placeholder="Area" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">City</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="city" id="city" placeholder="City" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">State</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="state" id="state" placeholder="State" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Pincode</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="pincode" id="pincode" placeholder="Pincode" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Country</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="country" placeholder="Country">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Phone</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="phone" id="phone" placeholder="Phone No." required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Reason</label>
                                        <div class="col-sm-9">
                                            <input type="text" class="form-control" name="rov" placeholder="Reason Of Visit" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Room No</label>
                                        <div class="col-sm-9">
                                            <select class="form-control" name="roomNo" id="roomNo" onchange="retrieveBeds()" required>
                                                <option value="">Select Room</option>
                                                <%
                                                    PreparedStatement ps3 = c.prepareStatement("SELECT DISTINCT room_no FROM room_info", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                    ResultSet rs3 = ps3.executeQuery();
                                                    while (rs3.next()) {
                                                        int roomNo = rs3.getInt(1);
                                                %>
                                                <option value="<%=roomNo%>"><%=roomNo%></option>
                                                <%
                                                    }
                                                    ps3.close();
                                                    rs3.close();
                                                %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Bed No.</label>
                                        <div class="col-sm-9" id="beds">
                                            <select class="form-control" name="bed_no" required>
                                                <option value="">Select Bed</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Doctor</label>
                                        <div class="col-sm-9">
                                            <select class="form-control" name="doct" required>
                                                <option value="">Select Doctor</option>
                                                <%
                                                    PreparedStatement ps4 = c.prepareStatement("SELECT ID, NAME FROM DOCTOR_INFO", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                    ResultSet rs4 = ps4.executeQuery();
                                                    while (rs4.next()) {
                                                        int doctId = rs4.getInt("ID");
                                                        String doctName = rs4.getString("NAME");
                                                %>
                                                <option value="<%=doctId%>"><%=doctName%> (<%=doctId%>)</option>
                                                <%
                                                    }
                                                    ps4.close();
                                                    rs4.close();
                                                %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Sex</label>
                                        <div class="col-sm-9">
                                            <select class="form-control" name="gender" required>
                                                <option value="Male">Male</option>
                                                <option value="Female">Female</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Admit Date</label>
                                        <div class="col-sm-9">
                                            <input type="date" class="form-control" name="joindate" placeholder="Admission date" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Age</label>
                                        <div class="col-sm-9">
                                            <input type="number" class="form-control" name="age" placeholder="Age" required>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-3 control-label">Blood Group</label>
                                        <div class="col-sm-9">
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
                                        <div class="col-sm-offset-3 col-sm-9">
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
    <script src="js/bootstrap.min.js"></script>
</body>
</html>