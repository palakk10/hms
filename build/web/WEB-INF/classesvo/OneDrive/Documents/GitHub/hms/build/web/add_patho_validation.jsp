<%@page import="java.sql.*" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Pathology Validation</title>
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

        Connection con = (Connection) application.getAttribute("connection");
        PreparedStatement ps = con.prepareStatement("INSERT INTO pathology (X_RAYS, xray_count, U_SOUND, us_count, B_TEST, bt_count, CT_SCAN, ct_count, PNAME, ID, CHARGES) VALUES (?,?,?,?,?,?,?,?,?,?,?)");
        ps.setString(1, xray);
        ps.setInt(2, Integer.parseInt(xrayCount != null && !xrayCount.isEmpty() ? xrayCount : "0"));
        ps.setString(3, usound);
        ps.setInt(4, Integer.parseInt(usoundCount != null && !usoundCount.isEmpty() ? usoundCount : "0"));
        ps.setString(5, bt);
        ps.setInt(6, Integer.parseInt(btCount != null && !btCount.isEmpty() ? btCount : "0"));
        ps.setString(7, ctscan);
        ps.setInt(8, Integer.parseInt(ctCount != null && !ctCount.isEmpty() ? ctCount : "0"));
        ps.setString(9, patientname);
        ps.setInt(10, Integer.parseInt(patientid));
        ps.setInt(11, Integer.parseInt(charges != null && !charges.isEmpty() ? charges : "0"));

        int i = ps.executeUpdate();
        if (i > 0) {
    %>
    <div style="text-align:center;margin-top:25%">
        <font color="green">
            <script type="text/javascript">
                function Redirect() {
                    window.location = "pathology.jsp";
                }
                document.write("<h2>Pathology Information Added Successfully</h2><br><br>");
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