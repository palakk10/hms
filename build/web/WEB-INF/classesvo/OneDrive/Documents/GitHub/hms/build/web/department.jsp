<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manage Department - Hospital Management System</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script>
        function confirmDelete() {
            return confirm("Do You Really Want to Delete Department?");
        }
    </script>
</head>
<body>
<%@include file="header.jsp"%>

<div class="row">
    <%@include file="menu.jsp"%>

    <!------- Content Area start --------->
    <div class="col-md-10 maincontent">
        <!----------- Content Menu Tab Start ------------>
        <div class="panel panel-default contentinside">
            <div class="panel-heading">Manage Department</div>

            <!---------------- Panel Body Start --------------->
            <div class="panel-body">
                <ul class="nav nav-tabs doctor">
                    <li role="presentation" class="active"><a href="#doctorlist" data-toggle="tab">Department List</a></li>
                    <li role="presentation"><a href="#adddoctor" data-toggle="tab">Add Department</a></li>
                </ul>

                <!---------------- Display Department Data List start --------------->
                <div id="doctorlist" class="tab-pane fade in active switchgroup">
                    <table class="table table-bordered table-hover">
                        <thead>
                            <tr class="active">
                                <th>Department ID</th>
                                <th>Department Name</th>
                                <th>Department Description</th>
                                <th>Options</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try {
                                    Connection con = (Connection) application.getAttribute("connection");
                                    PreparedStatement ps = con.prepareStatement("SELECT * FROM department", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                                        int deptId = rs.getInt("ID");
                                        String deptName = rs.getString("NAME");
                                        String deptDesc = rs.getString("DESCRIPTION");
                            %>
                            <tr>
                                <td><%= deptId %></td>
                                <td><%= deptName %></td>
                                <td><%= deptDesc %></td>
                                <td>
                                    <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal<%= deptId %>">
                                        <span class="glyphicon glyphicon-wrench" aria-hidden="true"></span>
                                    </button>
                                    <a href="delete_dept_validation.jsp?deptId=<%= deptId %>" class="btn btn-danger" onclick="return confirmDelete()">
                                        <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
                                    </a>
                                </td>
                            </tr>
                            <%
                                    }
                                    rs.first();
                                    rs.previous();
                            %>
                        </tbody>
                    </table>
                </div>
                <!---------------- Display Department Data List ends --------------->

                <!------ Edit Department Modals Start ---------->
                <%
                    rs.beforeFirst(); // Reset cursor for modal generation
                    while (rs.next()) {
                        int deptId = rs.getInt("ID");
                        String deptName = rs.getString("NAME");
                        String deptDesc = rs.getString("DESCRIPTION");
                %>
                <div class="modal fade" id="myModal<%= deptId %>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel<%= deptId %>">
                    <div class="modal-dialog" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                <h4 class="modal-title" id="myModalLabel<%= deptId %>">Edit Department Information</h4>
                            </div>
                            <div class="modal-body">
                                <div class="panel panel-default">
                                    <div class="panel-body">
                                        <form class="form-horizontal" action="edit_dept_validation.jsp" method="post">
                                            <div class="form-group">
                                                <label class="col-sm-4 control-label">Department ID</label>
                                                <div class="col-sm-4">
                                                    <input type="number" class="form-control" name="deptId" value="<%= deptId %>" readonly>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-4 control-label">Department Name</label>
                                                <div class="col-sm-4">
                                                    <input type="text" class="form-control" name="deptName" value="<%= deptName %>">
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="col-sm-4 control-label">Department Description</label>
                                                <div class="col-sm-4">
                                                    <input type="text" class="form-control" name="deptDesc" value="<%= deptDesc %>">
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
                    </div>
                </div>
                <%
                    }
                    rs.close();
                    ps.close();
                } catch (SQLException e) {
                    out.println("<div class='text-danger'>Error: " + e.getMessage() + "</div>");
                }
                %>
                <!---------------- Modal ends here --------------->

                <!---------------- Add Department Start --------------->
                <div id="adddoctor" class="tab-pane fade switchgroup">
                    <div class="panel panel-default">
                        <div class="panel-body">
                            <form class="form-horizontal" action="add_dept_validation.jsp" method="post">
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Department ID</label>
                                    <div class="col-sm-4">
                                        <input type="number" class="form-control" name="deptId" placeholder="ID Auto Generated" readonly>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Department Name</label>
                                    <div class="col-sm-4">
                                        <input type="text" class="form-control" name="deptName" placeholder="Enter Department Name" required>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label class="col-sm-4 control-label">Department Description</label>
                                    <div class="col-sm-4">
                                        <input type="text" class="form-control" name="deptDesc" placeholder="Enter Department Description here..." required>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <div class="col-sm-offset-4 col-sm-10">
                                        <button type="submit" class="btn btn-primary">Add Department</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                <!---------------- Add Department Ends --------------->
            </div>
            <!---------------- Panel Body Ends --------------->
        </div>
        <!----------- Content Menu Tab Ends ------------>
    </div>
    <!------- Content Area Ends --------->
</div>

<script src="js/bootstrap.min.js"></script>
</body>
</html>