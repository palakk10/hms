<%@page import="java.sql.*"%>
<%
    response.setContentType("text/html");
    Connection c = (Connection) application.getAttribute("connection");
    String caseId = request.getParameter("case_id");
    if (c == null || caseId == null || caseId.trim().isEmpty()) {
        out.println("<tr><td colspan='15'>Error: Invalid request or database connection.</td></tr>");
        return;
    }
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        // Validate case_id exists in case_master
        ps = c.prepareStatement("SELECT CASE_ID FROM case_master WHERE CASE_ID = ?");
        ps.setInt(1, Integer.parseInt(caseId));
        rs = ps.executeQuery();
        if (!rs.next()) {
            out.println("<tr><td colspan='15'>Error: Invalid Case ID.</td></tr>");
            return;
        }
        rs.close();
        ps.close();

        // Fetch pathology records
        ps = c.prepareStatement(
            "SELECT p.PATHOLOGY_ID, pt.NAME AS TEST_NAME, p.TEST_DATE, p.B_TEST, p.BT_COUNT, p.URINALYSIS, p.URINALYSIS_COUNT, " +
            "p.LIVER_FUNCTION_TESTS, p.LIVER_FUNCTION_TESTS_COUNT, p.LIPID_PROFILES, p.LIPID_PROFILES_COUNT, " +
            "p.THYROID_FUNCTION_TESTS, p.THYROID_FUNCTION_TESTS_COUNT, p.KIDNEY_FUNCTION_TESTS, p.KIDNEY_FUNCTION_TESTS_COUNT " +
            "FROM pathology p " +
            "JOIN pathology_test pt ON p.TEST_ID = pt.TEST_ID " +
            "WHERE p.CASE_ID = ? ORDER BY p.TEST_DATE DESC"
        );
        ps.setInt(1, Integer.parseInt(caseId));
        rs = ps.executeQuery();
        if (!rs.isBeforeFirst()) {
            out.println("<tr><td colspan='15'>No pathology records found for Case ID: " + caseId + "</td></tr>");
        } else {
            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getInt("PATHOLOGY_ID") + "</td>");
                out.println("<td>" + (rs.getString("TEST_NAME") != null ? rs.getString("TEST_NAME") : "-") + "</td>");
                out.println("<td>" + (rs.getDate("TEST_DATE") != null ? rs.getDate("TEST_DATE") : "-") + "</td>");
                out.println("<td>" + (rs.getString("B_TEST") != null ? rs.getString("B_TEST") : "-") + "</td>");
                out.println("<td>" + rs.getInt("BT_COUNT") + "</td>");
                out.println("<td>" + (rs.getString("URINALYSIS") != null ? rs.getString("URINALYSIS") : "-") + "</td>");
                out.println("<td>" + rs.getInt("URINALYSIS_COUNT") + "</td>");
                out.println("<td>" + (rs.getString("LIVER_FUNCTION_TESTS") != null ? rs.getString("LIVER_FUNCTION_TESTS") : "-") + "</td>");
                out.println("<td>" + rs.getInt("LIVER_FUNCTION_TESTS_COUNT") + "</td>");
                out.println("<td>" + (rs.getString("LIPID_PROFILES") != null ? rs.getString("LIPID_PROFILES") : "-") + "</td>");
                out.println("<td>" + rs.getInt("LIPID_PROFILES_COUNT") + "</td>");
                out.println("<td>" + (rs.getString("THYROID_FUNCTION_TESTS") != null ? rs.getString("THYROID_FUNCTION_TESTS") : "-") + "</td>");
                out.println("<td>" + rs.getInt("THYROID_FUNCTION_TESTS_COUNT") + "</td>");
                out.println("<td>" + (rs.getString("KIDNEY_FUNCTION_TESTS") != null ? rs.getString("KIDNEY_FUNCTION_TESTS") : "-") + "</td>");
                out.println("<td>" + rs.getInt("KIDNEY_FUNCTION_TESTS_COUNT") + "</td>");
                out.println("</tr>");
            }
        }
    } catch (SQLException e) {
        out.println("<tr><td colspan='15'>Database Error: " + e.getMessage() + "</td></tr>");
    } catch (NumberFormatException e) {
        out.println("<tr><td colspan='15'>Error: Invalid Case ID format.</td></tr>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }
%>