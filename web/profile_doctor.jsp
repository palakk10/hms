<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
    <%@include file="header_doctor.jsp"%>
    <body>
        <div class="row">
            <%@include file="menu_doctor.jsp"%>
            
            <!---- Content Area Start  -------->
            <div class="col-md-10 maincontent">
                <!----------------   Menu Tab   --------------->
                <div class="panel panel-default contentinside">
                    <div class="panel-heading">Doctor Profile</div>
                    <!----------------   Panel body Start   --------------->
                    <div class="panel-body">
                        <ul class="nav nav-tabs">
                            <li class="active"><a href="#profile" data-toggle="tab">Profile</a></li>
                            <li><a href="#password" data-toggle="tab">Change Password</a></li>
                        </ul>
                        
                        <div class="tab-content">
                            <!-- Profile Tab -->
                            <div id="profile" class="tab-pane fade in active">
                                <div class="panel panel-default" style="margin-top: 15px;">
                                    <div class="panel-body">
                                        <%
                                            Connection c = (Connection)application.getAttribute("connection");
                                            int doctorId = Integer.parseInt((String)session.getAttribute("id"));
                                            PreparedStatement ps = c.prepareStatement(
                                                "SELECT d.*, dept.NAME as dept_name FROM doctor_info d " +
                                                "JOIN department dept ON d.DEPT_ID = dept.ID WHERE d.ID = ?");
                                            ps.setInt(1, doctorId);
                                            ResultSet rs = ps.executeQuery();
                                            
                                            if(rs.next()) {
                                        %>
                                        <table class="table table-bordered">
                                            <tr>
                                                <th>Doctor ID</th>
                                                <td><%=rs.getInt("ID")%></td>
                                            </tr>
                                            <tr>
                                                <th>Name</th>
                                                <td><%=rs.getString("NAME")%></td>
                                            </tr>
                                            <tr>
                                                <th>Email</th>
                                                <td><%=rs.getString("EMAIL")%></td>
                                            </tr>
                                            <tr>
                                                <th>Department</th>
                                                <td><%=rs.getString("dept_name")%></td>
                                            </tr>
                                            <tr>
                                                <th>Phone</th>
                                                <td><%=rs.getString("PHONE")%></td>
                                            </tr>
                                            <tr>
                                                <th>Gender</th>
                                                <td><%=rs.getString("GENDER")%></td>
                                            </tr>
                                            <tr>
                                                <th>Age</th>
                                                <td><%=rs.getInt("AGE")%></td>
                                            </tr>
                                            <tr>
                                                <th>Address</th>
                                                <td>
                                                    <%=rs.getString("STREET")%>, 
                                                    <%=rs.getString("AREA") != null ? rs.getString("AREA") + ", " : ""%>
                                                    <%=rs.getString("CITY")%>, 
                                                    <%=rs.getString("STATE")%>, 
                                                    <%=rs.getString("COUNTRY")%> - 
                                                    <%=rs.getString("PINCODE")%>
                                                </td>
                                            </tr>
                                        </table>
                                        <%
                                            }
                                            rs.close();
                                            ps.close();
                                        %>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Password Tab -->
                            <div id="password" class="tab-pane fade">
                                <div class="panel panel-default" style="margin-top: 15px;">
                                    <div class="panel-body">
                                        <form class="form-horizontal" action="change_pass_validation_doctor.jsp" method="post">
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Current Password</label>
                                                <div class="col-sm-9">
                                                    <input type="password" class="form-control" name="opass" placeholder="Current Password" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">New Password</label>
                                                <div class="col-sm-9">
                                                    <input type="password" class="form-control" name="npass" placeholder="New Password (min 8 characters)" minlength="8" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Confirm Password</label>
                                                <div class="col-sm-9">
                                                    <input type="password" class="form-control" name="cpass" placeholder="Confirm New Password" minlength="8" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div class="col-sm-offset-3 col-sm-9">
                                                    <button type="submit" class="btn btn-primary">Update Password</button>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!----------------   Panel body Ends   --------------->
                </div>
            </div>
        </div>
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>
    </body>
</html>