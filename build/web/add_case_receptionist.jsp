```jsp
<%@page import="java.sql.*"%>
<%
    response.setHeader("cache-control", "no-cache, no-store, must-revalidate");
    String emaill = (String) session.getAttribute("email");
    String namee = (String) session.getAttribute("name");
    if (emaill == null || namee == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Connection c = (Connection) application.getAttribute("connection");
    if (c == null) {
        out.println("<script>alert('Error: Database connection is null.'); window.location='receptionist.jsp';</script>");
        return;
    }

    String patientId = request.getParameter("patient_id");
    String reason = request.getParameter("reason");
    String doctorId = request.getParameter("doctor_id");
    String conditionDetails = request.getParameter("condition_details");

    if (patientId == null || reason == null || doctorId == null || 
        patientId.trim().isEmpty() || reason.trim().isEmpty() || doctorId.trim().isEmpty()) {
        out.println("<script>alert('Error: All required fields must be filled.'); window.location='receptionist.jsp';</script>");
        return;
    }

    PreparedStatement ps = null;
    try {
        String sql = "INSERT INTO case_master (CASE_DATE, PATIENT_ID, REASON, DOCTOR_ID, CONDITION_DETAILS) VALUES (CURDATE(), ?, ?, ?, ?)";
        ps = c.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(patientId));
        ps.setString(2, reason.trim());
        ps.setInt(3, Integer.parseInt(doctorId));
        ps.setString(4, conditionDetails != null && !conditionDetails.trim().isEmpty() ? conditionDetails.trim().replaceAll("[\\r\\n]+", " ") : null);
        int rows = ps.executeUpdate();
        if (rows > 0) {
            out.println("<script>alert('Case added successfully!'); window.location='receptionist.jsp';</script>");
        } else {
            out.println("<script>alert('Error: Failed to add case.'); window.location='receptionist.jsp';</script>");
        }
    } catch (SQLException e) {
        out.println("<script>alert('Error: " + e.getMessage().replace("'", "\\'") + "'); window.location='receptionist.jsp';</script>");
    } catch (NumberFormatException e) {
        out.println("<script>alert('Error: Invalid patient or doctor ID.'); window.location='receptionist.jsp';</script>");
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }
%>
```