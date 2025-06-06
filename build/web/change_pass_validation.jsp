<%@page import="java.sql.*"%>
<%
    String oldEmail = (String)session.getAttribute("email");
    String newEmail = request.getParameter("email");
    String opass1 = request.getParameter("opass");
    String npass = request.getParameter("npass");
    String cpass = request.getParameter("cpass");
%>
<%
    Connection c = (Connection)application.getAttribute("connection");
    // Check if new email already exists (if different from old email)
    boolean emailExists = false;
    if (!oldEmail.equals(newEmail)) {
        PreparedStatement checkPs = c.prepareStatement("SELECT COUNT(*) FROM staffinfo WHERE email=?");
        checkPs.setString(1, newEmail);
        ResultSet rsCheck = checkPs.executeQuery();
        rsCheck.next();
        emailExists = rsCheck.getInt(1) > 0;
        rsCheck.close();
        checkPs.close();
    }

    if (emailExists) {
%>
<div style="text-align:center;margin-top:25%">
<font color="red">
<script type="text/javascript">
function Redirect() {
    history.back();
}
document.write("<h2>Email Already Exists</h2><br><Br>");
document.write("<h3>Redirecting you to back page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
    } else {
        PreparedStatement ps = c.prepareStatement("SELECT password FROM staffinfo WHERE email=?");
        ps.setString(1, oldEmail);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            String opass2 = rs.getString(1);
            if (opass1.equals(opass2)) {
                if (npass.equals(cpass)) {
                    PreparedStatement updatePs = c.prepareStatement("UPDATE staffinfo SET email=?, password=? WHERE email=?");
                    updatePs.setString(1, newEmail);
                    updatePs.setString(2, npass);
                    updatePs.setString(3, oldEmail);
                    int i = updatePs.executeUpdate();
                    if (i > 0) {
                        // Update session email if changed
                        if (!oldEmail.equals(newEmail)) {
                            session.setAttribute("email", newEmail);
                        }
%>
<div style="text-align:center;margin-top:25%">
<font color="blue">
<script type="text/javascript">
function Redirect() {
    window.location="profile.jsp";
}
document.write("<h2>Password and Email Updated Successfully</h2><br><Br>");
document.write("<h3>Redirecting you to home page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
                    }
                    updatePs.close();
                } else {
%>
<div style="text-align:center;margin-top:25%">
<font color="red">
<script type="text/javascript">
function Redirect() {
    history.back();
}
document.write("<h2>New Password And Confirm Password Must Be Same</h2><br><Br>");
document.write("<h3>Redirecting you to back page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
                }
            } else {
%>
<div style="text-align:center;margin-top:25%">
<font color="red">
<script type="text/javascript">
function Redirect() {
    history.back();
}
document.write("<h2>Wrong Current Password</h2><br><Br>");
document.write("<h3>Redirecting you to back page....</h3>");
setTimeout('Redirect()', 3000);
</script>
</font>
</div>
<%
            }
        }
        rs.close();
        ps.close();
    }
%>