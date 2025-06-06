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
                    String email = (String)session.getAttribute("email");
                    String role = (String)session.getAttribute("role");
                    Connection c = (Connection)application.getAttribute("connection");
                    PreparedStatement ps = c.prepareStatement("SELECT name, sex, street, area, city, pincode, phno, desig FROM staffinfo WHERE email=? AND desig=?", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                    ps.setString(1, email);
                    ps.setString(2, role);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        String name = rs.getString("name");
                        String gender = rs.getString("sex");
                        String street = rs.getString("street");
                        String area = rs.getString("area");
                        String city = rs.getString("city");
                        String pincode = rs.getString("pincode");
                        String phone = rs.getString("phno");
                        String desig = rs.getString("desig");
                %>
                <div class="panel-body">
                    <form class="form-horizontal" action="edit_staff_validation.jsp">
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Email</label>
                            <div class="col-sm-10">
                                <input type="email" class="form-control" name="email" value="<%=email%>" placeholder="Email">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Name</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="name" value="<%=name%>" placeholder="Name">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Gender</label>
                            <div class="col-sm-10">
                                <select name="gender" class="form-control">
                                    <option selected><%=gender%></option>
                                    <option>Male</option>
                                    <option>Female</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Street</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="street" value="<%=street%>" placeholder="Street">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Area</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="area" value="<%=area%>" placeholder="Area">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">City</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="city" value="<%=city%>" placeholder="City">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Pincode</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="pincode" value="<%=pincode%>" placeholder="Pincode">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Phone</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="phone" value="<%=phone%>" placeholder="Phone No.">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Designation</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="desig" value="<%=desig%>" placeholder="Designation" readonly>
                            </div>
                        </div>
                        <div class="form-group">
                            <div class="col-sm-offset-2 col-sm-10">
                                <button type="submit" class="btn btn-primary">Update Profile</button>
                            </div>
                        </div>
                    </form>
                </div>
                <%
                    }
                    rs.close();
                    ps.close();
                %>
                <!----------------   Panel body Ends   --------------->
            </div>
            <!----------------   Change Password Panel   --------------->
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Change Password</div>
                <div class="panel-body">
                    <form class="form-horizontal" action="change_pass_validation.jsp">
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Email</label>
                            <div class="col-sm-10">
                                <input type="email" class="form-control" name="email" value="<%=email%>" placeholder="Email">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Password</label>
                            <div class="col-sm-10">
                                <input type="password" class="form-control" name="opass" placeholder="Current Password">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">New Password</label>
                            <div class="col-sm-10">
                                <input type="password" class="form-control" name="npass" placeholder="Enter New Password">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Confirm New Password</label>
                            <div class="col-sm-10">
                                <input type="password" class="form-control" name="cpass" placeholder="Confirm New Password">
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