<%@page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Prevent caching
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    // Check session
    String email = (String) session.getAttribute("email");
    String name = (String) session.getAttribute("name");
    if (email == null || name == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Initialize variables
    Connection conn = null;
    PreparedStatement ps = null;
    String message = null;

    try {
        // Get database connection
        conn = (Connection) application.getAttribute("connection");
        if (conn == null) {
            message = "Error: Database connection is unavailable.";
            throw new SQLException("Connection is null");
        }

        // Get form parameters
        String patientName = request.getParameter("name") != null ? request.getParameter("name").trim() : "";
        String gender = request.getParameter("gender");
        String ageStr = request.getParameter("age");
        String dobStr = request.getParameter("dob");
        String bloodGroup = request.getParameter("bgroup");
        String phone = request.getParameter("phone") != null ? request.getParameter("phone").trim() : "";
        String patientEmail = request.getParameter("email") != null ? request.getParameter("email").trim() : "";
        String street = request.getParameter("street") != null ? request.getParameter("street").trim() : "";
        String area = request.getParameter("area") != null ? request.getParameter("area").trim() : "";
        String city = request.getParameter("city") != null ? request.getParameter("city").trim() : "";
        String state = request.getParameter("state") != null ? request.getParameter("state").trim() : "";
        String country = request.getParameter("country") != null ? request.getParameter("country").trim() : "";
        String pincode = request.getParameter("pincode") != null ? request.getParameter("pincode").trim() : "";
        String medicalHistory = request.getParameter("medical_history") != null ? request.getParameter("medical_history").trim() : "";

        // Validate required fields
        if (patientName.isEmpty() || patientEmail.isEmpty() || phone.isEmpty() || gender == null || ageStr == null || bloodGroup == null) {
            message = "Error: Name, email, phone, gender, age, and blood group are required.";
            throw new IllegalArgumentException("Required fields missing");
        }

        // Validate email format
        if (!patientEmail.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
            message = "Error: Invalid email format.";
            throw new IllegalArgumentException("Invalid email");
        }

        // Validate phone (10-15 digits)
        if (!phone.matches("\\d{10,15}")) {
            message = "Error: Phone number must be 10-15 digits.";
            throw new IllegalArgumentException("Invalid phone");
        }

        // Validate pincode (if provided)
        if (!pincode.isEmpty() && !pincode.matches("\\d{5,10}")) {
            message = "Error: Pincode must be 5-10 digits.";
            throw new IllegalArgumentException("Invalid pincode");
        }

        // Validate age
        int age = 0;
        try {
            age = Integer.parseInt(ageStr);
            if (age < 0 || age > 150) {
                message = "Error: Age must be between 0 and 150.";
                throw new IllegalArgumentException("Invalid age");
            }
        } catch (NumberFormatException e) {
            message = "Error: Age must be a valid number.";
            throw new IllegalArgumentException("Invalid age format");
        }

        // Validate DOB (if provided)
        java.sql.Date dob = null;
        if (dobStr != null && !dobStr.isEmpty()) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                sdf.setLenient(false);
                Date parsedDob = sdf.parse(dobStr);
                dob = new java.sql.Date(parsedDob.getTime());
                // Check if DOB is in the future
                if (dob.after(new Date())) {
                    message = "Error: Date of birth cannot be in the future.";
                    throw new IllegalArgumentException("Invalid DOB");
                }
                // Validate age against DOB
                long ageFromDob = (new Date().getTime() - parsedDob.getTime()) / (1000L * 60 * 60 * 24 * 365);
                if (Math.abs(age - ageFromDob) > 1) {
                    message = "Error: Age does not match date of birth.";
                    throw new IllegalArgumentException("Age-DOB mismatch");
                }
            } catch (java.text.ParseException e) {
                message = "Error: Invalid date of birth format.";
                throw new IllegalArgumentException("Invalid DOB format");
            }
        }

        // Validate gender and blood group
        if (!gender.matches("Male|Female|Other")) {
            message = "Error: Invalid gender.";
            throw new IllegalArgumentException("Invalid gender");
        }
        if (!bloodGroup.matches("A\\+|A-|B\\+|B-|AB\\+|AB-|O\\+|O-")) {
            message = "Error: Invalid blood group.";
            throw new IllegalArgumentException("Invalid blood group");
        }

        // Insert into patient_info
        String sql = "INSERT INTO patient_info (PNAME, GENDER, AGE, DOB, BGROUP, PHONE, EMAIL, STREET, AREA, CITY, STATE, COUNTRY, PINCODE, MEDICAL_HISTORY) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        ps = conn.prepareStatement(sql);
        ps.setString(1, patientName);
        ps.setString(2, gender);
        ps.setInt(3, age);
        ps.setDate(4, dob);
        ps.setString(5, bloodGroup);
        ps.setString(6, phone);
        ps.setString(7, patientEmail);
        ps.setString(8, street.isEmpty() ? null : street);
        ps.setString(9, area.isEmpty() ? null : area);
        ps.setString(10, city.isEmpty() ? null : city);
        ps.setString(11, state.isEmpty() ? null : state);
        ps.setString(12, country.isEmpty() ? null : country);
        ps.setString(13, pincode.isEmpty() ? null : pincode);
        ps.setString(14, medicalHistory.isEmpty() ? null : medicalHistory);

        // Execute insert
        int rows = ps.executeUpdate();
        if (rows > 0) {
            message = "Patient added successfully.";
        } else {
            message = "Error: Failed to add patient.";
        }

    } catch (SQLException e) {
        if (e.getSQLState().equals("23000") && e.getMessage().contains("EMAIL")) {
            message = "Error: Email '" + request.getParameter("email") + "' already exists.";
        } else {
            message = "Error: Database error - " + e.getMessage();
        }
    } catch (IllegalArgumentException e) {
        // Message already set in validation
    } catch (Exception e) {
        message = "Error: Unexpected error - " + e.getMessage();
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        // Do not close conn as it's application-scoped
    }

    // Set message and redirect
    session.setAttribute("patientMessage", message);
    response.sendRedirect("receptionist.jsp");
%>