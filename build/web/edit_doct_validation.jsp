<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
    <%
        Connection con = null;
        PreparedStatement ps = null;
        String errorMessage = null;
        boolean success = false;

        try {
            // Get database connection
            con = (Connection) application.getAttribute("connection");
            if (con == null) {
                throw new Exception("Database connection not available.");
            }
            con.setAutoCommit(false); // Begin transaction

            // Get form parameters
            String doctorIdStr = request.getParameter("doctorid");
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String deptIdStr = request.getParameter("dept_id");
            String street = request.getParameter("street");
            String area = request.getParameter("area");
            String city = request.getParameter("city");
            String state = request.getParameter("state");
            String country = request.getParameter("country");
            String pincode = request.getParameter("pincode");
            String gender = request.getParameter("gender");
            String ageStr = request.getParameter("age");

            // Server-side validation
            if (doctorIdStr == null || doctorIdStr.trim().isEmpty()) {
                throw new Exception("Doctor ID is required.");
            }
            int doctorId;
            try {
                doctorId = Integer.parseInt(doctorIdStr);
            } catch (NumberFormatException e) {
                throw new Exception("Invalid Doctor ID format.");
            }

            if (name == null || name.trim().isEmpty()) {
                throw new Exception("Name is required.");
            }
            if (email == null || !email.matches("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")) {
                throw new Exception("Invalid email format.");
            }
            if (phone == null || !phone.matches("\\d{10}")) {
                throw new Exception("Phone number must be 10 digits.");
            }
            int deptId;
            try {
                deptId = Integer.parseInt(deptIdStr);
                // Verify dept_id exists in department table
                PreparedStatement deptCheck = con.prepareStatement("SELECT ID FROM department WHERE ID = ?");
                deptCheck.setInt(1, deptId);
                ResultSet deptRs = deptCheck.executeQuery();
                if (!deptRs.next()) {
                    throw new Exception("Invalid department ID.");
                }
                deptCheck.close();
                deptRs.close();
            } catch (NumberFormatException e) {
                throw new Exception("Invalid department ID format.");
            }
            if (gender == null || !gender.matches("Male|Female|Other")) {
                throw new Exception("Invalid gender selection.");
            }
            int age;
            try {
                if (ageStr == null || ageStr.trim().isEmpty()) {
                    throw new Exception("Age is required.");
                }
                age = Integer.parseInt(ageStr);
                if (age < 22 || age > 70) {
                    throw new Exception("Age must be between 22 and 70.");
                }
            } catch (NumberFormatException e) {
                throw new Exception("Invalid age format. Please enter a numeric value.");
            }
            if (pincode == null || !pincode.matches("\\d{6}")) {
                throw new Exception("Pincode must be 6 digits.");
            }
            if (street == null || street.trim().isEmpty() || city == null || city.trim().isEmpty() ||
                state == null || state.trim().isEmpty() || country == null || country.trim().isEmpty()) {
                throw new Exception("Street, city, state, and country are required.");
            }

            // Prepare SQL update statement
            String sql = "UPDATE doctor_info SET NAME=?, EMAIL=?, PHONE=?, DEPT_ID=?, STREET=?, AREA=?, CITY=?, STATE=?, COUNTRY=?, PINCODE=?, GENDER=?, AGE=? WHERE ID=?";
            ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setInt(4, deptId);
            ps.setString(5, street);
            ps.setString(6, area != null && !area.trim().isEmpty() ? area : null);
            ps.setString(7, city);
            ps.setString(8, state);
            ps.setString(9, country);
            ps.setString(10, pincode);
            ps.setString(11, gender);
            ps.setInt(12, age);
            ps.setInt(13, doctorId);

            // Execute update
            int rowsAffected = ps.executeUpdate();
            success = rowsAffected > 0;
            if (!success) {
                errorMessage = "No doctor found with the given ID.";
            }

            con.commit();
        } catch (SQLException e) {
            errorMessage = "Database error: " + e.getMessage();
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            errorMessage = "Error: " + e.getMessage();
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
    <div class="container">
        <% if (success) { %>
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
                <p><%= errorMessage != null ? errorMessage : "Unknown error occurred." %></p>
                <p><a href="javascript:history.back()" class="btn btn-default">Go Back and Try Again</a></p>
            </div>
        <% } %>
    </div>
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
</body>
</html>