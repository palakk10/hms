<%@page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <script>
            function confirmDelete() {
                return confirm("Do You Really Want to Delete This Report?");
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
                    <div class="panel-heading">Patient Reports</div>
                    <!----------------   Panel body Start   --------------->
                    <div class="panel-body">
                        <ul class="nav nav-tabs doctor">
                            <li role="presentation"><a href="#pathologyreports">Pathology Reports</a></li>
                        </ul>

                        <!----------------   Pathology Reports Start  --------------->
                        <div id="pathologyreports" class="switchgroup">
                            <table class="table table-bordered table-hover">
                                <tr class="active">
                                    <td>Patient ID</td>
                                    <td>Patient Name</td>
                                    <td>X-Ray</td>
                                    <td>Ultrasound</td>
                                    <td>Blood Test</td>
                                    <td>CT Scan</td>
                                    <td>Charges</td>
                                    <td>Options</td>
                                </tr>
<%
    Connection c = (Connection)application.getAttribute("connection");
    int doctorId = Integer.parseInt((String)session.getAttribute("id"));
    
    // Get pathology reports for all patients of this doctor
    PreparedStatement ps = c.prepareStatement(
        "SELECT p.*, pa.X_RAYS, pa.U_SOUND, pa.B_TEST, pa.CT_SCAN, pa.CHARGES " +
        "FROM patient_info p JOIN pathology pa ON p.ID = pa.ID " +
        "WHERE p.DOCTOR_ID = ?");
    ps.setInt(1, doctorId);
    ResultSet rs = ps.executeQuery();
    
    while(rs.next()) {
        int patientId = rs.getInt("ID");
        String patientName = rs.getString("PNAME");
        String xray = rs.getString("X_RAYS");
        String usound = rs.getString("U_SOUND");
        String btest = rs.getString("B_TEST");
        String ctscan = rs.getString("CT_SCAN");
        int charges = rs.getInt("CHARGES");
%>          
                                <tr>
                                    <td><%=patientId%></td>
                                    <td><%=patientName%></td>
                                    <td><%=xray != null ? xray : "N/A"%></td>
                                    <td><%=usound != null ? usound : "N/A"%></td>
                                    <td><%=btest != null ? btest : "N/A"%></td>
                                    <td><%=ctscan != null ? ctscan : "N/A"%></td>
                                    <td><%=charges%></td>
                                    <td>
                                        <a href="my_patients.jsp#patientModal<%=patientId%>" class="btn btn-info">
                                            <span class="glyphicon glyphicon-eye-open" aria-hidden="true"></span> View Patient
                                        </a>
                                    </td>
                                </tr>
<%
    }
    rs.close();
    ps.close();
%>
                            </table>
                        </div>
                        <!----------------   Pathology Reports Ends  --------------->
                    </div>
                    <!----------------   Panel body Ends   --------------->
                </div>
            </div>
        </div>
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>
    </body>
</html>