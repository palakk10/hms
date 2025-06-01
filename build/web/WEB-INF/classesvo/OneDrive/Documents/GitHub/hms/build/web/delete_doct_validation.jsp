<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Doctor Validation</title>
</head>
<body>
<%
    String doctId = request.getParameter("doctId");
    Connection con = null;
    PreparedStatement ps = null;
    try {
        // Validate input
        if (doctId == null || doctId.trim().isEmpty() || !doctId.matches("\\d+")) {
            out.println("<div style='text-align:center;margin-top:25%'>");
            out.println("<font color='red'>");
            out.println("<h2>Invalid Doctor ID</h2><br>");
            out.println("<h3>Redirecting to home page...</h3>");
            out.println("<script type='text/javascript'>setTimeout('window.location=\"doctor.jsp\"', 3000);</script>");
            out.println("</font>");
            out.println("</div>");
            return;
        }

        con = (Connection) application.getAttribute("connection");
        if (con == null) {
            out.println("<div style='text-align:center;margin-top:25%'>");
            out.println("<font color='red'>");
            out.println("<h2>Database connection not established</h2><br>");
            out.println("<h3>Redirecting to home page...</h3>");
            out.println("<script type='text/javascript'>setTimeout('window.location=\"doctor.jsp\"', 3000);</script>");
            out.println("</font>");
            out.println("</div>");
            return;
        }

        // Check if doctor exists
        ps = con.prepareStatement("SELECT ID FROM doctor_info WHERE ID = ?");
        ps.setInt(1, Integer.parseInt(doctId));
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            out.println("<div style='text-align:center;margin-top:25%'>");
            out.println("<font color='red'>");
            out.println("<h2>Doctor not found</h2><br>");
            out.println("<h3>Redirecting to home page...</h3>");
            out.println("<script type='text/javascript'>setTimeout('window.location=\"doctor.jsp\"', 3000);</script>");
            out.println("</font>");
            out.println("</div>");
            rs.close();
            ps.close();
            return;
        }
        rs.close();
        ps.close();

        // Attempt to delete doctor
        ps = con.prepareStatement("DELETE FROM doctor_info WHERE ID = ?");
        ps.setInt(1, Integer.parseInt(doctId));
        int i = ps.executeUpdate();

        if (i > 0) {
            out.println("<div style='text-align:center;margin-top:25%'>");
            out.println("<font color='green'>");
            out.println("<h2>Doctor Removed Successfully</h2><br>");
            out.println("<h3>Redirecting to home page...</h3>");
            out.println("<script type='text/javascript'>setTimeout('window.location=\"doctor.jsp\"', 3000);</script>");
            out.println("</font>");
            out.println("</div>");
        } else {
            out.println("<div style='text-align:center;margin-top:25%'>");
            out.println("<font color='red'>");
            out.println("<h2>Failed to Remove Doctor</h2><br>");
            out.println("<h3>Redirecting to home page...</h3>");
            out.println("<script type='text/javascript'>setTimeout('window.location=\"doctor.jsp\"', 3000);</script>");
            out.println("</font>");
            out.println("</div>");
        }
    } catch (SQLException e) {
        // Handle foreign key constraint violation or other SQL errors
        String errorMessage = e.getMessage().toLowerCase().contains("foreign key constraint") ?
            "Cannot delete doctor because they are referenced in patient or prescription records." :
            "Error deleting doctor: " + e.getMessage();
        out.println("<div style='text-align:center;margin-top:25%'>");
        out.println("<font color='red'>");
        out.println("<h2>" + errorMessage + "</h2><br>");
        out.println("<h3>Redirecting to home page...</h3>");
        out.println("<script type='text/javascript'>setTimeout('window.location=\"doctor.jsp\"', 3000);</script>");
        out.println("</font>");
        out.println("</div>");
        e.printStackTrace();
    } finally {
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        // Do not close the connection, as it is managed by the application context
        // No need for con.commit() since autoCommit is true
    }
%>
</body>
</html>