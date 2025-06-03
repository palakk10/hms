<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Add Nurse Validation</title>
</head>
<body>
    <%
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String street = request.getParameter("street");
        String area = request.getParameter("area");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String country = request.getParameter("country");
        String pincode = request.getParameter("pincode");
        String phone = request.getParameter("phone");

        Connection con = (Connection)application.getAttribute("connection");
        PreparedStatement ps = con.prepareStatement("insert into nurse_info(name,email,password,street,area,city,state,country,pincode,phone) values(?,?,?,?,?,?,?,?,?,?)");

        ps.setString(1, name);
        ps.setString(2, email);
        ps.setString(3, password);
        ps.setString(4, street);
        ps.setString(5, area);
        ps.setString(6, city);
        ps.setString(7, state);
        ps.setString(8, country);
        ps.setString(9, pincode);
        ps.setString(10, phone);

        int i = ps.executeUpdate();

        if(i > 0) {
    %>
    <div style="text-align:center;margin-top:30%">
        <font color="green">
            <script type="text/javascript">
                function Redirect() {
                    window.location="nurse.jsp";
                }
                document.write("<h2>Nurse Information Added Successfully</h2><br><br>");
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