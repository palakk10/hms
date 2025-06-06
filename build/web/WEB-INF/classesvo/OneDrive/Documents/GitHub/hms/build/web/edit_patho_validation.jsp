<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Pathology Validation</title>
</head>
<body>
    <%
        String patientid = request.getParameter("patientid");
        String patientname = request.getParameter("patientname");
        String xray = request.getParameter("xray");
        String xrayCount = request.getParameter("xray_count");
        String usound = request.getParameter("usound");
        String usoundCount = request.getParameter("usound_count");
        String bt = request.getParameter("bt");
        String btCount = request.getParameter("bt_count");
        String ctscan = request.getParameter("ctscan");
        String ctCount = request.getParameter("ct_count");
        String charges = request.getParameter("charges");
        String pathologyId = request.getParameter("pathologyId");

        Connection con = (Connection) application.getAttribute("connection");
        PreparedStatement ps = con.prepareStatement("UPDATE pathology SET PNAME=?, X_RAYS=?, xray_count=?, U_SOUND=?, us_count=?, B_TEST=?, bt_count=?, CT_SCAN=?, ct_count=?, CHARGES=? WHERE pathology_id=?");
        ps.setString(1, patientname);
        ps.setString(2, xray);
        ps.setInt(3, Integer.parseInt(xrayCount != null && !xrayCount.isEmpty() ? xrayCount : "0"));
        ps.setString(4, usound);
        ps.setInt(5, Integer.parseInt(usoundCount != null && !usoundCount.isEmpty() ? usoundCount : "0"));
        ps.setString(6, bt);
        ps.setInt(7, Integer.parseInt(btCount != null && !btCount.isEmpty() ? btCount : "0"));
        ps.setString(8, ctscan);
        ps.setInt(9, Integer.parseInt(ctCount != null && !ctCount.isEmpty() ? ctCount : "0"));
        ps.setInt(10, Integer.parseInt(charges != null && !charges.isEmpty() ? charges : "0"));
        ps.setInt(11, Integer.parseInt(pathologyId));

        int i = ps.executeUpdate();
        if (i > 0) {
    %>
    <div style="text-align:center;margin-top:25%">
        <font color="blue">
            <script type="text/javascript">
                function Redirect() {
                    window.location = "pathology.jsp";
                }
                document.write("<h2>Pathology Details Updated Successfully</h2><br><br>");
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