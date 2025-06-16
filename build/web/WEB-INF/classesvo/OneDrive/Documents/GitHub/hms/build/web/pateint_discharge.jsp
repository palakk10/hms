```jsp
<%-- 
    Document   : pateint_discharge
    Created on : 16 Jun 2025, 1:56:10?am
    Author     : Lenovo
--%>
<%@page import="java.sql.*, java.util.logging.Logger"%>
<%
    Logger logger = Logger.getLogger("pateint_discharge.jsp");
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    String email = (String) session.getAttribute("email");
    String name = (String) session.getAttribute("name");
    if (email == null || name == null) {
        logger.warning("Unauthorized access attempt: no session email or name.");
        response.sendRedirect("index.jsp");
        return;
    }

    Connection conn = (Connection) application.getAttribute("connection");
    if (conn == null) {
        session.setAttribute("dischargeMessage", "Database connection is unavailable.");
        logger.severe("Database connection is null.");
        response.sendRedirect("patients.jsp");
        return;
    }

    String patientId = request.getParameter("patient_id");
    String admitId = request.getParameter("admit_id");
    String dischargeDate = request.getParameter("discharge_date");
    logger.info("Discharge request - patientId: " + patientId + ", admitId: " + admitId + ", dischargeDate: " + dischargeDate);

    if (patientId == null || admitId == null || dischargeDate == null) {
        session.setAttribute("dischargeMessage", "All fields are required.");
        logger.warning("Missing required parameters.");
        response.sendRedirect("patients.jsp");
        return;
    }

    PreparedStatement psUpdateAdmission = null;
    PreparedStatement psUpdateRoom = null;
    PreparedStatement psGetRoom = null;
    ResultSet rsRoom = null;

    try {
        conn.setAutoCommit(false);
        logger.info("Starting transaction for admitId: " + admitId);

        // Get room and bed for the admission
        psGetRoom = conn.prepareStatement(
            "SELECT ROOM_NO, BED_NO FROM admission WHERE ADMIT_ID = ? AND PATIENT_ID = ? AND DISCHARGE_DATE IS NULL"
        );
        psGetRoom.setInt(1, Integer.parseInt(admitId));
        psGetRoom.setInt(2, Integer.parseInt(patientId));
        rsRoom = psGetRoom.executeQuery();
        if (!rsRoom.next()) {
            session.setAttribute("dischargeMessage", "Invalid admission or already discharged.");
            logger.warning("No active admission found for admitId: " + admitId + ", patientId: " + patientId);
            response.sendRedirect("patients.jsp");
            return;
        }
        int roomNo = rsRoom.getInt("ROOM_NO");
        int bedNo = rsRoom.getInt("BED_NO");
        logger.info("Found room: " + roomNo + ", bed: " + bedNo);

        // Update admission with discharge date
        psUpdateAdmission = conn.prepareStatement(
            "UPDATE admission SET DISCHARGE_DATE = ? WHERE ADMIT_ID = ? AND PATIENT_ID = ?"
        );
        psUpdateAdmission.setDate(1, java.sql.Date.valueOf(dischargeDate));
        psUpdateAdmission.setInt(2, Integer.parseInt(admitId));
        psUpdateAdmission.setInt(3, Integer.parseInt(patientId));
        int rowsAffected = psUpdateAdmission.executeUpdate();
        if (rowsAffected == 0) {
            throw new SQLException("No admission found for discharge.");
        }
        logger.info("Updated " + rowsAffected + " admission record(s).");

        // Update room status to Available
        psUpdateRoom = conn.prepareStatement(
            "UPDATE room_info SET STATUS = 'Available' WHERE ROOM_NO = ? AND BED_NO = ?"
        );
        psUpdateRoom.setInt(1, roomNo);
        psUpdateRoom.setInt(2, bedNo);
        int rowsUpdated = psUpdateRoom.executeUpdate();
        logger.info("Updated " + rowsUpdated + " room record(s) to Available.");

        conn.commit();
        session.setAttribute("dischargeMessage", "Patient discharged successfully.");
        logger.info("Discharge successful for admitId: " + admitId);
    } catch (SQLException | NumberFormatException e) {
        try { conn.rollback(); } catch (SQLException ignore) {}
        session.setAttribute("dischargeMessage", "Error discharging patient: " + e.getMessage());
        logger.severe("Error during discharge: " + e.getMessage());
    } finally {
        if (rsRoom != null) try { rsRoom.close(); } catch (SQLException ignore) {}
        if (psGetRoom != null) try { psGetRoom.close(); } catch (SQLException ignore) {}
        if (psUpdateAdmission != null) try { psUpdateAdmission.close(); } catch (SQLException ignore) {}
        if (psUpdateRoom != null) try { psUpdateRoom.close(); } catch (SQLException ignore) {}
        try { conn.setAutoCommit(true); } catch (SQLException ignore) {}
    }
    response.sendRedirect("patients.jsp");
%>
```