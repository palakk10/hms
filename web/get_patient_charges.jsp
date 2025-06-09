<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String patientId = request.getParameter("patientId");
    Connection conn = (Connection) application.getAttribute("connection");
    PreparedStatement psPathology = null;
    PreparedStatement psRoom = null;
    ResultSet rsPathology = null;
    ResultSet rsRoom = null;
    response.setContentType("application/json; charset=UTF-8");
    int pathologyCharge = 0;
    int roomCharge = 0;
    try {
        if (patientId == null || patientId.trim().isEmpty()) {
            out.print("{\"pathologyCharge\":0,\"roomCharge\":0}");
            return;
        }
        // Fetch pathology charge
        psPathology = conn.prepareStatement("SELECT CHARGES FROM pathology WHERE ID = ?");
        psPathology.setInt(1, Integer.parseInt(patientId));
        rsPathology = psPathology.executeQuery();
        if (rsPathology.next()) {
            pathologyCharge = rsPathology.getInt("CHARGES");
        }
        // Fetch room charge
        psRoom = conn.prepareStatement(
            "SELECT r.CHARGES FROM room_info r JOIN patient_info p ON p.ROOM_NO = r.ROOM_NO AND p.BED_NO = r.BED_NO WHERE p.ID = ?"
        );
        psRoom.setInt(1, Integer.parseInt(patientId));
        rsRoom = psRoom.executeQuery();
        if (rsRoom.next()) {
            roomCharge = rsRoom.getInt("CHARGES");
        }
        // Output JSON
        out.print(String.format("{\"pathologyCharge\":%d,\"roomCharge\":%d}", pathologyCharge, roomCharge));
    } catch (NumberFormatException e) {
        out.print("{\"pathologyCharge\":0,\"roomCharge\":0}");
    } catch (SQLException e) {
        out.print("{\"pathologyCharge\":0,\"roomCharge\":0}");
        System.err.println("SQL Error in get_patient_charges.jsp: " + e.getMessage());
    } finally {
        if (rsPathology != null) try { rsPathology.close(); } catch (SQLException e) {}
        if (psPathology != null) try { psPathology.close(); } catch (SQLException e) {}
        if (rsRoom != null) try { rsRoom.close(); } catch (SQLException e) {}
        if (psRoom != null) try { psRoom.close(); } catch (SQLException e) {}
    }
%>