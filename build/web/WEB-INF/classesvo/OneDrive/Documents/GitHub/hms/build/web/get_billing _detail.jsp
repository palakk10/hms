```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.JSONObject" %>
<% 
    response.setContentType("application/json; charset=UTF-8");
    String patientId = request.getParameter("patientId");
    String caseId = request.getParameter("caseId");
    JSONObject json = new JSONObject();

    // Debug logging
    System.err.println("get_billing_details.jsp called with patientId=" + patientId + ", caseId=" + caseId);

    double pathologyCharge = 0.0;
    double roomCharge = 0.0;
    double otherCharge = 0.0; // Default to 0.00
    double totalCharge = 0.0;
    String admissionDate = null;
    String dischargeDate = null;
    String patientName = null;

    if (patientId == null || patientId.trim().isEmpty() || caseId == null || caseId.trim().isEmpty()) {
        json.put("status", "error");
        json.put("error", "Invalid or missing patient ID or case ID");
        System.err.println("Error: Invalid or missing patient ID or case ID");
        out.print(json.toString());
        return;
    }

    Connection conn = null;
    PreparedStatement psPathology = null;
    ResultSet rsPathology = null;
    PreparedStatement psRoom = null;
    ResultSet rsRoom = null;
    PreparedStatement psBillingCheck = null;
    ResultSet rsBillingCheck = null;
    PreparedStatement psBillingInsert = null;
    PreparedStatement psBillingUpdate = null;
    PreparedStatement psPatient = null;
    ResultSet rsPatient = null;

    try {
        conn = (Connection) application.getAttribute("connection");
        if (conn == null) {
            throw new SQLException("Database connection is null");
        }
        System.err.println("Database connection established");

        // Fetch patient name
        psPatient = conn.prepareStatement("SELECT PNAME FROM patient_info WHERE ID = ?");
        psPatient.setInt(1, Integer.parseInt(patientId));
        rsPatient = psPatient.executeQuery();
        if (rsPatient.next()) {
            patientName = rsPatient.getString("PNAME");
            System.err.println("Patient name fetched: " + patientName);
        } else {
            throw new SQLException("Patient not found for ID: " + patientId);
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
            System.err.println("Pathology charge: " + pathologyCharge);
        }

        // Fetch room charges and admission/discharge dates
        psRoom = conn.prepareStatement(
            "SELECT ri.CHARGES, a.ADMIT_DATE, a.DISCHARGE_DATE " +
            "FROM admission a LEFT JOIN room_info ri ON a.ROOM_NO = ri.ROOM_NO AND a.BED_NO = ri.BED_NO " +
            "WHERE a.PATIENT_ID = ? AND a.CASE_ID = ?"
        );
        psRoom.setInt(1, Integer.parseInt(patientId));
        psRoom.setInt(2, Integer.parseInt(caseId));
        rsRoom = psRoom.executeQuery();
        if (rsRoom.next()) {
            roomCharge = rsRoom.getDouble("CHARGES");
            if (rsRoom.wasNull()) roomCharge = 0.0;
            admissionDate = rsRoom.getString("ADMIT_DATE");
            dischargeDate = rsRoom.getString("DISCHARGE_DATE");
            System.err.println("Room charge: " + roomCharge + ", Admission: " + admissionDate + ", Discharge: " + dischargeDate);
        }

        // Calculate total
        totalCharge = pathologyCharge + roomCharge + otherCharge;

        // Check if billing record exists
        psBillingCheck = conn.prepareStatement(
            "SELECT ID_NO FROM billing WHERE ID_NO = ? AND CASE_ID = ?"
        );
        psBillingCheck.setInt(1, Integer.parseInt(patientId));
        psBillingCheck.setInt(2, Integer.parseInt(caseId));
        rsBillingCheck = psBillingCheck.executeQuery();
        
        if (!rsBillingCheck.next()) {
            // Insert new billing record
            psBillingInsert = conn.prepareStatement(
                "INSERT INTO billing (ID_NO, PNAME, OT_CHARGE, PATHOLOGY, ENT_DATE, DIS_DATE, CASE_ID) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)"
            );
            psBillingInsert.setInt(1, Integer.parseInt(patientId));
            psBillingInsert.setString(2, patientName);
            psBillingInsert.setDouble(3, roomCharge + otherCharge);
            psBillingInsert.setDouble(4, pathologyCharge);
            psBillingInsert.setString(5, admissionDate != null ? admissionDate : java.time.LocalDate.now().toString());
            psBillingInsert.setString(6, dischargeDate);
            psBillingInsert.setInt(7, Integer.parseInt(caseId));
            psBillingInsert.executeUpdate();
            System.err.println("Inserted new billing record for patientId=" + patientId + ", caseId=" + caseId);
        } else {
            // Update existing billing record
            psBillingUpdate = conn.prepareStatement(
                "UPDATE billing SET PNAME = ?, OT_CHARGE = ?, PATHOLOGY = ?, ENT_DATE = ?, DIS_DATE = ? " +
                "WHERE ID_NO = ? AND CASE_ID = ?"
            );
            psBillingUpdate.setString(1, patientName);
            psBillingUpdate.setDouble(2, roomCharge + otherCharge);
            psBillingUpdate.setDouble(3, pathologyCharge);
            psBillingUpdate.setString(4, admissionDate != null ? admissionDate : java.time.LocalDate.now().toString());
            psBillingUpdate.setString(5, dischargeDate);
            psBillingUpdate.setInt(6, Integer.parseInt(patientId));
            psBillingUpdate.setInt(7, Integer.parseInt(caseId));
            psBillingUpdate.executeUpdate();
            System.err.println("Updated billing record for patientId=" + patientId + ", caseId=" + caseId);
        }

        json.put("patientId", patientId);
        json.put("caseId", caseId);
        json.put("patientName", patientName != null ? patientName : "-");
        json.put("pathologyCharge", String.format("%.2f", pathologyCharge));
        json.put("roomCharge", String.format("%.2f", roomCharge));
        json.put("otherCharge", String.format("%.2f", otherCharge));
        json.put("totalCharge", String.format("%.2f", totalCharge));
        json.put("admissionDate", admissionDate != null ? admissionDate : "-");
        json.put("dischargeDate", dischargeDate != null ? dischargeDate : "-");
        json.put("status", "success");
    } catch (NumberFormatException e) {
        json.put("status", "error");
        json.put("error", "Invalid patient ID or case ID format: " + e.getMessage());
        System.err.println("NumberFormatException in get_billing_details.jsp: " + e.getMessage());
    } catch (SQLException e) {
        json.put("status", "error");
        json.put("error", "Database error: " + e.getMessage());
        System.err.println("SQLException in get_billing_details.jsp: " + e.getMessage());
    } catch (Exception e) {
        json.put("status", "error");
        json.put("error", "Unexpected error: " + e.getMessage());
        System.err.println("Exception in get_billing_details.jsp: " + e.getMessage());
    } finally {
        if (rsPatient != null) try { rsPatient.close(); } catch (SQLException ignore) {}
        if (psPatient != null) try { psPatient.close(); } catch (SQLException ignore) {}
        if (rsPathology != null) try { rsPathology.close(); } catch (SQLException ignore) {}
        if (psPathology != null) try { psPathology.close(); } catch (SQLException ignore) {}
        if (rsRoom != null) try { rsRoom.close(); } catch (SQLException ignore) {}
        if (psRoom != null) try { psRoom.close(); } catch (SQLException ignore) {}
        if (rsBillingCheck != null) try { rsBillingCheck.close(); } catch (SQLException ignore) {}
        if (psBillingCheck != null) try { psBillingCheck.close(); } catch (SQLException ignore) {}
        if (psBillingInsert != null) try { psBillingInsert.close(); } catch (SQLException ignore) {}
        if (psBillingUpdate != null) try { psBillingUpdate.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.commit(); } catch (SQLException ignore) {}
        out.print(json.toString());
    }
%>
```