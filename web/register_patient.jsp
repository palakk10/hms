<!DOCTYPE html>
<%
    response.setHeader("cache-control", "no-cache,no-store,must-revalidate");
    String emaill = (String) session.getAttribute("email");
    String role = (String) session.getAttribute("role");
    if (emaill != null && role != null && role.equals("admin"))
        response.sendRedirect("admin.jsp");
    else if (emaill != null && role != null && role.equals("patient"))
        response.sendRedirect("patient_page.jsp");
%>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Online Hospital Management System</title>
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
                    <a class="navbar-brand logo" href="#">
                        <img alt="Brand" src="images/logo.png">
                    </a>
                    <div class="navbar-text title">
                        <p>Hospital Management System</p>
                    </div>
                </div>
            </div>
        </nav>
        <a href="index.jsp" style="text-align:center;font-weight:bold;font-size:120%;padding: 0 2%;color:red">LOGIN</a>
    </div>

    <!-- Registration Form -->
    <div class="row" style="margin-top: 100px;">
        <div class="col-md-12">
            <div class="panel panel-default login">
                <div class="panel-heading logintitle">Register As Patient</div>
                <div class="panel-body">
                    <form class="form-horizontal center-block" role="form" action="register_patient_validation.jsp" method="post">

                        <!-- Patient Id removed: DB auto-generates -->

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Name</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="patientname" placeholder="Name" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Email</label>
                            <div class="col-sm-10">
                                <input type="email" class="form-control" name="email" placeholder="Email" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Password</label>
                            <div class="col-sm-10">
                                <input type="password" class="form-control" name="pwd" placeholder="Password" required>
                            </div>
                        </div>

                        <!-- Address Fields -->
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Street</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="street" placeholder="Street" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Area</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="area" placeholder="Area" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">City</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="city" placeholder="City" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">State</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="state" placeholder="State" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Country</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="country" placeholder="Country" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="col-sm-2 control-label">Pincode</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="pincode" placeholder="Pincode" required>
                            </div>
                        </div>

                        <!-- Contact & Medical -->
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Phone</label>
                            <div class="col-sm-10">
                                <input type="text" class="form-control" name="phone" placeholder="Phone No." required>
                            </div>
                        </div>

                        <!-- Reason of Visit dropdown with scrollbar on overflow -->
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Reason Of Visit</label>
                            <div class="col-sm-10">
                                <select name="rov" class="form-control" required>
                                    <option value="">-- Select Reason --</option>
                                    <option>Fever</option>
                                    <option>Cold / Cough</option>
                                    <option>Headache / Migraine</option>
                                    <option>Chest Pain</option>
                                    <option>Shortness of Breath / Difficulty Breathing</option>
                                    <option>Abdominal Pain / Stomach Ache</option>
                                    <option>Back Pain</option>
                                    <option>Joint Pain / Arthritis</option>
                                    <option>Skin Rash / Allergies</option>
                                    <option>Diarrhea / Vomiting</option>
                                    <option>Fatigue / Weakness</option>
                                    <option>High Blood Pressure (Hypertension)</option>
                                    <option>Diabetes Checkup / High Blood Sugar</option>
                                    <option>Infection (e.g. Urinary Tract Infection, Respiratory Infection)</option>
                                    <option>Injury / Trauma (e.g. fractures, cuts, bruises)</option>
                                    <option>Pregnancy Checkup / Antenatal Care</option>
                                    <option>Mental Health Issues (Anxiety, Depression)</option>
                                    <option>Vision Problems / Eye Pain</option>
                                    <option>Earache / Hearing Problems</option>
                                    <option>Dental Pain</option>
                                    <option>Follow-up / Routine Checkup</option>
                                    <option>Medication Refill</option>
                                    <option>Allergy Reaction</option>
                                    <option>Asthma Attack</option>
                                    <option>Skin Infection / Boils</option>
                                    <option>Weight Loss / Gain</option>
                                    <option>Blood Disorders (Anemia, Bleeding)</option>
                                    <option>Palpitations / Irregular Heartbeat</option>
                                    <option>Neurological Problems (Seizures, Dizziness)</option>
                                    <option>Swelling (Edema)</option>
                                    <option>Urinary Problems / Painful Urination</option>
                                    <option>Sore Throat</option>
                                    <option>Cold Sores / Mouth Ulcers</option>
                                    <option>Chest Infection / Pneumonia</option>
                                    <option>Flu / Influenza</option>
                                    <option>COVID-19 Symptoms</option>
                                    <option>Vaccination</option>
                                    <option>Physical Examination / Health Screening</option>
                                </select>
                            </div>
                        </div>

                        <!-- Textarea for detailed description -->
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Describe Your Problem</label>
                            <div class="col-sm-10">
                                <textarea name="problem_description" class="form-control" rows="4" placeholder="Describe what is happening to you..." required></textarea>
                            </div>
                        </div>

                        <!-- Gender -->
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Gender</label>
                            <div class="col-sm-2">
                                <select class="form-control" name="gender" required>
                                    <option value="">Select Gender</option>
                                    <option>Male</option>
                                    <option>Female</option>
                                </select>
                            </div>
                        </div>

                        <!-- Age -->
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Age</label>
                            <div class="col-sm-10">
                                <input type="number" min="0" class="form-control" name="age" placeholder="Age" required>
                            </div>
                        </div>

                        <!-- Blood Group -->
                        <div class="form-group">
                            <label class="col-sm-2 control-label">Blood Group</label>
                            <div class="col-sm-2">
                                <select class="form-control" name="bgroup" required>
                                    <option value="">Select Blood Group</option>
                                    <option>A+</option>
                                    <option>A-</option>
                                    <option>B+</option>
                                    <option>B-</option>
                                    <option>AB+</option>
                                    <option>AB-</option>
                                    <option>O+</option>
                                    <option>O-</option>
                                </select>
                            </div>
                        </div>

                        <!-- Submit -->
                        <div class="form-group">
                            <div class="col-sm-7 col-sm-offset-2" style="margin-left: 40%;">
                                <button type="submit" class="btn btn-primary">Register As Patient Now</button>
                            </div>
                        </div>

                        <br><br><br>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="js/bootstrap.min.js"></script>
</body>
</html>
