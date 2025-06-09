
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.net.URLDecoder" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Billing Information</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css">
    <link rel="stylesheet" href="css/style.css">
    <style>
        #addBilling .form-group { margin-bottom: 15px !important; }
        #addBilling .panel-body { padding: 15px !important; }
        #addBilling .control-label { padding-right: 0; }
        #addBilling { margin: 0 !important; padding: 5px !important; background-color: #f0f8ff; }
        .panel, .panel-body, .tab-content, .row { margin: 0 !important; padding: 0 !important; }
        .maincontent { position: relative !important; min-height: 603px !important; }
        .contentinside { margin-top: 10px !important; }
        .panel-heading { padding: 10px 15px !important; }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script>
        $(document).ready(function() {
            console.log("billing.jsp loaded");
            var urlParams = new URLSearchParams(window.location.search);
            var tab = urlParams.get('tab');
            console.log("Tab parameter:", tab);

            // Remove active classes from all tabs and panes
            $('.nav-tabs li').removeClass('active');
            $('.tab-pane').removeClass('active in');

            if (tab === 'addBilling') {
                console.log("Activating Add Billing tab");
                $('.nav-tabs a[href="#addBilling"]').parent().addClass('active');
                $('#addBilling').addClass('active in');
                $('.nav-tabs a[href="#addBilling"]').tab('show');
            } else {
                console.log("Activating Billing List tab");
                $('.nav-tabs a[href="#billingList"]').parent().addClass('active');
                $('#billingList').addClass('active in');
                $('.nav-tabs a[href="#billingList"]').tab('show');
            }

            $('#addBillingForm').on('submit', function(e) {
                console.log("Form submission triggered");
                var patientId = $('#patientId').val().trim();
                var patientName = $('#patientName').val().trim();
                var otherCharge = $('#otherCharge').val().trim();
                var roomCharge = $('#roomCharge').val().trim();
                var pathoCharge = $('#pathoCharge').val().trim();
                var entryDate = $('#entryDate').val();
                var disDate = $('#disDate').val();

                if (!patientId.match(/^\d+$/)) {
                    alert("Patient ID must be a valid number.");
                    e.preventDefault();
                } else if (!patientName) {
                    alert("Patient Name is required.");
                    e.preventDefault();
                } else if (!otherCharge.match(/^\d+(\.\d{1,2})?$/) && otherCharge !== '0') {
                    alert("Other Charge must be a valid number (up to 2 decimal places).");
                    e.preventDefault();
                } else if (!roomCharge.match(/^\d+(\.\d{1,2})?$/) && roomCharge !== '0') {
                    alert("Room Charge must be a valid number (up to 2 decimal places).");
                    e.preventDefault();
                } else if (!pathoCharge.match(/^\d+(\.\d{1,2})?$/) && pathoCharge !== '0') {
                    alert("Pathology Charge must be a valid number (up to 2 decimal places).");
                    e.preventDefault();
                } else if (!entryDate) {
                    alert("Entry Date is required.");
                    e.preventDefault();
                } else if (!disDate) {
                    alert("Discharge Date is required.");
                    e.preventDefault();
                }
                console.log("Form validation passed");
            });
        });
    </script>
</head>
<body>
    <%
        String patientId = request.getParameter("patientId");
        String patientName = request.getParameter("patientName");
        String admitDate = request.getParameter("admitDate");
        double pathoCharge = 0.0;
        double roomCharge = 0.0;
        Connection conn = (Connection) application.getAttribute("connection");
        PreparedStatement psPatho = null;
        ResultSet rsPatho = null;
        PreparedStatement psRoom = null;
        ResultSet rsRoom = null;

        try {
            if (patientId != null && !patientId.trim().isEmpty()) {
                // Fetch pathology charges
                psPatho = conn.prepareStatement("SELECT SUM(CHARGES) AS total_charges FROM pathology WHERE ID = ?");
                psPatho.setInt(1, Integer.parseInt(patientId));
                rsPatho = psPatho.executeQuery();
                if (rsPatho.next()) {
                    pathoCharge = rsPatho.getDouble("total_charges");
                    if (rsPatho.wasNull()) {
                        pathoCharge = 0.0;
                    }
                }

                // Fetch room charges for form
                psRoom = conn.prepareStatement(
                    "SELECT ri.CHARGES FROM patient_info pi " +
                    "LEFT JOIN room_info ri ON pi.ROOM_NO = ri.ROOM_NO AND pi.BED_NO = ri.BED_NO " +
                    "WHERE pi.ID = ?"
                );
                psRoom.setInt(1, Integer.parseInt(patientId));
                rsRoom = psRoom.executeQuery();
                if (rsRoom.next()) {
                    roomCharge = rsRoom.getDouble("CHARGES");
                    if (rsRoom.wasNull()) {
                        roomCharge = 0.0;
                    }
                }
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error fetching charges: " + e.getMessage() + "</div>");
        } finally {
            if (rsPatho != null) try { rsPatho.close(); } catch (SQLException e) {}
            if (psPatho != null) try { psPatho.close(); } catch (SQLException e) {}
            if (rsRoom != null) try { rsRoom.close(); } catch (SQLException e) {}
            if (psRoom != null) try { psRoom.close(); } catch (SQLException e) {}
        }

        patientName = patientName != null ? URLDecoder.decode(patientName, "UTF-8") : "";
        admitDate = admitDate != null ? URLDecoder.decode(admitDate, "UTF-8") : "";
    %>
    <div class="row">
        <%@include file="header.jsp"%>
        <%@include file="menu.jsp"%>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Manage Billing Information</div>
                <div class="panel-body">
                    <ul class="nav nav-tabs">
                        <li role="presentation"><a href="#billingList" data-toggle="tab">Billing List</a></li>
                        <li role="presentation"><a href="#addBilling" data-toggle="tab">Add Billing Info</a></li>
                    </ul>
                    <div class="tab-content">
                        <!-- Billing List -->
                        <div id="billingList" class="tab-pane fade">
                            <table class="table table-bordered table-hover">
                                <tr class="active">
                                    <td>Bill No</td>
                                    <td>Patient ID</td>
                                    <td>Patient Name</td>
                                    <td>Pathology Charge</td>
                                    <td>Room Charge</td>
                                    <td>Other Charge</td>
                                    <td>Entry Date</td>
                                    <td>Discharge Date</td>
                                    <td>Total Charge</td>
                                    
                                </tr>
                                <%
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;
                                    PreparedStatement psRoomBill = null;
                                    ResultSet rsRoomBill = null;
                                    try {
                                        ps = conn.prepareStatement("SELECT BILL_NO, ID_NO, PNAME, OT_CHARGE, PATHOLOGY, ENT_DATE, DIS_DATE FROM billing");
                                        rs = ps.executeQuery();
                                        while (rs.next()) {
                                            int billNo = rs.getInt("BILL_NO");
                                            int idNo = rs.getInt("ID_NO");
                                            String pname = rs.getString("PNAME");
                                            double otCharge = rs.getDouble("OT_CHARGE");
                                            double pathology = rs.getDouble("PATHOLOGY");
                                            String entDate = rs.getString("ENT_DATE");
                                            String disDate = rs.getString("DIS_DATE");
                                            double roomChg = 0.0;

                                            // Fetch room charge for this patient
                                            psRoomBill = conn.prepareStatement(
                                                "SELECT ri.CHARGES FROM patient_info pi " +
                                                "LEFT JOIN room_info ri ON pi.ROOM_NO = ri.ROOM_NO AND pi.BED_NO = ri.BED_NO " +
                                                "WHERE pi.ID = ?"
                                            );
                                            psRoomBill.setInt(1, idNo);
                                            rsRoomBill = psRoomBill.executeQuery();
                                            if (rsRoomBill.next()) {
                                                roomChg = rsRoomBill.getDouble("CHARGES");
                                                if (rsRoomBill.wasNull()) {
                                                    roomChg = 0.0;
                                                }
                                            }

                                            // Calculate other charge (excluding room)
                                            double otherChg = otCharge - roomChg;
                                            if (otherChg < 0) otherChg = 0.0; // Prevent negative values

                                            // Calculate total charge
                                            double totalCharge = pathology + otCharge;
                                %>
                                <tr>
                                    <td><%=billNo%></td>
                                    <td><%=idNo%></td>
                                    <td><%=pname%></td>
                                    <td><%=String.format("%.2f", pathology)%></td>
                                    <td><%=String.format("%.2f", roomChg)%></td>
                                    <td><%=String.format("%.2f", otherChg)%></td>
                                    <td><%=entDate%></td>
                                    <td><%=disDate%></td>
                                    <td><%=String.format("%.2f", totalCharge)%></td>
                                    <td>
                                        <a href="#"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#editModal<%=billNo%>"><span class="glyphicon glyphicon-wrench"></span></button></a>
                                        <a href="delete_billing_validation.jsp?billNo=<%=billNo%>" onclick="return confirm('Do you really want to delete this bill?')" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span></a>
                                    </td>
                                </tr>
                                <!-- Edit Billing Modal -->
                                <div class="modal fade" id="editModal<%=billNo%>" tabindex="-1" role="dialog">
                                    <div class="modal-dialog" role="document">
                                        <div class="modal-content">
                                            <div class="modal-header">
                                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                                <h4 class="modal-title">Edit Billing Information</h4>
                                            </div>
                                            <div class="modal-body">
                                                <form class="form-horizontal" action="edit_billing_validation.jsp" method="post">
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Bill Number:</label>
                                                        <div class="col-sm-10">
                                                            <input type="number" class="form-control" name="bill_no" value="<%=billNo%>" readonly>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Patient Id</label>
                                                        <div class="col-sm-10">
                                                            <input type="number" class="form-control" name="patient_id" value="<%=idNo%>" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Name</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="patient_name" value="<%=pname%>" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Pathology Charge</label>
                                                        <div class="col-sm-10">
                                                            <input type="number" step="0.01" class="form-control" name="pathology_charge" value="<%=pathology%>" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Other Charge (incl. Room)</label>
                                                        <div class="col-sm-10">
                                                            <input type="number" step="0.01" class="form-control" name="other_charge" value="<%=otCharge%>" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Entry Date</label>
                                                        <div class="col-sm-10">
                                                            <input type="date" class="form-control" name="entry_date" value="<%=entDate%>" required>
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Discharge Date</label>
                                                        <div class="col-sm-10">
                                                            <input type="date" class="form-control" name="dis_date" value="<%=disDate%>" required>
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
                                <%
                                        }
                                    } catch (SQLException e) {
                                        out.println("<div class='alert alert-danger'>Error loading billing list: " + e.getMessage() + "</div>");
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                        if (rsRoomBill != null) try { rsRoomBill.close(); } catch (SQLException e) {}
                                        if (psRoomBill != null) try { psRoomBill.close(); } catch (SQLException e) {}
                                    }
                                %>
                            </table>
                        </div>
                        <!-- Add Billing Info -->
                        <div id="addBilling" class="tab-pane fade">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <form class="form-horizontal" action="add_billing_validation.jsp" method="post" id="addBillingForm">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Billing No:</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" name="bill_no" placeholder="Auto-generated" readonly>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Patient Id</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" name="patient_id" id="patientId" value="<%= patientId != null ? patientId : "" %>" placeholder="Patient ID" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Patient Name</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="patient_name" id="patientName" value="<%= patientName %>" placeholder="Patient Name" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Pathology Charge</label>
                                            <div class="col-sm-10">
                                                <input type="number" step="0.01" class="form-control" name="pathology_charge" id="pathoCharge" value="<%= String.format("%.2f", pathoCharge) %>" placeholder="Pathology Charge" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Room Charge</label>
                                            <div class="col-sm-10">
                                                <input type="number" step="0.01" class="form-control" name="room_charge" id="roomCharge" value="<%= String.format("%.2f", roomCharge) %>" readonly>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Other Charge</label>
                                            <div class="col-sm-10">
                                                <input type="number" step="0.01" class="form-control" name="other_charge" id="otherCharge" placeholder="Additional Other Charges" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Entry Date</label>
                                            <div class="col-sm-10">
                                                <input type="date" class="form-control" name="entry_date" id="entryDate" value="<%= admitDate %>" placeholder="Entry Date" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Discharge Date</label>
                                            <div class="col-sm-10">
                                                <input type="date" class="form-control" name="dis_date" id="disDate" placeholder="Discharge Date" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-sm-offset-2 col-sm-10">
                                                <button type="submit" class="btn btn-primary">Add Billing Info</button>
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