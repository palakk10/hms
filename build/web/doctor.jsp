
<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<head>
    <script>
        function confirmDelete() {
            return confirm("Do You Really Want to Delete Doctor?");
        }
    </script>
</head>
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu.jsp"%>

        <div class="col-md-10 maincontent">
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Manage Doctor</div>
                <div class="panel-body">
                    <ul class="nav nav-tabs doctor">
                        <li role="presentation" class="active"><a href="#doctorlist" data-toggle="tab">Doctor List</a></li>
                        <li role="presentation"><a href="#adddoctor" data-toggle="tab">Add Doctor</a></li>
                    </ul>

                    <div class="tab-content">
                        <div id="doctorlist" class="tab-pane fade in active">
                            <table class="table table-bordered table-hover">
                                <tr class="active">
                                    <td>Doctor ID</td>
                                    <td>Doctor Name</td>
                                    <td>Email</td>
                                    <td>Street</td>
                                    <td>Area</td>
                                    <td>City</td>
                                    <td>State</td>
                                    <td>Pincode</td>
                                    <td>Phone No.</td>
                                    <td>Department</td>
                                    <td>Options</td>
                                </tr>
                                <%!
                                    int deptId;
                                    String deptName;
                                    int id;
                                    String name, email, pwd, street, area, city, state, pincode, phone, dept;
                                    PreparedStatement ps;
                                    ResultSet rs;
                                %>
                                <%
                                    Connection c = (Connection) application.getAttribute("connection");
                                    try {
                                        PreparedStatement ps = c.prepareStatement(
                                            "SELECT di.ID, di.NAME, di.EMAIL, di.STREET, di.AREA, di.CITY, di.STATE, di.PINCODE, di.PHONE, d.NAME AS DEPT_NAME, di.PASSWORD FROM doctor_info di JOIN department d ON di.DEPT_ID = d.ID",
                                            ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                                        );
                                        rs = ps.executeQuery();
                                        while (rs.next()) {
                                            id = rs.getInt(1);
                                            name = rs.getString(2);
                                            email = rs.getString(3);
                                            street = rs.getString(4);
                                            area = rs.getString(5);
                                            city = rs.getString(6);
                                            state = rs.getString(7);
                                            pincode = rs.getString(8);
                                            phone = rs.getString(9);
                                            dept = rs.getString(10);
                                %>
                                <tr>
                                    <td><%=id%></td>
                                    <td><%=name%></td>
                                    <td><%=email%></td>
                                    <td><%=street%></td>
                                    <td><%=area%></td>
                                    <td><%=city%></td>
                                    <td><%=state%></td>
                                    <td><%=pincode%></td>
                                    <td><%=phone%></td>
                                    <td><%=dept%></td>
                                    <td>
                                        <a href="#"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal<%=id%>"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></button></a>
                                        <a href="delete_doct_validation.jsp?doctId=<%=id%>" onclick="return confirmDelete()" class="btn btn-danger"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
                                    </td>
                                </tr>
                                <%
                                        }
                                        rs.first();
                                        rs.previous();
                                    } catch (SQLException e) {
                                        out.println("<div class='alert alert-danger'>Error loading doctor list: " + e.getMessage() + "</div>");
                                    }
                                %>
                            </table>
                        </div>

                        <%
                            try {
                                while (rs.next()) {
                                    id = rs.getInt(1);
                                    name = rs.getString(2);
                                    email = rs.getString(3);
                                    street = rs.getString(4);
                                    area = rs.getString(5);
                                    city = rs.getString(6);
                                    state = rs.getString(7);
                                    pincode = rs.getString(8);
                                    phone = rs.getString(9);
                                    dept = rs.getString(10);
                                    pwd = rs.getString(11);
                                    System.out.println("Loading modal for doctor ID " + id + ", pwd=" + (pwd != null ? "[PROTECTED]" : "null"));
                        %>
                        <div class="modal fade" id="myModal<%=id%>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                        <h4 class="modal-title" id="myModalLabel">Edit Doctor Information</h4>
                                    </div>
                                    <div class="modal-body">
                                        <div class="panel panel-default">
                                            <div class="panel-body">
                                                <form class="form-horizontal" action="edit_doct_validation.jsp" method="post">
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Doctor Id:</label>
                                                        <div class="col-sm-10">
                                                            <input type="number" class="form-control" name="doctid" value="<%=id%>" readonly="readonly">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Name</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="doctname" value="<%=name%>" placeholder="Name">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Email</label>
                                                        <div class="col-sm-10">
                                                            <input type="email" class="form-control" name="email" value="<%=email%>" placeholder="Email">
                                                        </div>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="col-sm-2 control-label">Password</label>
                                                        <div class="col-sm-10">
                                                            <input type="password" class="form-control" name="pwd" value="<%=pwd != null ? pwd : ""%>" placeholder="Password">
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
                                                        <label class="col-sm-2 control-label">State</label>
                                                        <div class="col-sm-10">
                                                            <input type="text" class="form-control" name="state" value="<%=state%>" placeholder="State">
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
                                                        <label class="col-sm-2 control-label">Department</label>
                                                        <div class="col-sm-10">
                                                            <select class="form-control" name="dept">
                                                                <option selected="selected"><%=dept%></option>
                                                                <%
                                                                    try {
                                                                        PreparedStatement deptPs = c.prepareStatement("SELECT NAME FROM department", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                                        ResultSet deptRs = deptPs.executeQuery();
                                                                        while (deptRs.next()) {
                                                                            String deptOption = deptRs.getString(1);
                                                                            if (!deptOption.equals(dept)) {
                                                                %>
                                                                <option><%=deptOption%></option>
                                                                <%
                                                                            }
                                                                        }
                                                                    } catch (SQLException e) {
                                                                        out.println("<option>Error loading departments</option>");
                                                                    }
                                                                %>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                                        <input type="submit" class="btn btn-primary" value="Update">
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <%
                                }
                            } catch (SQLException e) {
                                out.println("<div class='alert alert-danger'>Error loading edit modals: " + e.getMessage() + "</div>");
                            }
                        %>

                        <div id="adddoctor" class="tab-pane fade">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <%
                                        String success = (String) session.getAttribute("success-message");
                                        String error = (String) session.getAttribute("error-message");
                                        if (success != null) {
                                    %>
                                        <div class="alert alert-success"><%=success%></div>
                                    <%
                                            session.removeAttribute("success-message");
                                        }
                                        if (error != null) {
                                    %>
                                        <div class='alert alert-danger'><%=error%></div>
                                    <%
                                            session.removeAttribute("error-message");
                                        }
                                    %>
                                    <form class="form-horizontal" action="add_doctor_validation.jsp" method="post" id="addDoctorForm">
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Name</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="doctname" placeholder="Name" required="required">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Email</label>
                                            <div class="col-sm-10">
                                                <input type="email" class="form-control" name="email" placeholder="Email" required="required">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Password</label>
                                            <div class="col-sm-10">
                                                <input type="password" class="form-control" name="pwd" id="pwd" placeholder="Password" required="required">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Street</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="street" placeholder="Street" required="required">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Area</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="area" placeholder="Area" required="required">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">City</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="city" placeholder="City" required="required">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">State</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="state" placeholder="State" required="required">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Pincode</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="pincode" id="pincode" placeholder="Pincode" required="required">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Phone</label>
                                            <div class="col-sm-10">
                                                <input type="text" class="form-control" name="phone" id="phone" placeholder="Phone No." required="required">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-2 control-label">Department</label>
                                            <div class="col-sm-10">
                                                <select class="form-control" name="dept" required="required">
                                                    <option value="" disabled selected>Select Department</option>
                                                    <%
                                                        try {
                                                            PreparedStatement deptPs = c.prepareStatement("SELECT NAME FROM department", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                            ResultSet deptRs = deptPs.executeQuery();
                                                            while (deptRs.next()) {
                                                                String deptName = deptRs.getString(1);
                                                    %>
                                                    <option value="<%=deptName%>"><%=deptName%></option>
                                                    <%
                                                            }
                                                        } catch (SQLException e) {
                                                            out.println("<option>Error loading departments</option>");
                                                        }
                                                    %>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-sm-offset-2 col-sm-10">
                                                <button type="submit" class="btn btn-primary">Add Doctor</button>
                                            </div>
                                        </div>
                                    </form>
                                    <script>
                                        document.getElementById('addDoctorForm').addEventListener('submit', function(e) {
                                            var pincode = document.getElementById('pincode').value.trim();
                                            var phone = document.getElementById('phone').value.trim();
                                            var pwd = document.getElementById('pwd').value.trim();
                                            console.log('Form submit: Password="' + pwd + '", Length=' + pwd.length + ', Pincode="' + pincode + '", Phone="' + phone + '"');
                                            if (!pincode.match(/^\d{6}$/)) {
                                                alert("Pincode must be exactly 6 digits.");
                                                e.preventDefault();
                                            } else if (!phone.match(/^\d{10}$/)) {
                                                alert("Phone must be exactly 10 digits.");
                                                e.preventDefault();
                                            } else if (!pwd || pwd.length < 8) {
                                                alert("Password must be at least 8 characters.");
                                                e.preventDefault();
                                            }
                                        });
                                    </script>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>
```

<x