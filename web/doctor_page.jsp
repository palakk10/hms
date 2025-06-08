<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <script>
            function confirmDelete() {
                return confirm("Do You Really Want to Delete Your Profile?");
            }
        </script>
    </head>
    <%@include file="header_doctor.jsp"%>
    <body>
        <div class="row">
            <%@include file="menu_doctor.jsp"%>

            <!---- Content Area Start  -------->
            <div class="col-md-10 maincontent" >
                <!----------------   Menu Tab   --------------->
                <div class="panel panel-default contentinside">
                    <div class="panel-heading">Doctor Profile</div>
                    <!----------------   Panel body Start   --------------->
                    <div class="panel-body">
                        <ul class="nav nav-tabs doctor">
                            <li role="presentation"><a href="#doctorprofile">My Profile</a></li>
                        </ul>

                        <!----------------   Display Doctor Profile Start  --------------->
                        <div id="doctorprofile" class="switchgroup">
                            <table class="table table-bordered table-hover">
                                <tr class="active">
                                    <td>Doctor ID</td>
                                    <td>Name</td>
                                    <td>Email</td>
                                    <td>Phone</td>
                                    <td>Department</td>
                                    <td>Gender</td>
                                    <td>Age</td>
                                    <td>Address</td>
                                    <td>Options</td>
                                </tr>
<%
    int id, age;
    String  dname, demail, phone, dept, gender, street, area, city, state, country, pincode;
    Connection c = (Connection)application.getAttribute("connection");
    int doctorId = Integer.parseInt((String)session.getAttribute("id"));
    PreparedStatement ps = c.prepareStatement("SELECT d.*, dept.NAME as dept_name FROM doctor_info d JOIN department dept ON d.DEPT_ID = dept.ID WHERE d.ID = ?", 
            ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
    ps.setInt(1, doctorId);
    ResultSet rs = ps.executeQuery();
    if(rs.next()) {
        id = rs.getInt("ID");
        dname = rs.getString("NAME");
        demail = rs.getString("EMAIL");
        phone = rs.getString("PHONE");
        dept = rs.getString("dept_name");
        gender = rs.getString("GENDER");
        age = rs.getInt("AGE");
        street = rs.getString("STREET");
        area = rs.getString("AREA");
        city = rs.getString("CITY");
        state = rs.getString("STATE");
        country = rs.getString("COUNTRY");
        pincode = rs.getString("PINCODE");
%>          
                                <tr>
                                    <td><%=id%></td>
                                    <td><%=dname%></td>
                                    <td><%=demail%></td>
                                    <td><%=phone%></td>
                                    <td><%=dept%></td>
                                    <td><%=gender%></td>
                                    <td><%=age%></td>
                                    <td><%=street + ", " + (area != null ? area + ", " : "") + city + ", " + state + ", " + country + " - " + pincode%></td>
                                    <td>
                                        <a href="#"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#editModal<%=id%>">
                                            <span class="glyphicon glyphicon-wrench" aria-hidden="true"></span> Edit
                                        </button></a>
                                    </td>
                                </tr>
<%
    }
    rs.first();
    rs.previous();
%>
                            </table>
                        </div>
                        <!----------------   Display Doctor Profile Ends  --------------->

                        <!------ Doctor Edit Info Modal Start Here ---------->
<%
    if(rs.next()) {
        id = rs.getInt("ID");
        dname = rs.getString("NAME");
        demail = rs.getString("EMAIL");
        phone = rs.getString("PHONE");
        dept = rs.getString("dept_name");
        gender = rs.getString("GENDER");
        age = rs.getInt("AGE");
        street = rs.getString("STREET");
        area = rs.getString("AREA");
        city = rs.getString("CITY");
        state = rs.getString("STATE");
        country = rs.getString("COUNTRY");
        pincode = rs.getString("PINCODE");
%>              
                        <div class="modal fade" id="editModal<%=id%>" tabindex="-1" role="dialog" aria-labelledby="editModalLabel">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                        <h4 class="modal-title" id="editModalLabel">Edit Doctor Information</h4>
                                    </div>
                                    
                                    <div class="modal-body">
                                        <div class="panel panel-default">
                                            <div class="panel-body">
                                                <form class="form-horizontal" action="edit_doctor_validation.jsp" method="post">
                                                    <input type="hidden" name="doctorid" value="<%=id%>">
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">Name:</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" class="form-control" name="name" value="<%=dname%>" required>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">Email:</label>
                                                        <div class="col-sm-9">
                                                            <input type="email" class="form-control" name="email" value="<%=demail%>" required>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">Phone:</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" class="form-control" name="phone" value="<%=phone%>" required>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">Gender:</label>
                                                        <div class="col-sm-9">
                                                            <select class="form-control" name="gender" required>
                                                                <option value="Male" <%=gender.equals("Male") ? "selected" : ""%>>Male</option>
                                                                <option value="Female" <%=gender.equals("Female") ? "selected" : ""%>>Female</option>
                                                                <option value="Other" <%=gender.equals("Other") ? "selected" : ""%>>Other</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">Age:</label>
                                                        <div class="col-sm-9">
                                                            <input type="number" class="form-control" name="age" value="<%=age%>" min="22" max="70" required>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">Street:</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" class="form-control" name="street" value="<%=street%>" required>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">Area:</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" class="form-control" name="area" value="<%=area != null ? area : ""%>">
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">City:</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" class="form-control" name="city" value="<%=city%>" required>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">State:</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" class="form-control" name="state" value="<%=state%>" required>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">Country:</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" class="form-control" name="country" value="<%=country%>" required>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="form-group">
                                                        <label class="col-sm-3 control-label">Pincode:</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" class="form-control" name="pincode" value="<%=pincode%>" pattern="[0-9]{6}" required>
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
                    </div>
                    <!----------------   Panel body Ends   --------------->
                </div>
            </div>
        </div>
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>
    </body>
</html>