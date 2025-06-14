```jsp
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%
    response.setHeader("cache-control", "no-cache, no-store, must-revalidate");
    String emaill = (String) session.getAttribute("email");
    String namee = (String) session.getAttribute("name");
    if (emaill == null || namee == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Connection c = (Connection) application.getAttribute("connection");
    if (c == null) {
        out.println("<script>alert('Error: Database connection is null.'); window.location='receptionist.jsp';</script>");
        return;
    }

    String pname = request.getParameter("pname");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String gender = request.getParameter("gender");
    String ageStr = request.getParameter("age");
    String dobStr = request.getParameter("dob");
    String bgroup = request.getParameter("bgroup");
    String street = request.getParameter("street");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String country = request.getParameter("country");
    String pincode = request.getParameter("pincode");
    String medicalHistory = request.getParameter("medical_history");
    String reason = request.getParameter("reason");
    String doctorIdStr = request.getParameter("doctor_id");
    String conditionDetails = request.getParameter("condition_details");

    // Input validation
    if (pname == null || email == null || phone == null || gender == null || ageStr == null ||
        dobStr == null || bgroup == null || street == null || area == null || city == null ||
        state == null || country == null || pincode == null || reason == null || doctorIdStr == null ||
        pname.trim().isEmpty() || email.trim().isEmpty() || phone.trim().isEmpty() ||
        gender.trim().isEmpty() || ageStr.trim().isEmpty() || dobStr.trim().isEmpty() ||
        bgroup.trim().isEmpty() || street.trim().isEmpty() || area.trim().isEmpty() ||
        city.trim().isEmpty() || state.trim().isEmpty() || country.trim().isEmpty() ||
        pincode.trim().isEmpty() || reason.trim().isEmpty() || doctorIdStr.trim().isEmpty()) {
        out.println("<script>alert('Error: All required fields must be filled.'); window.location='receptionist.jsp?status=error';</script>");
        return;
    }

    PreparedStatement psPatient = null;
    PreparedStatement psCase = null;
    ResultSet rs = null;
    boolean success = false;

    try {
        c.setAutoCommit(false); // Start transaction

        // Parse numeric inputs
        int age = Integer.parseInt(ageStr);
        int doctorId = Integer.parseInt(doctorIdStr);

        // Validate phone and pincode
        if (!phone.matches("\\d{10}")) {
            throw new Exception("Invalid phone number. Must be 10 digits.");
        }
        if (!pincode.matches("\\d{6}")) {
            throw new Exception("Invalid pincode. Must be 6 digits.");
        }

        // Validate DOB
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        sdf.setLenient(false);
        java.util.Date dobUtil = sdf.parse(dobStr);
        java.sql.Date dob = new java.sql.Date(dobUtil.getTime());

        // Validate age against DOB
        java.util.Calendar dobCal = java.util.Calendar.getInstance();
        dobCal.setTime(dob);
        java.util.Calendar now = java.util.Calendar.getInstance();
        int calculatedAge = now.get(java.util.Calendar.YEAR) - dobCal.get(java.util.Calendar.YEAR);
        if (now.get(java.util.Calendar.DAY_OF_YEAR) < dobCal.get(java.util.Calendar.DAY_OF_YEAR)) {
            calculatedAge--;
        }
        if (age != calculatedAge) {
            throw new Exception("Age does not match Date of Birth.");
        }

        // Insert into patient_info (excluding PASSWORD)
        String sqlPatient = "INSERT INTO patient_info (PNAME, GENDER, AGE, DOB, BGROUP, PHONE, EMAIL, STREET, AREA, CITY, STATE, COUNTRY, PINCODE, MEDICAL_HISTORY) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        psPatient = c.prepareStatement(sqlPatient, Statement.RETURN_GENERATED_KEYS);
        psPatient.setString(1, pname);
        psPatient.setString(2, gender);
        psPatient.setInt(3, age);
        psPatient.setDate(4, dob);
        psPatient.setString(5, bgroup);
        psPatient.setString(6, phone);
        psPatient.setString(7, email);
        psPatient.setString(8, street);
        psPatient.setString(9, area);
        psPatient.setString(10, city);
        psPatient.setString(11, state);
        psPatient.setString(12, country);
        psPatient.setString(13, pincode);
        psPatient.setString(14, medicalHistory != null && !medicalHistory.trim().isEmpty() ? medicalHistory.trim().replaceAll("[\\r\\n]+", " ") : null);
        int rowsPatient = psPatient.executeUpdate();

        if (rowsPatient > 0) {
            // Get generated patient ID
            rs = psPatient.getGeneratedKeys();
            if (rs.next()) {
                int patientId = rs.getInt(1);
                // Insert into case_master
                String sqlCase = "INSERT INTO case_master (CASE_DATE, PATIENT_ID, DOCTOR_ID, REASON, CONDITION_DETAILS) VALUES (CURDATE(), ?, ?, ?, ?)";
                psCase = c.prepareStatement(sqlCase);
                psCase.setInt(1, patientId);
                psCase.setInt(2, doctorId);
                psCase.setString(3, reason.trim());
                psCase.setString(4, conditionDetails != null && !conditionDetails.trim().isEmpty() ? conditionDetails.trim().replaceAll("[\\r\\n]+", " ") : null);
                int rowsCase = psCase.executeUpdate();

                if (rowsCase > 0) {
                    c.commit(); // Commit transaction
                    success = true;
                    out.println("<script>alert('Patient and case added successfully!'); window.location='receptionist.jsp?status=success';</script>");
                }
            }
        }

        if (!success) {
            c.rollback(); // Rollback on failure
            out.println("<script>alert('Error: Failed to add patient or case.'); window.location='receptionist.jsp?status=error';</script>");
        }
    } catch (SQLException e) {
        try { c.rollback(); } catch (SQLException rollbackEx) {}
        out.println("<script>alert('Error: " + e.getMessage().replace("'", "\\'") + "'); window.location='receptionist.jsp?status=error';</script>");
    } catch (NumberFormatException e) {
        out.println("<script>alert('Error: Invalid age or doctor ID.'); window.location='receptionist.jsp?status=error';</script>");
    } catch (java.text.ParseException e) {
        out.println("<script>alert('Error: Invalid date of birth format.'); window.location='receptionist.jsp?status=error';</script>");
    } catch (Exception e) {
        out.println("<script>alert('Error: " + e.getMessage().replace("'", "\\'") + "'); window.location='receptionist.jsp?status=error';</script>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (psPatient != null) try { psPatient.close(); } catch (SQLException e) {}
        if (psCase != null) try { psCase.close(); } catch (SQLException e) {}
        try { c.setAutoCommit(true); } catch (SQLException e) {}
    }
%>
```