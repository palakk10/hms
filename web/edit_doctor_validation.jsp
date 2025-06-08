<%@page import="java.sql.*"%>
<%
    // Get parameters from request
    String doctorId = request.getParameter("doctorid");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String deptId = request.getParameter("dept_id");
    String street = request.getParameter("street");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String country = request.getParameter("country");
    String pincode = request.getParameter("pincode");
    String gender = request.getParameter("gender");
    String age = request.getParameter("age");

    Connection con = null;
    PreparedStatement ps = null;
    String errorMessage = null;
    boolean success = false;
    
    try {
        con = (Connection)application.getAttribute("connection");
        ps = con.prepareStatement(
            "UPDATE doctor_info SET " +
            "NAME=?, EMAIL=?, PHONE=?, DEPT_ID=?, " +
            "STREET=?, AREA=?, CITY=?, STATE=?, COUNTRY=?, PINCODE=?, " +
            "GENDER=?, AGE=? " +
            "WHERE ID=?");
        
        ps.setString(1, name);
        ps.setString(2, email);
        ps.setString(3, phone);
        ps.setInt(4, Integer.parseInt(deptId));
        ps.setString(5, street);
        ps.setString(6, area != null ? area : "");
        ps.setString(7, city);
        ps.setString(8, state);
        ps.setString(9, country);
        ps.setString(10, pincode);
        ps.setString(11, gender);
        ps.setInt(12, Integer.parseInt(age));
        ps.setInt(13, Integer.parseInt(doctorId));
        
        int i = ps.executeUpdate();
        success = i > 0;
        
        if (!success) {
            errorMessage = "Update failed. Please try again.";
        }
    } catch(SQLException e) {
        errorMessage = "Database error: " + e.getMessage();
        e.printStackTrace();
    } catch(NumberFormatException e) {
        errorMessage = "Invalid numeric value in form fields.";
    } finally {
        try { if(ps != null) ps.close(); } catch(Exception e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Update Doctor Details</title>
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
                <h2>Details Updated Successfully!</h2>
                <p>You will be redirected to your profile page shortly...</p>
                <script>
                    setTimeout(function() {
                        window.location.href = "doctor_page.jsp";
                    }, 3000);
                </script>
            </div>
        <% } else { %>
            <div class="message-box error">
                <h2>Update Failed</h2>
                <p><%= errorMessage %></p>
                <p><a href="javascript:history.back()" class="btn btn-default">Go Back and Try Again</a></p>
            </div>
        <% } %>
    </div>
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>