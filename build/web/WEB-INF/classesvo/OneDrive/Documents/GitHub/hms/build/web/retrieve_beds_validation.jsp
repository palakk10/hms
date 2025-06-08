<%@page import="java.sql.*"%>
<%@page contentType="text/html;charset=UTF-8" %>
<%
    String roomNo = request.getParameter("roomNo");
    if (roomNo == null || roomNo.trim().isEmpty()) {
        %>
        <option value="">Invalid room number</option>
        <%
        return;
    }
    Connection conn = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        ps = conn.prepareStatement(
            "SELECT bed_no FROM room_info WHERE room_no = ? AND LOWER(status) = 'available' ORDER BY bed_no ASC"
        );
        ps.setInt(1, Integer.parseInt(roomNo));
        rs = ps.executeQuery();
        boolean hasBeds = false;
        %>
        <option value="">Select Bed</option>
        <%
        while (rs.next()) {
            int bedNo = rs.getInt("bed_no");
            hasBeds = true;
            %>
            <option value="<%=bedNo%>"><%=bedNo%></option>
            <%
        }
        if (!hasBeds) {
            %>
            <option value="">No available beds</option>
            <%
        }
    } catch (NumberFormatException e) {
        %>
        <option value="">Invalid room number format</option>
        <%
        e.printStackTrace();
    } catch (SQLException e) {
        %>
        <option value="">Error loading beds</option>
        <%
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }
%>