<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manage Patients</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script>
        function confirmDelete() {
            return confirm("Are you sure you want to delete this patient?");
        }
    </script>
</head>
<body>
    <div class="container-fluid">
        <div class="row navbar-fixed-top">
            <nav class="navbar navbar-default header">
                <div class="container-fluid">
                    <div class="navbar-header">
                        <a class="navbar-brand logo" href="#">
                            <img alt="Brand" src="images/logo.png">
                        </a>
                        <div class="navbar-text title"><p>Hospital Management System</p></div>
                    </div>
                </div>
            </nav>
        </div>
        <div class="row">
            <%@include file="receptionist_menu.jsp" %>
            <div class="col-md-10">
                <div class="panel panel-default">
                    <div class="panel-heading logintitle">Manage Patients</div>
                    <div class="panel-body">
                        <ul class="nav nav-tabs">
                            <li class="active"><a href="#patientList" data-toggle="tab">Patient List</a></li>
                        </ul>
                        <div class="tab-content">
                            <div class="tab-pane active" id="patientList">
                                <%
                                    Connection c = (Connection) application.getAttribute("connection");
                                    if (c == null) {
                                        out.println("<div class='alert alert-danger'>Error: Database connection is null. Check server configuration.</div>");
                                    } else {
                                %>
                                <table class="table table-bordered">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Patient Name</th>
                                            <th>Age</th>
                                            <th>Sex</th>
                                            <th>Phone</th>
                                            <th>Reason Of Visit</th>
                                            <th>Blood Grp</th>
                                            <th>Address</th>
                                            <th>Options</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            PreparedStatement ps = null;
                                            ResultSet rs = null;
                                            try {
                                                ps = c.prepareStatement("SELECT p.ID, p.PNAME, p.AGE, p.GENDER, p.PHONE, c.REASON, p.BGROUP, CONCAT(p.STREET, ', ', p.AREA, ', ', p.CITY, ', ', p.STATE, ', ', p.COUNTRY, ' ', p.PINCODE) AS ADDRESS FROM patient_info p LEFT JOIN case_master c ON p.ID = c.PATIENT_ID");
                                                rs = ps.executeQuery();
                                                if (!rs.isBeforeFirst()) {
                                                    out.println("<tr><td colspan='9'>No patients found in the database.</td></tr>");
                                                } else {
                                                    while (rs.next()) {
                                                        out.println("<tr>");
                                                        out.println("<td>" + rs.getInt("ID") + "</td>");
                                                        out.println("<td>" + rs.getString("PNAME") + "</td>");
                                                        out.println("<td>" + rs.getInt("AGE") + "</td>");
                                                        out.println("<td>" + rs.getString("GENDER") + "</td>");
                                                        out.println("<td>" + rs.getString("PHONE") + "</td>");
                                                        out.println("<td>" + (rs.getString("REASON") != null ? rs.getString("REASON") : "-") + "</td>");
                                                        out.println("<td>" + rs.getString("BGROUP") + "</td>");
                                                        out.println("<td>" + rs.getString("ADDRESS") + "</td>");
                                                        out.println("<td>");
                                                        out.println("<a href='#editModal" + rs.getInt("ID") + "' data-toggle='modal' class='btn btn-primary'>Edit</a> ");
                                                        out.println("<a href='delete_patient_validation.jsp?id=" + rs.getInt("ID") + "' onclick='return confirmDelete()' class='btn btn-danger'>Delete</a> ");
                                                        out.println("<a href='add_pathology.jsp?id=" + rs.getInt("ID") + "' class='btn btn-info'>Add Pathology</a> ");
                                                        out.println("<a href='billing.jsp?id=" + rs.getInt("ID") + "' class='btn btn-success'>Billing</a>");
                                                        out.println("</td>");
                                                        out.println("</tr>");
                                                    }
                                                }
                                            } catch (SQLException e) {
                                                out.println("<tr><td colspan='9'>Error loading patient list: " + e.getMessage() + "</td></tr>");
                                            } finally {
                                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                                if (ps != null) try { ps.close(); } catch (SQLException e) {}
                                            }
                                        %>
                                    </tbody>
                                </table>
                                <% } %>
                            </div>
                        </div>
                        <%
                            if (c != null) {
                                try {
                                    ps = c.prepareStatement("SELECT p.ID, p.PNAME, p.AGE, p.GENDER, p.PHONE, c.REASON, p.BGROUP, p.STREET, p.AREA, p.CITY, p.STATE, p.COUNTRY, p.PINCODE, p.EMAIL, p.PASSWORD FROM patient_info p LEFT JOIN case_master c ON p.ID = c.PATIENT_ID");
                                    rs = ps.executeQuery();
                                    while (rs.next()) {
                        %>
                        <div class="modal fade" id="editModal<%=rs.getInt("ID")%>" tabindex="-1" role="dialog">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">×</span></button>
                                        <h4 class="modal-title">Edit Patient</h4>
                                    </div>
                                    <div class="modal-body">
                                        <form action="edit_patient_validation.jsp" method="post">
                                            <input type="hidden" name="id" value="<%=rs.getInt("ID")%>">
                                            <div class="form-group">
                                                <label>Patient Id:</label>
                                                <input type="text" class="form-control" value="<%=rs.getInt("ID")%>" disabled>
                                            </div>
                                            <div class="form-group">
                                                <label>Name</label>
                                                <input type="text" name="pname" class="form-control" value="<%=rs.getString("PNAME")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Email</label>
                                                <input type="email" name="email" class="form-control" value="<%=rs.getString("EMAIL")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Password</label>
                                                <input type="password" name="password" class="form-control" value="<%=rs.getString("PASSWORD")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Street</label>
                                                <input type="text" name="street" class="form-control" value="<%=rs.getString("STREET")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Area</label>
                                                <input type="text" name="area" class="form-control" value="<%=rs.getString("AREA")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>City</label>
                                                <input type="text" name="city" class="form-control" value="<%=rs.getString("CITY")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>State</label>
                                                <input type="text" name="state" class="form-control" value="<%=rs.getString("STATE")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Pincode</label>
                                                <input type="text" name="pincode" class="form-control" value="<%=rs.getString("PINCODE")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Country</label>
                                                <input type="text" name="country" class="form-control" value="<%=rs.getString("COUNTRY")%>">
                                            </div>
                                            <div class="form-group">
                                                <label>Phone</label>
                                                <input type="text" name="phone" class="form-control" value="<%=rs.getString("PHONE")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Reason Of Visit</label>
                                                <select name="reason" class="form-control" required>
                                                    <%
                                                        PreparedStatement psReason = c.prepareStatement("SELECT REASON FROM reason_department_mapping");
                                                        ResultSet rsReason = psReason.executeQuery();
                                                        while (rsReason.next()) {
                                                            String reason = rsReason.getString("REASON");
                                                            out.println("<option value=\"" + reason + "\"" + (reason.equals(rs.getString("REASON")) ? " selected" : "") + ">" + reason + "</option>");
                                                        }
                                                        rsReason.close();
                                                        psReason.close();
                                                    %>
                                                </select>
                                            </div>
                                            <div class="form-group">
                                                <label>Gender</label>
                                                <select name="gender" class="form-control" required>
                                                    <option value="Male" <%= "Male".equals(rs.getString("GENDER")) ? "selected" : "" %>>Male</option>
                                                    <option value="Female" <%= "Female".equals(rs.getString("GENDER")) ? "selected" : "" %>>Female</option>
                                                    <option value="Other" <%= "Other".equals(rs.getString("GENDER")) ? "selected" : "" %>>Other</option>
                                                </select>
                                            </div>
                                            <div class="form-group">
                                                <label>Age</label>
                                                <input type="number" name="age" class="form-control" value="<%=rs.getInt("AGE")%>" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Blood Group</label>
                                                <select name="bgroup" class="form-control" required>
                                                    <option value="A+" <%= "A+".equals(rs.getString("BGROUP")) ? "selected" : "" %>>A+</option>
                                                    <option value="A-" <%= "A-".equals(rs.getString("BGROUP")) ? "selected" : "" %>>A-</option>
                                                    <option value="B+" <%= "B+".equals(rs.getString("BGROUP")) ? "selected" : "" %>>B+</option>
                                                    <option value="B-" <%= "B-".equals(rs.getString("BGROUP")) ? "selected" : "" %>>B-</option>
                                                    <option value="AB+" <%= "AB+".equals(rs.getString("BGROUP")) ? "selected" : "" %>>AB+</option>
                                                    <option value="AB-" <%= "AB-".equals(rs.getString("BGROUP")) ? "selected" : "" %>>AB-</option>
                                                    <option value="O+" <%= "O+".equals(rs.getString("BGROUP")) ? "selected" : "" %>>O+</option>
                                                    <option value="O-" <%= "O-".equals(rs.getString("BGROUP")) ? "selected" : "" %>>O-</option>
                                                </select>
                                            </div>
                                            <button type="submit" class="btn btn-primary">Update</button>
                                            <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% 
                            } 
                            rs.close();
                            ps.close();
                        } catch (SQLException e) {
                            out.println("<div class='alert alert-danger'>Error loading patient modals: " + e.getMessage() + "</div>");
                        }
                        %>
                    </div>
                </div>
            </div>
        </div>
        <div class="row marginreset">
            <div class="col-md-12 footer">
                <p class="developer">Designed and Developed By # #</p>
                <p>Copyrights © Hospital Management System 2017-18. All rights reserved.</p>
            </div>
        </div>
    </div>
</body>
</html>