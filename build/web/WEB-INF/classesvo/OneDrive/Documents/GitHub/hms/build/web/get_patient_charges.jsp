```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.JSONObject" %>
<% 
    response.setContentType("application/json; charset=UTF-8");
    String patientId = request.getParameter("patientId");
    JSONObject json = new JSONObject();
    double pathologyCharge = 0.0;
    double roomCharge = 0.0;

    if (patientId == null || patientId.trim().isEmpty()) {
        json.put("pathologyCharge", 0.00);
        json.put("roomCharge", 0.00);
        out.print(json.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement psPathology = null;
    ResultSet rsPathology = null;
    PreparedStatement psRoom = null;
    ResultSet rsRoom = null;

    try {
        conn = (Connection) application.getAttribute("connection");
        if (conn == null) {
            throw new SQLException("Database connection is null");
        }

        // Fetch pathology charges (across all cases)
        psPathology = conn.prepareStatement(
            "SELECT SUM(pt.PRICE) AS total_charges " +
            "FROM pathology p JOIN pathology_test pt ON p.TEST_ID = pt.TEST_ID " +
            "WHERE p.ID = ? AND (" +
            "p.B_TEST = 'Positive' OR p.URINALYSIS = 'Positive' OR " +
            "p.LIVER_FUNCTION_TESTS = 'Positive' OR p.LIPID_PROFILES = 'Positive' OR " +
            "p.THYROID_FUNCTION_TESTS = 'Positive' OR p.KIDNEY_FUNCTION_TESTS = 'Positive')"
        );
        psPathology.setInt(1, Integer.parseInt(patientId));
        rsPathology = psPathology.executeQuery();
        if (rsPathology.next()) {
            pathologyCharge = rsPathology.getDouble("total_charges");
            if (rsPathology.wasNull()) pathologyCharge = 0.0;
        }

        // Fetch room charges (all admissions)
        psRoom = conn.prepareStatement(
            "SELECT SUM(ri.CHARGES) AS total_charges " +
            "FROM admission a LEFT JOIN room_info ri ON a.ROOM_NO = ri.ROOM_NO AND a.BED_NO = ri.BED_NO " +
            "WHERE a.PATIENT_ID = ?"
        );
        psRoom.setInt(1, Integer.parseInt(patientId));
        rsRoom = psRoom.executeQuery();
        if (rsRoom.next()) {
            roomCharge = rsRoom.getDouble("total_charges");
            if (rsRoom.wasNull()) roomCharge = 0.0;
        }

        json.put("pathologyCharge", String.format("%.2f", pathologyCharge));
        json.put("roomCharge", String.format("%.2f", roomCharge));
    } catch (NumberFormatException e) {
        json.put("pathologyCharge", 0.00);
        json.put("roomCharge", 0.00);
    } catch (SQLException e) {
        json.put("pathologyCharge", 0.00);
        json.put("roomCharge", 0.00);
        System.err.println("SQLException in get_patient_charges.jsp: " + e.getMessage());
    } finally {
        if (rsPathology != null) try { rsPathology.close(); } catch (SQLException ignore) {}
        if (psPathology != null) try { psPathology.close(); } catch (SQLException ignore) {}
        if (rsRoom != null) try { rsRoom.close(); } catch (SQLException ignore) {}
        if (psRoom != null) try { psRoom.close(); } catch (SQLException ignore) {}
    }

    out.print(json.toString());
%>
```