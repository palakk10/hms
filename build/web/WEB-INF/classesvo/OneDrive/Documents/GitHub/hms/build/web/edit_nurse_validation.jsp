<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Nurse Validation</title>
</head>
<body>
    <%
        String id = request.getParameter("nurseId");
        String name = request.getParameter("nurseName");
        String email = request.getParameter("email");
        String street = request.getParameter("street");
        String area = request.getParameter("area");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String country = request.getParameter("country");
        String pincode = request.getParameter("pincode");
        String phone = request.getParameter("phone");

        Connection con = (Connection)application.getAttribute("connection");
        PreparedStatement ps = con.prepareStatement("update nurse_info set name=?,email=?,street=?,area=?,city=?,state=?,country=?,pincode=?,phone=? where id=?");

        ps.setString(1, name);
        ps.setString(2, email);
        ps.setString(3, street);
        ps.setString(4, area);
        ps.setString(5, city);
        ps.setString(6, state);
        ps.setString(7, country);
        ps.setString(8, pincode);
        ps.setString(9, phone);
        ps.setInt(10, Integer.parseInt(id));

        int i = ps.executeUpdate();

        if(i > 0) {
    %>
    <div style="text-align:center;margin-top:25%">
        <font color="blue">
            <script type="text/javascript">
                function Redirect() {
                    window.location="nurse.jsp";
                }
                document.write("<h2>Nurse Details Updated Successfully</h2><br><br>");
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