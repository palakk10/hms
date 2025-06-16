<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Room Validation</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        .message-box {
            text-align: center;
            margin-top: 25%;
            padding: 20px;
            border-radius: 5px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        .success {
            background-color: #dff0d8;
            color: #3c763d;
            border: 1px solid #d6e9c6;
        }
        .error {
            background-color: #f2dede;
            color: #a94442;
            border: 1px solid #ebccd1;
        }
    </style>
</head>
<body>
    <%
        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement checkPs = null;
        String errorMessage = null;
        boolean success = false;

        try {
            // Get parameters
            String roomNo = request.getParameter("roomNo");
            String bedNo = request.getParameter("bedNo");

            // Validate inputs
            if (roomNo == null || roomNo.trim().isEmpty() || bedNo == null || bedNo.trim().isEmpty()) {
                throw new Exception("Room number and bed number are required.");
            }

            int roomNoInt, bedNoInt;
            try {
                roomNoInt = Integer.parseInt(roomNo);
                bedNoInt = Integer.parseInt(bedNo);
                if (roomNoInt <= 0 || bedNoInt <= 0) {
                    throw new Exception("Room and bed numbers must be positive.");
                }
            } catch (NumberFormatException e) {
                throw new Exception("Invalid room or bed number format.");
            }

            // Get database connection
            con = (Connection) application.getAttribute("connection");
            if (con == null) {
                throw new Exception("Database connection not available.");
            }
            con.setAutoCommit(false); // Begin transaction

            // Check if room is assigned to any patient
            checkPs = con.prepareStatement("SELECT COUNT(*) FROM admission WHERE ROOM_NO = ? AND BED_NO = ? AND DISCHARGE_DATE IS NULL");
            checkPs.setInt(1, roomNoInt);
            checkPs.setInt(2, bedNoInt);
            ResultSet rs = checkPs.executeQuery();
            rs.next();
            int patientCount = rs.getInt(1);
            rs.close();
            checkPs.close();

            if (patientCount > 0) {
                throw new Exception("Room deletion blocked due to active patient assignment. Please discharge the patient before removing the room.");
            }

            // Delete room
            ps = con.prepareStatement("DELETE FROM room_info WHERE ROOM_NO = ? AND BED_NO = ?");
            ps.setInt(1, roomNoInt);
            ps.setInt(2, bedNoInt);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                success = true;
            } else {
                throw new Exception("Room not found. Check room and bed number.");
            }

            con.commit();
        } catch (SQLException e) {
            errorMessage = "Database error: " + e.getMessage();
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            errorMessage = e.getMessage();
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
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
    <div class="container">
        <% if (success) { %>
            <div class="message-box success">
                <h2>Room with Bed Removed Successfully</h2>
                <p>Redirecting you to the room page...</p>
                <script>
                    setTimeout(function() {
                        window.location.href = "room.jsp";
                    }, 3000);
                </script>
            </div>
        <% } else { %>
            <div class="message-box error">
                <h2>Error</h2>
                <p><%= errorMessage != null ? errorMessage : "Unknown error occurred." %></p>
                <p><a href="javascript:history.back()" class="btn btn-default">Go Back and Try Again</a></p>
                <script>
                    setTimeout(function() {
                        window.location.href = "room.jsp";
                    }, 3000);
                </script>
            </div>
        <% } %>
    </div>
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>