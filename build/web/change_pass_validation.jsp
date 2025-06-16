<!DOCTYPE html>
<%@page import="java.sql.*, java.util.*"%>
<html lang="en">
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu.jsp"%>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Change Password Validation</div>
                <div class="panel-body">
                    <%
                        String email = request.getParameter("email");
                        String opass = request.getParameter("opass");
                        String npass = request.getParameter("npass");
                        String cpass = request.getParameter("cpass");

                        String errorMessage = "";
                        if (email == null || !email.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
                            errorMessage = "Invalid email format.";
                        } else if (opass == null || opass.length() < 8) {
                            errorMessage = "Current password is invalid.";
                        } else if (npass == null || npass.length() < 8) {
                            errorMessage = "New password must be at least 8 characters.";
                        } else if (!npass.equals(cpass)) {
                            errorMessage = "New password and confirm password do not match.";
                        }

                        if (!errorMessage.isEmpty()) {
                    %>
                        <div class="alert alert-danger text-center">
                            <h2>Error: <%= errorMessage %></h2>
                            <h3>Redirecting back...</h3>
                            <script type="text/javascript">
                                setTimeout(function() { window.location="profile.jsp"; }, 3000);
                            </script>
                        </div>
                    <%
                        } else {
                            Connection con = null;
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            try {
                                con = (Connection) application.getAttribute("connection");
                                if (con == null) {
                                    throw new SQLException("Database connection not initialized.");
                                }
                                ps = con.prepareStatement("SELECT PASSWORD FROM staffinfo WHERE EMAIL=?");
                                ps.setString(1, email);
                                rs = ps.executeQuery();
                                if (rs.next() && rs.getString("PASSWORD").equals(opass)) {
                                    ps.close();
                                    ps = con.prepareStatement("UPDATE staffinfo SET PASSWORD=? WHERE EMAIL=?");
                                    ps.setString(1, npass); // TODO: Hash password
                                    ps.setString(2, email);
                                    int i = ps.executeUpdate();
                                    if (i > 0) {
                    %>
                                        <div class="alert alert-success text-center">
                                            <h2>Password Updated Successfully</h2>
                                            <h3>Redirecting to profile page...</h3>
                                            <script type="text/javascript">
                                                setTimeout(function() { window.location="profile.jsp"; }, 3000);
                                            </script>
                                        </div>
                    <%
                                    } else {
                                        errorMessage = "Failed to update password.";
                    %>
                                        <div class="alert alert-danger text-center">
                                            <h2><%= errorMessage %></h2>
                                            <h3>Redirecting back...</h3>
                                            <script type="text/javascript">
                                                setTimeout(function() { window.location="profile.jsp"; }, 3000);
                                            </script>
                                        </div>
                    <%
                                    }
                                } else {
                                    errorMessage = "Invalid current password.";
                    %>
                                    <div class="alert alert-danger text-center">
                                        <h2><%= errorMessage %></h2>
                                        <h3>Redirecting back...</h3>
                                        <script type="text/javascript">
                                            setTimeout(function() { window.location="profile.jsp"; }, 3000);
                                        </script>
                                    </div>
                    <%
                                }
                            } catch (SQLException e) {
                                errorMessage = "Database error: " + e.getMessage();
                    %>
                                <div class="alert alert-danger text-center">
                                    <h2><%= errorMessage %></h2>
                                    <h3>Redirecting back...</h3>
                                    <script type="text/javascript">
                                        setTimeout(function() { window.location="profile.jsp"; }, 3000);
                                    </script>
                                </div>
                    <%
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                if (con != null) try { con.commit(); } catch (SQLException e) {}
                            }
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>