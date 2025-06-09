

<%@page import="java.sql.*" %>
<%
try {
    String deptName = request.getParameter("deptName");
    String deptDesc = request.getParameter("deptDesc");

    Connection con = (Connection) application.getAttribute("connection");
    PreparedStatement ps = con.prepareStatement("INSERT INTO department (name, description) VALUES (?, ?)");
    ps.setString(1, deptName);
    ps.setString(2, deptDesc);

    int i = ps.executeUpdate();

    if (i > 0) {
%>
<div style="text-align:center;margin-top:35%">
<font color="green">
<script type="text/javascript">
function Redirect() {
    window.location="department.jsp";
}
document.write("<h2>Department Added Successfully</h2><br><br>");
document.write("<h3>Redirecting you to home page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
    } else {
%>
<div style="text-align:center;margin-top:35%">
<font color="red">
<h2>Failed to Add Department</h2><br><br>
<h3>Redirecting you to home page....</h3>
<script type="text/javascript">
setTimeout('Redirect()', 3000);
function Redirect() {
    window.location="department.jsp";
}
</script>
</font>
</div>
<%
    }
    ps.close();
    con.commit();
} catch (SQLException e) {
%>
<div style="text-align:center;margin-top:35%">
<font color="red">
<h2>Error: <%= e.getMessage() %></h2><br><br>
<h3>Redirecting you to home page....</h3>
<script type="text/javascript">
setTimeout('Redirect()', 3000);
function Redirect() {
    window.location="department.jsp";
}
</script>
</font>
</div>
<%
}
%>