<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Nurse Validation</title>
</head>
<body>
    <%
        String nurseId = request.getParameter("nurseId");

        Connection con = (Connection)application.getAttribute("connection");
        PreparedStatement ps = con.prepareStatement("delete from nurse_info where id=?");

        ps.setInt(1, Integer.parseInt(nurseId));

        int i = ps.executeUpdate();

        if(i > 0) {
    %>
    <div style="text-align:center;margin-top:25%">
        <font color="red">
            <script type="text/javascript">
                function Redirect() {
                    window.location="nurse.jsp";
                }
                document.write("<h2>Nurse Information Removed Successfully</h2><br><br>");
                document.write("<h3>Redirecting you to home page....</h3>");
                setTimeout('Redirect()', 3000);
            </script>
        </font>
    </div>
    <%
        }

        ps.close();
    %>
</body>
</html>