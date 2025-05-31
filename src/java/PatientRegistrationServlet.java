import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/registerPatient")
public class PatientRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String gender = request.getParameter("gender");
        int age = Integer.parseInt(request.getParameter("age"));
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String date = request.getParameter("date");
        String bloodgroup = request.getParameter("bloodgroup");
        String address = request.getParameter("address");
        String city = request.getParameter("city");
        String state = request.getParameter("state");
        String country = request.getParameter("country");
        String pincode = request.getParameter("pincode");
        String roomNo = request.getParameter("roomNo");
        String bedNo = request.getParameter("bedNo");
        String reasonOfVisit = request.getParameter("rov");
        String problemDescription = request.getParameter("problemDescription");

        int referredTo = 0;

        Connection conn = null;
        PreparedStatement deptStmt = null;
        PreparedStatement doctorStmt = null;
        PreparedStatement pstmt = null;
        ResultSet deptRs = null;
        ResultSet doctorRs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hms", "root", "Naman@123");

            // Step 1: Get department ID from reasonOfVisit
            System.out.println("Reason of Visit: " + reasonOfVisit);
            String getDeptIdQuery = "SELECT DEPT_ID FROM REASON_DEPARTMENT_MAPPING WHERE LOWER(REASON) = ?";
            deptStmt = conn.prepareStatement(getDeptIdQuery);
            deptStmt.setString(1, reasonOfVisit.toLowerCase());
            deptRs = deptStmt.executeQuery();

            int deptId = -1;
            if (deptRs.next()) {
                deptId = deptRs.getInt("DEPT_ID");
                System.out.println("Department ID for reason '" + reasonOfVisit + "': " + deptId);
            } else {
                System.out.println("No department found for reason: " + reasonOfVisit);
                response.getWriter().println("Error: No department found for reason: " + reasonOfVisit);
                return;
            }

            // Step 2: Get a random doctor ID from that department
            if (deptId != -1) {
                String doctorQuery = "SELECT ID FROM DOCTOR_INFO WHERE DEPT_ID = ? ORDER BY RAND() LIMIT 1";
                doctorStmt = conn.prepareStatement(doctorQuery);
                doctorStmt.setInt(1, deptId);
                doctorRs = doctorStmt.executeQuery();

                if (doctorRs.next()) {
                    referredTo = doctorRs.getInt("ID");
                    System.out.println("Assigned Doctor ID: " + referredTo + " for DEPT_ID: " + deptId);
                } else {
                    System.out.println("No doctor found for DEPT_ID: " + deptId);
                    response.getWriter().println("Error: No doctor available for department ID " + deptId);
                    return;
                }
            }

            // Step 3: Insert into PATIENT_INFO
            String insertQuery = "INSERT INTO PATIENT_INFO (PNAME, GENDER, AGE, PHONE, EMAIL, DATE_AD, BGROUP, STREET, CITY, STATE, COUNTRY, PINCODE, ROOM_NO, BED_NO, REA_OF_VISIT, PROBLEMDESCRIPTION, DOCTOR_ID) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertQuery);
            pstmt.setString(1, name);
            pstmt.setString(2, gender);
            pstmt.setInt(3, age);
            pstmt.setString(4, phone);
            pstmt.setString(5, email);
            pstmt.setString(6, date);
            pstmt.setString(7, bloodgroup);
            pstmt.setString(8, address);
            pstmt.setString(9, city);
            pstmt.setString(10, state);
            pstmt.setString(11, country);
            pstmt.setString(12, pincode);
            pstmt.setString(13, roomNo);
            pstmt.setString(14, bedNo);
            pstmt.setString(15, reasonOfVisit);
            pstmt.setString(16, problemDescription);
            pstmt.setInt(17, referredTo);

            pstmt.executeUpdate();

            response.sendRedirect("patients.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Database error: " + e.getMessage());
        } finally {
            try {
                if (doctorRs != null) doctorRs.close();
                if (deptRs != null) deptRs.close();
                if (doctorStmt != null) doctorStmt.close();
                if (deptStmt != null) deptStmt.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}