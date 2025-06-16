<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manage Doctor</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script>
        function confirmDelete() {
            return confirm("Do you really want to delete this doctor?");
        }

        function validateForm(form) {
            var pincode = form.pincode.value.trim();
            var phone = form.phone.value.trim();
            var pwd = form.pwd ? form.pwd.value.trim() : "";
            var email = form.email.value.trim();
            var age = form.age.value.trim();
            if (!pincode.match(/^\d{6}$/)) {
                alert("Pincode must be exactly 6 digits.");
                return false;
            }
            if (!phone.match(/^\d{10}$/)) {
                alert("Phone must be exactly 10 digits.");
                return false;
            }
            if (pwd && pwd.length < 8) {
                alert("Password must be at least 8 characters.");
                return false;
            }
            if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
                alert("Please enter a valid email address.");
                return false;
            }
            if (!age.match(/^\d{1,3}$/) || age < 0 || age > 150) {
                alert("Age must be a number between 0 and 150.");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <%@include file="header.jsp"%>
    <div class="row">
        <%@include file="menu.jsp"%>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Manage Doctor</div>
                <div class="panel-body">
                    <ul class="nav nav-tabs doctor">
                        <li class="active"><a href="#doctorlist" data-toggle="tab">Doctor List</a></li>
                        <li><a href="#adddoctor" data-toggle="tab">Add Doctor</a></li>
                    </ul>
                    <div class="tab-content">
                        <div id="doctorlist" class="tab-pane fade in active">
                            <table class="table table-bordered table-hover">
                                <tr class="active">
                                    <td>Doctor ID</td>
                                    <td>Name</td>
                                    <td>Email</td>
                                    <td>Street</td>
                                    <td>Area</td>
                                    <td>City</td>
                                    <td>State</td>
                                    <td>Pincode</td>
                                    <td>Phone</td>
                                    <td>Department</td>
                                    <td>Gender</td>
                                    <td>Age</td>
                                    <td>Degree</td>
                                    <td>Years of Experience</td>
                                    <td>Skills</td>
                                    <td>Options</td>
                                </tr>
                                <%
                                    Connection c = (Connection) application.getAttribute("connection");
                                    PreparedStatement ps = null;
                                    ResultSet rs = null;
                                    boolean hasYearsOfExperience = true;
                                    try {
                                        ps = c.prepareStatement(
                                            "SELECT di.ID, di.NAME, di.EMAIL, di.STREET, di.AREA, di.CITY, di.STATE, di.PINCODE, di.PHONE, d.NAME AS DEPT_NAME, di.GENDER, di.AGE, di.DEGREE, di.YEARS_OF_EXPERIENCE, di.SKILL " +
                                            "FROM doctor_info di JOIN department d ON di.DEPT_ID = d.ID",
                                            ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                                        );
                                        rs = ps.executeQuery();
                                        if (!rs.isBeforeFirst()) {
                                            out.println("<tr><td colspan='16'>No doctors found in the database.</td></tr>");
                                        } else {
                                            while (rs.next()) {
                                %>
                                <tr>
                                    <td><%=rs.getInt("ID")%></td>
                                    <td><%=rs.getString("NAME") != null ? rs.getString("NAME") : "-"%></td>
                                    <td><%=rs.getString("EMAIL") != null ? rs.getString("EMAIL") : "-"%></td>
                                    <td><%=rs.getString("STREET") != null ? rs.getString("STREET") : "-"%></td>
                                    <td><%=rs.getString("AREA") != null ? rs.getString("AREA") : "-"%></td>
                                    <td><%=rs.getString("CITY") != null ? rs.getString("CITY") : "-"%></td>
                                    <td><%=rs.getString("STATE") != null ? rs.getString("STATE") : "-"%></td>
                                    <td><%=rs.getString("PINCODE") != null ? rs.getString("PINCODE") : "-"%></td>
                                    <td><%=rs.getString("PHONE") != null ? rs.getString("PHONE") : "-"%></td>
                                    <td><%=rs.getString("DEPT_NAME") != null ? rs.getString("DEPT_NAME") : "-"%></td>
                                    <td><%=rs.getString("GENDER") != null ? rs.getString("GENDER") : "-"%></td>
                                    <td><%=rs.getInt("AGE")%></td>
                                    <td><%=rs.getString("DEGREE") != null ? rs.getString("DEGREE") : "-"%></td>
                                    <td><%=rs.getObject("YEARS_OF_EXPERIENCE") != null ? rs.getInt("YEARS_OF_EXPERIENCE") : "-"%></td>
                                    <td><%=rs.getString("SKILL") != null ? rs.getString("SKILL") : "-"%></td>
                                    <td>
                                        <a href="#myModal<%=rs.getInt("ID")%>" data-toggle="modal" class="btn btn-primary"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></a>
                                        <a href="delete_doct_validation.jsp?doctId=<%=rs.getInt("ID")%>" onclick="return confirmDelete()" class="btn btn-danger"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
                                    </td>
                                </tr>
                                <%
                                            }
                                            rs.beforeFirst(); // Reset cursor for modal generation
                                        }
                                    } catch (SQLException e) {
                                        if (e.getMessage().contains("YEARS_OF_EXPERIENCE")) {
                                            hasYearsOfExperience = false;
                                            // Retry query without YEARS_OF_EXPERIENCE
                                            if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                                            if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
                                            ps = c.prepareStatement(
                                                "SELECT di.ID, di.NAME, di.EMAIL, di.STREET, di.AREA, di.CITY, di.STATE, di.PINCODE, di.PHONE, d.NAME AS DEPT_NAME, di.GENDER, di.AGE, di.DEGREE, di.SKILL " +
                                                "FROM doctor_info di JOIN department d ON di.DEPT_ID = d.ID",
                                                ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                                            );
                                            rs = ps.executeQuery();
                                            while (rs.next()) {
                                %>
                                <tr>
                                    <td><%=rs.getInt("ID")%></td>
                                    <td><%=rs.getString("NAME") != null ? rs.getString("NAME") : "-"%></td>
                                    <td><%=rs.getString("EMAIL") != null ? rs.getString("EMAIL") : "-"%></td>
                                    <td><%=rs.getString("STREET") != null ? rs.getString("STREET") : "-"%></td>
                                    <td><%=rs.getString("AREA") != null ? rs.getString("AREA") : "-"%></td>
                                    <td><%=rs.getString("CITY") != null ? rs.getString("CITY") : "-"%></td>
                                    <td><%=rs.getString("STATE") != null ? rs.getString("STATE") : "-"%></td>
                                    <td><%=rs.getString("PINCODE") != null ? rs.getString("PINCODE") : "-"%></td>
                                    <td><%=rs.getString("PHONE") != null ? rs.getString("PHONE") : "-"%></td>
                                    <td><%=rs.getString("DEPT_NAME") != null ? rs.getString("DEPT_NAME") : "-"%></td>
                                    <td><%=rs.getString("GENDER") != null ? rs.getString("GENDER") : "-"%></td>
                                    <td><%=rs.getInt("AGE")%></td>
                                    <td><%=rs.getString("DEGREE") != null ? rs.getString("DEGREE") : "-"%></td>
                                    <td>-</td>
                                    <td><%=rs.getString("SKILL") != null ? rs.getString("SKILL") : "-"%></td>
                                    <td>
                                        <a href="#myModal<%=rs.getInt("ID")%>" data-toggle="modal" class="btn btn-primary"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></a>
                                        <a href="delete_doct_validation.jsp?doctId=<%=rs.getInt("ID")%>" onclick="return confirmDelete()" class="btn btn-danger"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
                                    </td>
                                </tr>
                                <%
                                            }
                                            rs.beforeFirst();
                                        } else {
                                            out.println("<div class='alert alert-danger'>Error loading doctor list: " + e.getMessage() + "</div>");
                                        }
                                    }
                                %>
                            </table>
                        </div>
                        <%
                            try {
                                while (rs.next()) {
                                    int id = rs.getInt("ID");
                                    String name = rs.getString("NAME");
                                    String email = rs.getString("EMAIL");
                                    String street = rs.getString("STREET");
                                    String area = rs.getString("AREA");
                                    String city = rs.getString("CITY");
                                    String state = rs.getString("STATE");
                                    String pincode = rs.getString("PINCODE");
                                    String phone = rs.getString("PHONE");
                                    String dept = rs.getString("DEPT_NAME");
                                    String gender = rs.getString("GENDER");
                                    int age = rs.getInt("AGE");
                                    String degree = rs.getString("DEGREE");
                                    String yearsOfExperience = hasYearsOfExperience ? (rs.getObject("YEARS_OF_EXPERIENCE") != null ? rs.getString("YEARS_OF_EXPERIENCE") : "") : "";
                                    String skill = rs.getString("SKILL");
                        %>
                        <div class="modal fade" id="myModal<%=id%>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                        <h4 class="modal-title" id="myModalLabel">Edit Doctor Information</h4>
                                    </div>
                                    <div class="modal-body">
                                        <form class="form-horizontal" action="edit_doct_validation.jsp" method="post" onsubmit="return validateForm(this)">
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Doctor ID</label>
                                                <div class="col-sm-10">
                                                    <input type="number" class="form-control" name="doctid" value="<%=id%>" readonly>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Name</label>
                                                <div class="col-sm-10">
                                                    <input type="text" class="form-control" name="doctname" value="<%=name != null ? name : ""%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Email</label>
                                                <div class="col-sm-10">
                                                    <input type="email" class="form-control" name="email" value="<%=email != null ? email : ""%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Password</label>
                                                <div class="col-sm-10">
                                                    <input type="password" class="form-control" name="pwd" placeholder="Enter new password (leave blank to keep unchanged)">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Street</label>
                                                <div class="col-sm-10">
                                                    <input type="text" class="form-control" name="street" value="<%=street != null ? street : ""%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Area</label>
                                                <div class="col-sm-10">
                                                    <input type="text" class="form-control" name="area" value="<%=area != null ? area : ""%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">City</label>
                                                <div class="col-sm-10">
                                                    <input type="text" class="form-control" name="city" value="<%=city != null ? city : ""%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">State</label>
                                                <div class="col-sm-10">
                                                    <input type="text" class="form-control" name="state" value="<%=state != null ? state : ""%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Pincode</label>
                                                <div class="col-sm-10">
                                                    <input type="text" class="form-control" name="pincode" value="<%=pincode != null ? pincode : ""%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Phone</label>
                                                <div class="col-sm-10">
                                                    <input type="text" class="form-control" name="phone" value="<%=phone != null ? phone : ""%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Department</label>
                                                <div class="col-sm-10">
                                                    <select class="form-control" name="dept" required>
                                                        <option value="<%=dept%>" selected><%=dept%></option>
                                                        <%
                                                            PreparedStatement deptPs = c.prepareStatement("SELECT NAME FROM department");
                                                            ResultSet deptRs = deptPs.executeQuery();
                                                            while (deptRs.next()) {
                                                                String deptOption = deptRs.getString("NAME");
                                                                if (!deptOption.equals(dept)) {
                                                                    out.println("<option value=\"" + deptOption + "\">" + deptOption + "</option>");
                                                                }
                                                            }
                                                            deptRs.close();
                                                            deptPs.close();
                                                        %>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Gender</label>
                                                <div class="col-sm-10">
                                                    <select class="form-control" name="gender" required>
                                                        <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                                                        <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                                                        <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Age</label>
                                                <div class="col-sm-10">
                                                    <input type="number" class="form-control" name="age" value="<%=age%>" required>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Degree</label>
                                                <div class="col-sm-10">
                                                    <input type="text" class="form-control" name="degree" value="<%=degree != null ? degree : ""%>" required>
                                                </div>
                                            </div>
                                            <% if (hasYearsOfExperience) { %>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Years of Experience</label>
                                                <div class="col-sm-10">
                                                    <input type="number" class="form-control" name="years_of_experience" value="<%=yearsOfExperience%>">
                                                </div>
                                            </div>
                                            <% } %>
                                            <div class="form-group">
                                                <label class="col-sm-2 control-label">Skills</label>
                                                <div class="col-sm-10">
                                                    <textarea class="form-control" name="skill"><%=skill != null ? skill : ""%></textarea>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                                <button type="submit" class="btn btn-primary">Update</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                }
                            } catch (SQLException e) {
                                out.println("<div class='alert alert-danger'>Error loading edit modals: " + e.getMessage() + "</div>");
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                            }
                        %>
                        <div id="adddoctor" class="tab-pane fade">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <%
                                        String success = (String) session.getAttribute("success-message");
                                        String error = (String) session.getAttribute("error-message");
                                        if (success != null) {
                                            out.println("<div class='alert alert-success'>" + success + "</div>");
                                            session.removeAttribute("success-message");
                                        }
                                        if (error != null) {
                                            out.println("<div class='alert alert-danger'>" + error + "</div>");
                                            session.removeAttribute("error-message");
                                        }
                                    %>
                                    <form class="form-horizontal" action="add_doctor_validation.jsp" method="post" id="addDoctorForm" onsubmit="return validateForm(this)">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Name</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="doctname" placeholder="Name" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Email</label>
                                            <div class="col-sm-10">
                                                <input type="email" class="form-control" name="email" placeholder="Email" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Password</label>
                                            <div class="col-sm-10">
                                                <input type="password" class="form-control" name="pwd" id="pwd" placeholder="Password" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Street</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="street" placeholder="Street" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Area</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="area" placeholder="Area" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">City</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="city" placeholder="City" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">State</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="state" placeholder="State" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Pincode</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="pincode" id="pincode" placeholder="Pincode" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Phone</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="phone" id="phone" placeholder="Phone No." required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Department</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="dept" required>
                                                    <option value="" disabled selected>Select Department</option>
                                                    <%
                                                        PreparedStatement deptPs = c.prepareStatement("SELECT NAME FROM department");
                                                        ResultSet deptRs = deptPs.executeQuery();
                                                        while (deptRs.next()) {
                                                            String deptName = deptRs.getString("NAME");
                                                            out.println("<option value=\"" + deptName + "\">" + deptName + "</option>");
                                                        }
                                                        deptRs.close();
                                                        deptPs.close();
                                                    %>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Gender</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="gender" required>
                                                    <option value="Male">Male</option>
                                                    <option value="Female">Female</option>
                                                    <option value="Other">Other</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Age</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" name="age" placeholder="Age" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Degree</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="degree" placeholder="Degree" required>
                                            </div>
                                        </div>
                                        <% if (hasYearsOfExperience) { %>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Years of Experience</label>
                                            <div class="col-sm-10">
                                                <input type="number" class="form-control" name="years_of_experience" placeholder="Years of Experience">
                                            </div>
                                        </div>
                                        <% } %>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Skills</label>
                                            <div class="col-sm-10">
                                                <textarea class="form-control" name="skill" placeholder="Skills"></textarea>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-sm-offset-2 col-sm-10">
                                                <button type="submit" class="btn btn-primary">Add Doctor</button>
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
</body>
</html>