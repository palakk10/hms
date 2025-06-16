<%@page import="java.sql.*, javax.servlet.http.HttpSession"%>
<!DOCTYPE html>
<html lang="en">
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    String email = (String) session.getAttribute("email");
    String name = (String) session.getAttribute("name");
    if (email == null || name == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<%@include file="header.jsp"%>
<body>
    <nav class="navbar navbar-custom navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbarCollapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="#">Hospital Management System</a>
            </div>
            <div class="collapse navbar-collapse" id="navbarCollapse">
                <ul class="nav navbar-nav navbar-right">
                    <li class="dropdown">
                        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button"><%=name.toUpperCase()%> <span class="caret"></span></a>
                        <ul class="dropdown-menu">
                            <li><a href="profile_receptionist.jsp">Change Profile</a></li>
                            <li role="separator" class="divider"></li>
                            <li><a href="logout.jsp">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    <div class="container-fluid">
        <div class="row">
            <%@include file="receptionist_menu.jsp"%>
            <div class="col-md-10 maincontent">
                <div class="panel panel-default contentinside">
                    <div class="panel-heading">Receptionist Profile</div>
                    <div class="panel-body">
                        <%
                            String profileMessage = (String) session.getAttribute("profileMessage");
                            if (profileMessage != null) {
                                String alertClass = profileMessage.contains("successfully") ? "alert-success" : "alert-danger";
                        %>
                        <div class="alert <%=alertClass%> alert-dismissible">
                            <button type="button" class="close" data-dismiss="alert">×</button>
                            <%=profileMessage%>
                        </div>
                        <%
                                session.removeAttribute("profileMessage");
                            }
                            String passwordMessage = (String) session.getAttribute("passwordMessage");
                            if (passwordMessage != null) {
                                String alertClass = passwordMessage.contains("successfully") ? "alert-success" : "alert-danger";
                        %>
                        <div class="alert <%=alertClass%> alert-dismissible">
                            <button type="button" class="close" data-dismiss="alert">×</button>
                            <%=passwordMessage%>
                        </div>
                        <%
                                session.removeAttribute("passwordMessage");
                            }
                        %>
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
                                            Connection conn = (Connection) application.getAttribute("connection");
                                            PreparedStatement ps = null;
                                            ResultSet rs = null;
                                            try {
                                                ps = conn.prepareStatement("SELECT * FROM staffinfo WHERE EMAIL = ?");
                                                ps.setString(1, email);
                                                rs = ps.executeQuery();
                                                if (rs.next()) {
                                        %>
                                        <form class="form-horizontal" action="update_profile_receptionist.jsp" method="post" id="profileForm">
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Email</label>
                                                <div class="col-sm-9">
                                                    <input type="email" name="email" class="form-control" value="<%=rs.getString("EMAIL")%>" readonly>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Name</label>
                                                <div class="col-sm-9">
                                                    <input type="text" name="name" class="form-control" value="<%=rs.getString("NAME") != null ? rs.getString("NAME") : ""%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Sex</label>
                                                <div class="col-sm-9">
                                                    <select name="sex" class="form-control" required>
                                                        <option value="Male" <%= "Male".equals(rs.getString("SEX")) ? "selected" : "" %>>Male</option>
                                                        <option value="Female" <%= "Female".equals(rs.getString("SEX")) ? "selected" : "" %>>Female</option>
                                                        <option value="Other" <%= "Other".equals(rs.getString("SEX")) ? "selected" : "" %>>Other</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Street</label>
                                                <div class="col-sm-9">
                                                    <input type="text" name="street" class="form-control" value="<%=rs.getString("STREET") != null ? rs.getString("STREET") : ""%>">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Area</label>
                                                <div class="col-sm-9">
                                                    <input type="text" name="area" class="form-control" value="<%=rs.getString("AREA") != null ? rs.getString("AREA") : ""%>">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">City</label>
                                                <div class="col-sm-9">
                                                    <input type="text" name="city" class="form-control" value="<%=rs.getString("CITY") != null ? rs.getString("CITY") : ""%>">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">State</label>
                                                <div class="col-sm-9">
                                                    <input type="text" name="state" class="form-control" value="<%=rs.getString("STATE") != null ? rs.getString("STATE") : ""%>">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Country</label>
                                                <div class="col-sm-9">
                                                    <input type="text" name="country" class="form-control" value="<%=rs.getString("COUNTRY") != null ? rs.getString("COUNTRY") : ""%>">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Pincode</label>
                                                <div class="col-sm-9">
                                                    <input type="text" name="pincode" class="form-control" value="<%=rs.getString("PINCODE") != null ? rs.getString("PINCODE") : ""%>" pattern="\d{5,10}?">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Phone</label>
                                                <div class="col-sm-9">
                                                    <input type="text" name="phone" class="form-control" value="<%=rs.getLong("PHNO") != 0 ? rs.getLong("PHNO") : ""%>" pattern="\d{10,15}" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Designation</label>
                                                <div class="col-sm-9">
                                                    <input type="text" name="desig" class="form-control" value="<%=rs.getString("DESIG") != null ? rs.getString("DESIG") : ""%>" readonly>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <div class="col-sm-offset-3 col-sm-9">
                                                    <button type="submit" class="btn btn-primary">Update Profile</button>
                                                </div>
                                            </div>
                                        </form>
                                        <%
                                                } else {
                                                    out.println("<div class='alert alert-danger'>Profile not found.</div>");
                                                }
                                            } catch (SQLException e) {
                                                out.println("<div class='alert alert-danger'>Error loading profile: " + e.getMessage() + "</div>");
                                            } finally {
                                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </div>
                                </div>
                            </div>
                            <!-- Password Tab -->
                            <div id="password" class="tab-pane fade">
                                <div class="panel panel-default" style="margin-top: 15px;">
                                    <div class="panel-body">
                                        <form class="form-horizontal" action="change_pass_validation_receptionist.jsp" method="post" id="passwordForm">
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Email</label>
                                                <div class="col-sm-9">
                                                    <input type="email" name="email" class="form-control" value="<%=email%>" readonly>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Current Password</label>
                                                <div class="col-sm-9">
                                                    <input type="password" name="opass" class="form-control" placeholder="Current Password" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">New Password</label>
                                                <div class="col-sm-9">
                                                    <input type="password" name="npass" class="form-control" placeholder="New Password (min 8 characters)" minlength="8" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-3 control-label">Confirm New Password</label>
                                                <div class="col-sm-9">
                                                    <input type="password" name="cpass" class="form-control" placeholder="Confirm New Password" minlength="8" required>
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
                </div>
            </div>
        </div>
    </div>
    <script>
        $(document).ready(function() {
            // Auto-dismiss alerts after 5 seconds
            setTimeout(function() {
                $('.alert').fadeOut('slow', function() {
                    $(this).remove();
                });
            }, 5000);

            // Validate Profile Form
            $('#profileForm').submit(function(e) {
                var name = $('input[name="name"]').val().trim();
                var phone = $('input[name="phone"]').val().trim();
                var pincode = $('input[name="pincode"]').val().trim();
                var phoneRegex = /^\d{10,15}$/;
                var pincodeRegex = /^\d{5,10}?$/;

                if (!name) {
                    alert('Please enter a name.');
                    e.preventDefault();
                    return false;
                }

                if (!phoneRegex.test(phone)) {
                    alert('Please enter a valid phone number (10-15 digits).');
                    e.preventDefault();
                    return false;
                }

                if (pincode && !pincodeRegex.test(pincode)) {
                    alert('Please enter a valid pincode (5-10 digits).');
                    e.preventDefault();
                    return false;
                }

                return true;
            });

            // Validate Password Form
            $('#passwordForm').submit(function(e) {
                var newPass = $('input[name="npass"]').val();
                var confirmPass = $('input[name="cpass"]').val();

                if (newPass !== confirmPass) {
                    alert('New password and confirm password do not match.');
                    e.preventDefault();
                    return false;
                }

                if (newPass.length < 8) {
                    alert('New password must be at least 8 characters long.');
                    e.preventDefault();
                    return false;
                }

                return true;
            });
        });
    </script>
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>