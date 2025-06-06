<%@page import="java.sql.*" %>
<%@page contentType="text/plain" pageEncoding="UTF-8"%>
<%
    String patientId = request.getParameter("patientId");
    String patientName = "";
    try {
        Connection con = (Connection) application.getAttribute("connection");
        PreparedStatement ps = con.prepareStatement("SELECT PNAME FROM patient_info WHERE ID = ?");
        ps.setInt(1, Integer.parseInt(patientId));
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            patientName = rs.getString("PNAME");
        } else {
            patientName = "Patient Not Found";
        }
        rs.close();
        ps.close();
    } catch (Exception e) {
        patientName = "Error: " + e.getMessage();
    }
    out.print(patientName);
%>