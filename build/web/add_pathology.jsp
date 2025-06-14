```jsp
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    response.setHeader("cache-control", "no-cache, no-store, must-revalidate");
    String emaill = (String) session.getAttribute("email");
    String namee = (String) session.getAttribute("name");
    if (emaill == null || namee == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Connection conn = (Connection) application.getAttribute("connection");
    if (conn == null) {
        out.println("<script>alert('Error: Database connection is null.'); window.location='receptionist.jsp';</script>");
        return;
    }

    String patientId = request.getParameter("patient_id");
    String caseId = request.getParameter("case_id");
    String testId = request.getParameter("test_id");
    String testDate = request.getParameter("test_date");
    String bTest = request.getParameter("b_test");
    String btCount = request.getParameter("bt_count");
    String urinalysis = request.getParameter("urinalysis");
    String urinalysisCount = request.getParameter("urinalysis_count");
    String liverFunctionTests = request.getParameter("liver_function_tests");
    String liverFunctionTestsCount = request.getParameter("liver_function_tests_count");
    String lipidProfiles = request.getParameter("lipid_profiles");
    String lipidProfilesCount = request.getParameter("lipid_profiles_count");
    String thyroidFunctionTests = request.getParameter("thyroid_function_tests");
    String thyroidFunctionTestsCount = request.getParameter("thyroid_function_tests_count");
    String kidneyFunctionTests = request.getParameter("kidney_function_tests");
    String kidneyFunctionTestsCount = request.getParameter("kidney_function_tests_count");

    // Input validation
    if (patientId == null || caseId == null || testId == null || testDate == null ||
        btCount == null || urinalysisCount == null || liverFunctionTestsCount == null ||
        lipidProfilesCount == null || thyroidFunctionTestsCount == null || kidneyFunctionTestsCount == null ||
        patientId.trim().isEmpty() || caseId.trim().isEmpty() || testId.trim().isEmpty() || testDate.trim().isEmpty()) {
        out.println("<script>alert('Error: All required fields must be filled.'); window.location='receptionist.jsp?status=error';</script>");
        return;
    }

    PreparedStatement ps = null;
    ResultSet rs = null;
    boolean success = false;

    try {
        conn.setAutoCommit(false); // Start transaction

        // Parse inputs
        int patientIdInt = Integer.parseInt(patientId);
        int caseIdInt = Integer.parseInt(caseId);
        int testIdInt = Integer.parseInt(testId);
        int btCountInt = Integer.parseInt(btCount);
        int urinalysisCountInt = Integer.parseInt(urinalysisCount);
        int liverFunctionTestsCountInt = Integer.parseInt(liverFunctionTestsCount);
        int lipidProfilesCountInt = Integer.parseInt(lipidProfilesCount);
        int thyroidFunctionTestsCountInt = Integer.parseInt(thyroidFunctionTestsCount);
        int kidneyFunctionTestsCountInt = Integer.parseInt(kidneyFunctionTestsCount);

        // Validate test date
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        sdf.setLenient(false);
        java.util.Date testDateUtil = sdf.parse(testDate);
        java.sql.Date testDateSql = new java.sql.Date(testDateUtil.getTime());

        // Validate patient ID and case ID
        ps = conn.prepareStatement("SELECT ID FROM patient_info WHERE ID = ?");
        ps.setInt(1, patientIdInt);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Invalid Patient ID.");
        }
        rs.close();
        ps.close();

        ps = conn.prepareStatement("SELECT CASE_ID FROM case_master WHERE CASE_ID = ? AND PATIENT_ID = ?");
        ps.setInt(1, caseIdInt);
        ps.setInt(2, patientIdInt);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Invalid Case ID for this patient.");
        }
        rs.close();
        ps.close();

        // Validate test ID
        ps = conn.prepareStatement("SELECT TEST_ID FROM pathology_test WHERE TEST_ID = ?");
        ps.setInt(1, testIdInt);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Invalid Test ID.");
        }
        rs.close();
        ps.close();

        // Insert into pathology
        ps = conn.prepareStatement(
            "INSERT INTO pathology (ID, CASE_ID, TEST_ID, TEST_DATE, B_TEST, BT_COUNT, URINALYSIS, URINALYSIS_COUNT, " +
            "LIVER_FUNCTION_TESTS, LIVER_FUNCTION_TESTS_COUNT, LIPID_PROFILES, LIPID_PROFILES_COUNT, " +
            "THYROID_FUNCTION_TESTS, THYROID_FUNCTION_TESTS_COUNT, KIDNEY_FUNCTION_TESTS, KIDNEY_FUNCTION_TESTS_COUNT) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        );
        ps.setInt(1, patientIdInt);
        ps.setInt(2, caseIdInt);
        ps.setInt(3, testIdInt);
        ps.setDate(4, testDateSql);
        ps.setString(5, bTest != null && !bTest.isEmpty() ? bTest : null);
        ps.setInt(6, btCountInt);
        ps.setString(7, urinalysis != null && !urinalysis.isEmpty() ? urinalysis : null);
        ps.setInt(8, urinalysisCountInt);
        ps.setString(9, liverFunctionTests != null && !liverFunctionTests.isEmpty() ? liverFunctionTests : null);
        ps.setInt(10, liverFunctionTestsCountInt);
        ps.setString(11, lipidProfiles != null && !lipidProfiles.isEmpty() ? lipidProfiles : null);
        ps.setInt(12, lipidProfilesCountInt);
        ps.setString(13, thyroidFunctionTests != null && !thyroidFunctionTests.isEmpty() ? thyroidFunctionTests : null);
        ps.setInt(14, thyroidFunctionTestsCountInt);
        ps.setString(15, kidneyFunctionTests != null && !kidneyFunctionTests.isEmpty() ? kidneyFunctionTests : null);
        ps.setInt(16, kidneyFunctionTestsCountInt);

        int rows = ps.executeUpdate();
        if (rows > 0) {
            conn.commit();
            success = true;
            out.println("<script>alert('Pathology record added successfully!'); window.location='receptionist.jsp?status=success';</script>");
        } else {
            conn.rollback();
            out.println("<script>alert('Error: Failed to add pathology record.'); window.location='receptionist.jsp?status=error';</script>");
        }
    } catch (SQLException e) {
        try { conn.rollback(); } catch (SQLException rollbackEx) {}
        out.println("<script>alert('Error: " + e.getMessage().replace("'", "\\'") + "'); window.location='receptionist.jsp?status=error';</script>");
    } catch (NumberFormatException e) {
        out.println("<script>alert('Error: Invalid numeric input.'); window.location='receptionist.jsp?status=error';</script>");
    } catch (java.text.ParseException e) {
        out.println("<script>alert('Error: Invalid test date format.'); window.location='receptionist.jsp?status=error';</script>");
    } catch (Exception e) {
        out.println("<script>alert('Error: " + e.getMessage().replace("'", "\\'") + "'); window.location='receptionist.jsp?status=error';</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        try { conn.setAutoCommit(true); } catch (SQLException e) {}
    }
%>
```