<%@page import="java.sql.*" %>
<%
    String roomNo = request.getParameter("roomNo");
    String bedNo = request.getParameter("bedNo");
    String status = request.getParameter("status");
    String type = request.getParameter("type");

    try {
        int roomNoInt = Integer.parseInt(roomNo);
        int bedNoInt = Integer.parseInt(bedNo);

        if (roomNoInt <= 0 || bedNoInt <= 0) {
            throw new Exception("Room Number and Bed Number must be positive numbers.");
        }
        if (type == null || type.trim().isEmpty()) {
            throw new Exception("Room Type is required.");
        }

        // Assign charges based on room type
        int charges;
        String typeTrim = type.trim();
        switch (typeTrim) {
            case "Common":
                charges = 2000;
                break;
            case "Deluxe":
                charges = 5000;
                break;
            case "ICU":
                charges = 10000;
                break;
            default:
                charges = 2000; // Default for other types
        }

        Connection con = (Connection)application.getAttribute("connection");
        PreparedStatement ps = con.prepareStatement("INSERT INTO room_info (room_no, bed_no, status, type, charges) VALUES (?, ?, ?, ?, ?)");
        ps.setInt(1, roomNoInt);
        ps.setInt(2, bedNoInt);
        ps.setString(3, status);
        ps.setString(4, type);
        ps.setInt(5, charges);

        int i = ps.executeUpdate();
        if (i > 0) {
%>
<div style="text-align:center;margin-top:35%">
<font color="green">
<script type="text/javascript">
function Redirect() {
    window.location="room.jsp";
}
document.write("<h2>Room with Bed Added Successfully</h2><br><br>");
document.write("<h3>Redirecting you to home page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
        } else {
            throw new Exception("Failed to add room.");
        }
        ps.close();
    } catch (Exception e) {
%>
<div style="text-align:center;margin-top:35%">
<font color="red">
<script type="text/javascript">
function Redirect() {
    window.location="room.jsp";
}
document.write("<h2>Error: <%=e.getMessage()%></h2><br><br>");
document.write("<h3>Redirecting you to home page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
    }
%>