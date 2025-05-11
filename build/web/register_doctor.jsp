<!DOCTYPE html>
<%
    response.setHeader("cache-control", "no-cache,no-store,must-revalidate");
    String emaill = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");
    if (emaill != null && role != null && role.equals("admin"))
        response.sendRedirect("admin.jsp");
    else if (emaill != null && role != null && role.equals("patient"))
        response.sendRedirect("pateint_page.jsp");
     else if (emaill != null && role != null && role.equals("doctor"))
        response.sendRedirect("doctor_page.jsp");
%>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Register Doctor - Hospital Management System</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
</head>
<body>

<div class="container-fluid">
    <!-- Header -->
    <div class="row navbar-fixed-top">
        <nav class="navbar navbar-default header">
            <div class="container-fluid">
                <div class="navbar-header">
                    <a class="navbar-brand logo" href="#"><img alt="Brand" src="images/logo.png"></a>
                    <div class="navbar-text title"><p>Hospital Management System<p></div>
                </div>
            </div>
        </nav>
        <a href="index.jsp" style="text-align:Center;font-weight:bold;font-size:120%;padding: 0 2%;color:red">LOGIN</a>
    </div>

    <!-- Doctor Registration Panel -->
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-default login">
                <div class="panel-heading logintitle">Register As Doctor</div>
                <div class="panel-body">
                    <form class="form-horizontal center-block" role="form" action="register_doctor_validation.jsp" method="post">

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Doctor Id:</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="doctorid" placeholder="Auto-generated" readonly>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Name:</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="name" placeholder="Full Name" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Email:</label>
                            <div class="col-sm-10">
                                <input type="email" class="form-control" name="email" placeholder="Email" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Password:</label>
                            <div class="col-sm-10">
                                <input type="password" class="form-control" name="password" placeholder="Password" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Phone:</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="phone" placeholder="Phone Number" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Specialization:</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="specialization" placeholder="E.g. Cardiologist, Neurologist..." required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Experience (in years):</label>
                            <div class="col-sm-10">
                                <input type="number" class="form-control" name="experience" placeholder="Years of experience" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Address:</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="address" placeholder="Address" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Gender:</label>
                            <div class="col-sm-2">
                                <select class="form-control" name="gender">
                                    <option>Male</option>
                                    <option>Female</option>
                                    <option>Other</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group">
                            <div class="col-sm-7 col-sm-offset-2" style="margin:0 0 0 40%">
                                <button type="submit" class="btn btn-primary">Register As Doctor Now</button>
                            </div>
                        </div>
                        <br><br><br>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    
    </div>
</div>

<script src="js/bootstrap.min.js"></script>
</body>
</html>
