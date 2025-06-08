<%@ page import="java.sql.*" %>
<%
    Connection con = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    ResultSet rs = null;
    StringBuilder json = new StringBuilder("[");

    try {
        ps = con.prepareStatement("SELECT ID, NAME FROM doctor_info");
        rs = ps.executeQuery();
        boolean first = true;
        while (rs.next()) {
            if (!first) json.append(",");
            json.append(String.format("{\"id\":%d,\"name\":\"%s\"}", rs.getInt("ID"), rs.getString("NAME").replace("\"", "\\\"")));
            first = false;
        }
        json.append("]");
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
    }

    response.setContentType("application/json");
    out.print(json.toString());
%>