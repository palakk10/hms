<%@page import="java.sql.*" %>
<%
    String roomNo = request.getParameter("roomNo");
    String bedNo = request.getParameter("bedNo");
    String status = request.getParameter("status");
    String type = request.getParameter("type");

    Connection con = (Connection)application.getAttribute("connection");
    PreparedStatement ps = con.prepareStatement("UPDATE room_info SET status=?, type=? WHERE room_no=? AND bed_no=?");
    ps.setString(1, status);
    ps.setString(2, type);
    ps.setInt(3, Integer.parseInt(roomNo));
    ps.setInt(4, Integer.parseInt(bedNo));

    int i = ps.executeUpdate();
    if (i > 0) {
%>
<div style="text-align:center;margin-top:25%">
<font color="blue">
<script type="text/javascript">
function Redirect() {
    window.location="room.jsp";
}
document.write("<h2>Room with Bed Updated Successfully</h2><br><Br>");
document.write("<h3>Redirecting you to home page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
    } else {
%>
<div style="text-align:center;margin-top:25%">
<font color="red">
<script type="text/javascript">
function Redirect() {
    window.location="room.jsp";
}
document.write("<h2>Room Not Updated. Check Room and Bed Number.</h2><br><Br>");
document.write("<h3>Redirecting you to home page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
    }
    ps.close();
%>