<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<head>
    <script>
        function confirmDelete() {
            return confirm("Do You Really Want to Delete Patient?");
        }
    </script>
    <script src="validation.js"></script>
</head>
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu.jsp"%>
        <!---- Content Area Start  -------->
        <div class="col-md-10 maincontent">
            <!----------------   Menu Tab   --------------->
            <div class="panel panel-default contentinside">
                <div class="panel-heading">Manage Patient</div>
                <!----------------   Panel body Start   --------------->
                <div class="panel-body">
                    <ul class="nav nav-tabs doctor">
                        <li role="presentation"><a href="#doctorlist">Patient List</a></li>
                        <li role="presentation"><a href="#adddoctor">Add Patient</a></li>
                    </ul>

                    <!----------------   Display Patients Data List Start  --------------->
                    <div id="doctorlist" class="switchgroup">
                        <table class="table table-bordered table-hover">
                            <tr class="active">
                                <td>#</td>
                                <td>Patient Name</td>
                                <td>Age</td>
                                <td>Sex</td>
                                <td>Phone</td>
                                <td>Reason Of Visit</td>
                                <td>Blood Grp</td>
                                <td>Date Of Admit</td>
                                <td>Room No</td>
                                <td>Bed No</td>
                                <td>Observed By</td>
                                <td>Address</td>
                                <td>Options</td>
                            </tr>
                            <%
                                Connection c = (Connection) application.getAttribute("connection");
                                PreparedStatement ps = c.prepareStatement(
                                    "SELECT p.ID, p.PNAME, p.GENDER, p.AGE, p.BGROUP, p.PHONE, p.REA_OF_VISIT, p.ROOM_NO, p.BED_NO, p.DOCTOR_ID, d.NAME AS DOCTOR_NAME, p.DATE_AD, p.EMAIL, CONCAT(p.STREET, ', ', p.AREA, ', ', p.CITY, ', ', p.STATE, ', ', p.COUNTRY, ', ', p.PINCODE) AS FULL_ADDRESS FROM PATIENT_INFO p LEFT JOIN DOCTOR_INFO d ON p.DOCTOR_ID = d.ID",
                                    ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                                );
                                ResultSet rs = ps.executeQuery();
                                while (rs.next()) {
                                    int id = rs.getInt("ID");
                                    String name = rs.getString("PNAME");
                                    String gender = rs.getString("GENDER");
                                    int age = rs.getInt("AGE");
                                    String bgroup = rs.getString("BGROUP");
                                    String phone = rs.getString("PHONE");
                                    String rov = rs.getString("REA_OF_VISIT");
                                    int room_no = rs.getInt("ROOM_NO");
                                    int bed_no = rs.getInt("BED_NO");
                                    String doc_name = rs.getString("DOCTOR_NAME") != null ? rs.getString("DOCTOR_NAME") : "Not Assigned";
                                    String admit_date = rs.getString("DATE_AD");
                                    String full_address = rs.getString("FULL_ADDRESS");
                                    pageContext.setAttribute("currentDoctorId", rs.getInt("DOCTOR_ID"));
                            %>
                            <tr>
                                <td><%=id%></td>
                                <td><%=name%></td>
                                <td><%=age%></td>
                                <td><%=gender%></td>
                                <td><%=phone%></td>
                                <td><%=rov%></td>
                                <td><%=bgroup%></td>
                                <td><%=admit_date%></td>
                                <td><%=room_no%></td>
                                <td><%=bed_no%></td>
                                <td><%=doc_name%></td>
                                <td><%=full_address%></td>
                                <td>
                                    <a href="#"><button type="button" class="btn btn-primary" data-toggle="modal" data-target="#myModal<%=id%>"><span class="glyphicon glyphicon-wrench" aria-hidden="true"></span></button></a>
                                    <a href="delete_patient_validation.jsp?patientId=<%=id%>&roomNo=<%=room_no%>&bedNo=<%=bed_no%>" onclick="return confirmDelete()" class="btn btn-danger"><span class="glyphicon glyphicon-trash" aria-hidden="true"></span></a>
                                </td>
                            </tr>
                            <%
                                }
                                rs.first();
                                rs.previous();
                            %>
                        </table>
                    </div>
                    <!----------------   Display Patient Data List Ends  --------------->

                    <!------ Patient Edit Info Modal Start Here ---------->
                    <%
                        // Re-execute query for edit modals to avoid cursor issues
                        PreparedStatement psModal = c.prepareStatement(
                            "SELECT p.ID, p.PNAME, p.GENDER, p.AGE, p.BGROUP, p.PHONE, p.REA_OF_VISIT, p.ROOM_NO, p.BED_NO, p.DOCTOR_ID, d.NAME AS DOCTOR_NAME, p.DATE_AD, p.EMAIL, CONCAT(p.STREET, ', ', p.AREA, ', ', p.CITY, ', ', p.STATE, ', ', p.COUNTRY, ', ', p.PINCODE) AS FULL_ADDRESS FROM PATIENT_INFO p LEFT JOIN DOCTOR_INFO d ON p.DOCTOR_ID = d.ID",
                            ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE
                        );
                        ResultSet rsModal = psModal.executeQuery();
                        while (rsModal.next()) {
                            int id = rsModal.getInt("ID");
                            String name = rsModal.getString("PNAME");
                            String gender = rsModal.getString("GENDER");
                            int age = rsModal.getInt("AGE");
                            String bgroup = rsModal.getString("BGROUP");
                            String phone = rsModal.getString("PHONE");
                            String rov = rsModal.getString("REA_OF_VISIT");
                            int room_no = rsModal.getInt("ROOM_NO");
                            int bed_no = rsModal.getInt("BED_NO");
                            int doctorId = rsModal.getInt("DOCTOR_ID");
                            String admit_date = rsModal.getString("DATE_AD");
                            String email = rsModal.getString("EMAIL");
                            String full_address = rsModal.getString("FULL_ADDRESS");
                            pageContext.setAttribute("currentDoctorId", doctorId);
                    %>
                    <div class="modal fade" id="myModal<%=id%>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                    <h4 class="modal-title" id="myModalLabel">Edit Patient Information</h4>
                                </div>
                                <div class="modal-body">
                                    <div class="panel panel-default">
                                        <div class="panel-body">
                                            <form class="form-horizontal" action="edit_patient_validation.jsp" method="post">
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Patient Id:</label>
                                                    <div class="col-sm-10">
                                                        <input type="number" class="form-control" name="patientid" value="<%=id%>" readonly="readonly">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Name</label>
                                                    <div class="col-sm-10">
                                                        <input type="text" class="form-control" name="patientname" value="<%=name%>" placeholder="Name">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Email</label>
                                                    <div class="col-sm-10">
                                                        <input type="email" class="form-control" name="email" value="<%=email%>" placeholder="Email">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Address</label>
                                                    <div class="col-sm-10">
                                                        <input type="text" class="form-control" name="add" value="<%=full_address%>" placeholder="Address">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Phone</label>
                                                    <div class="col-sm-10">
                                                        <input type="text" class="form-control" name="phone" value="<%=phone%>" placeholder="Phone">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Reason Of Visit</label>
                                                    <div class="col-sm-10">
                                                        <input type="text" class="form-control" name="rov" value="<%=rov%>" placeholder="Reason Of Visit">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Room Number</label>
                                                    <div class="col-sm-10">
                                                        <select class="form-control" name="roomNo" id="roomNo<%=id%>" onchange="retrieveBeds2('<%=id%>')">
                                                            <option selected="selected"><%=room_no%></option>
                                                            <%
                                                                PreparedStatement ps1 = c.prepareStatement("SELECT DISTINCT room_no FROM room_info", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                                ResultSet rs1 = ps1.executeQuery();
                                                                while (rs1.next()) {
                                                                    int roomNo1 = rs1.getInt(1);
                                                            %>
                                                            <option value="<%=roomNo1%>"><%=roomNo1%></option>
                                                            <%
                                                                }
                                                                ps1.close();
                                                                rs1.close();
                                                            %>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Bed No.</label>
                                                    <div class="col-sm-10" id="beds<%=id%>">
                                                        <select class="form-control" name="bed_no">
                                                            <option selected="selected"><%=bed_no%></option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Reffered To</label>
                                                    <div class="col-sm-10">
                                                        <select class="form-control" name="doct">
                                                            <%
                                                                PreparedStatement ps2 = c.prepareStatement("SELECT ID, NAME FROM DOCTOR_INFO", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                                ResultSet rs2 = ps2.executeQuery();
                                                                while (rs2.next()) {
                                                                    int doctId = rs2.getInt("ID");
                                                                    String doctName = rs2.getString("NAME");
                                                                    String selected = (doctId == doctorId) ? "selected" : "";
                                                            %>
                                                            <option value="<%=doctId%>" <%=selected%>><%=doctName%> (<%=doctId%>)</option>
                                                            <%
                                                                }
                                                                ps2.close();
                                                                rs2.close();
                                                            %>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Gender</label>
                                                    <div class="col-sm-10">
                                                        <input type="text" class="form-control" name="gender" value="<%=gender%>" placeholder="Gender">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Admission Date</label>
                                                    <div class="col-sm-10">
                                                        <input type="text" class="form-control" name="admit_date" value="<%=admit_date%>" placeholder="Admission Date">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Age</label>
                                                    <div class="col-sm-10">
                                                        <input type="text" class="form-control" name="age" value="<%=age%>" placeholder="Age">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label class="col-sm-2 control-label">Blood Group</label>
                                                    <div class="col-sm-10">
                                                        <input type="text" class="form-control" name="bgroup" value="<%=bgroup%>" placeholder="Blood Group">
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
                        psModal.close();
                        rsModal.close();
                    %>
                    <!----------------   Modal ends here  --------------->

                    <!----------------   Add Patient Start   --------------->
                    <div id="adddoctor" class="switchgroup">
                        <div class="panel panel-default">
                            <div class="panel-body">
                                <form class="form-horizontal" action="add_patient_validation.jsp">
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Patient Id:</label>
                                        <div class="col-sm-10">
                                            <input type="number" class="form-control" name="patientid" placeholder="unique_id auto generated" readonly>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Name</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="patientname" placeholder="Name">
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
                                            <input type="password" class="form-control" name="pwd" placeholder="Password">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Address</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="add" placeholder="Address">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Phone</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="phone" placeholder="Phone No.">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Reason Of Visit</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="rov" placeholder="Reason Of Visit">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Room No</label>
                                        <div class="col-sm-10">
                                            <select class="form-control" name="roomNo" id="roomNo" onchange="retrieveBeds()">
                                                <option selected="selected">Select Room</option>
                                                <%
                                                    PreparedStatement ps3 = c.prepareStatement("SELECT DISTINCT room_no FROM room_info", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                    ResultSet rs3 = ps3.executeQuery();
                                                    while (rs3.next()) {
                                                        int roomNo = rs3.getInt(1);
                                                %>
                                                <option value="<%=roomNo%>"><%=roomNo%></option>
                                                <%
                                                    }
                                                    ps3.close();
                                                    rs3.close();
                                                %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Bed No.</label>
                                        <div class="col-sm-10" id="beds">
                                            <select class="form-control" name="bed_no">
                                                <option selected="selected">Select Bed</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Reffered To</label>
                                        <div class="col-sm-10">
                                            <select class="form-control" name="doct">
                                                <option value="">Select Doctor</option>
                                                <%
                                                    PreparedStatement ps4 = c.prepareStatement("SELECT ID, NAME FROM DOCTOR_INFO", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                                    ResultSet rs4 = ps4.executeQuery();
                                                    while (rs4.next()) {
                                                        int doctId = rs4.getInt("ID");
                                                        String doctName = rs4.getString("NAME");
                                                %>
                                                <option value="<%=doctId%>"><%=doctName%> (<%=doctId%>)</option>
                                                <%
                                                    }
                                                    ps4.close();
                                                    rs4.close();
                                                %>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Sex</label>
                                        <div class="col-sm-2">
                                            <select class="form-control" name="gender">
                                                <option>Male</option>
                                                <option>Female</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Admission Date</label>
                                        <div class="col-sm-10">
                                            <input type="date" class="form-control" name="joindate" placeholder="Admission date">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Age</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" name="age" placeholder="Age">
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="col-sm-2 control-label">Blood Group</label>
                                        <div class="col-sm-2">
                                            <select class="form-control" name="bgroup">
                                                <option>A+</option>
                                                <option>A-</option>
                                                <option>B+</option>
                                                <option>B-</option>
                                                <option>AB+</option>
                                                <option>AB-</option>
                                                <option>O+</option>
                                                <option>O-</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <div class="col-sm-offset-2 col-sm-10">
                                            <button type="submit" class="btn btn-primary">Add Patient</button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <!----------------   Add Patients Ends   --------------->
                </div>
                <!----------------   Panel body Ends   --------------->
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>