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
            "SELECT p.PRESCRIPTION_ID, p.MEDICINE, p.DOSAGE, p.DURATION, p.DATE_ISSUED, p.NOTES " +
            "FROM prescription p INNER JOIN case_master cm ON p.CASE_ID = cm.CASE_ID " +
            "WHERE cm.PATIENT_ID = ? AND p.DOCTOR_ID = ? ORDER BY p.DATE_ISSUED DESC"
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
            out.print("\"id\":" + rs.getInt("PRESCRIPTION_ID") + ",");
            out.print("\"medicine\":\"" + (rs.getString("MEDICINE") != null ? rs.getString("MEDICINE").replace("\"", "\\\"") : "-") + "\",");
            out.print("\"dosage\":\"" + (rs.getString("DOSAGE") != null ? rs.getString("DOSAGE").replace("\"", "\\\"") : "-") + "\",");
            out.print("\"duration\":\"" + (rs.getString("DURATION") != null ? rs.getString("DURATION").replace("\"", "\\\"") : "-") + "\",");
            out.print("\"date\":\"" + (rs.getDate("DATE_ISSUED") != null ? dateFormat.format(rs.getDate("DATE_ISSUED")) : "-") + "\",");
            out.print("\"notes\":\"" + (rs.getString("NOTES") != null ? rs.getString("NOTES").replace("\"", "\\\"") : "-") + "\"");
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