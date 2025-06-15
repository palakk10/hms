<%@page import="java.sql.*, javax.servlet.http.HttpSession"%>
<%
    String admitId = request.getParameter("admit_id");
    String dischargeDate = request.getParameter("discharge_date");
    String patientId = request.getParameter("patient_id");
    Connection conn = (Connection) application.getAttribute("connection");
    boolean success = false;
    String message = "";
    
    if (admitId != null && dischargeDate != null && patientId != null) {
        try {
            conn.setAutoCommit(false);
            // Update admission
            PreparedStatement psAdmission = conn.prepareStatement(
                "UPDATE admission SET DISCHARGE_DATE = ? WHERE ADMIT_ID = ? AND PATIENT_ID = ? AND DISCHARGE_DATE IS NULL"
            );
            psAdmission.setDate(1, java.sql.Date.valueOf(dischargeDate));
            psAdmission.setInt(2, Integer.parseInt(admitId));
            psAdmission.setInt(3, Integer.parseInt(patientId));
            int rowsUpdated = psAdmission.executeUpdate();
            psAdmission.close();
            
            if (rowsUpdated > 0) {
                // Update room status
                PreparedStatement psRoom = conn.prepareStatement(
                    "UPDATE room_info SET STATUS = 'Available' WHERE ROOM_NO = " +
                    "(SELECT ROOM_NO FROM admission WHERE ADMIT_ID = ?) AND BED_NO = " +
                    "(SELECT BED_NO FROM admission WHERE ADMIT_ID = ?)"
                );
                psRoom.setInt(1, Integer.parseInt(admitId));
                psRoom.setInt(2, Integer.parseInt(admitId));
                psRoom.executeUpdate();
                psRoom.close();
                
                conn.commit();
                success = true;
                message = "Patient discharged successfully.";
            } else {
                message = "Invalid admission or patient already discharged.";
            }
        } catch (SQLException e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            message = "Error: " + e.getMessage();
        } catch (Exception e) {
            try { conn.rollback(); } catch (SQLException ex) {}
            message = "Error: " + e.getMessage();
        } finally {
            try { conn.setAutoCommit(true); } catch (SQLException e) {}
        }
    } else {
        message = "Missing required parameters.";
    }
    
    session.setAttribute("dischargeMessage", message);
    response.sendRedirect("receptionist.jsp");
%>