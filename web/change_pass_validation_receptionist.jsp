<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="receptionist_menu.jsp"%>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Change Password</div>
                <div class="panel-body">
                    <%
                        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                        String email = (String) session.getAttribute("email");
                        String name = (String) session.getAttribute("name");
                        if (email == null || name == null) {
                            response.sendRedirect("index.jsp");
                            return;
                        }
                        Connection conn = (Connection) application.getAttribute("connection");
                        String currentPass = request.getParameter("opass");
                        String newPass = request.getParameter("npass");
                        String confirmPass = request.getParameter("cpass");
                        String errorMessage = "";
                        String successMessage = "";
                        if (conn == null || conn.isClosed()) {
                            errorMessage = "Database connection unavailable.";
                        } else if (currentPass == null || currentPass.trim().isEmpty()) {
                            errorMessage = "Current password is required.";
                        } else if (newPass == null || newPass.length() < 8) {
                            errorMessage = "New password must be at least 8 characters.";
                        } else if (!newPass.equals(confirmPass)) {
                            errorMessage = "New password and confirm password do not match.";
                        } else {
                            PreparedStatement ps = null;
                            ResultSet rs = null;
                            try {
                                ps = conn.prepareStatement("SELECT PASSWORD FROM staffinfo WHERE EMAIL = ?");
                                ps.setString(1, email);
                                rs = ps.executeQuery();
                                if (rs.next()) {
                                    String storedPass = rs.getString("PASSWORD");
                                    if (!currentPass.equals(storedPass)) {
                                        errorMessage = "Current password is incorrect.";
                                    } else {
                                        ps.close();
                                        ps = conn.prepareStatement("UPDATE staffinfo SET PASSWORD = ? WHERE EMAIL = ?");
                                        ps.setString(1, newPass);
                                        ps.setString(2, email);
                                        int rows = ps.executeUpdate();
                                        if (rows > 0) {
                                            successMessage = "Password updated successfully.";
                                        } else {
                                            errorMessage = "Failed to update password.";
                                        }
                                    }
                                } else {
                                    errorMessage = "Profile not found.";
                                }
                            } catch (SQLException e) {
                                errorMessage = "Database Error: " + e.getMessage();
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                            }
                        }
                        session.setAttribute("passwordMessage", successMessage.isEmpty() ? errorMessage : successMessage);
                        response.sendRedirect("profile_receptionist.jsp");
                    %>
                </div>
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>