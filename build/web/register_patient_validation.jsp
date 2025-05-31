<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    String pname = request.getParameter("patientname");
    String email = request.getParameter("email");
    String pwd = request.getParameter("pwd");
    String phone = request.getParameter("phone");
    String rov = request.getParameter("rov");
    String gender = request.getParameter("gender");
    String age = request.getParameter("age");
    String bgroup = request.getParameter("bgroup");
    String street = request.getParameter("street");
    String area = request.getParameter("area");
    String city = request.getParameter("city");
    String state = request.getParameter("state");
    String country = request.getParameter("country");
    String pincode = request.getParameter("pincode");

    // Room, Bed, and Doctor will be assigned by admin later, so set as NULL
    Integer roomNo = null;
    Integer bedNo = null;
    Integer doctorId = null;

    // Current date for DATE_AD
    java.util.Date currentDate = new java.util.Date();
    java.sql.Date sqlDate = new java.sql.Date(currentDate.getTime());

    Connection con = null;
    PreparedStatement ps = null;
    PreparedStatement deptStmt = null;
    PreparedStatement doctorStmt = null;
    ResultSet deptRs = null;
    ResultSet doctorRs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hms", "root", "Naman@123");

        // Step 1: Get department ID from reasonOfVisit
        String getDeptIdQuery = "SELECT DEPT_ID FROM REASON_DEPARTMENT_MAPPING WHERE LOWER(REASON) = ?";
        deptStmt = con.prepareStatement(getDeptIdQuery);
        deptStmt.setString(1, rov.toLowerCase());
        deptRs = deptStmt.executeQuery();

        int deptId = -1;
        if (deptRs.next()) {
            deptId = deptRs.getInt("DEPT_ID");
        } else {
            // Fallback: Assign to General Physician (DEPT_ID = 1)
            deptId = 1;
        }

        // Step 2: Get a random doctor ID from that department
        if (deptId != -1) {
            String doctorQuery = "SELECT ID FROM DOCTOR_INFO WHERE DEPT_ID = ? ORDER BY RAND() LIMIT 1";
            doctorStmt = con.prepareStatement(doctorQuery);
            doctorStmt.setInt(1, deptId);
            doctorRs = doctorStmt.executeQuery();

            if (doctorRs.next()) {
                doctorId = doctorRs.getInt("ID");
            } else {
                // Fallback: Pick any doctor
                doctorStmt = con.prepareStatement("SELECT ID FROM DOCTOR_INFO LIMIT 1");
                doctorRs = doctorStmt.executeQuery();
                if (doctorRs.next()) {
                    doctorId = doctorRs.getInt("ID");
                }
            }
        }

        // Step 3: Insert into PATIENT_INFO
        String sql = "INSERT INTO PATIENT_INFO (PNAME, GENDER, AGE, BGROUP, PHONE, REA_OF_VISIT, ROOM_NO, BED_NO, DOCTOR_ID, DATE_AD, EMAIL, PASSWORD, STREET, AREA, CITY, STATE, COUNTRY, PINCODE) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        ps = con.prepareStatement(sql);

        ps.setString(1, pname);
        ps.setString(2, gender);
        ps.setInt(3, Integer.parseInt(age));
        ps.setString(4, bgroup);
        ps.setString(5, phone);
        ps.setString(6, rov);
        ps.setNull(7, java.sql.Types.INTEGER); // ROOM_NO
        ps.setNull(8, java.sql.Types.INTEGER); // BED_NO
        if (doctorId != null) {
            ps.setInt(9, doctorId); // DOCTOR_ID
        } else {
            ps.setNull(9, java.sql.Types.INTEGER);
        }
        ps.setDate(10, sqlDate);
        ps.setString(11, email);
        ps.setString(12, pwd);
        ps.setString(13, street);
        ps.setString(14, area);
        ps.setString(15, city);
        ps.setString(16, state);
        ps.setString(17, country);
        ps.setString(18, pincode);

        int i = ps.executeUpdate();

        if (i > 0) {
%>
            <script>
                alert("Patient Registered Successfully! Admin will assign room and bed details.");
                window.location.href = "index.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("Registration Failed!");
                window.history.back();
            </script>
<%
        }
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (doctorRs != null) try { doctorRs.close(); } catch(Exception e) {}
        if (deptRs != null) try { deptRs.close(); } catch(Exception e) {}
        if (doctorStmt != null) try { doctorStmt.close(); } catch(Exception e) {}
        if (deptStmt != null) try { deptStmt.close(); } catch(Exception e) {}
        if (ps != null) try { ps.close(); } catch(Exception e) {}
        if (con != null) try { con.close(); } catch(Exception e) {}
    }
%>