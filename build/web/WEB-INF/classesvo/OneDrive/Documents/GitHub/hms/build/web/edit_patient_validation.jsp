<%@page import="java.sql.*, java.text.SimpleDateFormat, java.util.Date"%>
<%!
    // Method to validate email uniqueness (excluding the current patient)
    boolean isEmailUnique(Connection conn, String email, int patientId) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement("SELECT ID FROM patient_info WHERE EMAIL = ? AND ID != ?");
            ps.setString(1, email);
            ps.setInt(2, patientId);
            rs = ps.executeQuery();
            return !rs.next();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
            if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        }
    }

    // Method to calculate age from DOB
    int calculateAge(Date dob) {
        if (dob == null) return -1;
        Date today = new Date();
        long diffInMillies = today.getTime() - dob.getTime();
        return (int) (diffInMillies / (1000L * 60 * 60 * 24 * 365));
    }
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Connection conn = (Connection) application.getAttribute("connection");
    if (conn == null || conn.isClosed()) {
        session.setAttribute("error-message", "Database connection is unavailable.");
        response.sendRedirect("patients.jsp");
        return;
    }

    String patientIdStr = request.getParameter("patientid");
    String name = request.getParameter("pname");
    String gender = request.getParameter("gender");
    String ageStr = request.getParameter("age");
    String dobStr = request.getParameter("dob");
    String bloodGroup = request.getParameter("bgroup");
    String phone = request.getParameter("phone");
    String patientEmail = request.getParameter("email");
    String street = request.getParameter("street");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String country = request.getParameter("country");
    String pincode = request.getParameter("pincode");
    String medicalHistory = request.getParameter("medical_history");

    // Validate inputs
    if (patientIdStr == null || name == null || name.trim().isEmpty() || gender == null || ageStr == null || bloodGroup == null || phone == null || patientEmail == null) {
        session.setAttribute("error-message", "All required fields must be filled.");
        response.sendRedirect("patients.jsp");
        return;
    }

    int patientId;
    int age;
    try {
        patientId = Integer.parseInt(patientIdStr);
        age = Integer.parseInt(ageStr);
        if (age < 0 || age > 150) {
            session.setAttribute("error-message", "Invalid age. Must be between 0 and 150.");
            response.sendRedirect("patients.jsp");
            return;
        }
    } catch (NumberFormatException e) {
        session.setAttribute("error-message", "Invalid patient ID or age format.");
        response.sendRedirect("patients.jsp");
        return;
    }

    // Validate email format
    String emailRegex = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$";
    if (!patientEmail.matches(emailRegex)) {
        session.setAttribute("error-message", "Invalid email format.");
        response.sendRedirect("patients.jsp");
        return;
    }

    // Check email uniqueness
    try {
        if (!isEmailUnique(conn, patientEmail, patientId)) {
            session.setAttribute("error-message", "Email is already in use by another patient.");
            response.sendRedirect("patients.jsp");
            return;
        }
    } catch (SQLException e) {
        session.setAttribute("error-message", "Database error while checking email: " + e.getMessage());
        response.sendRedirect("patients.jsp");
        return;
    }

    // Validate phone format (10 digits)
    if (!phone.matches("\\d{10}")) {
        session.setAttribute("error-message", "Phone number must be 10 digits.");
        response.sendRedirect("patients.jsp");
        return;
    }

    // Validate pincode (6 digits, optional)
    if (pincode != null && !pincode.trim().isEmpty() && !pincode.matches("\\d{6}")) {
        session.setAttribute("error-message", "Pincode must be 6 digits.");
        response.sendRedirect("patients.jsp");
        return;
    }

    // Validate DOB and age consistency
    Date dob = null;
    if (dobStr != null && !dobStr.trim().isEmpty()) {
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            sdf.setLenient(false);
            dob = sdf.parse(dobStr);
            if (dob.after(new Date())) {
                session.setAttribute("error-message", "Date of birth cannot be in the future.");
                response.sendRedirect("patients.jsp");
                return;
            }
            int calculatedAge = calculateAge(dob);
            if (Math.abs(calculatedAge - age) > 1) {
                session.setAttribute("error-message", "Age does not match date of birth.");
                response.sendRedirect("patients.jsp");
                return;
            }
        } catch (Exception e) {
            session.setAttribute("error-message", "Invalid date of birth format.");
            response.sendRedirect("patients.jsp");
            return;
        }
    }

    // Validate gender and blood group
    String[] validGenders = {"Male", "Female", "Other"};
    String[] validBloodGroups = {"A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"};
    boolean validGender = false;
    boolean validBloodGroup = false;
    for (String g : validGenders) {
        if (g.equals(gender)) {
            validGender = true;
            break;
        }
    }
    for (String bg : validBloodGroups) {
        if (bg.equals(bloodGroup)) {
            validBloodGroup = true;
            break;
        }
    }
    if (!validGender) {
        session.setAttribute("error-message", "Invalid gender selected.");
        response.sendRedirect("patients.jsp");
        return;
    }
    if (!validBloodGroup) {
        session.setAttribute("error-message", "Invalid blood group selected.");
        response.sendRedirect("patients.jsp");
        return;
    }

    // Update patient information
    PreparedStatement ps = null;
    try {
        String sql = "UPDATE patient_info SET PNAME = ?, GENDER = ?, AGE = ?, DOB = ?, BGROUP = ?, PHONE = ?, EMAIL = ?, STREET = ?, AREA = ?, CITY = ?, STATE = ?, COUNTRY = ?, PINCODE = ?, MEDICAL_HISTORY = ? WHERE ID = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, name.trim());
        ps.setString(2, gender);
        ps.setInt(3, age);
        ps.setString(4, dobStr != null && !dobStr.trim().isEmpty() ? dobStr : null);
        ps.setString(5, bloodGroup);
        ps.setString(6, phone);
        ps.setString(7, patientEmail);
        ps.setString(8, street != null ? street.trim() : null);
        ps.setString(9, area != null ? area.trim() : null);
        ps.setString(10, city != null ? city.trim() : null);
        ps.setString(11, state != null ? state.trim() : null);
        ps.setString(12, country != null ? country.trim() : null);
        ps.setString(13, pincode != null && !pincode.trim().isEmpty() ? pincode : null);
        ps.setString(14, medicalHistory != null ? medicalHistory.trim() : null);
        ps.setInt(15, patientId);

        int rowsUpdated = ps.executeUpdate();
        if (rowsUpdated > 0) {
            session.setAttribute("success-message", "Patient updated successfully.");
        } else {
            session.setAttribute("error-message", "Patient not found or no changes made.");
        }
    } catch (SQLException e) {
        session.setAttribute("error-message", "Database error: " + e.getMessage());
    } finally {
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
    }

    response.sendRedirect("patients.jsp");
%>