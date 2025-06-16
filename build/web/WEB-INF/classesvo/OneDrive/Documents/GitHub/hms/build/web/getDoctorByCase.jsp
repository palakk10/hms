<%@page import="java.sql.*, org.json.JSONObject"%>
<%
    response.setContentType("application/json");
    Connection conn = (Connection) application.getAttribute("connection");
    String caseId = request.getParameter("caseId");
    JSONObject json = new JSONObject();
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        if (conn == null || caseId == null || caseId.trim().isEmpty()) {
            json.put("error", "Invalid request or database connection.");
        } else {
            ps = conn.prepareStatement(
                "SELECT d.ID, d.NAME FROM case_master c JOIN doctor_info d ON c.DOCTOR_ID = d.ID WHERE c.CASE_ID = ?"
            );
            ps.setInt(1, Integer.parseInt(caseId));
            rs = ps.executeQuery();
            if (rs.next()) {
                json.put("doctorId", rs.getInt("ID"));
                json.put("doctorName", rs.getString("NAME"));
            } else {
                json.put("doctorId", "");
                json.put("doctorName", "");
            }
        }
    } catch (SQLException | NumberFormatException e) {
        json.put("error", e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
    }
    out.print(json.toString());
%>