<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String patientId = request.getParameter("patientId");
    Connection conn = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    ResultSet rs = null;
    response.setContentType("text/plain; charset=UTF-8");
    try {
        if (patientId == null || patientId.trim().isEmpty()) {
            out.print("");
            return;
        }
        ps = conn.prepareStatement("SELECT PNAME FROM patient_info WHERE ID = ?");
        ps.setInt(1, Integer.parseInt(patientId));
        rs = ps.executeQuery();
        if (rs.next()) {
            String name = rs.getString("PNAME");
            out.print(name != null ? name : "");
        } else {
            out.print("");
        }
    } catch (NumberFormatException e) {
        out.print("");
    } catch (SQLException e) {
        out.print("");
        System.err.println("SQL Error in get_patient_name.jsp: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }
%>