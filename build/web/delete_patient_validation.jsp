<%@page import="java.sql.*"%>
<%!
    // Check if patient has active admissions
    boolean hasActiveAdmission(Connection conn, int patientId) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement("SELECT COUNT(*) FROM admission WHERE PATIENT_ID = ? AND DISCHARGE_DATE IS NULL");
            ps.setInt(1, patientId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        }
    }

    // Check if patient has any cases
    boolean hasCases(Connection conn, int patientId) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement("SELECT COUNT(*) FROM case_master WHERE PATIENT_ID = ?");
            ps.setInt(1, patientId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        }
    }

    // Check if patient has any pathology records
    boolean hasPathologyRecords(Connection conn, int patientId) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement("SELECT COUNT(*) FROM pathology WHERE ID = ?");
            ps.setInt(1, patientId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        }
    }

    // Check if patient has any billing records
    boolean hasBillingRecords(Connection conn, int patientId) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement("SELECT COUNT(*) FROM billing WHERE ID_NO = ?");
            ps.setInt(1, patientId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        }
    }
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Connection conn = (Connection) application.getAttribute("connection");
    if (conn == null || conn.isClosed()) {
        session.setAttribute("error-message", "Database connection is unavailable.");
        response.sendRedirect("patients.jsp");
        return;
    }

    String patientIdStr = request.getParameter("patientId");
    String roomNoStr = request.getParameter("roomNo");
    String bedNoStr = request.getParameter("bedNo");

    int patientId;
    try {
        patientId = Integer.parseInt(patientIdStr);
    } catch (NumberFormatException e) {
        session.setAttribute("error-message", "Invalid patient ID.");
        response.sendRedirect("patients.jsp");
        return;
    }

    // Check for dependencies
    try {
        if (hasActiveAdmission(conn, patientId)) {
            session.setAttribute("error-message", "Cannot delete patient with active admission. Please discharge the patient first.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (hasCases(conn, patientId)) {
            session.setAttribute("error-message", "Cannot delete patient with existing cases.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (hasPathologyRecords(conn, patientId)) {
            session.setAttribute("error-message", "Cannot delete patient with existing pathology records.");
            response.sendRedirect("patients.jsp");
            return;
        }
        if (hasBillingRecords(conn, patientId)) {
            session.setAttribute("error-message", "Cannot delete patient with existing billing records.");
            response.sendRedirect("patients.jsp");
            return;
        }

        // Delete the patient
        PreparedStatement psDelete = null;
        try {
            psDelete = conn.prepareStatement("DELETE FROM patient_info WHERE ID = ?");
            psDelete.setInt(1, patientId);
            int rowsDeleted = psDelete.executeUpdate();
            if (rowsDeleted > 0) {
                session.setAttribute("success-message", "Patient deleted successfully.");
            } else {
                session.setAttribute("error-message", "Patient not found.");
            }
        } finally {
            if (psDelete != null) try { psDelete.close(); } catch (SQLException ignore) {}
        }
    } catch (SQLException e) {
        session.setAttribute("error-message", "Database error: " + e.getMessage());
    }

    response.sendRedirect("patients.jsp");
%>