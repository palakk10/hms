<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<head>
    <script>
        function confirmDelete() {
            return confirm("Do You Really Want to Delete nurse record?");
        }
    </script>
</head>
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu.jsp"%>
        <!---- Content Area Start  -------->
        <div class="col-md-10 maincontent">
            <!----------------   Menu Tab Start   --------------->
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Manage Nurse</div>
                <!----------------   Panel body Start   --------------->
                <div class="panel-body">
                    <ul class="nav nav-tabs doctor">
                        <li role="presentation"><a href="#doctorlist">Nurse List</a></li>
                        <li role="presentation"><a href="#adddoctor">Add Nurse</a></li>
                    </ul>

                    <!----------------   Display Nurse Data List Start  --------------->
                    <div id="doctorlist" class="switchgroup">
                        <table class="table table-bordered table-hover">
                            <tr class="active">
                                <td>Nurse ID</td>
                                <td>Nurse Name</td>
                                <td>Email</td>
                                <td>Street</td>
                                <td>Area</td>
                                <td>City</td>
                                <td>State</td>
                                <td>Country</td>
                                <td>Pincode</td>
                                <td>Phone No.</td>
                                <td>Options</td>
                            </tr>
                            <%!
                                int nurseId;
                                String nurseName, email, street, area, city, state, country, pincode, phone;
                            %>
                            <%
                                Connection c = (Connection)application.getAttribute("connection");
                                PreparedStatement ps = c.prepareStatement("select * from nurse_info", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                ResultSet rs = ps.executeQuery();
                                while(rs.next()) {
                                    nurseId = rs.getInt(1);
                                    nurseName = rs.getString(2);
                                    email = rs.getString(3);
                                    street = rs.getString(5);
                                    area = rs.getString(6);
                                    city = rs.getString(7);
                                    state = rs.getString(8);
                                    country = rs.getString(9);
                                    pincode = rs.getString(10);
                                    phone = rs.getString(11);
                            %>
                            <tr>
                                <td><%=nurseId%></td>
                                <td><%=nurseName%></td>
                                <td><%=email%></td>
                                <td><%=street%></td>
                                <td><%=area%></td>
                                <td><%=city%></td>
                                <td><%=state%></td>
                                <td><%=country%></td>
                                <td><%=pincode%></td>
                                <td><%=phone%></td>
                                <td>
                                    <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal<%=nurseId%>"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></button>
                                    <a href="delete_nurse_validation.jsp?nurseId=<%=nurseId%>" onclick="return confirmDelete()" class="btn btn-danger"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
                                </td>
                            </tr>
                            <%
                                }
                                rs.first();
                                rs.previous();
                            %>
                        </table>
                    </div>
                    <!----------------   Display Nurse Data List Ends  --------------->

                    <!------ Edit Nurse Modal Start ---------->
                    <%
                        while(rs.next()) {
                            nurseId = rs.getInt(1);
                            nurseName = rs.getString(2);
                            email = rs.getString(3);
                            street = rs.getString(5);
                            area = rs.getString(6);
                            city = rs.getString(7);
                            state = rs.getString(8);
                            country = rs.getString(9);
                            pincode = rs.getString(10);
                            phone = rs.getString(11);
                    %>
                    <div class="modal fade" id="myModal<%=nurseId%>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                    <h4 class="modal-title" id="myModalLabel">Edit Nurse Information</h4>
                                </div>
                                <div class="modal-body">
                                    <div class="panel panel-default">
                                        <div class="panel-body">
                                            <form class="form-horizontal" action="edit_nurse_validation.jsp">
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Nurse Id</label>
                                                    <div class="col-sm-4">
                                                        <input type="number" class="form-control" name="nurseId" value="<%=nurseId%>" readonly="readonly">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Name</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="nurseName" value="<%=nurseName%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Email</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="email" value="<%=email%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Street</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="street" value="<%=street%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Area</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="area" value="<%=area%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">City</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="city" value="<%=city%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">State</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="state" value="<%=state%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Country</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="country" value="<%=country%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Pincode</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="pincode" value="<%=pincode%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Phone</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="phone" value="<%=phone%>">
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
                        ps.close();
                        rs.close();
                    %>
                    <!----------------   Modal ends here  --------------->

                    <!----------------   Add Nurse Start   --------------->
                    <div id="adddoctor" class="switchgroup">
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <form class="form-horizontal" action="add_nurse_validation.jsp">
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Nurse Id:</label>
                                        <div class="col-sm-10">
                                            <input type="number" class="form-control" name="id" placeholder="Nurse ID auto generated" readonly>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Name</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="name" placeholder="Name">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Email</label>
                                        <div class="col-sm-10">
                                            <input type="email" class="form-control" name="email" placeholder="Email">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Password</label>
                                        <div class="col-sm-10">
                                            <input type="password" class="form-control" name="password" placeholder="Password">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Street</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="street" placeholder="Street">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Area</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="area" placeholder="Area">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">City</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="city" placeholder="City">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">State</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="state" placeholder="State">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Country</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="country" placeholder="Country">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Pincode</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="pincode" placeholder="Pincode">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Phone</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="phone" placeholder="Phone No.">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-sm-offset-2 col-sm-10">
                                            <button type="submit" class="btn btn-primary">Add Nurse</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <!----------------   Add Nurse Ends   --------------->
                </div>
                <!----------------   Panel body Ends   --------------->
            </div>
            <!----------------   Menu Tab Ends   --------------->
        </div>
        <!---- Content Area Ends  -------->
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>