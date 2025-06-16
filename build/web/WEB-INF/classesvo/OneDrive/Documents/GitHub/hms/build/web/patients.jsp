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
%>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="images/logo.png" rel="icon"/>
    <title>Manage Patients</title>
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
            console.log('jQuery version:', $.fn.jquery);
            console.log('Bootstrap modal available:', typeof $.fn.modal === 'function');

            setTimeout(function() {
                $('.alert').fadeOut('slow', function() {
                    $(this).remove();
                });
            }, 5000);

            $('#addPatientModal form').submit(function(e) {
                var name = $('input[name="name"]').val().trim();
                var email = $('input[name="email"]').val().trim();
                var phone = $('input[name="phone"]').val().trim();
                var age = $('input[name="age"]').val().trim();
                var dob = $('input[name="dob"]').val();
                var pincode = $('input[name="pincode"]').val().trim();
                var emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
                var phoneRegex = /^\d{10}$/;
                var pincodeRegex = /^\d{6}$/;

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
                    alert('Please enter a valid phone number (10 digits).');
                    e.preventDefault();
                    return false;
                }
                if (pincode && !pincodeRegex.test(pincode)) {
                    alert('Please enter a valid pincode (6 digits).');
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

            $('form[id^="editPatientForm"]').submit(function(e) {
                var name = $(this).find('input[name="pname"]').val().trim();
                var email = $(this).find('input[name="email"]').val().trim();
                var phone = $(this).find('input[name="phone"]').val().trim();
                var age = $(this).find('input[name="age"]').val().trim();
                var pincode = $(this).find('input[name="pincode"]').val().trim();
                var emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
                var phoneRegex = /^\d{10}$/;
                var pincodeRegex = /^\d{6}$/;

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
                    alert('Please enter a valid phone number (10 digits).');
                    e.preventDefault();
                    return false;
                }
                if (pincode && !pincodeRegex.test(pincode)) {
                    alert('Please enter a valid pincode (6 digits).');
                    e.preventDefault();
                    return false;
                }
                if (!age || age < 0 || age > 150) {
                    alert('Please enter a valid age (0-150).');
                    e.preventDefault();
                    return false;
                }
                return true;
            });

            $('.delete-patient').click(function(e) {
                if (!confirm('Are you sure you want to delete this patient?')) {
                    e.preventDefault();
                }
            });

            $('#addCaseModal').on('show.bs.modal', function(event) {
                console.log('Add Case modal triggered');
                var button = $(event.relatedTarget);
                var patientId = button.data('patient-id');
                var modal = $(this);
                modal.find('#case_patient_id').val(patientId);
                $.ajax({
                    url: 'get_patient_name.jsp',
                    method: 'GET',
                    data: { patientId: patientId },
                    success: function(data) {
                        modal.find('#case_patient_name').val(data.trim());
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error('Error fetching patient name:', textStatus, errorThrown);
                        modal.find('#case_patient_name').val('Error loading name');
                    }
                });
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
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error('Error fetching doctors:', textStatus, errorThrown);
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
                        error: function(jqXHR, textStatus, errorThrown) {
                            console.error('Error fetching doctor by reason:', textStatus, errorThrown);
                            $('#case_doctor_id').val('');
                            alert('Error fetching doctor for the selected reason.');
                        }
                    });
                } else {
                    $('#case_doctor_id').val('');
                }
            });

            $(document).on('click', '.add-admission-btn', function() {
                var modalId = $(this).data('target');
                var patientId = $(this).data('patient-id');
                console.log('Add Admission clicked - Patient ID:', patientId, 'Modal ID:', modalId);
                if (!$(modalId).length) {
                    alert('Modal not found for ID: ' + modalId);
                    return;
                }
                var modal = $(modalId);
                var patientNameInput = modal.find('input[id^="admission_patient_name_"]');
                var caseSelect = modal.find('select[id^="case_id_"]');
                var doctorSelect = modal.find('select[id^="doctor_id_"]');

                $.ajax({
                    url: 'get_patient_name.jsp',
                    method: 'GET',
                    data: { patientId: patientId },
                    success: function(data) {
                        patientNameInput.val(data.trim());
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error('Patient name AJAX error:', textStatus, errorThrown);
                        patientNameInput.val('Error loading name');
                    }
                });

                $.ajax({
                    url: 'getAllDoctors.jsp',
                    method: 'GET',
                    dataType: 'json',
                    success: function(data) {
                        doctorSelect.empty();
                        doctorSelect.append('<option value="">Select Doctor</option>');
                        $.each(data, function(index, doctor) {
                            doctorSelect.append('<option value="' + doctor.id + '">' + doctor.name + '</option>');
                        });
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error('Error fetching all doctors:', textStatus, errorThrown);
                        doctorSelect.empty();
                        doctorSelect.append('<option value="">Error loading doctors</option>');
                    }
                });

                caseSelect.off('change').on('change', function() {
                    var caseId = $(this).val();
                    console.log('Case selected:', caseId);
                    if (caseId) {
                        $.ajax({
                            url: 'getDoctorByCase.jsp',
                            method: 'GET',
                            data: { caseId: caseId },
                            dataType: 'json',
                            success: function(data) {
                                if (data.doctorId && data.doctorName) {
                                    if (doctorSelect.find('option[value="' + data.doctorId + '"]').length === 0) {
                                        doctorSelect.append('<option value="' + data.doctorId + '">' + data.doctorName + '</option>');
                                    }
                                    doctorSelect.val(data.doctorId);
                                } else {
                                    console.log('No doctor assigned to case:', caseId);
                                    doctorSelect.val('');
                                }
                            },
                            error: function(jqXHR, textStatus, errorThrown) {
                                console.error('Doctor AJAX error:', textStatus, errorThrown);
                                doctorSelect.val('');
                            }
                        });
                    } else {
                        doctorSelect.val('');
                    }
                });

                caseSelect.trigger('change');
            });

            $('form[action="add_patient_admission.jsp"]').submit(function(e) {
                console.log('Admission form submitted');
                var caseId = $(this).find('select[name="case_id"]').val();
                var doctorId = $(this).find('select[name="doctor_id"]').val();
                var roomBed = $(this).find('select[name="room_bed"]').val();
                var admitDate = $(this).find('input[name="admit_date"]').val();

                if (!caseId) {
                    alert('Please select a case.');
                    e.preventDefault();
                    return false;
                }
                if (!doctorId) {
                    alert('Please select a doctor.');
                    e.preventDefault();
                    return false;
                }
                if (!roomBed) {
                    alert('Please select a room and bed.');
                    e.preventDefault();
                    return false;
                }
                if (!admitDate || new Date(admitDate) > new Date()) {
                    alert('Please select a valid admission date (not in the future).');
                    e.preventDefault();
                    return false;
                }
                return true;
            });

            $('#addDischargeModal').on('show.bs.modal', function(event) {
                console.log('Discharge modal triggered');
                var button = $(event.relatedTarget);
                var patientId = button.data('patient-id');
                var admitId = button.data('admit-id');
                var modal = $(this);
                modal.find('#discharge_patient_id').val(patientId);
                modal.find('#discharge_admit_id').val(admitId);
                $.ajax({
                    url: 'get_patient_name.jsp',
                    method: 'GET',
                    data: { patientId: patientId },
                    success: function(data) {
                        modal.find('#discharge_patient_name').val(data.trim());
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        console.error('Error fetching patient name for discharge:', textStatus, errorThrown);
                        modal.find('#discharge_patient_name').val('Error loading name');
                    }
                });
                var today = new Date().toISOString().split('T')[0];
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
                <div class="panel panel-default contentinside">
                    <div class="panel-heading">Patient Management</div>
                    <div class="panel-body">
                        <%
                            String successMessage = (String) session.getAttribute("success-message");
                            String errorMessage = (String) session.getAttribute("error-message");
                            if (successMessage != null) {
                        %>
                        <div class="alert alert-success alert-dismissible">
                            <button type="button" class="close" data-dismiss="alert">×</button>
                            <%=successMessage%>
                        </div>
                        <%
                                session.removeAttribute("success-message");
                            }
                            if (errorMessage != null) {
                        %>
                        <div class="alert alert-danger alert-dismissible">
                            <button type="button" class="close" data-dismiss="alert">×</button>
                            <%=errorMessage%>
                        </div>
                        <%
                                session.removeAttribute("error-message");
                            }
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
                            if (conn == null || conn.isClosed()) {
                                out.println("<div class='alert alert-danger'>Database connection is null or closed!</div>");
                            } else {
                                PreparedStatement psPatients = null;
                                ResultSet rsPatients = null;
                                PreparedStatement psAdmission = null;
                                ResultSet rsAdmission = null;
                                try {
                                    psPatients = conn.prepareStatement(
                                        "SELECT p.*, GROUP_CONCAT(c.REASON SEPARATOR ', ') AS REASONS " +
                                        "FROM patient_info p LEFT JOIN case_master c ON p.ID = c.PATIENT_ID " +
                                        "GROUP BY p.ID ORDER BY p.ID"
                                    );
                                    rsPatients = psPatients.executeQuery();
                        %>
                        <table class="table table-bordered table-hover">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Gender</th>
                                    <th>Age</th>
                                    <th>DOB</th>
                                    <th>Blood Group</th>
                                    <th>Phone</th>
                                    <th>Email</th>
                                    <th>Address</th>
                                    <th>Medical History</th>
                                    <th>Reasons</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (!rsPatients.isBeforeFirst()) {
                                        out.println("<tr><td colspan='12'>No patients found.</td></tr>");
                                    } else {
                                        while (rsPatients.next()) {
                                            int patientId = rsPatients.getInt("ID");
                                            String patientName = rsPatients.getString("PNAME");
                                            String gender = rsPatients.getString("GENDER");
                                            int age = rsPatients.getInt("AGE");
                                            String dob = rsPatients.getString("DOB");
                                            String bloodGroup = rsPatients.getString("BGROUP");
                                            String phone = rsPatients.getString("PHONE");
                                            String patientEmail = rsPatients.getString("EMAIL");
                                            String street = rsPatients.getString("STREET");
                                            String area = rsPatients.getString("AREA");
                                            String city = rsPatients.getString("CITY");
                                            String state = rsPatients.getString("STATE");
                                            String country = rsPatients.getString("COUNTRY");
                                            String pincode = rsPatients.getString("PINCODE");
                                            String medicalHistory = rsPatients.getString("MEDICAL_HISTORY");
                                            String reasons = rsPatients.getString("REASONS") != null ? rsPatients.getString("REASONS") : "-";
                                            StringBuilder addressBuilder = new StringBuilder();
                                            if (street != null && !street.trim().isEmpty()) addressBuilder.append(street).append(", ");
                                            if (area != null && !area.trim().isEmpty()) addressBuilder.append(area).append(", ");
                                            if (city != null && !city.trim().isEmpty()) addressBuilder.append(city).append(", ");
                                            if (state != null && !state.trim().isEmpty()) addressBuilder.append(state).append(", ");
                                            if (country != null && !country.trim().isEmpty()) addressBuilder.append(country).append(" ");
                                            if (pincode != null && !pincode.trim().isEmpty()) addressBuilder.append(pincode);
                                            String address = addressBuilder.length() > 0 ? addressBuilder.toString().trim() : "-";
                                            if (address.endsWith(",")) address = address.substring(0, address.length() - 1);
                                            psAdmission = conn.prepareStatement(
                                                "SELECT ADMIT_ID, ROOM_NO, BED_NO FROM admission WHERE PATIENT_ID = ? AND DISCHARGE_DATE IS NULL"
                                            );
                                            psAdmission.setInt(1, patientId);
                                            rsAdmission = psAdmission.executeQuery();
                                            boolean hasAdmission = rsAdmission.next();
                                            int admitId = hasAdmission ? rsAdmission.getInt("ADMIT_ID") : 0;
                                            int roomNo = hasAdmission ? rsAdmission.getInt("ROOM_NO") : 0;
                                            int bedNo = hasAdmission ? rsAdmission.getInt("BED_NO") : 0;
                                %>
                                <tr>
                                    <td><%=patientId%></td>
                                    <td><%=patientName != null ? patientName : "-"%></td>
                                    <td><%=gender != null ? gender : "-"%></td>
                                    <td><%=age > 0 ? age : "-"%></td>
                                    <td><%=dob != null ? dob : "-"%></td>
                                    <td><%=bloodGroup != null ? bloodGroup : "-"%></td>
                                    <td><%=phone != null ? phone : "-"%></td>
                                    <td><%=patientEmail != null ? patientEmail : "-"%></td>
                                    <td><%=address%></td>
                                    <td><%=medicalHistory != null ? medicalHistory : "-"%></td>
                                    <td><%=reasons%></td>
                                    <td>
                                        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#editPatientModal_<%=patientId%>">Edit</button>
                                        <a href="delete_patient_validation.jsp?patientId=<%=patientId%>&roomNo=<%=roomNo%>&bedNo=<%=bedNo%>" class="btn btn-danger btn-sm delete-patient">Delete</a>
                                        <button class="btn btn-success btn-sm" data-toggle="modal" data-target="#addCaseModal" data-patient-id="<%=patientId%>">Add Case</button>
                                        <a href="patient_view_cases.jsp?patient_id=<%=patientId%>" class="btn btn-info btn-sm">View Cases</a>
                                        <% if (!hasAdmission) { %>
                                        <button class="btn btn-primary btn-sm add-admission-btn" data-toggle="modal" data-target="#addAdmissionModal_<%=patientId%>" data-patient-id="<%=patientId%>">Add Admission</button>
                                        <% } else { %>
                                        <button class="btn btn-danger btn-sm" data-toggle="modal" data-target="#addDischargeModal" data-patient-id="<%=patientId%>" data-admit-id="<%=admitId%>">Discharge</button>
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
                                e.printStackTrace();
                                out.println("<div class='alert alert-danger'>Error loading patients: " + e.getMessage() + "</div>");
                            } finally {
                                if (rsAdmission != null) try { rsAdmission.close(); } catch (SQLException ignore) {}
                                if (psAdmission != null) try { psAdmission.close(); } catch (SQLException ignore) {}
                                if (rsPatients != null) try { rsPatients.close(); } catch (SQLException ignore) {}
                                if (psPatients != null) try { psPatients.close(); } catch (SQLException ignore) {}
                            }
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal fade" id="addPatientModal" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title">Add New Patient</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="add_patient_admission.jsp" method="post">
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
                                    <input type="text" name="phone" class="form-control" placeholder="Phone Number" required pattern="\d{10}">
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
                                    <input type="text" name="pincode" class="form-control" placeholder="Pincode" pattern="\d{6}?">
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
        <div class="modal fade" id="addCaseModal" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title">Add New Case</h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="add_patient_case.jsp" method="post">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient ID</label>
                                <div class="col-sm-9">
                                    <input type="number" name="case_patient_id" id="case_patient_id" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient Name</label>
                                <div class="col-sm-9">
                                    <input type="text" id="case_patient_name" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case Date</label>
                                <div class="col-sm-9">
                                    <input type="date" name="case_date" class="form-control" required value="2025-06-16">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Reason</label>
                                <div class="col-sm-9">
                                    <select name="reason" id="case_reason" class="form-control" required>
                                        <option value="">Select Reason</option>
                                        <%
                                            PreparedStatement psCaseReasons = null;
                                            ResultSet rsCaseReasons = null;
                                            try {
                                                psCaseReasons = conn.prepareStatement("SELECT REASON FROM reason_department_mapping ORDER BY REASON");
                                                rsCaseReasons = psCaseReasons.executeQuery();
                                                while (rsCaseReasons.next()) {
                                                    String reason = rsCaseReasons.getString("REASON");
                                                    out.println("<option value=\"" + (reason != null ? reason : "") + "\">" + (reason != null ? reason : "Unknown") + "</option>");
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error loading reasons: " + e.getMessage() + "</option>");
                                            } finally {
                                                if (rsCaseReasons != null) try { rsCaseReasons.close(); } catch (SQLException ignore) {}
                                                if (psCaseReasons != null) try { psCaseReasons.close(); } catch (SQLException ignore) {}
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
            PreparedStatement psPatientsModals = null;
            ResultSet rsPatientsModals = null;
            try {
                psPatientsModals = conn.prepareStatement(
                    "SELECT p.*, GROUP_CONCAT(c.REASON SEPARATOR ', ') AS REASONS " +
                    "FROM patient_info p LEFT JOIN case_master c ON p.ID = c.PATIENT_ID " +
                    "GROUP BY p.ID ORDER BY p.ID"
                );
                rsPatientsModals = psPatientsModals.executeQuery();
                int modalCount = 0;
                while (rsPatientsModals.next()) {
                    int patientId = rsPatientsModals.getInt("ID");
                    String patientName = rsPatientsModals.getString("PNAME");
                    String gender = rsPatientsModals.getString("GENDER");
                    int age = rsPatientsModals.getInt("AGE");
                    String dob = rsPatientsModals.getString("DOB");
                    String bloodGroup = rsPatientsModals.getString("BGROUP");
                    String phone = rsPatientsModals.getString("PHONE");
                    String patientEmail = rsPatientsModals.getString("EMAIL");
                    String street = rsPatientsModals.getString("STREET");
                    String area = rsPatientsModals.getString("AREA");
                    String city = rsPatientsModals.getString("CITY");
                    String state = rsPatientsModals.getString("STATE");
                    String country = rsPatientsModals.getString("COUNTRY");
                    String pincode = rsPatientsModals.getString("PINCODE");
                    String medicalHistory = rsPatientsModals.getString("MEDICAL_HISTORY");
                    modalCount++;
        %>
        <div class="modal fade" id="editPatientModal_<%=patientId%>" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title">Edit Patient <%=patientId%></h4>
                    </div>
                    <div class="modal-body">
                        <form id="editPatientForm_<%=patientId%>" class="form-horizontal" action="edit_patient_validation.jsp" method="post">
                            <input type="hidden" name="patientid" value="<%=patientId%>">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Name</label>
                                <div class="col-sm-9">
                                    <input type="text" name="pname" class="form-control" value="<%=patientName != null ? patientName : ""%>" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Gender</label>
                                <div class="col-sm-9">
                                    <select name="gender" class="form-control" required>
                                        <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                                        <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                                        <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Age</label>
                                <div class="col-sm-9">
                                    <input type="number" name="age" class="form-control" value="<%=age > 0 ? age : ""%>" required min="0" max="150">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Date of Birth</label>
                                <div class="col-sm-9">
                                    <input type="date" name="dob" class="form-control" value="<%=dob != null ? dob : ""%>">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Blood Group</label>
                                <div class="col-sm-9">
                                    <select name="bgroup" class="form-control" required>
                                        <option value="A+" <%= "A+".equals(bloodGroup) ? "selected" : "" %>>A+</option>
                                        <option value="A-" <%= "A-".equals(bloodGroup) ? "selected" : "" %>>A-</option>
                                        <option value="B+" <%= "B+".equals(bloodGroup) ? "selected" : "" %>>B+</option>
                                        <option value="B-" <%= "B-".equals(bloodGroup) ? "selected" : "" %>>B-</option>
                                        <option value="AB+" <%= "AB+".equals(bloodGroup) ? "selected" : "" %>>AB+</option>
                                        <option value="AB-" <%= "AB-".equals(bloodGroup) ? "selected" : "" %>>AB-</option>
                                        <option value="O+" <%= "O+".equals(bloodGroup) ? "selected" : "" %>>O+</option>
                                        <option value="O-" <%= "O-".equals(bloodGroup) ? "selected" : "" %>>O-</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Phone</label>
                                <div class="col-sm-9">
                                    <input type="text" name="phone" class="form-control" value="<%=phone != null ? phone : ""%>" required pattern="\d{10}">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Email</label>
                                <div class="col-sm-9">
                                    <input type="email" name="email" class="form-control" value="<%=patientEmail != null ? patientEmail : ""%>" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Street</label>
                                <div class="col-sm-9">
                                    <input type="text" name="street" class="form-control" value="<%=street != null ? street : ""%>">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Area</label>
                                <div class="col-sm-9">
                                    <input type="text" name="area" class="form-control" value="<%=area != null ? area : ""%>">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">City</label>
                                <div class="col-sm-9">
                                    <input type="text" name="city" class="form-control" value="<%=city != null ? city : ""%>">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">State</label>
                                <div class="col-sm-9">
                                    <input type="text" name="state" class="form-control" value="<%=state != null ? state : ""%>">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Country</label>
                                <div class="col-sm-9">
                                    <input type="text" name="country" class="form-control" value="<%=country != null ? country : ""%>">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Pincode</label>
                                <div class="col-sm-9">
                                    <input type="text" name="pincode" class="form-control" value="<%=pincode != null ? pincode : ""%>" pattern="\d{6}?">
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Medical History</label>
                                <div class="col-sm-9">
                                    <textarea name="medical_history" class="form-control"><%=medicalHistory != null ? medicalHistory : ""%></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-9">
                                    <button type="submit" class="btn btn-primary">Update Patient</button>
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal fade" id="addAdmissionModal_<%=patientId%>" tabindex="-1" role="dialog" aria-labelledby="addAdmissionModalLabel_<%=patientId%>">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                        <h4 class="modal-title" id="addAdmissionModalLabel_<%=patientId%>">Add Admission for Patient <%=patientId%></h4>
                    </div>
                    <div class="modal-body">
                        <form class="form-horizontal" action="add_patient_admission.jsp" method="post">
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
                                    <input type="text" id="admission_patient_name_<%=patientId%>" class="form-control" readonly>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case ID</label>
                                <div class="col-sm-9">
                                    <select name="case_id" id="case_id_<%=patientId%>" class="form-control" required>
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
                                                        int caseId = rsCase.getInt("CASE_ID");
                                                        String reason = rsCase.getString("REASON") != null ? rsCase.getString("REASON") : "Unknown";
                                                        String caseDate = rsCase.getString("CASE_DATE") != null ? rsCase.getString("CASE_DATE") : "N/A";
                                                        out.println("<option value=\"" + caseId + "\">" + caseId + " - " + reason + " (" + caseDate + ")</option>");
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
                                <label class="col-sm-3 control-label">Doctor ID</label>
                                <div class="col-sm-9">
                                    <select name="doctor_id" id="doctor_id_<%=patientId%>" class="form-control" required>
                                        <option value="">Select Doctor</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Room and Bed</label>
                                <div class="col-sm-9">
                                    <select name="room_bed" class="form-control" required>
                                        <option value="">Select Room and Bed</option>
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
                                                        String roomNo = rsRooms.getString("ROOM_NO") != null ? rsRooms.getString("ROOM_NO") : "N/A";
                                                        String roomType = rsRooms.getString("TYPE") != null ? rsRooms.getString("TYPE") : "Unknown";
                                                        String bedNo = rsRooms.getString("BED_NO") != null ? rsRooms.getString("BED_NO") : "N/A";
                                                        String value = roomNo + "_" + bedNo;
                                                        out.println("<option value=\"" + value + "\">" + roomNo + " - " + roomType + " - Bed " + bedNo + "</option>");
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                out.println("<option value=\"\">Error: " + e.getMessage() + "</option>");
                                            } finally {
                                                if (rsRooms != null) try { rsRooms.close(); } catch (SQLException ignore) {}
                                                if (psRooms != null) try { psRooms.close(); } catch (SQLException ignore) {}
                                            }
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Admission Date</label>
                                <div class="col-sm-9">
                                    <input type="date" name="admit_date" class="form-control" value="2025-06-16" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-9">
                                    <button type="submit" class="btn btn-primary">Add Admission</button>
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
                System.out.println("Generated " + modalCount + " modals for patients.");
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<div class='alert alert-danger'>Error generating modals: " + e.getMessage() + "</div>");
            } finally {
                if (rsPatientsModals != null) try { rsPatientsModals.close(); } catch (SQLException ignore) {}
                if (psPatientsModals != null) try { psPatientsModals.close(); } catch (SQLException ignore) {}
            }
        %>
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
                                <label class="col-sm-3 control-label">Patient Name</label>
                                <div class="col-sm-9">
                                    <input type="text" id="discharge_patient_name" class="form-control" readonly>
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