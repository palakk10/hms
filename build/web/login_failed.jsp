<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login Failed</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
    <script src="js/jquery.js"></script>
    <script src="js/bootstrap.min.js"></script>
</head>
<body>
    <div class="container-fluid">
        <div class="row navbar-fixed-top">
            <nav class="navbar navbar-default header">
                <div class="container-fluid">
                    <div class="navbar-header">
                        <a class="navbar-brand logo" href="#">
                            <img alt="Brand" src="images/logo.png">
                        </a>
                        <div class="navbar-text title"><p>Hospital Management System</p></div>
                    </div>
                </div>
            </nav>
        </div>
        <div class="row">
            <div class="col-md-12">
                <div class="panel panel-default login">
                    <div class="panel-heading logintitle">Login</div>
                    <div class="panel-body">
                        <div class="alert alert-danger">
                            Login Failed. Check Username or Password.
                        </div>
                        <form class="form-horizontal center-block" role="form" action="login_validation.jsp" method="post">
                            <div class="input-group input-group-lg">
                                <span class="input-group-addon" id="sizing-addon1"><span class="glyphicon glyphicon-user" aria-hidden="true"></span></span>
                                <select class="form-control" name="userrole" required>
                                    <option selected="selected" disabled>Select User</option>
                                    <option value="admin">Admin</option>
                                    <option value="doctor">Doctor</option>
                                    <option value="receptionist">Receptionist</option>
                                </select>
                            </div>
                            <br/>
                            <div class="input-group input-group-lg">
                                <span class="input-group-addon" id="sizing-addon1"><span class="glyphicon glyphicon-envelope" aria-hidden="true"></span></span>
                                <input type="email" class="form-control" name="email" placeholder="example@gmail.com" required aria-describedby="sizing-addon1">
                            </div>
                            <br/>
                            <div class="input-group input-group-lg">
                                <span class="input-group-addon" id="sizing-addon1"><span class="glyphicon glyphicon-lock" aria-hidden="true"></span></span>
                                <input type="password" name="password" class="form-control" placeholder="Password" required aria-describedby="sizing-addon1">
                            </div>
                            <br/>
                            <div class="col-sm-7 col-sm-offset-2">
                                <button type="submit" class="btn btn-primary btn-block btn-lg">Login</button>
                            </div>
                        </form>
                        <div style="text-align:center;font-weight:bold;font-size:120%;padding: 0 2%">
                            <a href="register_doctor.jsp">Register As Doctor</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="row marginreset">
            <div class="col-md-12 footer">
                <p class="developer">Designed and Developed By # #</p>
                <p>Copyrights © Hospital Management System 2017-18. All rights reserved.</p>
            </div>
        </div>
    </div>
</body>
</html>