<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Room</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <style>
        .contentinside { margin-top: 10px; }
        .panel-heading { padding: 10px 15px; }
        .form-group { margin-bottom: 15px; }
        .maincontent { min-height: 603px; }
        .charges-display { background-color: #f5f5f5; padding: 8px; border-radius: 4px; }
        .error-message { color: red; text-align: center; }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script>
        function confirmDelete() {
            return confirm("Do you really want to delete this room?");
        }

        $(document).ready(function() {
            const roomTypeRates = {
                'Common': 2000,
                'Deluxe': 5000,
                'ICU': 10000
            };

            // Update charges display in Add Room form
            $('#roomTypeAdd').on('change', function() {
                const type = $(this).val();
                const charges = roomTypeRates[type] || '';
                $('#chargesDisplayAdd').val(charges);
            });

            // Trigger initial charges display
            $('#roomTypeAdd').trigger('change');

            // Update charges display in Edit Room forms
            $(document).on('change', '[id^="roomTypeEdit"]', function() {
                const form = $(this).closest('form');
                const type = $(this).val();
                const charges = roomTypeRates[type] || '';
                form.find('.charges-display').text(charges);
            });

            // Validate Add Room form
            $('#addRoomForm').on('submit', function(e) {
                const roomNo = $('#roomNoAdd').val();
                const bedNo = $('#bedNoAdd').val();
                const type = $('#roomTypeAdd').val();
                if (!roomNo || roomNo <= 0) {
                    alert('Room Number must be a positive number.');
                    e.preventDefault();
                } else if (!bedNo || bedNo <= 0) {
                    alert('Bed Number must be a positive number.');
                    e.preventDefault();
                } else if (!type) {
                    alert('Room Type is required.');
                    e.preventDefault();
                }
            });

            // Validate Edit Room forms
            $(document).on('submit', '[id^="editRoomForm"]', function(e) {
                const bedNo = $(this).find('[id^="bedNoEdit"]').val();
                const type = $(this).find('[id^="roomTypeEdit"]').val();
                if (!bedNo || bedNo <= 0) {
                    alert('Bed Number must be a positive number.');
                    e.preventDefault();
                } else if (!type) {
                    alert('Room Type is required.');
                    e.preventDefault();
                }
            });

            // Ensure Room List tab is visible on click
            $('a[href="#roomList"]').on('shown.bs.tab', function() {
                $('#roomList').addClass('active in');
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
                <div class="panel-heading">Manage Room</div>
                <div class="panel-body">
                    <ul class="nav nav-tabs">
                        <li role="presentation" class="active"><a href="#roomList" data-toggle="tab">Room List</a></li>
                        <li role="presentation"><a href="#addRoom" data-toggle="tab">Add Room</a></li>
                    </ul>
                    <div class="tab-content">
                        <!-- Room List -->
                        <div id="roomList" class="tab-pane active">
                            <%
                                Connection c = (Connection) application.getAttribute("connection");
                                PreparedStatement ps = null;
                                PreparedStatement patientPs = null;
                                ResultSet rs = null;
                                try {
                                    ps = c.prepareStatement("SELECT ROOM_NO, BED_NO, STATUS, TYPE, CHARGES FROM room_info ORDER BY ROOM_NO, BED_NO ASC");
                                    rs = ps.executeQuery();
                                    if (!rs.isBeforeFirst()) {
                            %>
                            <p class="error-message">No rooms found in the database.</p>
                            <%
                                    } else {
                            %>
                            <table class="table table-bordered table-hover">
                                <tr class="active">
                                    <th>Room Number</th>
                                    <th>Bed No</th>
                                    <th>Availability Status</th>
                                    <th>Room Type</th>
                                    <th>Charges (Rs/day)</th>
                                    <th>Options</th>
                                </tr>
                                <%
                                    patientPs = c.prepareStatement("SELECT COUNT(*) FROM admission WHERE ROOM_NO = ? AND BED_NO = ? AND DISCHARGE_DATE IS NULL");
                                    while (rs.next()) {
                                        int roomNo = rs.getInt("ROOM_NO");
                                        int bedNo = rs.getInt("BED_NO");
                                        String storedStatus = rs.getString("STATUS");
                                        String type = rs.getString("TYPE");
                                        Integer charges = rs.getInt("CHARGES");
                                        if (rs.wasNull()) charges = null;

                                        // Determine effective status
                                        patientPs.setInt(1, roomNo);
                                        patientPs.setInt(2, bedNo);
                                        ResultSet patientRs = patientPs.executeQuery();
                                        String effectiveStatus = storedStatus;
                                        if (patientRs.next()) {
                                            effectiveStatus = patientRs.getInt(1) > 0 ? "Occupied" : 
                                                             storedStatus.equals("Maintenance") ? "Maintenance" : "Available";
                                        }
                                        patientRs.close();
                                %>
                                <tr>
                                    <td><%=roomNo%></td>
                                    <td><%=bedNo%></td>
                                    <td><%=effectiveStatus%></td>
                                    <td><%=type != null ? type : "N/A"%></td>
                                    <td><%=charges != null ? charges : "N/A"%></td>
                                    <td>
                                        <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal<%=roomNo%><%=bedNo%>"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></button>
                                        <a href="delete_room_validation.jsp?roomNo=<%=roomNo%>&bedNo=<%=bedNo%>" class="btn btn-danger" onclick="return confirmDelete()"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
                                    </td>
                                </tr>
                                <%
                                    }
                                %>
                            </table>
                            <%
                                    }
                                } catch (Exception e) {
                            %>
                            <p class="error-message">Error loading room list: <%=e.getMessage()%></p>
                            <%
                                } finally {
                                    if (patientPs != null) try { patientPs.close(); } catch (Exception e) {}
                                    if (rs != null) try { rs.close(); } catch (Exception e) {}
                                    if (ps != null) try { ps.close(); } catch (Exception e) {}
                                }
                            %>
                        </div>
                        <!-- Add Room -->
                        <div id="addRoom" class="tab-pane">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <form class="form-horizontal" action="add_room_validation.jsp" id="addRoomForm">
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label">Room No</label>
                                            <div class="col-sm-4">
                                                <input type="number" class="form-control" name="roomNo" id="roomNoAdd" placeholder="Room Number" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label">Bed No</label>
                                            <div class="col-sm-4">
                                                <input type="number" class="form-control" name="bedNo" id="bedNoAdd" placeholder="Bed No" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label">Room Type</label>
                                            <div class="col-sm-4">
                                                <select name="type" class="form-control" id="roomTypeAdd" required>
                                                    <option value="" disabled selected>Select Room Type</option>
                                                    <option value="Common">Common</option>
                                                    <option value="Deluxe">Deluxe</option>
                                                    <option value="ICU">ICU</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label">Charges (Rs/day)</label>
                                            <div class="col-sm-4">
                                                <input type="number" class="form-control charges-display" id="chargesDisplayAdd" readonly>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-sm-offset-4 col-sm-4">
                                                <button type="submit" class="btn btn-primary">Add Room Now</button>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Edit Room Modals -->
                    <%
                        PreparedStatement modalPs = null;
                        PreparedStatement modalPatientPs = null;
                        ResultSet modalRs = null;
                        try {
                            modalPs = c.prepareStatement("SELECT ROOM_NO, BED_NO, STATUS, TYPE, CHARGES FROM room_info ORDER BY ROOM_NO, BED_NO ASC");
                            modalRs = modalPs.executeQuery();
                            modalPatientPs = c.prepareStatement("SELECT COUNT(*) FROM admission WHERE ROOM_NO = ? AND BED_NO = ? AND DISCHARGE_DATE IS NULL");
                            while (modalRs.next()) {
                                int roomNo = modalRs.getInt("ROOM_NO");
                                int bedNo = modalRs.getInt("BED_NO");
                                String storedStatus = modalRs.getString("STATUS");
                                String type = modalRs.getString("TYPE");
                                Integer charges = modalRs.getInt("CHARGES");
                                if (modalRs.wasNull()) charges = null;

                                // Determine effective status for modal
                                modalPatientPs.setInt(1, roomNo);
                                modalPatientPs.setInt(2, bedNo);
                                ResultSet patientRs = modalPatientPs.executeQuery();
                                String effectiveStatus = storedStatus;
                                if (patientRs.next()) {
                                    effectiveStatus = patientRs.getInt(1) > 0 ? "Occupied" : 
                                                     storedStatus.equals("Maintenance") ? "Maintenance" : "Available";
                                }
                                patientRs.close();
                    %>
                    <div class="modal fade" id="myModal<%=roomNo%><%=bedNo%>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel<%=roomNo%><%=bedNo%>">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                    <h4 class="modal-title" id="myModalLabel<%=roomNo%><%=bedNo%>">Edit Room Information</h4>
                                </div>
                                <div class="modal-body">
                                    <div class="panel panel-default">
                                        <div class="panel-body">
                                            <form class="form-horizontal" action="edit_room_validation.jsp" id="editRoomForm<%=roomNo%><%=bedNo%>">
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Room No</label>
                                                    <div class="col-sm-4">
                                                        <input type="number" class="form-control" name="roomNo" value="<%=roomNo%>" readonly>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Bed No</label>
                                                    <div class="col-sm-4">
                                                        <input type="number" class="form-control" name="bedNo" id="bedNoEdit<%=roomNo%><%=bedNo%>" value="<%=bedNo%>" required>
                                                        <input type="hidden" name="oldBedNo" value="<%=bedNo%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Status</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" value="<%=effectiveStatus%>" readonly>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Room Type</label>
                                                    <div class="col-sm-4">
                                                        <select name="type" class="form-control" id="roomTypeEdit<%=roomNo%><%=bedNo%>" required>
                                                            <option value="Common" <%= "Common".equals(type) ? "selected" : "" %>>Common</option>
                                                            <option value="Deluxe" <%= "Deluxe".equals(type) ? "selected" : "" %>>Deluxe</option>
                                                            <option value="ICU" <%= "ICU".equals(type) ? "selected" : "" %>>ICU</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Charges (Rs/day)</label>
                                                    <div class="col-sm-4">
                                                        <span class="charges-display"><%=charges != null ? charges : "N/A"%></span>
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
                        } catch (Exception e) {
                    %>
                    <p class="error-message">Error loading edit modals: <%=e.getMessage()%></p>
                    <%
                        } finally {
                            if (modalPatientPs != null) try { modalPatientPs.close(); } catch (Exception e) {}
                            if (modalRs != null) try { modalRs.close(); } catch (Exception e) {}
                            if (modalPs != null) try { modalPs.close(); } catch (Exception e) {}
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
</body>
</html>