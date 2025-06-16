```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<% 
    String patientId = request.getParameter("patient_id");
    String patientName = request.getParameter("patient_name");
    String caseId = request.getParameter("case_id");
    String entryDate = request.getParameter("entry_date");
    String disDate = request.getParameter("dis_date");
    String otherChargeStr = request.getParameter("other_charge");

    Connection conn = null;
    PreparedStatement psPathology = null;
    ResultSet rsPathology = null;
    PreparedStatement psRoom = null;
    ResultSet rsRoom = null;
    PreparedStatement psInsert = null;
    double pathologyCharge = 0.0;
    double roomCharge = 0.0;
    double otherCharge = 0.0;
    double otCharge = 0.0;

    try {
        // Validate inputs
        if (patientId == null || patientId.trim().isEmpty() || 
            patientName == null || patientName.trim().isEmpty() ||
            caseId == null || caseId.trim().isEmpty() ||
            entryDate == null || entryDate.trim().isEmpty()) {
            out.println("<div class='alert alert-danger'>Error: Missing required fields.</div>");
            return;
        }

        // Parse other charge
        if (otherChargeStr != null && !otherChargeStr.trim().isEmpty()) {
            otherCharge = Double.parseDouble(otherChargeStr);
            if (otherCharge < 0) otherCharge = 0.0;
        }

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

        // Calculate OT_CHARGE (room + other)
        otCharge = roomCharge + otherCharge;

        // Insert billing record
        psInsert = conn.prepareStatement(
            "INSERT INTO billing (ID_NO, PNAME, OT_CHARGE, PATHOLOGY, ENT_DATE, DIS_DATE, CASE_ID) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?)"
        );
        psInsert.setInt(1, Integer.parseInt(patientId));
        psInsert.setString(2, patientName);
        psInsert.setDouble(3, otCharge);
        psInsert.setDouble(4, pathologyCharge);
        psInsert.setString(5, entryDate);
        psInsert.setString(6, disDate != null && !disDate.trim().isEmpty() ? disDate : null);
        psInsert.setInt(7, Integer.parseInt(caseId));

        int result = psInsert.executeUpdate();
        if (result > 0) {
%>
<div style="text-align: center; margin-top: 25%;">
    <font color="green">
        <script>
            function redirect() { window.location = "billing.jsp"; }
            document.write("<h2>Billing Information Added Successfully</h2><br><br>");
            document.write("<h3>Redirecting...</h3>");
            setTimeout(redirect, 2000);
        </script>
    </font>
</div>
<% 
        } else {
            out.println("<div class='alert alert-danger'>Failed to add billing information.</div>");
        }
    } catch (NumberFormatException e) {
        out.println("<div class='alert alert-danger'>Error: Invalid number format in IDs or charges.</div>");
        System.err.println("NumberFormatException in add_billing_validation.jsp: " + e.getMessage());
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Database error: " + e.getMessage() + "</div>");
        System.err.println("SQLException in add_billing_validation.jsp: " + e.getMessage());
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Unexpected error: " + e.getMessage() + "</div>");
        System.err.println("Exception in add_billing_validation.jsp: " + e.getMessage());
    } finally {
        if (rsPathology != null) try { rsPathology.close(); } catch (SQLException ignore) {}
        if (psPathology != null) try { psPathology.close(); } catch (SQLException ignore) {}
        if (rsRoom != null) try { rsRoom.close(); } catch (SQLException ignore) {}
        if (psRoom != null) try { psRoom.close(); } catch (SQLException ignore) {}
        if (psInsert != null) try { psInsert.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.commit(); } catch (SQLException ignore) {}
    }
%>
```