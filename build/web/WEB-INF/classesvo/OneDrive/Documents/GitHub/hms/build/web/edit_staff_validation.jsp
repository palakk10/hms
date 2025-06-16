<%@page import="java.sql.*" %>
<%
    String email = request.getParameter("email");
    String name = request.getParameter("name");
    String gender = request.getParameter("gender");
    String street = request.getParameter("street");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String pincode = request.getParameter("pincode");
    String phone = request.getParameter("phone");
    String desig = request.getParameter("desig");

    Connection con = (Connection)application.getAttribute("connection");
    PreparedStatement ps = con.prepareStatement("UPDATE staffinfo SET name=?, sex=?, street=?, area=?, city=?, pincode=?, phno=? WHERE email=? AND desig=?");
    ps.setString(1, name);
    ps.setString(2, gender);
    ps.setString(3, street);
    ps.setString(4, area);
    ps.setString(5, city);
    ps.setString(6, pincode);
    ps.setString(7, phone);
    ps.setString(8, email);
    ps.setString(9, desig);

    int i = ps.executeUpdate();
    if (i > 0) {
%>
<div style="text-align:center;margin-top:25%">
<font color="blue">
<script type="text/javascript">
function Redirect() {
    window.location="profile.jsp";
}
document.write("<h2><%=desig.toUpperCase()%> Details Updated Successfully</h2><br><Br>");
document.write("<h3>Redirecting you to home page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
    }
    ps.close();
    con.commit();
%>
</script>
</font>
</div>
<%
    }
    ps.close();
    con.commit();
%>