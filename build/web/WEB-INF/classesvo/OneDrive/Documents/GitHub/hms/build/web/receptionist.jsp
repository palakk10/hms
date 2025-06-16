<%@page import="java.sql.*, javax.servlet.http.HttpSession"%>
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
%>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="images/logo.png" rel="icon"/>
    <title>Receptionist Dashboard</title>
    <!-- Bootstrap and jQuery -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <style>
        body {
            padding-top: 50px;
            /* Replace with your actual background image path */
            background: url('images/receptionist_background.jpg') no-repeat center center fixed;
            /* Fallback placeholder */
            background: url('https://via.placeholder.com/1920x1080?text=Receptionist+Background') no-repeat center center fixed;
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
        .contentinside {
            margin-top: 20px;
        }
        .panel-heading {
            background-color: #337ab7 !important;
            color: #fff !important;
            font-size: 18px;
        }
        .table th {
            background-color: #f5f5f5;
        }
        .modal-header {
            background-color: #337ab7;
            color: #fff;
        }
        .modal-header .close {
            color: #fff;
            opacity: 0.8;
        }
        .modal-header .close:hover {
            opacity: 1;
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
            // Auto-dismiss alerts after 5 seconds
            setTimeout(function() {
                $('.alert').fadeOut('slow', function() {
                    $(this).remove();
                });
            }, 5000);

            // Validate Add Patient form
            $('#addPatientModal form').submit(function(e) {
                var name = $('input[name="name"]').val().trim();
                var email = $('input[name="email"]').val().trim();
                var phone = $('input[name="phone"]').val().trim();
                var age = $('input[name="age"]').val().trim();
                var dob = $('input[name="dob"]').val();
                var emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
                var phoneRegex = /^\d{10,15}$/;

                if (!name) {
                    alert('Please enter a patient name.');
                    e.preventDefault();
                    return false;
                }

                if (!emailRegex.test(email)) {
                    alert('Please enter a valid email address.');
                    e.preventDefault();
                    return false;
                }

                if (!phoneRegex.test(phone)) {
                    alert('Please enter a valid phone number (10-15 digits).');
                    e.preventDefault();
                    return false;
                }

                if (!age || age < 0 || age > 150) {
                    alert('Please enter a valid age (0-150).');
                    e.preventDefault();
                    return false;
                }

                if (dob && new Date(dob) > new Date()) {
                    alert('Date of birth cannot be in the future.');
                    e.preventDefault();
                    return false;
                }

                if (age && dob) {
                    var dobDate = new Date(dob);
                    var ageFromDob = Math.floor((new Date() - dobDate) / (1000 * 60 * 60 * 24 * 365));
                    if (Math.abs(age - ageFromDob) > 1) {
                        alert('Age does not match date of birth.');
                        e.preventDefault();
                        return false;
                    }
                }

                return true;
            });

            $('#addCaseModal').on('show.bs.modal', function(event) {
                var button = $(event.relatedTarget);
                var patientId = button.data('patient-id');
                $(this).find('#case_patient_id').val(patientId);
                $('#case_doctor_id').html('<option value="">Loading...</option>');
                $.ajax({
                    url: 'getAllDoctors.jsp',
                    method: 'GET',
                    dataType: 'json',
                    success: function(data) {
                        var doctorSelect = $('#case_doctor_id');
                        doctorSelect.empty();
                        doctorSelect.append('<option value="">Select Doctor</option>');
                        $.each(data, function(index, doctor) {
                            doctorSelect.append('<option value="' + doctor.id + '">' + doctor.name + '</option>');
                        });
                    },
                    error: function() {
                        $('#case_doctor_id').html('<option value="">Error loading doctors</option>');
                    }
                });
            });

            $('#case_reason').change(function() {
                var reason = $(this).val();
                if (reason) {
                    $.ajax({
                        url: 'getDoctorByReason.jsp',
                        method: 'GET',
                        data: { reason: reason },
                        dataType: 'json',
                        success: function(data) {
                            var doctorSelect = $('#case_doctor_id');
                            if (data.doctorId && data.doctorName) {
                                if (doctorSelect.find('option[value="' + data.doctorId + '"]').length === 0) {
                                    doctorSelect.append('<option value="' + data.doctorId + '">' + data.doctorName + '</option>');
                                }
                                doctorSelect.val(data.doctorId);
                            } else {
                                doctorSelect.val('');
                            }
                        },
                        error: function() {
                            $('#case_doctor_id').val('');
                            alert('Error fetching doctor for the selected reason.');
                        }
                    });
                } else {
                    $('#case_doctor_id').val('');
                }
            });

            $('#addAdmissionModal').on('show.bs.modal', function(event) {
                var button = $(event.relatedTarget);
                var patientId = button.data('patient-id');
                var modal = $(this);
                modal.find('#admission_patient_id').val(patientId);
            });

            $('#room_bed_selection').change(function() {
                var value = $(this).val();
                if (value) {
                    var parts = value.split('|');
                    $('#room_no').val(parts[0]);
                    $('#bed_no').val(parts[1]);
                } else {
                    $('#room_no').val('');
                    $('#bed_no').val('');
                }
            });

            $('#addDischargeModal').on('show.bs.modal', function(event) {
                var button = $(event.relatedTarget);
                var patientId = button.data('patient-id');
                var admitId = button.data('admit-id');
                var modal = $(this);
                modal.find('#discharge_patient_id').val(patientId);
                modal.find('#discharge_admit_id').val(admitId);
                var today = new Date('2025-06-15').toISOString().split('T')[0];
                modal.find('#discharge_date').val(today);
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
                            <li><a href="profile_receptionist.jsp">Change Profile</a></li>
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
            <%@include file="receptionist_menu.jsp" %>
            <div class="col-md-10 maincontent">
                <div class="panel panel-default contentinside">
                    <div class="panel-heading">Patient Management</div>
                    <div class="panel-body">
                        <%
                            String patientMessage = (String) session.getAttribute("patientMessage");
                            if (patientMessage != null) {
                                String alertClass = patientMessage.contains("successfully") ? "alert-success" : "alert-danger";
                        %>
                        <div class="alert <%=alertClass%> alert-dismissible">
                            <button type="button" class="close" data-dismiss="alert">×</button>
                            <%=patientMessage%>
                        </div>
                        <%
                                session.removeAttribute("patientMessage");
                            }
                            String dischargeMessage = (String) session.getAttribute("dischargeMessage");
                            if (dischargeMessage != null) {
                                String alertClass = dischargeMessage.contains("successfully") ? "alert-success" : "alert-danger";
                        %>
                        <div class="alert <%=alertClass%> alert-dismissible">
                            <button type="button" class="close" data-dismiss="alert">×</button>
                            <%=dischargeMessage%>
                        </div>
                        <%
                                session.removeAttribute("dischargeMessage");
                            }
                        %>
                        <button class="btn btn-primary" data-toggle="modal" data-target="#addPatientModal">Add Patient</button>
                        <br><br>
                        <%
                            Connection conn = (Connection) application.getAttribute("connection");
                            PreparedStatement psPatients = null;
                            ResultSet rsPatients = null;
                            PreparedStatement psAdmission = null;
                            ResultSet rsAdmission = null;
                            try {
                                psPatients = conn.prepareStatement("SELECT * FROM patient_info ORDER BY ID");
                                rsPatients = psPatients.executeQuery();
                        %>
                        <table class="table table-bordered table-hover">
                            <thead>
                                <tr>
                                    <th>Patient ID</th>
                                    <th>Name</th>
                                    <th>Gender</th>
                                    <th>Age</th>
                                    <th>Blood Group</th>
                                    <th>Phone</th>
                                    <th>Email</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (!rsPatients.isBeforeFirst()) {
                                        out.println("<tr><td colspan='8'>No patients found.</td></tr>");
                                    } else {
                                        while (rsPatients.next()) {
                                            int patientId = rsPatients.getInt("ID");
                                            String patientName = rsPatients.getString("PNAME");
                                            String gender = rsPatients.getString("GENDER");
                                            int age = rsPatients.getInt("AGE");
                                            String bloodGroup = rsPatients.getString("BGROUP");
                                            String phone = rsPatients.getString("PHONE");
                                            String patientEmail = rsPatients.getString("EMAIL");
                                            psAdmission = conn.prepareStatement(
                                                "SELECT ADMIT_ID FROM admission WHERE PATIENT_ID = ? AND DISCHARGE_DATE IS NULL"
                                            );
                                            psAdmission.setInt(1, patientId);
                                            rsAdmission = psAdmission.executeQuery();
                                            boolean hasAdmission = rsAdmission.next();
                                            int admitId = hasAdmission ? rsAdmission.getInt("ADMIT_ID") : 0;
                                %>
                                <tr>
                                    <td><%=patientId%></td>
                                    <td><%=patientName != null ? patientName : "-"%></td>
                                    <td><%=gender != null ? gender : "-"%></td>
                                    <td><%=age > 0 ? age : "-"%></td>
                                    <td><%=bloodGroup != null ? bloodGroup : "-"%></td>
                                    <td><%=phone != null ? phone : "-"%></td>
                                    <td><%=patientEmail != null ? patientEmail : "-"%></td>
                                    <td>
                                        <button class="btn btn-success btn-sm" data-toggle="modal" data-target="#addCaseModal" data-patient-id="<%=patientId%>">Add Case</button>
                                        <a href="view_cases.jsp?patient_id=<%=patientId%>" class="btn btn-info btn-sm">View Cases</a>
                                        <% if (!hasAdmission) { %>
                                        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#addAdmissionModal_<%=patientId%>" data-patient-id="<%=patientId%>">Add Admission</button>
                                        <% } else { %>
                                        <button class="btn btn-danger btn-sm" data-toggle="modal" data-target="#addDischargeModal" data-patient-id="<%=patientId%>" data-admit-id="<%=admitId%>">Discharge Patient</button>
                                        <% } %>
                                    </td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                        <%
                            } catch (SQLException e) {
                                out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                            } finally {
                                if (rsAdmission != null) try { rsAdmission.close(); } catch (SQLException e) {}
                                if (psAdmission != null) try { psAdmission.close(); } catch (SQLException e) {}
                                if (rsPatients != null) try { rsPatients.close(); } catch (SQLException e) {}
                                if (psPatients != null) try { psPatients.close(); } catch (SQLException e) {}
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>
        <!-- Add Patient Modal -->
        <div class="modal fade" id="addPatientModal" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title">Add New Patient</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="add_patient_receptionist.jsp" method="post">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Name</label>
                                <div class="col-sm-9">
                                    <input type="text" name="name" class="form-control" placeholder="Patient Name" required>
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
                                    <input type="date" name="dob" class="form-control" placeholder="Date of Birth">
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
                                <label class="col-sm-3 control-label">Phone</label>
                                <div class="col-sm-9">
                                    <input type="text" name="phone" class="form-control" placeholder="Phone Number" required pattern="\d{10,15}">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Email</label>
                                <div class="col-sm-9">
                                    <input type="email" name="email" class="form-control" placeholder="Email" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Street</label>
                                <div class="col-sm-9">
                                    <input type="text" name="street" class="form-control" placeholder="Street">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Area</label>
                                <div class="col-sm-9">
                                    <input type="text" name="area" class="form-control" placeholder="Area">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">City</label>
                                <div class="col-sm-9">
                                    <input type="text" name="city" class="form-control" placeholder="City">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">State</label>
                                <div class="col-sm-9">
                                    <input type="text" name="state" class="form-control" placeholder="State">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Country</label>
                                <div class="col-sm-9">
                                    <input type="text" name="country" class="form-control" placeholder="Country">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Pincode</label>
                                <div class="col-sm-9">
                                    <input type="text" name="pincode" class="form-control" placeholder="Pincode" pattern="\d{5,10}?">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Medical History</label>
                                <div class="col-sm-9">
                                    <textarea name="medical_history" class="form-control" placeholder="Medical History"></textarea>
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
                        <h4 class="modal-title">Add New Case</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="add_case_receptionist.jsp" method="post">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="patient_id" id="case_patient_id" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case Date</label>
                                <div class="col-sm-9">
                                    <input type="date" name="case_date" class="form-control" required value="2025-06-15">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Reason</label>
                                <div class="col-sm-9">
                                    <select name="reason" id="case_reason" class="form-control" required>
                                        <%
                                            PreparedStatement psReasons = null;
                                            ResultSet rsReasons = null;
                                            try {
                                                psReasons = conn.prepareStatement("SELECT REASON FROM reason_department_mapping ORDER BY REASON");
                                                rsReasons = psReasons.executeQuery();
                                                while (rsReasons.next()) {
                                                    out.println("<option value=\"" + rsReasons.getString("REASON") + "\">" + rsReasons.getString("REASON") + "</option>");
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error loading reasons</option>");
                                            } finally {
                                                if (rsReasons != null) try { rsReasons.close(); } catch (SQLException e) {}
                                                if (psReasons != null) try { psReasons.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Doctor</label>
                                <div class="col-sm-9">
                                    <select name="doctor_id" id="case_doctor_id" class="form-control" required>
                                        <option value="">Select Doctor</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Condition Details</label>
                                <div class="col-sm-9">
                                    <textarea name="condition_details" class="form-control" placeholder="Condition Details"></textarea>
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
        <%
            try {
                psPatients = conn.prepareStatement("SELECT ID FROM patient_info ORDER BY ID");
                rsPatients = psPatients.executeQuery();
                while (rsPatients.next()) {
                    int patientId = rsPatients.getInt("ID");
        %>
        <!-- Add Admission Modal for Patient <%=patientId%> -->
        <div class="modal fade" id="addAdmissionModal_<%=patientId%>" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title">Add Admission for Patient <%=patientId%></h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="add_admission.jsp" method="post">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="patient_id" id="admission_patient_id" class="form-control" value="<%=patientId%>" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case ID</label>
                                <div class="col-sm-9">
                                    <select name="case_id" id="case_id_<%=patientId%>" class="form-control" required>
                                        <%
                                            PreparedStatement psCase = null;
                                            ResultSet rsCase = null;
                                            try {
                                                psCase = conn.prepareStatement(
                                                    "SELECT CASE_ID, DOCTOR_ID FROM case_master WHERE PATIENT_ID = ? ORDER BY CASE_DATE DESC, CASE_ID DESC LIMIT 1"
                                                );
                                                psCase.setInt(1, patientId);
                                                rsCase = psCase.executeQuery();
                                                if (rsCase.next()) {
                                                    int caseId = rsCase.getInt("CASE_ID");
                                                    out.println("<option value=\"" + caseId + "\">" + caseId + "</option>");
                                                } else {
                                                    out.println("<option value=\"\">No cases found for this patient</option>");
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error loading case ID: " + e.getMessage() + "</option>");
                                            } finally {
                                                if (rsCase != null) try { rsCase.close(); } catch (SQLException e) {}
                                                if (psCase != null) try { psCase.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Doctor ID</label>
                                <div class="col-sm-9">
                                    <select name="doctor_id" id="doctor_id_<%=patientId%>" class="form-control" required disabled>
                                        <%
                                            try {
                                                psCase = conn.prepareStatement(
                                                    "SELECT CASE_ID, DOCTOR_ID FROM case_master WHERE PATIENT_ID = ? ORDER BY CASE_DATE DESC, CASE_ID DESC LIMIT 1"
                                                );
                                                psCase.setInt(1, patientId);
                                                rsCase = psCase.executeQuery();
                                                if (rsCase.next()) {
                                                    int doctorId = rsCase.getInt("DOCTOR_ID");
                                                    PreparedStatement psDoctorName = conn.prepareStatement(
                                                        "SELECT NAME FROM doctor_info WHERE ID = ?"
                                                    );
                                                    psDoctorName.setInt(1, doctorId);
                                                    ResultSet rsDoctorName = psDoctorName.executeQuery();
                                                    if (rsDoctorName.next()) {
                                                        String doctorName = rsDoctorName.getString("NAME");
                                                        out.println("<option value=\"" + doctorId + "\">" + doctorName + "</option>");
                                                    }
                                                    rsDoctorName.close();
                                                    psDoctorName.close();
                                                } else {
                                                    out.println("<option value=\"\">No doctor assigned</option>");
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error loading doctor: " + e.getMessage() + "</option>");
                                            } finally {
                                                if (rsCase != null) try { rsCase.close(); } catch (SQLException e) {}
                                                if (psCase != null) try { psCase.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Room and Bed</label>
                                <div class="col-sm-9">
                                    <select name="room_bed_selection" id="room_bed_selection" class="form-control" required>
                                        <%
                                            PreparedStatement psRooms = null;
                                            ResultSet rsRooms = null;
                                            try {
                                                psRooms = conn.prepareStatement(
                                                    "SELECT ROOM_NO, TYPE, BED_NO FROM room_info WHERE STATUS = 'Available' ORDER BY ROOM_NO, BED_NO"
                                                );
                                                rsRooms = psRooms.executeQuery();
                                                if (!rsRooms.isBeforeFirst()) {
                                                    out.println("<option value=\"\">No available rooms</option>");
                                                } else {
                                                    while (rsRooms.next()) {
                                                        String roomNo = rsRooms.getString("ROOM_NO");
                                                        String roomType = rsRooms.getString("TYPE");
                                                        String bedNo = rsRooms.getString("BED_NO");
                                                        String displayText = roomNo + " - " + (roomType != null ? roomType : "Unknown Type") + " - Bed " + bedNo;
                                                        String value = roomNo + "|" + bedNo;
                                                        out.println("<option value=\"" + value + "\">" + displayText + "</option>");
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error loading rooms: " + e.getMessage() + "</option>");
                                            } finally {
                                                if (rsRooms != null) try { rsRooms.close(); } catch (SQLException e) {}
                                                if (psRooms != null) try { psRooms.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </select>
                                    <input type="hidden" name="room_no" id="room_no">
                                    <input type="hidden" name="bed_no" id="bed_no">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Admission Date</label>
                                <div class="col-sm-9">
                                    <input type="date" name="admit_date" id="admit_date" class="form-control" value="2025-06-15" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-9">
                                    <%
                                        boolean hasCase = false;
                                        try {
                                            psCase = conn.prepareStatement(
                                                "SELECT CASE_ID FROM case_master WHERE PATIENT_ID = ? ORDER BY CASE_DATE DESC, CASE_ID DESC LIMIT 1"
                                            );
                                            psCase.setInt(1, patientId);
                                            rsCase = psCase.executeQuery();
                                            hasCase = rsCase.next();
                                        } catch (SQLException e) {
                                            out.println("<div class='alert alert-danger'>Error checking case: " + e.getMessage() + "</div>");
                                        } finally {
                                            if (rsCase != null) try { rsCase.close(); } catch (SQLException e) {}
                                            if (psCase != null) try { psCase.close(); } catch (SQLException e) {}
                                        }
                                    %>
                                    <button type="submit" class="btn btn-primary" <%= hasCase ? "" : "disabled" %>>Add Admission</button>
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <%
                }
            } catch (SQLException e) {
                out.println("<div class='alert alert-danger'>Error loading modals: " + e.getMessage() + "</div>");
            } finally {
                if (rsPatients != null) try { rsPatients.close(); } catch (SQLException e) {}
                if (psPatients != null) try { psPatients.close(); } catch (SQLException e) {}
            }
        %>
        <!-- Add Discharge Modal -->
        <div class="modal fade" id="addDischargeModal" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title">Discharge Patient</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="discharge_patient.jsp" method="post">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="patient_id" id="discharge_patient_id" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Admission ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="admit_id" id="discharge_admit_id" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Discharge Date</label>
                                <div class="col-sm-9">
                                    <input type="date" name="discharge_date" id="discharge_date" class="form-control" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-9">
                                    <button type="submit" class="btn btn-primary">Discharge</button>
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