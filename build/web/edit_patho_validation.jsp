<!DOCTYPE html>
<%@page import="java.sql.*"%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Pathology Information</title>
    <!-- Cache Control -->
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css">
    <!-- External CSS -->
    <link rel="stylesheet" href="css/style.css">
    <!-- Inline CSS -->
    <style>
        .form-group { margin-bottom: 15px !important; }
        .panel-body { padding: 15px !important; }
        .control-label { padding-right: 0; }
        .panel, .contentinside { margin: 0 !important; padding: 0 !important; }
        .maincontent { position: relative !important; min-height: 603px !important; }
        .panel-heading { padding: 10px 15px !important; }
        .contentinside { margin-top: 0 !important; }
        .panel-body { padding-top: 0 !important; }
        .form-horizontal { margin-top: 0 !important; }
    </style>
    <!-- JavaScript -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script>
        function calculateCharges() {
            console.log("Calculating charges");
            var xray = document.forms["editForm"]["xray"].value;
            var xrayCount = parseInt(document.forms["editForm"]["xray_count"].value || 0);
            var usound = document.forms["editForm"]["usound"].value;
            var usoundCount = parseInt(document.forms["editForm"]["usound_count"].value || 0);
            var bt = document.forms["editForm"]["bt"].value;
            var btCount = parseInt(document.forms["editForm"]["bt_count"].value || 0);
            var ctscan = document.forms["editForm"]["ctscan"].value;
            var ctCount = parseInt(document.forms["editForm"]["ct_count"].value || 0);
            var charges = 0;
            if (xray === "Positive") charges += 50 * xrayCount;
            if (usound === "Positive") charges += 100 * usoundCount;
            if (bt === "Positive") charges += 30 * btCount;
            if (ctscan === "Positive") charges += 200 * ctCount;
            document.forms["editForm"]["charges"].value = charges;
            console.log("Calculated charges: " + charges);
        }

        window.onload = function() {
            // Attach event listeners to all relevant form elements
            document.forms["editForm"]["xray"].onchange = calculateCharges;
            document.forms["editForm"]["xray_count"].onchange = calculateCharges;
            document.forms["editForm"]["usound"].onchange = calculateCharges;
            document.forms["editForm"]["usound_count"].onchange = calculateCharges;
            document.forms["editForm"]["bt"].onchange = calculateCharges;
            document.forms["editForm"]["bt_count"].onchange = calculateCharges;
            document.forms["editForm"]["ctscan"].onchange = calculateCharges;
            document.forms["editForm"]["ct_count"].onchange = calculateCharges;
            
            // Calculate initial charges
            calculateCharges();
        };
    </script>
</head>
<body>
    <div class="row">
        <%@include file="header.jsp"%>
        <%@ include file="menu.jsp" %>
        <div class="col-md-10 maincontent">
            <div class="panel panel-default">
                <div class="panel-heading">Edit Pathology Information</div>
                <div class="panel-body">
                    <%
                        // Handle form submission
                        if ("POST".equalsIgnoreCase(request.getMethod())) {
                            Connection conn = null;
                            PreparedStatement pstmt = null;
                            try {
                                int pathologyId = Integer.parseInt(request.getParameter("pathologyId"));
                                int patientId = Integer.parseInt(request.getParameter("patientid"));
                                String patientName = request.getParameter("patientname");
                                String xray = request.getParameter("xray");
                                int xrayCount = Integer.parseInt(request.getParameter("xray_count"));
                                String usound = request.getParameter("usound");
                                int usoundCount = Integer.parseInt(request.getParameter("usound_count"));
                                String bt = request.getParameter("bt");
                                int btCount = Integer.parseInt(request.getParameter("bt_count"));
                                String ctscan = request.getParameter("ctscan");
                                int ctCount = Integer.parseInt(request.getParameter("ct_count"));
                                int charges = Integer.parseInt(request.getParameter("charges"));
                                
                                conn = (Connection) application.getAttribute("connection");
                                String sql = "UPDATE pathology SET ID=?, PNAME=?, X_RAYS=?, xray_count=?, U_SOUND=?, us_count=?, B_TEST=?, bt_count=?, CT_SCAN=?, ct_count=?, CHARGES=? WHERE pathology_id=?";
                                pstmt = conn.prepareStatement(sql);
                                pstmt.setInt(1, patientId);
                                pstmt.setString(2, patientName);
                                pstmt.setString(3, xray);
                                pstmt.setInt(4, xrayCount);
                                pstmt.setString(5, usound);
                                pstmt.setInt(6, usoundCount);
                                pstmt.setString(7, bt);
                                pstmt.setInt(8, btCount);
                                pstmt.setString(9, ctscan);
                                pstmt.setInt(10, ctCount);
                                pstmt.setInt(11, charges);
                                pstmt.setInt(12, pathologyId);
                                
                                int rowsAffected = pstmt.executeUpdate();
                                if (rowsAffected > 0) {
                                    response.sendRedirect("pathology.jsp");
                                    return;
                                } else {
                                    out.println("<div class='alert alert-danger'>Failed to update pathology record.</div>");
                                }
                            } catch (SQLException e) {
                                out.println("<div class='alert alert-danger'>Error updating pathology information: " + e.getMessage() + "</div>");
                            } catch (NumberFormatException e) {
                                out.println("<div class='alert alert-danger'>Invalid input data.</div>");
                            } finally {
                                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                            }
                        }
                        
                        // Display edit form
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        try {
                            int pathologyId = Integer.parseInt(request.getParameter("pathologyId"));
                            conn = (Connection) application.getAttribute("connection");
                            pstmt = conn.prepareStatement("SELECT * FROM pathology WHERE pathology_id = ?");
                            pstmt.setInt(1, pathologyId);
                            rs = pstmt.executeQuery();
                            
                            if (rs.next()) {
                                String xray = rs.getString("X_RAYS") != null ? rs.getString("X_RAYS") : "None";
                                int xrayCount = rs.getInt("xray_count");
                                String usound = rs.getString("U_SOUND") != null ? rs.getString("U_SOUND") : "None";
                                int usoundCount = rs.getInt("us_count");
                                String bt = rs.getString("B_TEST") != null ? rs.getString("B_TEST") : "None";
                                int btCount = rs.getInt("bt_count");
                                String ctscan = rs.getString("CT_SCAN") != null ? rs.getString("CT_SCAN") : "None";
                                int ctCount = rs.getInt("ct_count");
                                String name = rs.getString("PNAME");
                                int id = rs.getInt("ID");
                                int charges = rs.getInt("CHARGES");
                    %>
                    <form class="form-horizontal" id="editForm" action="edit_patho_validation.jsp" method="post">
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Patient Id:</label>
                            <div class="col-sm-10">
                                <input type="number" class="form-control" name="patientid" value="<%= id %>" readonly>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Patient Name</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="patientname" value="<%= name %>" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">X-Ray</label>
                            <div class="col-sm-5">
                                <select class="form-control" name="xray">
                                    <option <%= xray.equals("None") ? "selected" : "" %>>None</option>
                                    <option <%= xray.equals("Positive") ? "selected" : "" %>>Positive</option>
                                    <option <%= xray.equals("Negative") ? "selected" : "" %>>Negative</option>
                                </select>
                            </div>
                            <div class="col-sm-5">
                                <input type="number" class="form-control" name="xray_count" value="<%= xrayCount %>" min="0">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">UltraSound</label>
                            <div class="col-sm-5">
                                <select class="form-control" name="usound">
                                    <option <%= usound.equals("None") ? "selected" : "" %>>None</option>
                                    <option <%= usound.equals("Positive") ? "selected" : "" %>>Positive</option>
                                    <option <%= usound.equals("Negative") ? "selected" : "" %>>Negative</option>
                                </select>
                            </div>
                            <div class="col-sm-5">
                                <input type="number" class="form-control" name="usound_count" value="<%= usoundCount %>" min="0">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Blood Test</label>
                            <div class="col-sm-5">
                                <select class="form-control" name="bt">
                                    <option <%= bt.equals("None") ? "selected" : "" %>>None</option>
                                    <option <%= bt.equals("Positive") ? "selected" : "" %>>Positive</option>
                                    <option <%= bt.equals("Negative") ? "selected" : "" %>>Negative</option>
                                </select>
                            </div>
                            <div class="col-sm-5">
                                <input type="number" class="form-control" name="bt_count" value="<%= btCount %>" min="0">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">CT-Scan</label>
                            <div class="col-sm-5">
                                <select class="form-control" name="ctscan">
                                    <option <%= ctscan.equals("None") ? "selected" : "" %>>None</option>
                                    <option <%= ctscan.equals("Positive") ? "selected" : "" %>>Positive</option>
                                    <option <%= ctscan.equals("Negative") ? "selected" : "" %>>Negative</option>
                                </select>
                            </div>
                            <div class="col-sm-5">
                                <input type="number" class="form-control" name="ct_count" value="<%= ctCount %>" min="0">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Charges</label>
                            <div class="col-sm-10">
                                <input type="number" class="form-control" name="charges" value="<%= charges %>" readonly>
                            </div>
                        </div>
                        <input type="hidden" name="pathologyId" value="<%= pathologyId %>">
                        <div class="form-group">
                            <div class="col-sm-offset-2 col-sm-10">
                                <button type="submit" class="btn btn-primary">Update Pathology Info</button>
                                <a href="pathology.jsp" class="btn btn-default">Cancel</a>
                            </div>
                        </div>
                    </form>
                    <%
                            } else {
                                out.println("<div class='alert alert-danger'>Pathology record not found.</div>");
                            }
                        } catch (SQLException e) {
                            out.println("<div class='alert alert-danger'>Error loading pathology information: " + e.getMessage() + "</div>");
                        } catch (NumberFormatException e) {
                            out.println("<div class='alert alert-danger'>Invalid pathology ID.</div>");
                        } finally {
                            if (rs != null) try { rs.close(); } catch (SQLException e) {}
                            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                        }
                    %>
                </div>
            </div>
        </div>
    </div>
</body>
</html>