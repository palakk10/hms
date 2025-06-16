<%-- 
    Document   : get_room_charges
    Created on : 16 Jun 2025, 4:46:58 am
    Author     : Lenovo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Hello World!</h1>
    </body>
</html>
```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String patientId = request.getParameter("patientId");
    String caseId = request.getParameter("caseId");
    Connection conn = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    ResultSet rs = null;
    response.setContentType("text/plain; charset=UTF-8");
    try {
        if (patientId == null || patientId.trim().isEmpty() || caseId == null || caseId.trim().isEmpty()) {
            out.print("0.00");
            return;
        }
        ps = conn.prepareStatement(
            "SELECT ri.CHARGES " +
            "FROM admission a JOIN room_info ri ON a.ROOM_NO = ri.ROOM_NO AND a.BED_NO = ri.BED_NO " +
            "WHERE a.PATIENT_ID = ? AND a.CASE_ID = ?"
        );
        ps.setInt(1, Integer.parseInt(patientId));
        ps.setInt(2, Integer.parseInt(caseId));
        rs = ps.executeQuery();
        if (rs.next()) {
            double roomCharge = rs.getDouble("CHARGES");
            out.print(String.format("%.2f", roomCharge));
        } else {
            out.print("0.00");
        }
    } catch (Exception e) {
        out.print("0.00");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
    }
%>
```