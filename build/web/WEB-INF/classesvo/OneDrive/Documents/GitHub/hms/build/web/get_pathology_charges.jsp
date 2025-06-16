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
            "SELECT SUM(pt.PRICE) AS total_charges " +
            "FROM pathology p JOIN pathology_test pt ON p.TEST_ID = pt.TEST_ID " +
            "WHERE p.ID = ? AND p.CASE_ID = ? AND (" +
            "p.B_TEST = 'Positive' OR p.URINALYSIS = 'Positive' OR " +
            "p.LIVER_FUNCTION_TESTS = 'Positive' OR p.LIPID_PROFILES = 'Positive' OR " +
            "p.THYROID_FUNCTION_TESTS = 'Positive' OR p.KIDNEY_FUNCTION_TESTS = 'Positive')"
        );
        ps.setInt(1, Integer.parseInt(patientId));
        ps.setInt(2, Integer.parseInt(caseId));
        rs = ps.executeQuery();
        if (rs.next()) {
            double totalCharges = rs.getDouble("total_charges");
            if (rs.wasNull()) totalCharges = 0.0;
            out.print(String.format("%.2f", totalCharges));
        } else {
            out.print("0.00");
        }
    } catch (Exception e) {
        out.print("0.00");
        System.err.println("Exception in get_pathology_charges.jsp: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
    }
%>
```