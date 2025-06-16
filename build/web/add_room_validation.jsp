<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Room Validation</title>
    <style>
        .message-box {
            text-align: center;
            margin-top: 35%;
            padding: 20px;
        }
    </style>
</head>
<body>
    <%
        String roomNo = request.getParameter("roomNo");
        String bedNo = request.getParameter("bedNo");
        String type = request.getParameter("type");

        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement checkPs = null;
        try {
            // Validate inputs
            if (roomNo == null || bedNo == null || type == null ||
                roomNo.trim().isEmpty() || bedNo.trim().isEmpty() || type.trim().isEmpty()) {
                throw new Exception("All fields are required.");
            }

            int roomNoInt = Integer.parseInt(roomNo);
            int bedNoInt = Integer.parseInt(bedNo);
            if (roomNoInt <= 0 || bedNoInt <= 0) {
                throw new Exception("Room and bed numbers must be positive.");
            }

            String typeTrim = type.trim();
            Integer charges = null;
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

            // Get database connection
            con = (Connection) application.getAttribute("connection");
            if (con == null) {
                throw new Exception("Database connection not available.");
            }

            // Check for duplicate room
            checkPs = con.prepareStatement("SELECT COUNT(*) FROM room_info WHERE ROOM_NO = ? AND BED_NO = ?");
            checkPs.setInt(1, roomNoInt);
            checkPs.setInt(2, bedNoInt);
            ResultSet checkRs = checkPs.executeQuery();
            if (checkRs.next() && checkRs.getInt(1) > 0) {
                throw new Exception("Room Number " + roomNoInt + " with Bed Number " + bedNoInt + " already exists.");
            }
            checkRs.close();
            checkPs.close();

            // Set default status to Available (new rooms are not assigned)
            String status = "Available";

            // Insert room
            con.setAutoCommit(false); // Begin transaction
            ps = con.prepareStatement("INSERT INTO room_info (ROOM_NO, BED_NO, STATUS, TYPE, CHARGES) VALUES (?, ?, ?, ?, ?)");
            ps.setInt(1, roomNoInt);
            ps.setInt(2, bedNoInt);
            ps.setString(3, status);
            ps.setString(4, typeTrim);
            if (charges != null) {
                ps.setInt(5, charges);
            } else {
                ps.setNull(5, Types.INTEGER);
            }

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                con.commit();
    %>
    <div class="message-box">
        <font color="green">
            <h2>Room with Bed Added Successfully</h2><br><br>
            <h3>Redirecting you to home page...</h3>
            <script>
                setTimeout(function() { window.location="room.jsp"; }, 3000);
            </script>
        </font>
    </div>
    <%
            } else {
                throw new Exception("Failed to add room.");
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
                if (con != null) con.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
</body>
</html>