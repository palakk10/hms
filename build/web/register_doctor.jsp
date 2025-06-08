<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<%
    // Session validation and redirection
    response.setHeader("cache-control", "no-cache,no-store,must-revalidate");
    String emaill = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");
    
    if (emaill != null && role != null) {
        if (role.equals("admin")) {
            response.sendRedirect("admin.jsp");
            return;
        } else if (role.equals("patient")) {
            response.sendRedirect("patient_page.jsp");
            return;
        } else if (role.equals("doctor")) {
            response.sendRedirect("doctor_page.jsp");
            return;
        }
    }
%>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Register Doctor - Hospital Management System</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <style>
        .required-field::after {
            content: " *";
            color: red;
        }
        .header {
            margin-bottom: 20px;
        }
        .login {
            max-width: 900px;
            margin: 0 auto;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .logintitle {
            background-color: #337ab7;
            color: white;
            font-weight: bold;
        }
        .form-horizontal .control-label {
            text-align: right;
        }
        @media (max-width: 768px) {
            .form-horizontal .control-label {
                text-align: left;
            }
        }
    </style>
</head>
<body>

<div class="container-fluid">
    <!-- Header -->
    <div class="row">
        <nav class="navbar navbar-default navbar-fixed-top header">
            <div class="container-fluid">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="index.jsp">
                        <img alt="Brand" src="images/logo.png" class="logo">
                    </a>
                    <div class="navbar-text title"><p>Hospital Management System</p></div>
                </div>
                <div class="collapse navbar-collapse" id="navbar-collapse">
                    <ul class="nav navbar-nav navbar-right">
                        <li><a href="index.jsp" style="color:red;font-weight:bold">LOGIN</a></li>
                    </ul>
                </div>
            </div>
        </nav>
    </div>

    <!-- Doctor Registration Panel -->
    <div class="row" style="margin-top: 80px;">
        <div class="col-md-12">
            <div class="panel panel-default login">
                <div class="panel-heading logintitle">Register As Doctor</div>
                <div class="panel-body">
                    <form class="form-horizontal" role="form" action="register_doctor_validation.jsp" method="post" onsubmit="return validateForm()">

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Name:</label>
                            <div class="col-sm-7">
                                <input type="text" class="form-control" name="name" placeholder="Full Name" required 
                               >
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Email:</label>
                            <div class="col-sm-7">
                                <input type="email" class="form-control" name="email" placeholder="Email" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Password:</label>
                            <div class="col-sm-7">
                                <div class="input-group">
                                    <input type="password" class="form-control" name="password" id="password" 
                                           placeholder="Password (min 8 characters)" required minlength="8">
                                    <span class="input-group-btn">
                                        <button class="btn btn-default" type="button" onclick="togglePassword()">Show</button>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Phone:</label>
                            <div class="col-sm-7">
                                <input type="tel" class="form-control" name="phone" placeholder="Phone Number" 
                                       pattern="[0-9]{10,15}" title="10-15 digit phone number" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Department:</label>
                            <div class="col-sm-7">
                                <select class="form-control" name="dept_id" required>
                                    <option value="" disabled selected>Select Department</option>
                                    <%
                                        Connection con = null;
                                        Statement st = null;
                                        ResultSet rs = null;
                                        try {
                                            con = (Connection)application.getAttribute("connection");
                                            if (con != null && !con.isClosed()) {
                                                st = con.createStatement();
                                                rs = st.executeQuery("SELECT ID, NAME FROM department ORDER BY NAME");
                                                while(rs.next()) {
                                                    out.println("<option value='" + rs.getInt("ID") + "'>" + rs.getString("NAME") + "</option>");
                                                }
                                            } else {
                                                out.println("<option disabled>Database connection error</option>");
                                            }
                                        } catch(Exception e) {
                                            out.println("<option disabled>Error loading departments</option>");
                                            e.printStackTrace();
                                        } finally {
                                            try { if (rs != null) rs.close(); } catch (Exception e) {}
                                            try { if (st != null) st.close(); } catch (Exception e) {}
                                        }
                                    %>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Street:</label>
                            <div class="col-sm-7">
                                <input type="text" class="form-control" name="street" placeholder="Street" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label">Area:</label>
                            <div class="col-sm-7">
                                <input type="text" class="form-control" name="area" placeholder="Area">
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">City:</label>
                            <div class="col-sm-7">
                                <input type="text" class="form-control" name="city" placeholder="City" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">State:</label>
                            <div class="col-sm-7">
                                <input type="text" class="form-control" name="state" placeholder="State" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Country:</label>
                            <div class="col-sm-7">
                                <input type="text" class="form-control" name="country" placeholder="Country" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Pincode:</label>
                            <div class="col-sm-7">
                                <input type="text" class="form-control" name="pincode" placeholder="Pincode" 
                                       pattern="[0-9]{6}" title="6 digit pincode" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Gender:</label>
                            <div class="col-sm-7">
                                <select class="form-control" name="gender" required>
                                    <option value="" disabled selected>Select Gender</option>
                                    <option value="Male">Male</option>
                                    <option value="Female">Female</option>
                                    <option value="Other">Other</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-3 control-label required-field">Age:</label>
                            <div class="col-sm-7">
                                <input type="number" class="form-control" name="age" placeholder="Age" 
                                       min="22" max="70" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-sm-offset-3 col-sm-7">
                                <button type="submit" class="btn btn-primary btn-block">Register As Doctor</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function togglePassword() {
        const pwdField = document.getElementById("password");
        const btn = event.currentTarget;
        if (pwdField.type === "password") {
            pwdField.type = "text";
            btn.textContent = "Hide";
        } else {
            pwdField.type = "password";
            btn.textContent = "Show";
        }
    }

    function validateForm() {
        // Additional client-side validation if needed
        return true;
    }
</script>

<script src="js/jquery.js"></script>
<script src="js/bootstrap.min.js"></script>
</body>
</html>