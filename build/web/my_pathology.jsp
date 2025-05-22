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
<%@include file="header_patient.jsp"%>
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
                    <li role="presentation"><a href="#doctorlist">Pathology List</a></li>
                </ul>

                <!-- Display Pathology Data List Start -->
                <div id="doctorlist" class="switchgroup">
                    <table class="table table-bordered table-hover">
                        <tr class="active">
                            <td>Patient Id</td>
                            <td>Patient Name</td>
                            <td>XRay</td>
                            <td>UltraSound</td>
                            <td>Blood Test</td>
                            <td>CTScan</td>
                            <td>Charges</td>  <!-- New Charges column header -->
                        </tr>
                        <%
                            Connection c = (Connection) application.getAttribute("connection");
                            int id = Integer.parseInt((String) session.getAttribute("id"));
                            PreparedStatement ps = c.prepareStatement("select * from pathology where id=?", ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
                            ps.setInt(1, id);
                            ResultSet rs = ps.executeQuery();

                            int totalCharges = 0;

                            while (rs.next()) {
                                String xray = rs.getString(1);
                                String usound = rs.getString(2);
                                String bt = rs.getString(3);
                                String ctscan = rs.getString(4);
                                String name = rs.getString(5);
                                int pid = rs.getInt(6);
                                int charges = 0;
                                try {
                                    charges = rs.getInt("charges");  // Assuming column name is 'charges'
                                } catch (Exception e) {
                                    charges = 0; // If column missing or null
                                }
                                totalCharges += charges;
                        %>
                        <tr>
                            <td><%= pid %></td>
                            <td><%= name %></td>
                            <td><%= xray %></td>
                            <td><%= usound %></td>
                            <td><%= bt %></td>
                            <td><%= ctscan %></td>
                            <td><%= charges %></td> <!-- Show charges -->
                        </tr>
                        <%
                            }
                            rs.close();
                            ps.close();
                        %>
                        <!-- Total charges row -->
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
</div>

<script src="js/bootstrap.min.js"></script>
</body>
</html>
