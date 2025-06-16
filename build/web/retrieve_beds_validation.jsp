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

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        int roomNoInt = Integer.parseInt(roomNo);
        if (roomNoInt <= 0) {
            %>
            <option value="">Invalid room number</option>
            <%
            return;
        }

        conn = (Connection) application.getAttribute("connection");
        if (conn == null) {
            %>
            <option value="">Database connection unavailable</option>
            <%
            return;
        }

        ps = conn.prepareStatement(
            "SELECT BED_NO FROM room_info WHERE ROOM_NO = ? AND STATUS = 'Available' ORDER BY BED_NO ASC"
        );
        ps.setInt(1, roomNoInt);
        rs = ps.executeQuery();
        boolean hasBeds = false;
        %>
        <option value="" disabled selected>Select Bed</option>
        <%
        while (rs.next()) {
            int bedNo = rs.getInt("BED_NO");
            hasBeds = true;
            %>
            <option value="<%=bedNo%>"><%=bedNo%></option>
            <%
        }
        if (!hasBeds) {
            %>
            <option value="" disabled>No available beds</option>
            <%
        }
    } catch (NumberFormatException e) {
        %>
        <option value="">Invalid room number format</option>
        <%
    } catch (SQLException e) {
        %>
        <option value="">Error loading beds: <%=e.getMessage()%></option>
        <%
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }
%>