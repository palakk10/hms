<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Patients - Hospital Management System</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script>
        function confirmDelete() {
            return confirm("Do You Really Want to Delete This Prescription?");
        }
    </script>
    <style>
        .prescription-table {
            margin-top: 15px;
        }
        .prescription-table th {
            background-color: #f8f9fa;
        }
        .patient-details-table th {
            width: 30%;
        }
        .expandable-row {
            cursor: pointer;
        }
        .expandable-row:hover {
            background-color: #f5f5f5;
        }
        .expanded-details {
            display: none;
            background-color: #f9f9f9;
            padding: 15px;
            border-left: 4px solid #337ab7;
        }
        .action-buttons {
            white-space: nowrap;
        }
    </style>
</head>
<%@include file="header_doctor.jsp"%>
<body>
<div class="row">
    <%@include file="menu_doctor.jsp"%>

    <!---- Content Area Start -------->
    <div class="col-md-10 maincontent">
        <!---------------- Menu Tab --------------->
        <div class="panel panel-default contentinside">
            <div class="panel-heading">My Patients</div>
            <!---------------- Panel body Start --------------->
            <div class="panel-body">
                <div class="table-responsive">
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr class="active">
                                <th>Patient ID</th>
                                <th>Name</th>
                                <th>Age/Gender</th>
                                <th>Contact</th>
                                <th>Admission Details</th>
                                <th>Room Details</th>
                                <th>Prescriptions</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
<%
    Connection c = (Connection)application.getAttribute("connection");
    int doctorId = Integer.parseInt((String)session.getAttribute("id"));
    
    // Get all patients assigned to this doctor
    PreparedStatement psPatients = c.prepareStatement(
        "SELECT p.*, r.ROOM_NO, r.BED_NO, r.TYPE as room_type, r.STATUS as room_status, r.CHARGES as room_charges " +
        "FROM patient_info p LEFT JOIN room_info r ON (p.ROOM_NO = r.ROOM_NO AND p.BED_NO = r.BED_NO) " +
        "WHERE p.DOCTOR_ID = ?", 
        ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
    psPatients.setInt(1, doctorId);
    ResultSet rsPatients = psPatients.executeQuery();
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    
    while(rsPatients.next()) {
        int patientId = rsPatients.getInt("ID");
        String patientName = rsPatients.getString("PNAME");
        int age = rsPatients.getInt("AGE");
        String gender = rsPatients.getString("GENDER");
        String bloodGroup = rsPatients.getString("BGROUP");
        String phone = rsPatients.getString("PHONE");
        String reason = rsPatients.getString("REA_OF_VISIT");
        String admitDate = rsPatients.getString("DATE_AD");
        Integer roomNo = rsPatients.getInt("ROOM_NO") == 0 ? null : rsPatients.getInt("ROOM_NO");
        Integer bedNo = rsPatients.getInt("BED_NO") == 0 ? null : rsPatients.getInt("BED_NO");
        String roomType = rsPatients.getString("room_type");
        String roomStatus = rsPatients.getString("room_status");
        Integer roomCharges = rsPatients.getInt("room_charges") == 0 ? null : rsPatients.getInt("room_charges");
        String patientEmail = rsPatients.getString("EMAIL");
        String street = rsPatients.getString("STREET");
        String area = rsPatients.getString("AREA");
        String city = rsPatients.getString("CITY");
        String state = rsPatients.getString("STATE");
        String country = rsPatients.getString("COUNTRY");
        String pincode = rsPatients.getString("PINCODE");
        String problemDescription = rsPatients.getString("PROBLEM_DESCRIPTION");
        
        // Get prescriptions count for this patient
        PreparedStatement psPrescCount = c.prepareStatement(
            "SELECT COUNT(*) as presc_count FROM prescription WHERE PATIENT_ID = ?");
        psPrescCount.setInt(1, patientId);
        ResultSet rsPrescCount = psPrescCount.executeQuery();
        int prescriptionCount = 0;
        if(rsPrescCount.next()) {
            prescriptionCount = rsPrescCount.getInt("presc_count");
        }
        rsPrescCount.close();
        psPrescCount.close();
%>          
                            <tr class="expandable-row" onclick="toggleDetails(<%=patientId%>)">
                                <td><%=patientId%></td>
                                <td><%=patientName%></td>
                                <td><%=age%> / <%=gender%><br><small>Blood: <%=bloodGroup%></small></td>
                                <td>
                                    <%=phone%><br>
                                    <small><%=patientEmail%></small>
                                </td>
                                <td>
                                    <strong>Reason:</strong> <%=reason%><br>
                                    <strong>Admitted:</strong> <%=admitDate%><br>
                                    <strong>Problem:</strong> <%=problemDescription != null ? problemDescription : "N/A"%>
                                </td>
                                <td>
                                    <strong>Room:</strong> <%=(roomNo != null && bedNo != null) ? roomNo + "/" + bedNo + " (" + (roomType != null ? roomType : "N/A") + ")" : "Not Assigned"%><br>
                                    <strong>Status:</strong> <%=roomStatus != null ? roomStatus : "N/A"%><br>
                                    <strong>Charges:</strong> <%=roomCharges != null ? roomCharges : "N/A"%>
                                </td>
                                <td>
                                    <%=prescriptionCount%> prescription(s)
                                </td>
                                <td class="action-buttons">
                                    <button class="btn btn-primary btn-sm" data-toggle="modal" 
                                            data-target="#addPrescriptionModal<%=patientId%>">
                                        <span class="glyphicon glyphicon-plus"></span> Add Rx
                                    </button>
                                    <button class="btn btn-info btn-sm" data-toggle="modal" 
                                            data-target="#patientModal<%=patientId%>">
                                        <span class="glyphicon glyphicon-search"></span> View
                                    </button>
                                </td>
                            </tr>
                            <tr id="details-<%=patientId%>" class="expanded-details">
                                <td colspan="8">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <h4>Patient Details</h4>
                                            <table class="table table-bordered patient-details-table">
                                                <tr>
                                                    <th>Address</th>
                                                    <td>
                                                        <%=street%>, <%=area != null ? area + ", " : ""%>
                                                        <%=city%>, <%=state%>, <%=country%> - <%=pincode%>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th>Admission Date</th>
                                                    <td><%=admitDate%></td>
                                                </tr>
                                                <tr>
                                                    <th>Room/Bed</th>
                                                    <td><%=(roomNo != null && bedNo != null) ? roomNo + "/" + bedNo + " (" + (roomType != null ? roomType : "N/A") + ")" : "Not Assigned"%></td>
                                                </tr>
                                                <tr>
                                                    <th>Room Status</th>
                                                    <td><%=roomStatus != null ? roomStatus : "N/A"%></td>
                                                </tr>
                                                <tr>
                                                    <th>Room Charges</th>
                                                    <td><%=roomCharges != null ? roomCharges : "N/A"%></td>
                                                </tr>
                                                <tr>
                                                    <th>Problem Description</th>
                                                    <td><%=problemDescription != null ? problemDescription : "N/A"%></td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div class="col-md-6">
                                            <h4>Latest Prescriptions</h4>
                                            <table class="table table-bordered prescription-table">
                                                <thead>
                                                    <tr class="active">
                                                        <th>Date</th>
                                                        <th>Medicine</th>
                                                        <th>Dosage</th>
                                                        <th>Duration</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
<%
        // Get latest 3 prescriptions for this patient
        PreparedStatement psPresc = c.prepareStatement(
            "SELECT * FROM prescription WHERE PATIENT_ID = ? ORDER BY DATE_ISSUED DESC LIMIT 3");
        psPresc.setInt(1, patientId);
        ResultSet rsPresc = psPresc.executeQuery();
        
        boolean hasPrescriptions = false;
        while(rsPresc.next()) {
            hasPrescriptions = true;
            int prescId = rsPresc.getInt("PRESCRIPTION_ID");
            String medicine = rsPresc.getString("MEDICINE");
            String dosage = rsPresc.getString("DOSAGE");
            String duration = rsPresc.getString("DURATION");
            String dateIssued = rsPresc.getString("DATE_ISSUED");
            String notes = rsPresc.getString("NOTES");
%>
                                                    <tr>
                                                        <td><%=dateIssued%></td>
                                                        <td><%=medicine%></td>
                                                        <td><%=dosage%></td>
                                                        <td><%=duration%></td>
                                                        <td class="action-buttons">
                                                            <a href="#" class="btn btn-xs btn-warning" data-toggle="modal" 
                                                               data-target="#editPrescriptionModal<%=prescId%>">
                                                                <span class="glyphicon glyphicon-edit"></span>
                                                            </a>
                                                            <a href="delete_prescription.jsp?prescId=<%=prescId%>" 
                                                               class="btn btn-xs btn-danger" onclick="return confirmDelete()">
                                                                <span class="glyphicon glyphicon-trash"></span>
                                                            </a>
                                                        </td>
                                                    </tr>
<%
        }
        if (!hasPrescriptions) {
%>
                                                    <tr>
                                                        <td colspan="5" class="text-center">No prescriptions found</td>
                                                    </tr>
<%
        }
        rsPresc.close();
        psPresc.close();
%>
                                                </tbody>
                                            </table>
                                            <div class="text-right">
                                                <a href="#" class="btn btn-default btn-sm" data-toggle="modal" 
                                                   data-target="#patientModal<%=patientId%>">
                                                    View all prescriptions
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
<%
    }
    rsPatients.close();
    psPatients.close();
%>
                        </tbody>
                    </table>
                </div>

                <!------ Patient Details Modal Start Here ---------->
<%
    // Re-fetch patients to create modals
    PreparedStatement psPatientsModal = c.prepareStatement(
        "SELECT p.*, r.ROOM_NO, r.BED_NO, r.TYPE as room_type, r.STATUS as room_status, r.CHARGES as room_charges " +
        "FROM patient_info p LEFT JOIN room_info r ON (p.ROOM_NO = r.ROOM_NO AND p.BED_NO = r.BED_NO) " +
        "WHERE p.DOCTOR_ID = ?", 
        ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
    psPatientsModal.setInt(1, doctorId);
    ResultSet rsPatientsModal = psPatientsModal.executeQuery();
    
    while(rsPatientsModal.next()) {
        int patientId = rsPatientsModal.getInt("ID");
        String patientName = rsPatientsModal.getString("PNAME");
        int age = rsPatientsModal.getInt("AGE");
        String gender = rsPatientsModal.getString("GENDER");
        String bloodGroup = rsPatientsModal.getString("BGROUP");
        String phone = rsPatientsModal.getString("PHONE");
        String reason = rsPatientsModal.getString("REA_OF_VISIT");
        String admitDate = rsPatientsModal.getString("DATE_AD");
        Integer roomNo = rsPatientsModal.getInt("ROOM_NO") == 0 ? null : rsPatientsModal.getInt("ROOM_NO");
        Integer bedNo = rsPatientsModal.getInt("BED_NO") == 0 ? null : rsPatientsModal.getInt("BED_NO");
        String roomType = rsPatientsModal.getString("room_type");
        String roomStatus = rsPatientsModal.getString("room_status");
        Integer roomCharges = rsPatientsModal.getInt("room_charges") == 0 ? null : rsPatientsModal.getInt("room_charges");
        String patientEmail = rsPatientsModal.getString("EMAIL");
        String street = rsPatientsModal.getString("STREET");
        String area = rsPatientsModal.getString("AREA");
        String city = rsPatientsModal.getString("CITY");
        String state = rsPatientsModal.getString("STATE");
        String country = rsPatientsModal.getString("COUNTRY");
        String pincode = rsPatientsModal.getString("PINCODE");
        String problemDescription = rsPatientsModal.getString("PROBLEM_DESCRIPTION");
%>              
                <div class="modal fade" id="patientModal<%=patientId%>" tabindex="-1" role="dialog" aria-labelledby="patientModalLabel">
                    <div class="modal-dialog modal-lg" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">×</span>
                                </button>
                                <h4 class="modal-title" id="patientModalLabel">Patient Details - <%=patientName%> (ID: <%=patientId%>)</h4>
                            </div>
                            <div class="modal-body">
                                <ul class="nav nav-tabs">
                                    <li class="active"><a data-toggle="tab" href="#basicInfo<%=patientId%>">Basic Info</a></li>
                                    <li><a data-toggle="tab" href="#prescriptions<%=patientId%>">Prescriptions</a></li>
                                    <li><a data-toggle="tab" href="#reports<%=patientId%>">Reports</a></li>
                                    <li><a data-toggle="tab" href="#billing<%=patientId%>">Billing</a></li>
                                </ul>
                                <div class="tab-content">
                                    <!-- Basic Info Tab -->
                                    <div id="basicInfo<%=patientId%>" class="tab-pane fade in active">
                                        <div class="panel panel-default" style="margin-top: 15px;">
                                            <div class="panel-body">
                                                <div class="row">
                                                    <div class="col-md-6">
                                                        <h4>Personal Information</h4>
                                                        <table class="table table-bordered">
                                                            <tr>
                                                                <th>Name</th>
                                                                <td><%=patientName%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Age</th>
                                                                <td><%=age%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Gender</th>
                                                                <td><%=gender%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Blood Group</th>
                                                                <td><%=bloodGroup%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Email</th>
                                                                <td><%=patientEmail%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Phone</th>
                                                                <td><%=phone%></td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                    <div class="col-md-6">
                                                        <h4>Hospital Information</h4>
                                                        <table class="table table-bordered">
                                                            <tr>
                                                                <th>Reason of Visit</th>
                                                                <td><%=reason%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Admission Date</th>
                                                                <td><%=admitDate%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Room/Bed</th>
                                                                <td><%=(roomNo != null && bedNo != null) ? roomNo + "/" + bedNo + " (" + (roomType != null ? roomType : "N/A") + ")" : "Not Assigned"%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Room Status</th>
                                                                <td><%=roomStatus != null ? roomStatus : "N/A"%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Room Charges</th>
                                                                <td><%=roomCharges != null ? roomCharges : "N/A"%></td>
                                                            </tr>
                                                            <tr>
                                                                <th>Problem Description</th>
                                                                <td><%=problemDescription != null ? problemDescription : "N/A"%></td>
                                                            </tr>
                                                        </table>
                                                        <h4>Address</h4>
                                                        <address>
                                                            <%=street%>, <%=area != null ? area + "<br>" : ""%>
                                                            <%=city%>, <%=state%><br>
                                                            <%=country%> - <%=pincode%>
                                                        </address>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Prescriptions Tab -->
                                    <div id="prescriptions<%=patientId%>" class="tab-pane fade">
                                        <div class="panel panel-default" style="margin-top: 15px;">
                                            <div class="panel-heading">
                                                <h4>Prescriptions</h4>
                                                <button class="btn btn-primary btn-sm" data-toggle="modal" 
                                                        data-target="#addPrescriptionModal<%=patientId%>">
                                                    <span class="glyphicon glyphicon-plus"></span> Add New Prescription
                                                </button>
                                            </div>
                                            <div class="panel-body">
                                                <table class="table table-bordered table-striped">
                                                    <thead>
                                                        <tr class="active">
                                                            <th>Date</th>
                                                            <th>Medicine</th>
                                                            <th>Dosage</th>
                                                            <th>Duration</th>
                                                            <th>Notes</th>
                                                            <th>Actions</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
<%
        // Get all prescriptions for this patient
        PreparedStatement psPrescAll = c.prepareStatement(
            "SELECT * FROM prescription WHERE PATIENT_ID = ? ORDER BY DATE_ISSUED DESC");
        psPrescAll.setInt(1, patientId);
        ResultSet rsPrescAll = psPrescAll.executeQuery();
        
        while(rsPrescAll.next()) {
            int prescId = rsPrescAll.getInt("PRESCRIPTION_ID");
            String medicine = rsPrescAll.getString("MEDICINE");
            String dosage = rsPrescAll.getString("DOSAGE");
            String duration = rsPrescAll.getString("DURATION");
            String dateIssued = rsPrescAll.getString("DATE_ISSUED");
            String notes = rsPrescAll.getString("NOTES");
%>
                                                        <tr>
                                                            <td><%=dateIssued%></td>
                                                            <td><%=medicine%></td>
                                                            <td><%=dosage%></td>
                                                            <td><%=duration%></td>
                                                            <td><%=notes != null ? notes : ""%></td>
                                                            <td class="action-buttons">
                                                                <a href="#" class="btn btn-xs btn-warning" data-toggle="modal" 
                                                                   data-target="#editPrescriptionModal<%=prescId%>">
                                                                    <span class="glyphicon glyphicon-edit"></span>
                                                                </a>
                                                                <a href="delete_prescription.jsp?prescId=<%=prescId%>" 
                                                                   class="btn btn-xs btn-danger" onclick="return confirmDelete()">
                                                                    <span class="glyphicon glyphicon-trash"></span>
                                                                </a>
                                                            </td>
                                                        </tr>
<%
        }
        rsPrescAll.close();
        psPrescAll.close();
%>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Reports Tab -->
                                    <div id="reports<%=patientId%>" class="tab-pane fade">
                                        <div class="panel panel-default" style="margin-top: 15px;">
                                            <div class="panel-heading">
                                                <h4>Patient Reports</h4>
                                            </div>
                                            <div class="panel-body">
                                                <table class="table table-bordered">
                                                    <tr class="active">
                                                        <th>X-Ray</th>
                                                        <th>Ultrasound</th>
                                                        <th>Blood Test</th>
                                                        <th>CT Scan</th>
                                                        <th>X-Ray Count</th>
                                                        <th>Ultrasound Count</th>
                                                        <th>Blood Test Count</th>
                                                        <th>CT Scan Count</th>
                                                        <th>Charges</th>
                                                    </tr>
<%
        // Get pathology reports for this patient
        PreparedStatement psPatho = c.prepareStatement(
            "SELECT * FROM pathology WHERE ID = ?");
        psPatho.setInt(1, patientId);
        ResultSet rsPatho = psPatho.executeQuery();
        
        if(rsPatho.next()) {
            String xray = rsPatho.getString("X_RAYS");
            String usound = rsPatho.getString("U_SOUND");
            String btest = rsPatho.getString("B_TEST");
            String ctscan = rsPatho.getString("CT_SCAN");
            int xrayCount = rsPatho.getInt("xray_count");
            int usCount = rsPatho.getInt("us_count");
            int btCount = rsPatho.getInt("bt_count");
            int ctCount = rsPatho.getInt("ct_count");
            int charges = rsPatho.getInt("CHARGES");
%>
                                                    <tr>
                                                        <td><%=xray != null ? xray : "N/A"%></td>
                                                        <td><%=usound != null ? usound : "N/A"%></td>
                                                        <td><%=btest != null ? btest : "N/A"%></td>
                                                        <td><%=ctscan != null ? ctscan : "N/A"%></td>
                                                        <td><%=xrayCount%></td>
                                                        <td><%=usCount%></td>
                                                        <td><%=btCount%></td>
                                                        <td><%=ctCount%></td>
                                                        <td><%=charges%></td>
                                                    </tr>
<%
        } else {
%>
                                                    <tr>
                                                        <td colspan="9" class="text-center">No reports available</td>
                                                    </tr>
<%
        }
        rsPatho.close();
        psPatho.close();
%>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                    <!-- Billing Tab -->
                                    <div id="billing<%=patientId%>" class="tab-pane fade">
                                        <div class="panel panel-default" style="margin-top: 15px;">
                                            <div class="panel-heading">
                                                <h4>Billing Information</h4>
                                            </div>
                                            <div class="panel-body">
                                                <table class="table table-bordered">
                                                    <tr class="active">
                                                        <th>Bill No</th>
                                                        <th>OT Charges</th>
                                                        <th>Pathology Charges</th>
                                                        <th>Entry Date</th>
                                                        <th>Discharge Date</th>
                                                    </tr>
<%
        // Get billing information for this patient
        PreparedStatement psBilling = c.prepareStatement(
            "SELECT * FROM billing WHERE ID_NO = ?");
        psBilling.setInt(1, patientId);
        ResultSet rsBilling = psBilling.executeQuery();
        
        if(rsBilling.next()) {
            int billNo = rsBilling.getInt("BILL_NO");
            int otCharge = rsBilling.getInt("OT_CHARGE");
            int pathologyCharge = rsBilling.getInt("PATHOLOGY");
            String entryDate = rsBilling.getString("ENT_DATE");
            String dischargeDate = rsBilling.getString("DIS_DATE");
%>
                                                    <tr>
                                                        <td><%=billNo%></td>
                                                        <td><%=otCharge > 0 ? otCharge : "N/A"%></td>
                                                        <td><%=pathologyCharge > 0 ? pathologyCharge : "N/A"%></td>
                                                        <td><%=entryDate%></td>
                                                        <td><%=dischargeDate%></td>
                                                    </tr>
<%
        } else {
%>
                                                    <tr>
                                                        <td colspan="5" class="text-center">No billing information available</td>
                                                    </tr>
<%
        }
        rsBilling.close();
        psBilling.close();
%>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Add Prescription Modal -->
                <div class="modal fade" id="addPrescriptionModal<%=patientId%>" tabindex="-1" role="dialog" 
                     aria-labelledby="addPrescriptionModalLabel">
                    <div class="modal-dialog" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">×</span>
                                </button>
                                <h4 class="modal-title" id="addPrescriptionModalLabel">Add Prescription for <%=patientName%></h4>
                            </div>
                            <form action="add_prescription.jsp" method="post">
                                <input type="hidden" name="patientid" value="<%=patientId%>">
                                <input type="hidden" name="doctorid" value="<%=doctorId%>">
                                <div class="modal-body">
                                    <div class="form-group">
                                        <label>Medicine</label>
                                        <input type="text" class="form-control" name="medicine" required>
                                    </div>
                                    <div class="form-group">
                                        <label>Dosage</label>
                                        <input type="text" class="form-control" name="dosage" required>
                                    </div>
                                    <div class="form-group">
                                        <label>Duration</label>
                                        <input type="text" class="form-control" name="duration" required>
                                    </div>
                                    <div class="form-group">
                                        <label>Notes</label>
                                        <textarea class="form-control" name="notes" rows="3"></textarea>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                                    <button type="submit" class="btn btn-primary">Save Prescription</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <!-- Edit Prescription Modals -->
<%
        // Re-fetch prescriptions to create edit modals with unique variable names
        PreparedStatement psPrescEdit = c.prepareStatement(
            "SELECT * FROM prescription WHERE PATIENT_ID = ?");
        psPrescEdit.setInt(1, patientId);
        ResultSet rsPrescEdit = psPrescEdit.executeQuery();
        
        while(rsPrescEdit.next()) {
            int prescId = rsPrescEdit.getInt("PRESCRIPTION_ID");
            String medicine = rsPrescEdit.getString("MEDICINE");
            String dosage = rsPrescEdit.getString("DOSAGE");
            String duration = rsPrescEdit.getString("DURATION");
            String notes = rsPrescEdit.getString("NOTES");
%>
                <div class="modal fade" id="editPrescriptionModal<%=prescId%>" tabindex="-1" role="dialog" 
                     aria-labelledby="editPrescriptionModalLabel">
                    <div class="modal-dialog" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">×</span>
                                </button>
                                <h4 class="modal-title" id="editPrescriptionModalLabel">Edit Prescription</h4>
                            </div>
                            <form action="update_prescription.jsp" method="post">
                                <input type="hidden" name="prescid" value="<%=prescId%>">
                                <div class="modal-body">
                                    <div class="form-group">
                                        <label>Medicine</label>
                                        <input type="text" class="form-control" name="medicine" value="<%=medicine%>" required>
                                    </div>
                                    <div class="form-group">
                                        <label>Dosage</label>
                                        <input type="text" class="form-control" name="dosage" value="<%=dosage%>" required>
                                    </div>
                                    <div class="form-group">
                                        <label>Duration</label>
                                        <input type="text" class="form-control" name="duration" value="<%=duration%>" required>
                                    </div>
                                    <div class="form-group">
                                        <label>Notes</label>
                                        <textarea class="form-control" name="notes" rows="3"><%=notes != null ? notes : ""%></textarea>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                                    <button type="submit" class="btn btn-primary">Update Prescription</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
<%
        }
        rsPrescEdit.close();
        psPrescEdit.close();
%>
<%
    }
    rsPatientsModal.close();
    psPatientsModal.close();
%>
                </div>
                <!---------------- Panel body Ends --------------->
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
    <script>
        function toggleDetails(patientId) {
            var detailsRow = document.getElementById('details-' + patientId);
            if (detailsRow.style.display === 'none') {
                detailsRow.style.display = 'table-row';
            } else {
                detailsRow.style.display = 'none';
            }
        }
        // Close all expanded rows when clicking anywhere else
        document.addEventListener('click', function(event) {
            if (!event.target.closest('.expandable-row')) {
                var expandedRows = document.querySelectorAll('.expanded-details');
                expandedRows.forEach(function(row) {
                    row.style.display = 'none';
                });
            }
        });
    </script>
</body>
</html>