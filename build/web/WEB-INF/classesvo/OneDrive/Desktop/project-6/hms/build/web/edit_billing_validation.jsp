<%@ page import="java.sql.*" %>
<%
    String billNo = request.getParameter("billNo");
    String id = request.getParameter("patientid");
    String name = request.getParameter("patientname");
    String otherCharge = request.getParameter("otherCharge");
    String pathoCharge = request.getParameter("pathoCharge");
    String entryDate = request.getParameter("entryDate");
    String disDate = request.getParameter("disDate");

    Connection con = (Connection) application.getAttribute("connection");
    PreparedStatement ps = null;
    try {
        ps = con.prepareStatement("UPDATE billing SET id_no=?, pname=?, ot_charge=?, pathology=?, ent_date=?, dis_date=? WHERE bill_no=?");
        ps.setInt(1, Integer.parseInt(id));
        ps.setString(2, name);
        ps.setDouble(3, Double.parseDouble(otherCharge));
        ps.setDouble(4, Double.parseDouble(pathoCharge));
        ps.setString(5, entryDate);
        ps.setString(6, disDate);
        ps.setInt(7, Integer.parseInt(billNo));

        int i = ps.executeUpdate();
        if (i > 0) {
%>
<div style="text-align:center;margin-top:25%">
    <font color="blue">
        <script type="text/javascript">
            function Redirect() {
                window.location = "billing.jsp";
            }
            document.write("<h2>Billing Details Updated Successfully</h2><br><br>");
            document.write("<h3>Redirecting you to home page....</h3>");
            setTimeout('Redirect()', 3000);
        </script>
    </font>
</div>
<%
        } else {
            out.println("<div class='alert alert-danger'>Failed to update billing information.</div>");
        }
    } catch (SQLException e) {
        out.println("<div class='alert alert-danger'>Database error: " + e.getMessage() + "</div>");
    } catch (NumberFormatException e) {
        out.println("<div class='alert alert-danger'>Invalid input format.</div>");
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        con.commit();
    }
%>