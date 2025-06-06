<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Pathology Validation</title>
</head>
<body>
    <%
        String pathologyId = request.getParameter("pathologyId");

        Connection con = (Connection) application.getAttribute("connection");
        PreparedStatement ps = con.prepareStatement("DELETE FROM pathology WHERE pathology_id=?");
        ps.setInt(1, Integer.parseInt(pathologyId));

        int i = ps.executeUpdate();
        if (i > 0) {
    %>
    <div style="text-align:center;margin-top:25%">
        <font color="red">
            <script type="text/javascript">
                function Redirect() {
                    window.location = "pathology.jsp";
                }
                document.write("<h2>Pathology Information Removed Successfully</h2><br><br>");
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