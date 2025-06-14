<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    Connection conn = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    String patientId = request.getParameter("patientid");
    String patientName = request.getParameter("patientname");
    String xray = request.getParameter("xray");
    String xrayCount = request.getParameter("xray_count");
    String usound = request.getParameter("usound");
    String usoundCount = request.getParameter("usound_count");
    String bt = request.getParameter("bt");
    String btCount = request.getParameter("bt_count");
    String ctscan = request.getParameter("ctscan");
    String ctCount = request.getParameter("ct_count");
    String charges = request.getParameter("charges");
    String error = null;
    try {
        ps = conn.prepareStatement("SELECT PNAME FROM patient_info WHERE ID = ?");
        ps.setInt(1, Integer.parseInt(patientId));
        ResultSet rs = ps.executeQuery();
        if (!rs.next() || !rs.getString("PNAME").equals(patientName)) {
            error = "Invalid Patient ID or Name.";
        } else {
            ps.close();
            ps = conn.prepareStatement("INSERT INTO pathology (ID, PNAME, X_RAYS, xray_count, U_SOUND, us_count, B_TEST, bt_count, CT_SCAN, ct_count, CHARGES) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            ps.setInt(1, Integer.parseInt(patientId));
            ps.setString(2, patientName);
            ps.setString(3, xray.equals("None") ? null : xray);
            ps.setInt(4, Integer.parseInt(xrayCount));
            ps.setString(5, usound.equals("None") ? null : usound);
            ps.setInt(6, Integer.parseInt(usoundCount));
            ps.setString(7, bt.equals("None") ? null : bt);
            ps.setInt(8, Integer.parseInt(btCount));
            ps.setString(9, ctscan.equals("None") ? null : ctscan);
            ps.setInt(10, Integer.parseInt(ctCount));
            ps.setInt(11, Integer.parseInt(charges));
            int rows = ps.executeUpdate();
            if (rows > 0) {
                response.sendRedirect("pathology.jsp?success=Pathology+record+added");
            } else {
                error = "Failed to add pathology record.";
            }
        }
        rs.close();
    } catch (SQLException e) {
        error = "Database error: " + e.getMessage();
    } catch (NumberFormatException e) {
        error = "Invalid input format.";
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }
    if (error != null) {
        request.setAttribute("error", error);
        request.getRequestDispatcher("pathology.jsp?tab=adddoctor").forward(request, response);
    }
%>