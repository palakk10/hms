<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="receptionist_menu.jsp"%>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Update Profile</div>
                <div class="panel-body">
                    <%
                        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                        String email = (String) session.getAttribute("email");
                        String sessionName = (String) session.getAttribute("name");
                        if (email == null || sessionName == null) {
                            response.sendRedirect("index.jsp");
                            return;
                        }
                        Connection conn = (Connection) application.getAttribute("connection");
                        String name = request.getParameter("name");
                        String sex = request.getParameter("sex");
                        String street = request.getParameter("street");
                        String area = request.getParameter("area");
                        String city = request.getParameter("city");
                        String state = request.getParameter("state");
                        String country = request.getParameter("country");
                        String pincode = request.getParameter("pincode");
                        String phone = request.getParameter("phone");
                        String errorMessage = "";
                        String successMessage = "";
                        if (conn == null || conn.isClosed()) {
                            errorMessage = "Database connection unavailable.";
                        } else if (name == null || name.trim().isEmpty()) {
                            errorMessage = "Name is required.";
                        } else if (sex == null || !sex.matches("Male|Female|Other")) {
                            errorMessage = "Invalid sex selection.";
                        } else if (phone == null || !phone.matches("\\d{10,15}")) {
                            errorMessage = "Phone number must be 10-15 digits.";
                        } else if (pincode != null && !pincode.isEmpty() && !pincode.matches("\\d{5,10}")) {
                            errorMessage = "Pincode must be 5-10 digits.";
                        } else {
                            PreparedStatement ps = null;
                            try {
                                ps = conn.prepareStatement(
                                    "UPDATE staffinfo SET NAME = ?, SEX = ?, STREET = ?, AREA = ?, CITY = ?, STATE = ?, COUNTRY = ?, PINCODE = ?, PHNO = ? WHERE EMAIL = ?"
                                );
                                ps.setString(1, name);
                                ps.setString(2, sex);
                                ps.setString(3, street != null && !street.trim().isEmpty() ? street : null);
                                ps.setString(4, area != null && !area.trim().isEmpty() ? area : null);
                                ps.setString(5, city != null && !city.trim().isEmpty() ? city : null);
                                ps.setString(6, state != null && !state.trim().isEmpty() ? state : null);
                                ps.setString(7, country != null && !country.trim().isEmpty() ? country : null);
                                ps.setString(8, pincode != null && !pincode.trim().isEmpty() ? pincode : null);
                                ps.setLong(9, Long.parseLong(phone));
                                ps.setString(10, email);
                                int rows = ps.executeUpdate();
                                if (rows > 0) {
                                    successMessage = "Profile updated successfully.";
                                    session.setAttribute("name", name); // Update session name
                                } else {
                                    errorMessage = "Failed to update profile.";
                                }
                            } catch (SQLException e) {
                                errorMessage = "Database Error: " + e.getMessage();
                            } finally {
                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                            }
                        }
                        session.setAttribute("profileMessage", successMessage.isEmpty() ? errorMessage : successMessage);
                        response.sendRedirect("profile_receptionist.jsp");
                    %>
                </div>
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html><%-- 
    Document   : update_profile_receptionist
    Created on : 16 Jun 2025, 7:00:10 am
    Author     : Lenovo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Hello World!</h1>
    </body>
</html>
