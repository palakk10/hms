<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Patient Reports</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script>
        $(function() {
            $('.view-cases-btn').click(function() {
                var patientId = $(this).data('patient-id');
                $('#viewCasesModal #patientId').val(patientId);
                $.ajax({
                    url: 'get_cases.jsp',
                    method: 'GET',
                    data: { patientId: patientId },
                    dataType: 'json',
                    success: function(data) {
                        var tbody = $('#viewCasesModal .case-table tbody');
                        tbody.empty();
                        if (data.length === 0) {
                            tbody.append('<tr><td colspan="4">No cases found.</td></tr>');
                        } else {
                            $.each(data, function(i, c) {
                                tbody.append(
                                    '<tr>' +
                                    '<td>' + (c.id || '-') + '</td>' +
                                    '<td>' + (c.date || '-') + '</td>' +
                                    '<td>' + (c.reason || '-') + '</td>' +
                                    '<td>' + (c.details || '-') + '</td>' +
                                    '</tr>'
                                );
                            });
                        }
                    },
                    error: function() {
                        $('#viewCasesModal .case-table tbody').html('<tr><td colspan="4">Error loading cases.</td></tr>');
                    }
                });
                $('#viewCasesModal').modal('show');
            });
        });
    </script>
</head>
<body>
    <%@include file="header_doctor.jsp"%>
    <div class="row">
        <%@include file="menu_doctor.jsp"%>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Patient Reports</div>
                <div class="panel-body">
                    <ul class="nav nav-tabs">
                        <li class="active"><a href="#pathology">Pathology Reports</a></li>
                    </ul>
                    <div id="pathology" class="tab-pane fade in active">
                        <table class="table table-bordered table-hover">
                            <thead>
                                <tr>
                                    <th>Patient ID</th>
                                    <th>Name</th>
                                    <th>X-Ray</th>
                                    <th>Ultrasound</th>
                                    <th>Blood Test</th>
                                    <th>CT Scan</th>
                                    <th>Charges</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                            <%
                                if (session.getAttribute("id") == null) {
                                    response.sendRedirect("login.jsp");
                                    return;
                                }
                                int doctorId = Integer.parseInt((String) session.getAttribute("id"));
                                Connection conn = (Connection) application.getAttribute("connection");
                                PreparedStatement ps = null;
                                ResultSet rs = null;
                                try {
                                    ps = conn.prepareStatement(
                                        "SELECT p.ID, p.PNAME, pa.X_RAYS, pa.U_SOUND, pa.B_TEST, pa.CT_SCAN, pa.CHARGES " +
                                        "FROM patient_info p JOIN pathology pa ON p.ID = pa.ID " +
                                        "JOIN case_master cm ON p.ID = cm.PATIENT_ID WHERE cm.DOCTOR_ID = ?",
                                        ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                                    );
                                    ps.setInt(1, doctorId);
                                    rs = ps.executeQuery();
                                    if (!rs.isBeforeFirst()) {
                                        out.println("<tr><td colspan='8'>No reports found.</td></tr>");
                                    } else {
                                        while (rs.next()) {
                                            int patientId = rs.getInt("ID");
                                            String patientName = rs.getString("PNAME");
                                            String xray = rs.getString("X_RAYS");
                                            String usound = rs.getString("U_SOUND");
                                            String btest = rs.getString("B_TEST");
                                            String ctscan = rs.getString("CT_SCAN");
                                            int charges = rs.getInt("CHARGES");
                            %>
                            <tr>
                                <td><%=patientId%></td>
                                <td><%=patientName != null ? patientName : "N/A"%></td>
                                <td><%=xray != null ? xray : "N/A"%></td>
                                <td><%=usound != null ? usound : "N/A"%></td>
                                <td><%=btest != null ? btest : "N/A"%></td>
                                <td><%=ctscan != null ? ctscan : "N/A"%></td>
                                <td><%=charges%></td>
                                <td>
                                    <button class="btn btn-info btn-sm view-cases-btn" data-patient-id="<%=patientId%>"><span class="glyphicon glyphicon-eye-open"></span> Cases</button>
                                </td>
                            </tr>
                            <%
                                        }
                                    }
                                } catch (SQLException e) {
                                    out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                                    if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
                                }
                            %>
                            </tbody>
                        </table>
                    </div>
                    <div class="modal fade" id="viewCasesModal" tabindex="-1" role="dialog">
                        <div class="modal-dialog modal-lg" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal"><span aria-hidden="true">×</span></button>
                                    <h4 class="modal-title">Patient Cases</h4>
                                </div>
                                <div class="modal-body">
                                    <input type="hidden" id="patientId">
                                    <table class="table table-bordered table-hover case-table">
                                        <thead><tr><th>Case ID</th><th>Date</th><th>Reason</th><th>Details</th></tr></thead>
                                        <tbody></tbody>
                                    </table>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
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