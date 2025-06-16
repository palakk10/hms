<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu.jsp"%>
        <!---- Content Area Start  -------->
        <div class="col-md-10 maincontent">
            <!----------------   Update Profile Panel   --------------->
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Update Profile</div>
                <!----------------   Panel body Start   --------------->
                <%
                    String email = (String) session.getAttribute("email");
                    String desig = (String) session.getAttribute("role"); // Renamed from 'role' to avoid duplication
                    String errorMessage = "";
                    String name = "", sex = "", street = "", area = "", city = "", state = "", country = "", pincode = "", phone = "";

                    if (email == null || desig == null) {
                        errorMessage = "Please log in to view this page.";
                    } else {
                        Connection con = null;
                        PreparedStatement ps = null;
                        ResultSet rs = null;
                        try {
                            con = (Connection) application.getAttribute("connection");
                            if (con == null) {
                                throw new SQLException("Database connection not initialized.");
                            }
                            ps = con.prepareStatement("SELECT NAME, SEX, STREET, AREA, CITY, STATE, COUNTRY, PINCODE, PHNO, DESIG FROM staffinfo WHERE EMAIL=?");
                            ps.setString(1, email);
                            rs = ps.executeQuery();
                            if (rs.next()) {
                                name = rs.getString("NAME") != null ? rs.getString("NAME") : "";
                                sex = rs.getString("SEX") != null ? rs.getString("SEX") : "";
                                street = rs.getString("STREET") != null ? rs.getString("STREET") : "";
                                area = rs.getString("AREA") != null ? rs.getString("AREA") : "";
                                city = rs.getString("CITY") != null ? rs.getString("CITY") : "";
                                state = rs.getString("STATE") != null ? rs.getString("STATE") : "";
                                country = rs.getString("COUNTRY") != null ? rs.getString("COUNTRY") : "";
                                pincode = rs.getString("PINCODE") != null ? rs.getString("PINCODE") : "";
                                phone = rs.getString("PHNO") != null ? rs.getString("PHNO") : "";
                                desig = rs.getString("DESIG") != null ? rs.getString("DESIG") : desig;
                            } else {
                                errorMessage = "Staff details not found.";
                            }
                        } catch (SQLException e) {
                            errorMessage = "Database error: " + e.getMessage();
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) {}
                            if (ps != null) try { ps.close(); } catch (SQLException e) {}
                        }
                    }
                %>
                <div class="panel-body">
                    <% if (!errorMessage.isEmpty()) { %>
                        <div class="alert alert-danger"><%= errorMessage %></div>
                    <% } else { %>
                    <form class="form-horizontal" action="edit_staff_validation.jsp" method="post">
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Email</label>
                            <div class="col-sm-10">
                                <input type="email" class="form-control" name="email" value="<%= email %>" readonly>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Name</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="name" value="<%= name %>" placeholder="Name" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Sex</label>
                            <div class="col-sm-10">
                                <select name="sex" class="form-control" required>
                                    <option value="Male" <%= "Male".equals(sex) ? "selected" : "" %>>Male</option>
                                    <option value="Female" <%= "Female".equals(sex) ? "selected" : "" %>>Female</option>
                                    <option value="Other" <%= "Other".equals(sex) ? "selected" : "" %>>Other</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Street</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="street" value="<%= street %>" placeholder="Street">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Area</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="area" value="<%= area %>" placeholder="Area">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">City</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="city" value="<%= city %>" placeholder="City">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">State</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="state" value="<%= state %>" placeholder="State">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Country</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="country" value="<%= country %>" placeholder="Country">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Pincode</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="pincode" value="<%= pincode %>" placeholder="Pincode">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Phone</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="phone" value="<%= phone %>" placeholder="Phone No." pattern="\d{10}" title="10-digit phone number" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Designation</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="desig" value="<%= desig %>" readonly>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-sm-offset-2 col-sm-10">
                                <button type="submit" class="btn btn-primary">Update Profile</button>
                            </div>
                        </div>
                    </form>
                    <% } %>
                </div>
                <!----------------   Panel body Ends   --------------->
            </div>
            <!----------------   Change Password Panel   --------------->
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Change Password</div>
                <div class="panel-body">
                    <form class="form-horizontal" action="change_pass_validation.jsp" method="post">
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Email</label>
                            <div class="col-sm-10">
                                <input type="email" class="form-control" name="email" value="<%= email != null ? email : "" %>" readonly>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Current Password</label>
                            <div class="col-sm-10">
                                <input type="password" class="form-control" name="opass" placeholder="Current Password" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">New Password</label>
                            <div class="col-sm-10">
                                <input type="password" class="form-control" name="npass" placeholder="Enter New Password" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Confirm New Password</label>
                            <div class="col-sm-10">
                                <input type="password" class="form-control" name="cpass" placeholder="Confirm New Password" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-sm-offset-2 col-sm-10">
                                <button type="submit" class="btn btn-primary">Update Password</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>