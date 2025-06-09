<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<head>
    <script>
        function confirmDelete() {
            return confirm("Do You Really Want to Delete Pathology Information?");
        }
    </script>
</head>
<%@include file="header.jsp"%>
<body>
    <div class="row">
        <%@include file="menu_patient.jsp"%>
        <!-- Content Area Start -->
        <div class="col-md-10 maincontent">
            <!-- Menu Tab -->
            <div class="panel panel-default contentinside">
                <div class="panel-heading">MY Pathology Info</div>
                <!-- Panel body Start -->
                <div class="panel-body">
                    <ul class="nav nav-tabs doctor">
                        <li role="presentation" class="active"><a href="#doctorlist">Pathology List</a></li>
                    </ul>
                    <!-- Display Pathology Data List Start -->
                    <div id="doctorlist" class="switchgroup">
                        <table class="table table-bordered table-hover">
                            <tr class="active">
                                <td>Patient Id</td>
                                <td>Patient Name</td>
                                <td>XRay (Count)</td>
                                <td>UltraSound (Count)</td>
                                <td>Blood Test (Count)</td>
                                <td>CTScan (Count)</td>
                                <td>Charges</td>
                            </tr>
                            <%
                                Connection c = (Connection) application.getAttribute("connection");
                                int id = Integer.parseInt((String) session.getAttribute("id"));
                                PreparedStatement ps = c.prepareStatement("SELECT * FROM pathology WHERE ID=?", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                                ps.setInt(1, id);
                                ResultSet rs = ps.executeQuery();
                                int totalCharges = 0;
                                while (rs.next()) {
                                    String xray = rs.getString("X_RAYS");
                                    int xrayCount = rs.getInt("xray_count");
                                    String usound = rs.getString("U_SOUND");
                                    int usoundCount = rs.getInt("us_count");
                                    String bt = rs.getString("B_TEST");
                                    int btCount = rs.getInt("bt_count");
                                    String ctscan = rs.getString("CT_SCAN");
                                    int ctCount = rs.getInt("ct_count");
                                    String name = rs.getString("PNAME");
                                    int pid = rs.getInt("ID");
                                    int charges = rs.getInt("CHARGES");
                                    totalCharges += charges;
                            %>
                            <tr>
                                <td><%= pid %></td>
                                <td><%= name %></td>
                                <td><%= xray %> (<%= xrayCount %>)</td>
                                <td><%= usound %> (<%= usoundCount %>)</td>
                                <td><%= bt %> (<%= btCount %>)</td>
                                <td><%= ctscan %> (<%= ctCount %>)</td>
                                <td><%= charges %></td>
                            </tr>
                            <%
                                }
                                rs.close();
                                ps.close();
                            %>
                            <tr class="active">
                                <td colspan="6" style="text-align: right;"><strong>Total Charges</strong></td>
                                <td><strong><%= totalCharges %></strong></td>
                            </tr>
                        </table>
                    </div>
                    <!-- Display Pathology Data List Ends -->
                </div>
                <!-- Panel body Ends -->
            </div>
        </div>
    </div>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>