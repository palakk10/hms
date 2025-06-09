```jsp
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
            System.out.println("get_pathology_charges.jsp: No patientId provided");
            out.print("0.00");
            return;
        }
        System.out.println("get_pathology_charges.jsp: Fetching charges for patientId=" + patientId);
        ps = conn.prepareStatement("SELECT SUM(CHARGES) AS total_charges FROM pathology WHERE ID = ?");
        ps.setInt(1, Integer.parseInt(patientId));
        rs = ps.executeQuery();
        if (rs.next()) {
            double totalCharges = rs.getDouble("total_charges");
            if (rs.wasNull()) {
                totalCharges = 0.0;
                System.out.println("get_pathology_charges.jsp: No charges found for patientId=" + patientId);
            } else {
                System.out.println("get_pathology_charges.jsp: Charges=" + totalCharges + " for patientId=" + patientId);
            }
            out.print(String.format("%.2f", totalCharges));
        } else {
            System.out.println("get_pathology_charges.jsp: No result set for patientId=" + patientId);
            out.print("0.00");
        }
    } catch (NumberFormatException e) {
        System.err.println("get_pathology_charges.jsp: Invalid patientId format: " + patientId);
        out.print("0.00");
    } catch (SQLException e) {
        System.err.println("get_pathology_charges.jsp: SQL Error: " + e.getMessage());
        out.print("0.00");
    } catch (Exception e) {
        System.err.println("get_pathology_charges.jsp: Unexpected error: " + e.getMessage());
        out.print("0.00");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }
%>
```