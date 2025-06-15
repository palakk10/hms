<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html>
<%
    response.setHeader("cache-control", "no-cache, no-store, must-revalidate");
    String emaill = (String) session.getAttribute("email");
    String namee = (String) session.getAttribute("name");
    if (emaill == null || namee == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="images/logo.png" rel="icon"/>
    <title>Add Admission</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/bootstrap-theme.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <style>
        body { padding-top: 60px; }
        .header { 
            display: block !important; 
            visibility: visible !important; 
            position: fixed !important; 
            top: 0; 
            width: 100%; 
            z-index: 1000 !important; 
            background-color: #fff; 
            border-bottom: 1px solid #ddd;
        }
        .content { margin-left: 16.66%; float: left; padding: 20px; }
        .sidebar { 
            position: static; 
            width: 16.66%; 
            float: left; 
            margin-top: 60px; 
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Header Start -->
        <div class="row header">
            <div class="col-md-10">
                <h2>Hospital Management System</h2>
            </div>
            <div class="col-md-2">
                <ul class="nav nav-pills">
                    <li class="dropdown dmenu">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><%=namee.toUpperCase()%> <span class="caret"></span></a>
                        <ul class="dropdown-menu">
                            <li><a href="profile_receptionist.jsp">Change Profile</a></li>
                            <li role="separator" class="divider"></li>
                            <li><a href="logout.jsp">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
        <!-- Header Ends -->
        <div class="row">
            <%@include file="receptionist_menu.jsp" %>
            <div class="col-md-10 content">
                <div class="panel panel-default">
                    <div class="panel-heading logintitle">Admit Patient</div>
                    <div class="panel-body">
                        <%
                            Connection c = (Connection) application.getAttribute("connection");
                            String patientId = request.getParameter("patient_id");
                            if (c == null || patientId == null || patientId.trim().isEmpty()) {
                                out.println("<div class='alert alert-danger'>Error: Invalid request or database connection.</div>");
                                return;
                            }
                            try {
                                // Check if patient is already admitted
                                PreparedStatement psCheck = c.prepareStatement(
                                    "SELECT ADMIT_ID FROM admission WHERE PATIENT_ID = ? AND DISCHARGE_DATE IS NULL"
                                );
                                psCheck.setInt(1, Integer.parseInt(patientId));
                                ResultSet rsCheck = psCheck.executeQuery();
                                if (rsCheck.next()) {
                                    out.println("<div class='alert alert-warning'>Patient is already admitted.</div>");
                                    out.println("<a href='receptionist.jsp' class='btn btn-default'>Back to Dashboard</a>");
                                    rsCheck.close();
                                    psCheck.close();
                                    return;
                                }
                                rsCheck.close();
                                psCheck.close();
                        %>
                        <form class="form-horizontal" action="add_admission.jsp" method="post">
                            <input type="hidden" name="patient_id" value="<%= patientId %>">
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Patient ID</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" value="<%= patientId %>" disabled>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Case ID</label>
                                <div class="col-sm-9">
                                    <select name="case_id" class="form-control" required>
                                        <%
                                            PreparedStatement psCases = c.prepareStatement(
                                                "SELECT CASE_ID, REASON, CASE_DATE FROM case_master WHERE PATIENT_ID = ? ORDER BY CASE_DATE DESC"
                                            );
                                            psCases.setInt(1, Integer.parseInt(patientId));
                                            ResultSet rsCases = psCases.executeQuery();
                                            if (!rsCases.isBeforeFirst()) {
                                                out.println("<option value=\"\">No cases available</option>");
                                            } else {
                                                while (rsCases.next()) {
                                                    out.println("<option value=\"" + rsCases.getInt("CASE_ID") + "\">" +
                                                        rsCases.getInt("CASE_ID") + " - " + rsCases.getString("REASON") + " (" +
                                                        rsCases.getDate("CASE_DATE") + ")</option>");
                                                }
                                            }
                                            rsCases.close();
                                            psCases.close();
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Doctor</label>
                                <div class="col-sm-9">
                                    <select name="doctor_id" class="form-control" required>
                                        <%
                                            PreparedStatement psDoctors = c.prepareStatement("SELECT ID, NAME FROM doctor_info");
                                            ResultSet rsDoctors = psDoctors.executeQuery();
                                            if (!rsDoctors.isBeforeFirst()) {
                                                out.println("<option value=\"\">No doctors available</option>");
                                            } else {
                                                while (rsDoctors.next()) {
                                                    out.println("<option value=\"" + rsDoctors.getInt("ID") + "\">" +
                                                        rsDoctors.getString("NAME") + "</option>");
                                                }
                                            }
                                            rsDoctors.close();
                                            psDoctors.close();
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="col-sm-3 control-label">Room and Bed</label>
                                <div class="col-sm-9">
                                    <select name="room_bed" class="form-control" required>
                                        <%
                                            PreparedStatement psRooms = c.prepareStatement(
                                                "SELECT ROOM_NO, BED_NO, TYPE FROM room_info WHERE STATUS = 'Available'"
                                            );
                                            ResultSet rsRooms = psRooms.executeQuery();
                                            if (!rsRooms.isBeforeFirst()) {
                                                out.println("<option value=\"\">No rooms available</option>");
                                            } else {
                                                while (rsRooms.next()) {
                                                    out.println("<option value=\"" + rsRooms.getInt("ROOM_NO") + "_" +
                                                        rsRooms.getInt("BED_NO") + "\">" +
                                                        "Room " + rsRooms.getInt("ROOM_NO") + ", Bed " +
                                                        rsRooms.getInt("BED_NO") + " (" + rsRooms.getString("TYPE") + ")</option>");
                                                }
                                            }
                                            rsRooms.close();
                                            psRooms.close();
                                        %>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <div class="col-sm-offset-3 col-sm-9">
                                    <button type="submit" class="btn btn-primary">Submit Admission</button>
                                    <a href="receptionist.jsp" class="btn btn-default">Cancel</a>
                                </div>
                            </div>
                        </form>
                        <%
                            // Handle form submission
                            if ("POST".equalsIgnoreCase(request.getMethod())) {
                                String caseId = request.getParameter("case_id");
                                String doctorId = request.getParameter("doctor_id");
                                String roomBed = request.getParameter("room_bed");
                                if (caseId != null && doctorId != null && roomBed != null) {
                                    String[] roomBedParts = roomBed.split("_");
                                    String roomNo = roomBedParts[0];
                                    String bedNo = roomBedParts[1];
                                    PreparedStatement psInsert = null;
                                    PreparedStatement psUpdateRoom = null;
                                    try {
                                        c.setAutoCommit(false);
                                        // Insert into admission
                                        psInsert = c.prepareStatement(
                                            "INSERT INTO admission (CASE_ID, PATIENT_ID, DOCTOR_ID, ROOM_NO, BED_NO, ADMIT_DATE) " +
                                            "VALUES (?, ?, ?, ?, ?, CURDATE())"
                                        );
                                        psInsert.setInt(1, Integer.parseInt(caseId));
                                        psInsert.setInt(2, Integer.parseInt(patientId));
                                        psInsert.setInt(3, Integer.parseInt(doctorId));
                                        psInsert.setInt(4, Integer.parseInt(roomNo));
                                        psInsert.setInt(5, Integer.parseInt(bedNo));
                                        int rows = psInsert.executeUpdate();
                                        // Update room status
                                        psUpdateRoom = c.prepareStatement(
                                            "UPDATE room_info SET STATUS = 'Occupied' WHERE ROOM_NO = ? AND BED_NO = ?"
                                        );
                                        psUpdateRoom.setInt(1, Integer.parseInt(roomNo));
                                        psUpdateRoom.setInt(2, Integer.parseInt(bedNo));
                                        psUpdateRoom.executeUpdate();
                                        c.commit();
                                        response.sendRedirect("receptionist.jsp?status=success");
                                    } catch (SQLException e) {
                                        c.rollback();
                                        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                                    } finally {
                                        c.setAutoCommit(true);
                                        if (psInsert != null) try { psInsert.close(); } catch (SQLException e) {}
                                        if (psUpdateRoom != null) try { psUpdateRoom.close(); } catch (SQLException e) {}
                                    }
                                }
                            }
                        %>
                        <%
                            } catch (SQLException | NumberFormatException e) {
                                out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
                            }
                        %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>