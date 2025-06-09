<%@ page import="java.sql.*" %>
<%
    // Initialize variables
    String errorMessage = null;
    boolean success = false;
    
    // Read parameters from request with null checks
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String pwd = request.getParameter("password");
    String street = request.getParameter("street");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String country = request.getParameter("country");
    String pincode = request.getParameter("pincode");
    String phone = request.getParameter("phone");
    String gender = request.getParameter("gender");
    String ageStr = request.getParameter("age");
    String deptIdStr = request.getParameter("dept_id");

    // Validate required fields
    if (name == null || name.trim().isEmpty() ||
        email == null || email.trim().isEmpty() ||
        pwd == null || pwd.trim().isEmpty()) {
        errorMessage = "Name, Email and Password are required fields.";
    } else {
        // Convert numeric params safely
        int age = 0;
        int deptId = 0;
        
        try {
            age = (ageStr != null && !ageStr.isEmpty()) ? Integer.parseInt(ageStr) : 0;
            deptId = (deptIdStr != null && !deptIdStr.isEmpty()) ? Integer.parseInt(deptIdStr) : 0;
            
            if (deptId <= 0) {
                errorMessage = "Please select a valid department.";
            }
        } catch (NumberFormatException e) {
            errorMessage = "Invalid age or department ID format.";
        }

        // Proceed if no validation errors
        if (errorMessage == null) {
            Connection con = null;
            PreparedStatement ps = null;
            PreparedStatement checkEmail = null;
            ResultSet rs = null;

            try {
                // Get connection from application scope
                con = (Connection) application.getAttribute("connection");
                if (con == null || con.isClosed()) {
                    errorMessage = "Database connection not available.";
                } else {
                    // Check if email already exists
                    checkEmail = con.prepareStatement("SELECT 1 FROM doctor_info WHERE EMAIL = ?");
                    checkEmail.setString(1, email);
                    rs = checkEmail.executeQuery();
                    
                    if (rs.next()) {
                        errorMessage = "This email is already registered.";
                    } else {
                        // Insert new doctor
                        ps = con.prepareStatement(
                            "INSERT INTO doctor_info (NAME, EMAIL, PASSWORD, STREET, AREA, CITY, STATE, COUNTRY, " +
                            "PINCODE, PHONE, DEPT_ID, GENDER, AGE) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                        
                        ps.setString(1, name);
                        ps.setString(2, email);
                        ps.setString(3, pwd);
                        ps.setString(4, street != null ? street : "");
                        ps.setString(5, area != null ? area : "");
                        ps.setString(6, city != null ? city : "");
                        ps.setString(7, state != null ? state : "");
                        ps.setString(8, country != null ? country : "");
                        ps.setString(9, pincode != null ? pincode : "");
                        ps.setString(10, phone != null ? phone : "");
                        ps.setInt(11, deptId);
                        ps.setString(12, gender != null ? gender : "");
                        ps.setInt(13, age);

                        int i = ps.executeUpdate();
                        success = i > 0;
                        
                        if (!success) {
                            errorMessage = "Registration failed. Please try again.";
                        }
                    }
                }
            } catch(SQLException ex) {
                errorMessage = "Database error: " + ex.getMessage();
                ex.printStackTrace();
            } finally {
                // Close resources
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (checkEmail != null) checkEmail.close(); } catch (Exception e) {}
                try { if (ps != null) ps.close(); } catch (Exception e) {}
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Doctor Registration</title>
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
        <% if (success) { %>
            <div class="message-box success">
                <h2>Doctor Registration Successful!</h2>
                <p>You will be redirected to the login page shortly...</p>
                <script>
                    setTimeout(function() {
                        window.location.href = "index.jsp";
                    }, 3000);
                </script>
            </div>
        <% } else { %>
            <div class="message-box error">
                <h2>Registration Failed</h2>
                <p><%= errorMessage != null ? errorMessage : "Unknown error occurred" %></p>
                <p><a href="javascript:history.back()" class="btn btn-default">Go back and try again</a></p>
            </div>
        <% } %>
    </div>
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>