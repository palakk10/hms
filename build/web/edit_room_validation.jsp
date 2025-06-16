<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Room Validation</title>
    <style>
        .message-box {
            text-align: center;
            margin-top: 25%;
            padding: 20px;
        }
    </style>
</head>
<body>
    <%
        String roomNo = request.getParameter("roomNo");
        String bedNo = request.getParameter("bedNo");
        String oldBedNo = request.getParameter("oldBedNo");
        String type = request.getParameter("type");

        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement checkPs = null;
        PreparedStatement dupPs = null;
        PreparedStatement patientPs = null;
        try {
            // Validate inputs
            if (roomNo == null || bedNo == null || oldBedNo == null || type == null ||
                roomNo.trim().isEmpty() || bedNo.trim().isEmpty() || oldBedNo.trim().isEmpty() ||
                type.trim().isEmpty()) {
                throw new Exception("All fields are required.");
            }

            int roomNoInt = Integer.parseInt(roomNo);
            int bedNoInt = Integer.parseInt(bedNo);
            int oldBedNoInt = Integer.parseInt(oldBedNo);
            if (roomNoInt <= 0 || bedNoInt <= 0 || oldBedNoInt <= 0) {
                throw new Exception("Room and bed numbers must be positive.");
            }

            // Get database connection
            con = (Connection) application.getAttribute("connection");
            if (con == null) {
                throw new Exception("Database connection not available.");
            }

            // Check if room exists
            checkPs = con.prepareStatement("SELECT STATUS FROM room_info WHERE ROOM_NO = ? AND BED_NO = ?");
            checkPs.setInt(1, roomNoInt);
            checkPs.setInt(2, oldBedNoInt);
            ResultSet checkRs = checkPs.executeQuery();
            if (!checkRs.next()) {
                throw new Exception("Room and bed not found.");
            }
            String currentStatus = checkRs.getString("STATUS");
            checkRs.close();
            checkPs.close();

            // Check if new ROOM_NO, BED_NO combination exists
            if (bedNoInt != oldBedNoInt) {
                dupPs = con.prepareStatement("SELECT COUNT(*) FROM room_info WHERE ROOM_NO = ? AND BED_NO = ?");
                dupPs.setInt(1, roomNoInt);
                dupPs.setInt(2, bedNoInt);
                ResultSet dupRs = dupPs.executeQuery();
                if (dupRs.next() && dupRs.getInt(1) > 0) {
                    throw new Exception("Room Number " + roomNoInt + " with Bed Number " + bedNoInt + " already exists.");
                }
                dupRs.close();
                dupPs.close();

                // Check if bed is assigned to a patient
                patientPs = con.prepareStatement("SELECT COUNT(*) FROM admission WHERE ROOM_NO = ? AND BED_NO = ? AND DISCHARGE_DATE IS NULL");
                patientPs.setInt(1, roomNoInt);
                patientPs.setInt(2, oldBedNoInt);
                ResultSet patientRs = patientPs.executeQuery();
                if (patientRs.next() && patientRs.getInt(1) > 0) {
                    throw new Exception("Cannot update bed number; bed is assigned to a patient.");
                }
                patientRs.close();
                patientPs.close();
            }

            // Assign charges based on room type
            Integer charges = null;
            String typeTrim = type.trim();
            switch (typeTrim) {
                case "Common":
                    charges = 2000;
                    break;
                case "Deluxe":
                    charges = 5000;
                    break;
                case "ICU":
                    charges = 10000;
                    break;
                default:
                    throw new Exception("Invalid room type.");
            }

            // Determine status based on patient assignment
            String status;
            patientPs = con.prepareStatement("SELECT COUNT(*) FROM admission WHERE ROOM_NO = ? AND BED_NO = ? AND DISCHARGE_DATE IS NULL");
            patientPs.setInt(1, roomNoInt);
            patientPs.setInt(2, bedNoInt != oldBedNoInt ? oldBedNoInt : bedNoInt);
            ResultSet patientRs = patientPs.executeQuery();
            if (patientRs.next() && patientRs.getInt(1) > 0) {
                status = "Occupied";
            } else {
                status = currentStatus.equals("Maintenance") ? "Maintenance" : "Available";
            }
            patientRs.close();
            patientPs.close();

            // Update room_info
            con.setAutoCommit(false); // Begin transaction
            ps = con.prepareStatement("UPDATE room_info SET BED_NO = ?, STATUS = ?, TYPE = ?, CHARGES = ? WHERE ROOM_NO = ? AND BED_NO = ?");
            ps.setInt(1, bedNoInt);
            ps.setString(2, status);
            ps.setString(3, typeTrim);
            if (charges != null) {
                ps.setInt(4, charges);
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setInt(5, roomNoInt);
            ps.setInt(6, oldBedNoInt);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                con.commit();
    %>
    <div class="message-box">
        <font color="blue">
            <h2>Room with Bed Updated Successfully</h2><br><br>
            <h3>Redirecting you to home page...</h3>
            <script>
                setTimeout(function() { window.location="room.jsp"; }, 3000);
            </script>
        </font>
    </div>
    <%
            } else {
                throw new Exception("Room not updated. Check room and bed number.");
            }
        } catch (SQLException e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
    %>
    <div class="message-box">
        <font color="red">
            <h2>Error: Database error: <%=e.getMessage()%></h2><br><br>
            <h3>Redirecting you to home page...</h3>
            <script>
                setTimeout(function() { window.location="room.jsp"; }, 3000);
            </script>
        </font>
    </div>
    <%
        } catch (Exception e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
    %>
    <div class="message-box">
        <font color="red">
            <h2>Error: <%=e.getMessage()%></h2><br><br>
            <h3>Redirecting you to home page...</h3>
            <script>
                setTimeout(function() { window.location="room.jsp"; }, 3000);
            </script>
        </font>
    </div>
    <%
        } finally {
            try {
                if (ps != null) ps.close();
                if (checkPs != null) checkPs.close();
                if (dupPs != null) dupPs.close();
                if (patientPs != null) patientPs.close();
                if (con != null) con.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
</body>
</html>