<%@page import="java.sql.*, java.text.SimpleDateFormat"%>
<%
    if (session.getAttribute("id") == null) {
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized access");
        return;
    }
    String patientIdStr = request.getParameter("patientId");
    String doctorIdStr = (String) session.getAttribute("id");
    if (patientIdStr == null || !patientIdStr.matches("\\d+")) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing patient ID");
        return;
    }
    if (doctorIdStr == null || !doctorIdStr.matches("\\d+")) {
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or missing doctor ID");
        return;
    }
    int patientId = Integer.parseInt(patientIdStr);
    int doctorId = Integer.parseInt(doctorIdStr);
    Connection conn = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        ps = conn.prepareStatement(
            "SELECT CASE_ID, CASE_DATE, REASON, CONDITION_DETAILS FROM case_master WHERE PATIENT_ID = ? AND DOCTOR_ID = ? ORDER BY CASE_DATE DESC"
        );
        ps.setInt(1, patientId);
        ps.setInt(2, doctorId);
        rs = ps.executeQuery();
        response.setContentType("application/json");
        out.print("[");
        boolean first = true;
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        while (rs.next()) {
            if (!first) out.print(",");
            out.print("{");
            out.print("\"id\":" + rs.getInt("CASE_ID") + ",");
            out.print("\"date\":\"" + (rs.getDate("CASE_DATE") != null ? dateFormat.format(rs.getDate("CASE_DATE")) : "-") + "\",");
            out.print("\"reason\":\"" + (rs.getString("REASON") != null ? rs.getString("REASON").replace("\"", "\\\"") : "-") + "\",");
            out.print("\"details\":\"" + (rs.getString("CONDITION_DETAILS") != null ? rs.getString("CONDITION_DETAILS").replace("\"", "\\\"") : "-") + "\"");
            out.print("}");
            first = false;
        }
        out.print("]");
    } catch (SQLException e) {
        response.setContentType("application/json");
        out.print("{\"error\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
    }
%>