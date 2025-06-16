```jsp
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Billing</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { padding-top: 60px; }
        .container { max-width: 600px; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="panel panel-default">
            <div class="panel-heading">Add Billing Information</div>
            <div class="panel-body">
                <form action="add_billing_validation.jsp" method="post" class="form-horizontal">
                    <div class="form-group">
                        <label class="col-sm-4 control-label">Patient ID</label>
                        <div class="col-sm-8">
                            <input type="number" name="patient_id" class="form-control" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label">Patient Name</label>
                        <div class="col-sm-8">
                            <input type="text" name="patient_name" class="form-control" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label">Case ID</label>
                        <div class="col-sm-8">
                            <input type="number" name="case_id" class="form-control" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label">Entry Date</label>
                        <div class="col-sm-8">
                            <input type="date" name="entry_date" class="form-control" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label">Discharge Date</label>
                        <div class="col-sm-8">
                            <input type="date" name="dis_date" class="form-control">
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-4 control-label">Other Charges (₹)</label>
                        <div class="col-sm-8">
                            <input type="number" name="other_charge" class="form-control" min="0" step="0.01" value="0.00">
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-sm-offset-4 col-sm-8">
                            <button type="submit" class="btn btn-primary">Add Bill</button>
                            <a href="patients.jsp" class="btn btn-default">Cancel</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
```