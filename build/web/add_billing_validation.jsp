```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String patientId = request.getParameter("patient_id");
    String patientName = request.getParameter("patient_name");
    String otherCharge = request.getParameter("other_charge");
    String roomCharge = request.getParameter("room_charge");
    String pathoCharge = request.getParameter("pathology_charge");
    String entryDate = request.getParameter("entry_date");
    String disDate = request.getParameter("dis_date");

    // Combine room_charge and other_charge into otCharge
    double otCharge = 0.0;
    try {
        double roomChg = roomCharge != null && !roomCharge.isEmpty() ? Double.parseDouble(roomCharge) : 0.0;
        double otherChg = otherCharge != null && !otherCharge.isEmpty() ? Double.parseDouble(otherCharge) : 0.0;
        otCharge = roomChg + otherChg;
    } catch (NumberFormatException e) {
        System.err.println("add_billing_validation.jsp: Invalid charge format: " + e.getMessage());
    }

    System.out.println("add_billing_validation.jsp: Parameters: patient_id=" + patientId + ", patient_name=" + patientName + ", ot_charge=" + otCharge + ", pathology_charge=" + pathoCharge + ", room_charge=" + roomCharge + ", other_charge=" + otherCharge + ", entry_date=" + entryDate + ", dis_date=" + disDate);

    Connection conn = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    try {
        ps = conn.prepareStatement("INSERT INTO billing (ID_NO, PNAME, OT_CHARGE, PATHOLOGY, ENT_DATE, DIS_DATE) VALUES (?, ?, ?, ?, ?, ?)");
        ps.setInt(1, Integer.parseInt(patientId));
        ps.setString(2, patientName);
        ps.setDouble(3, otCharge);
        ps.setDouble(4, Double.parseDouble(pathoCharge));
        ps.setString(5, entryDate);
        ps.setString(6, disDate != null && !disDate.isEmpty() ? disDate : null);

        int result = ps.executeUpdate();
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
<%      } else {
            out.println("<div class='alert alert-danger'>Failed to add billing information.</div>");
        }
    } catch (SQLException e) {
        System.err.println("add_billing_validation.jsp: SQL Error: " + e.getMessage());
        out.println("<div class='alert alert-danger'>Database error: " + e.getMessage() + "</div>");
    } catch (NumberFormatException e) {
        System.err.println("add_billing_validation.jsp: Invalid number format: " + e.getMessage());
        out.println("<div class='alert alert-danger'>Invalid input format for charges or patient ID.</div>");
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }
%>
```