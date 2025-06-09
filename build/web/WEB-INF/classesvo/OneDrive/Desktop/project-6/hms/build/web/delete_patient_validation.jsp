<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Patient Validation</title>
</head>
<body>
<% 
    // Retrieve form parameters
    String patientId = request.getParameter("patientId");
    String roomNo = request.getParameter("roomNo");
    String bedNo = request.getParameter("bedNo");

    // Log parameters
    System.out.println("Delete Patient Parameters: patientId=" + patientId + ", roomNo=" + roomNo + ", bedNo=" + bedNo);

    Connection con = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    try {
        // Validate connection
        if (con == null) {
            System.out.println("ERROR: Database connection is null");
            session.setAttribute("error-message", "Database connection failed.");
            response.sendRedirect("patients.jsp");
            return;
        }
        System.out.println("Database connection established");

        // Validate parameters
        if (patientId == null || patientId.trim().isEmpty() || !patientId.matches("\\d+")) {
            System.out.println("ERROR: Invalid Patient ID: " + patientId);
            session.setAttribute("error-message", "Invalid Patient ID.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (roomNo == null || roomNo.trim().isEmpty() || !roomNo.matches("\\d+")) {
            System.out.println("ERROR: Invalid Room Number: " + roomNo);
            session.setAttribute("error-message", "Invalid Room Number.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (bedNo == null || bedNo.trim().isEmpty() || !bedNo.matches("\\d+")) {
            System.out.println("ERROR: Invalid Bed Number: " + bedNo);
            session.setAttribute("error-message", "Invalid Bed Number.");
            response.sendRedirect("patients.jsp");
            return;
        }

        int pId = Integer.parseInt(patientId);
        int rNo = Integer.parseInt(roomNo);
        int bNo = Integer.parseInt(bedNo);

        // Verify patient exists
        ps = con.prepareStatement("SELECT ID FROM patient_info WHERE ID = ?");
        ps.setInt(1, pId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            System.out.println("ERROR: Patient ID not found: " + pId);
            session.setAttribute("error-message", "Patient not found.");
            rs.close();
            ps.close();
            response.sendRedirect("patients.jsp");
            return;
        }
        rs.close();
        ps.close();

        // Delete related pathology records to satisfy foreign key constraint
        System.out.println("Deleting related pathology records for patient ID: " + pId);
        ps = con.prepareStatement("DELETE FROM pathology WHERE ID = ?");
        ps.setInt(1, pId);
        int pathologyRows = ps.executeUpdate();
        System.out.println("Pathology records deleted: " + pathologyRows);
        ps.close();

        // Delete patient record
        System.out.println("Deleting patient_info record for ID: " + pId);
        ps = con.prepareStatement("DELETE FROM patient_info WHERE ID = ?");
        ps.setInt(1, pId);
        int rowsAffected = ps.executeUpdate();
        System.out.println("Rows affected by patient_info deletion: " + rowsAffected);
        ps.close();

        if (rowsAffected > 0) {
            // Update room status
            System.out.println("Updating room_info: ROOM_NO=" + rNo + ", BED_NO=" + bNo + " to Available");
            ps = con.prepareStatement("UPDATE room_info SET STATUS = 'Available' WHERE ROOM_NO = ? AND BED_NO = ?");
            ps.setInt(1, rNo);
            ps.setInt(2, bNo);
            int roomRows = ps.executeUpdate();
            System.out.println("Rows affected by room_info update: " + roomRows);
            ps.close();

            System.out.println("Committing transaction");
            con.commit();
%>
            <div style="text-align:center;margin-top:25%">
                <font color="blue">
                    <script type="text/javascript">
                        function Redirect() {
                            window.location = "patients.jsp";
                        }
                        document.write("<h2>Patient Removed Successfully</h2><br><br>");
                        document.write("<h3>Redirecting you to home page....</h3>");
                        setTimeout('Redirect()', 3000);
                    </script>
                </font>
            </div>
<%
        } else {
            System.out.println("ERROR: Deletion failed for patient ID: " + pId);
            session.setAttribute("error-message", "Failed to delete patient. No matching record found.");
            response.sendRedirect("patients.jsp");
        }
    } catch (SQLException e) {
        System.out.println("SQLException: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("error-message", "Database error: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    } catch (NumberFormatException e) {
        System.out.println("NumberFormatException: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("error-message", "Invalid number format: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    } catch (Exception e) {
        System.out.println("Unexpected error: " + e.getMessage());
        e.printStackTrace();
        session.setAttribute("error-message", "Unexpected error: " + e.getMessage());
        response.sendRedirect("patients.jsp");
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) { System.out.println("Error closing PreparedStatement: " + e.getMessage()); }
    }
%>
</body>
</html>