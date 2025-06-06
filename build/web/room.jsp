<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<head>
    <script>
        function confirmDelete() {
            return confirm("Do You Really Want to Delete Room?");
        }
    </script>
</head>
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu.jsp"%>
        <!------- Content Area start --------->
        <div class="col-md-10 maincontent">
            <!----------- Content Menu Tab Start ------------>
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Manage Room</div>
                <!---------------- Panel Body Start --------------->
                <div class="panel-body">
                    <ul class="nav nav-tabs doctor">
                        <li role="presentation" class="active"><a href="#doctorlist" data-toggle="tab">Room List</a></li>
                        <li role="presentation"><a href="#adddoctor" data-toggle="tab">Add Room</a></li>
                    </ul>
                    <div class="tab-content">
                        <!---------------- Display Room Data List start --------------->
                        <div id="doctorlist" class="tab-pane fade in active switchgroup">
                            <table class="table table-bordered table-hover">
                                <tr class="active">
                                    <td>Room Number</td>
                                    <td>Bed No</td>
                                    <td>Availability Status</td>
                                    <td>Room Type</td>
                                    <td>Options</td>
                                </tr>
                                <%
                                    Connection c = (Connection)application.getAttribute("connection");
                                    PreparedStatement ps = c.prepareStatement("SELECT room_no, bed_no, status, type FROM room_info ORDER BY room_no, bed_no ASC", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                    ResultSet rs = ps.executeQuery();
                                    while (rs.next()) {
                                        int roomNo = rs.getInt("room_no");
                                        int bedNo = rs.getInt("bed_no");
                                        String status = rs.getString("status");
                                        String type = rs.getString("type");
                                %>
                                <tr>
                                    <td><%=roomNo%></td>
                                    <td><%=bedNo%></td>
                                    <td><%=status%></td>
                                    <td><%=type != null ? type : "N/A"%></td>
                                    <td>
                                        <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal<%=roomNo%><%=bedNo%>"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></button>
                                        <a href="delete_room_validation.jsp?roomNo=<%=roomNo%>&bedNo=<%=bedNo%>" class="btn btn-danger" onclick="return confirmDelete()"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
                                    </td>
                                </tr>
                                <%
                                    }
                                    rs.first();
                                    rs.previous();
                                %>
                            </table>
                        </div>
                        <!---------------- Display Room Data List ends --------------->
                        <!---------------- Add Room Start --------------->
                        <div id="adddoctor" class="tab-pane fade switchgroup">
                            <div class="panel panel-default">
                                <div class="panel-body">
                                    <form class="form-horizontal" action="add_room_validation.jsp">
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label">Room No</label>
                                            <div class="col-sm-4">
                                                <input type="number" class="form-control" name="roomNo" placeholder="Room Number" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label">Bed No</label>
                                            <div class="col-sm-4">
                                                <input type="number" class="form-control" name="bedNo" placeholder="Bed No" required>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label">Availability Status</label>
                                            <div class="col-sm-4">
                                                <input type="text" class="form-control" name="status" placeholder="Available" value="available" required readonly>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="col-sm-4 control-label">Room Type</label>
                                            <div class="col-sm-4">
                                                <select name="type" class="form-control" required>
                                                    <%
                                                        PreparedStatement typePs = c.prepareStatement("SELECT DISTINCT type FROM room_info WHERE type IS NOT NULL ORDER BY type ASC");
                                                        ResultSet typeRs = typePs.executeQuery();
                                                        boolean hasTypes = false;
                                                        while (typeRs.next()) {
                                                            String roomType = typeRs.getString("type");
                                                            hasTypes = true;
                                                    %>
                                                    <option><%=roomType%></option>
                                                    <%
                                                        }
                                                        typeRs.close();
                                                        typePs.close();
                                                        if (!hasTypes) {
                                                    %>
                                                    <option value="" disabled selected>No room types available</option>
                                                    <%
                                                        }
                                                    %>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <div class="col-sm-offset-4 col-sm-4">
                                                <button type="submit" class="btn btn-primary">Add Room Now</button>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                        <!---------------- Add Room Ends --------------->
                    </div>
                    <!------ Edit Room Modal Start ---------->
                    <%
                        while (rs.next()) {
                            int roomNo = rs.getInt("room_no");
                            int bedNo = rs.getInt("bed_no");
                            String status = rs.getString("status");
                            String type = rs.getString("type");
                    %>
                    <div class="modal fade" id="myModal<%=roomNo%><%=bedNo%>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                    <h4 class="modal-title" id="myModalLabel">Edit Room Information</h4>
                                </div>
                                <div class="modal-body">
                                    <div class="panel panel-default">
                                        <div class="panel-body">
                                            <form class="form-horizontal" action="edit_room_validation.jsp">
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Room No</label>
                                                    <div class="col-sm-4">
                                                        <input type="number" class="form-control" name="roomNo" value="<%=roomNo%>" readonly>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Bed No</label>
                                                    <div class="col-sm-4">
                                                        <input type="number" class="form-control" name="bedNo" value="<%=bedNo%>" readonly>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Status</label>
                                                    <div class="col-sm-4">
                                                        <input type="text" class="form-control" name="status" value="<%=status%>">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-4 control-label">Room Type</label>
                                                    <div class="col-sm-4">
                                                        <select name="type" class="form-control" required>
                                                            <%
                                                                PreparedStatement editTypePs = c.prepareStatement("SELECT DISTINCT type FROM room_info WHERE type IS NOT NULL ORDER BY type ASC");
                                                                ResultSet editTypeRs = editTypePs.executeQuery();
                                                                boolean editHasTypes = false;
                                                                while (editTypeRs.next()) {
                                                                    String roomType = editTypeRs.getString("type");
                                                                    editHasTypes = true;
                                                            %>
                                                            <option <%=type != null && type.equals(roomType) ? "selected" : ""%>><%=roomType%></option>
                                                            <%
                                                                }
                                                                editTypeRs.close();
                                                                editTypePs.close();
                                                                if (!editHasTypes) {
                                                            %>
                                                            <option value="" disabled selected>No room types available</option>
                                                            <%
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
                        rs.close();
                        ps.close();
                    %>
                    <!---------------- Modal ends here---------------->
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