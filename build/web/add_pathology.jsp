<%@page import="java.sql.*"%>
<%
    response.setContentType("text/html");
    Connection c = (Connection) application.getAttribute("connection");
    String caseId = request.getParameter("case_id");
    String testId = request.getParameter("test_id");
    String testDate = request.getParameter("test_date");
    String bTest = request.getParameter("b_test");
    String btCount = request.getParameter("bt_count");
    String urinalysis = request.getParameter("urinalysis");
    String urinalysisCount = request.getParameter("urinalysis_count");

    if (c == null || caseId == null || testId == null || testDate == null) {
        out.println("<script>alert('Error: Invalid input.'); window.location='view_cases.jsp?patient_id=" + request.getParameter("patient_id") + "';</script>");
        return;
    }

    PreparedStatement ps = null;
    try {
        ps = c.prepareStatement(
            "INSERT INTO pathology (CASE_ID, TEST_ID, TEST_DATE, B_TEST, BT_COUNT, URINALYSIS, URINALYSIS_COUNT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?)"
        );
        ps.setInt(1, Integer.parseInt(caseId));
        ps.setInt(2, Integer.parseInt(testId));
        ps.setDate(3, java.sql.Date.valueOf(testDate));
        ps.setString(4, bTest != null && !bTest.trim().isEmpty() ? bTest : null);
        ps.setInt(5, btCount != null ? Integer.parseInt(btCount) : 0);
        ps.setString(6, urinalysis != null && !urinalysis.trim().isEmpty() ? urinalysis : null);
        ps.setInt(7, urinalysisCount != null ? Integer.parseInt(urinalysisCount) : 0);
        int rows = ps.executeUpdate();
        if (rows > 0) {
            out.println("<script>alert('Pathology report added successfully.'); window.location='view_cases.jsp?patient_id=" + request.getParameter("patient_id") + "';</script>");
        } else {
            out.println("<script>alert('Error: Failed to add pathology report.'); window.location='view_cases.jsp?patient_id=" + request.getParameter("patient_id") + "';</script>");
        }
    } catch (SQLException e) {
        out.println("<script>alert('Database Error: " + e.getMessage() + "'); window.location='view_cases.jsp?patient_id=" + request.getParameter("patient_id") + "';</script>");
    } catch (NumberFormatException e) {
        out.println("<script>alert('Error: Invalid input format.'); window.location='view_cases.jsp?patient_id=" + request.getParameter("patient_id") + "';</script>");
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }
%>