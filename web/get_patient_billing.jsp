```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.JSONObject" %>
<% 
    response.setContentType("application/json; charset=UTF-8");
    String patientId = request.getParameter("patientId");
    String caseId = request.getParameter("caseId");
    JSONObject json = new JSONObject();
    double pathologyCharge = 0.0;
    double roomCharge = 0.0;

    if (patientId == null || patientId.trim().isEmpty() || caseId == null || caseId.trim().isEmpty()) {
        json.put("status", "error");
        json.put("error", "Invalid or missing patient ID or case ID");
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

        // Fetch pathology charges
        psPathology = conn.prepareStatement(
            "SELECT SUM(pt.PRICE) AS total_charges " +
            "FROM pathology p JOIN pathology_test pt ON p.TEST_ID = pt.TEST_ID " +
            "WHERE p.ID = ? AND p.CASE_ID = ? AND (" +
            "p.B_TEST = 'Positive' OR p.URINALYSIS = 'Positive' OR " +
            "p.LIVER_FUNCTION_TESTS = 'Positive' OR p.LIPID_PROFILES = 'Positive' OR " +
            "p.THYROID_FUNCTION_TESTS = 'Positive' OR p.KIDNEY_FUNCTION_TESTS = 'Positive')"
        );
        psPathology.setInt(1, Integer.parseInt(patientId));
        psPathology.setInt(2, Integer.parseInt(caseId));
        rsPathology = psPathology.executeQuery();
        if (rsPathology.next()) {
            pathologyCharge = rsPathology.getDouble("total_charges");
            if (rsPathology.wasNull()) pathologyCharge = 0.0;
        }

        // Fetch room charges
        psRoom = conn.prepareStatement(
            "SELECT ri.CHARGES " +
            "FROM admission a LEFT JOIN room_info ri ON a.ROOM_NO = ri.ROOM_NO AND a.BED_NO = ri.BED_NO " +
            "WHERE a.PATIENT_ID = ? AND a.CASE_ID = ?"
        );
        psRoom.setInt(1, Integer.parseInt(patientId));
        psRoom.setInt(2, Integer.parseInt(caseId));
        rsRoom = psRoom.executeQuery();
        if (rsRoom.next()) {
            roomCharge = rsRoom.getDouble("CHARGES");
            if (rsRoom.wasNull()) roomCharge = 0.0;
        }

        json.put("pathologyCharge", String.format("%.2f", pathologyCharge));
        json.put("roomCharge", String.format("%.2f", roomCharge));
        json.put("status", "success");
    } catch (NumberFormatException e) {
        json.put("status", "error");
        json.put("error", "Invalid patient ID or case ID format");
        System.err.println("NumberFormatException in get_patient_billing.jsp: " + e.getMessage());
    } catch (SQLException e) {
        json.put("status", "error");
        json.put("error", "Database error: " + e.getMessage());
        System.err.println("SQLException in get_patient_billing.jsp: " + e.getMessage());
    } catch (Exception e) {
        json.put("status", "error");
        json.put("error", "Unexpected error: " + e.getMessage());
        System.err.println("Exception in get_patient_billing.jsp: " + e.getMessage());
    } finally {
        if (rsPathology != null) try { rsPathology.close(); } catch (SQLException ignore) {}
        if (psPathology != null) try { psPathology.close(); } catch (SQLException ignore) {}
        if (rsRoom != null) try { rsRoom.close(); } catch (SQLException ignore) {}
        if (psRoom != null) try { psRoom.close(); } catch (SQLException ignore) {}
    }

    out.print(json.toString());
%>
```