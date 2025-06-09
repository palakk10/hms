<%@page import="java.sql.*"%>
<%
    // Get doctor ID from session
    int id = Integer.parseInt((String)session.getAttribute("id"));
    String opass1 = request.getParameter("opass");
    String npass = request.getParameter("npass");
    String cpass = request.getParameter("cpass");
    
    // Initialize connection and variables
    Connection c = (Connection)application.getAttribute("connection");
    PreparedStatement ps = null;
    ResultSet rs = null;
    String errorMessage = null;
    boolean success = false;
    
    try {
        // Check current password
        ps = c.prepareStatement("SELECT PASSWORD FROM doctor_info WHERE ID = ?");
        ps.setInt(1, id);
        rs = ps.executeQuery();
        
        if(rs.next()) {
            String opass2 = rs.getString(1);
            
            if(opass1.equals(opass2)) {
                if(npass.equals(cpass)) {
                    // Update password
                    ps = c.prepareStatement("UPDATE doctor_info SET PASSWORD = ? WHERE ID = ?");
                    ps.setString(1, npass);
                    ps.setInt(2, id);
                    int i = ps.executeUpdate();
                    
                    if(i > 0) {
                        success = true;
                    } else {
                        errorMessage = "Password update failed. Please try again.";
                    }
                } else {
                    errorMessage = "New password and confirm password must match.";
                }
            } else {
                errorMessage = "Current password is incorrect.";
            }
        } else {
            errorMessage = "Doctor record not found.";
        }
    } catch(SQLException e) {
        errorMessage = "Database error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        // Close resources
        try { if(rs != null) rs.close(); } catch(Exception e) {}
        try { if(ps != null) ps.close(); } catch(Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Password Update</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        .message-box {
            text-align: center;
            margin-top: 25%;
            padding: 20px;
            border-radius: 5px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        .success {
            background-color: #dff0d8;
            color: #3c763d;
            border: 1px solid #d6e9c6;
        }
        .error {
            background-color: #f2dede;
            color: #a94442;
            border: 1px solid #ebccd1;
        }
    </style>
</head>
<body>
    <div class="container">
        <% if(success) { %>
            <div class="message-box success">
                <h2>Password Updated Successfully!</h2>
                <p>You will be redirected to your profile page shortly...</p>
                <script>
                    setTimeout(function() {
                        window.location.href = "profile_doctor.jsp";
                    }, 3000);
                </script>
            </div>
        <% } else { %>
            <div class="message-box error">
                <h2>Password Update Failed</h2>
                <p><%= errorMessage %></p>
                <p><a href="javascript:history.back()" class="btn btn-default">Go Back</a></p>
            </div>
        <% } %>
    </div>
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>