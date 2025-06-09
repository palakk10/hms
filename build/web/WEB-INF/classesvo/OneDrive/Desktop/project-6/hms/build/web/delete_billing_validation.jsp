<%@ page import="java.sql.*" %>
<%
    String billNo = request.getParameter("billNo");
    Connection con = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    try {
        ps = con.prepareStatement("DELETE FROM billing WHERE bill_no=?");
        ps.setString(1, billNo);
        int i = ps.executeUpdate();
        if (i > 0) {
%>
<div style="text-align:center;margin-top:25%">
    <font color="red">
        <script type="text/javascript">
            function Redirect() {
                window.location = "billing.jsp";
            }
            document.write("<h2>Billing Information Removed Successfully</h2><br><br>");
            document.write("<h3>Redirecting you to home page....</h3>");
            setTimeout('Redirect()', 3000);
        </script>
    </font>
</div>
<%
        } else {
            out.println("<div class='alert alert-danger'>Failed to delete billing information.</div>");
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Database error: " + e.getMessage() + "</div>");
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        con.commit();
    }
%>